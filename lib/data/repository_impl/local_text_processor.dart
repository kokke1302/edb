import 'package:diffutil_dart/diffutil.dart';

import 'package:edb/domain/entity/token_data.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';
import 'package:edb/domain/repository_abstract/transelation_repository.dart';

/// 英文の解析、トークン化、辞書検索、訳語割り当てのロジックを実装するクラス
class LocalTextProcessor implements TextProcessor {
  final TranslationRepository db;
  LocalTextProcessor(this.db);

  // テキストをトークン化し、検索キーを生成する共通ロジック
  List<TokenData> _tokenizeText({required String text}) {
    final List<TokenData> initialTokens = [];

    // (ハイフン単語 | アポストロフィ単語 | シンプル単語 | 句読点 | 空白)のまとまりに分ける
    final matches = RegExp(
      r"(\w+-\w+|\w+'\w+|\w+|[^\w\s]+|\s+)",
    ).allMatches(text);

    // 1. テキストのトークン化と検索キーの生成
    for (final match in matches) {
      final String cutText = match.group(0)!;

      // 空白のみのトークンは無視
      if (cutText.trim().isEmpty) continue;

      final TokenData token = TokenData.fromInit(showWord: cutText);

      // Token.fromText ファクトリで初期Tokenを生成
      initialTokens.add(token);
    }
    return initialTokens;
  }

  @override
  Future<List<TokenData>> partTranslation({
    required List<TokenData> nowTokens,
    required String newText,
  }) async {
    // 1. テキストのトークン化
    final List<TokenData> newTokensInitial = _tokenizeText(text: newText);

    // 2. 差分計算 (比較用のキーを厳密に揃える)
    final List<String> oldKeys = nowTokens.map((t) => t.showWord).toList();
    final List<String> newKeys = newTokensInitial
        .map((t) => t.showWord)
        .toList();
    final diffResult = calculateListDiff<String>(oldKeys, newKeys);

    // 差分適用後のリスト
    List<TokenData> finalTokens = List.from(nowTokens);
    // 更新・追加が発生した「インデックス」を保持する
    Set<int> affectedIndices = {};

    // 3. 差分操作を逆順に適用
    for (final update in diffResult.getUpdates().toList()) {
      update.when(
        insert: (pos, count) {
          final inserted = newTokensInitial.sublist(pos, pos + count);
          finalTokens.insertAll(pos, inserted);
          // 挿入された範囲
          for (int i = 0; i < count; i++) {
            affectedIndices.add(pos + i);
          }
        },
        remove: (pos, count) {
          finalTokens.removeRange(pos, pos + count);
          // 後続の挿入/変更がposを上書きするため、affectedIndicesの更新は不要
        },
        change: (pos, payload) {
          finalTokens[pos] = newTokensInitial[pos];
          affectedIndices.add(pos);
        },
        move: (from, to) {
          final moved = finalTokens.removeAt(from);
          finalTokens.insert(to, moved);
          affectedIndices.add(to);
        },
      );
    }

    // 4. 辞書検索が必要な単語を収集
    final Set<String> lookupKeys = affectedIndices
        .map((i) => finalTokens[i])
        .where((t) => t.isWord && t.showWord.isNotEmpty)
        .map((t) => t.word)
        .toSet();

    final slimEntrys = await db.fetchTranslationsBatch(lookupKeys);

    // 5. DB検索（必要な分だけ）
    final Map<String, ({int id, String word, bool isShow})> translationMap = {};

    for (final entry in slimEntrys) {
      final key = entry.word.toLowerCase();

      // すでに登録済みかつ「表示設定(isShow)」がtrueのものを優先するロジック
      final bool alreadyHasShowEntry = translationMap[key]?.isShow ?? false;
      if (!alreadyHasShowEntry) translationMap[key] = entry;
    }

    // 6. トークンに訳語を割り当てる
    final List<TokenData> resultTokens = [];

    // 変更があった最初の位置
    final int firstEffect = affectedIndices.isEmpty
        ? finalTokens.length
        : affectedIndices.reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < finalTokens.length; i++) {
      final token = finalTokens[i];

      // 変更があったインデックス、または位置がズレたインデックスをすべて更新
      if (i >= firstEffect || token.id != i) {
        final entry = translationMap[token.word];

        resultTokens.add(
          token.copyWith(
            id: i,
            vocabId: entry?.id ?? -1,
            nowShow: entry?.isShow ?? false,
          ),
        );
      } else {
        // 変更がなく、IDも一致しているならそのまま
        resultTokens.add(token);
      }
    }
    return resultTokens;
  }

  @override
  Future<List<TokenData>> fullTranslation({required String text}) async {
    // 1. テキストのトークン化
    final List<TokenData> initialTokens = _tokenizeText(text: text);

    // 2. 一括検索のためのユニークキー収集
    final Set<String> lookupKeys = initialTokens
        .where((t) => t.isWord && t.showWord.isNotEmpty)
        .map((t) => t.showWord.toLowerCase())
        .toSet();

    // 3. DictionaryServiceによる訳語の一括検索
    final List<({int id, String word, bool isShow})> slimEntrys;
    try {
      slimEntrys = await db.fetchTranslationsBatch(lookupKeys);
    } catch (e) {
      rethrow;
    }

    // 4. <検索キー: 単語帳DBエントリー>のMapを作成
    final Map<String, ({int id, String word, bool isShow})> translationMap = {};
    for (final entry in slimEntrys) {
      final key = entry.word.toLowerCase();

      // isShow が true のエントリーを優先して保持するロジック
      final bool alreadyHasShowEntry = translationMap[key]?.isShow ?? false;
      if (!alreadyHasShowEntry) translationMap[key] = entry;
    }

    // 5. トークンに訳語を割り当てる
    List<TokenData> translatedTokens = [];
    for (int i = 0; i < initialTokens.length; i++) {
      final initialToken = initialTokens[i];

      // 単語でない、または辞書に存在しない場合は ID のみ更新して追加
      final entry = translationMap[initialToken.word];

      if (!initialToken.isWord || entry == null) {
        translatedTokens.add(initialToken.copyWith(id: i));
        continue;
      }

      // Record から ID と表示フラグを適用
      translatedTokens.add(
        initialToken.copyWith(id: i, vocabId: entry.id, nowShow: entry.isShow),
      );
    }

    return translatedTokens;
  }
}
