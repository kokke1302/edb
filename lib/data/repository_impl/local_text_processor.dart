import 'package:diffutil_dart/diffutil.dart';

import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/model/value_object/token_core.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';

// 英文の解析、トークン化、辞書検索、訳語割り当てのロジックを実装するクラス
class LocalTextProcessor implements TextProcessor {
  final TranslationRepository translationRepository;
  LocalTextProcessor(this.translationRepository);

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

      // Token.init で初期Tokenを生成
      final TokenData token = TokenData.init(showWord: cutText);

      initialTokens.add(token);
    }
    return initialTokens;
  }

  // 単語帳を検索し、<検索キー: 単語帳エントリー>のMapを作る
  Future<Map<String, TokenCore>> _fetchTranslationMap(Set<String> keys) async {
    final entries = await translationRepository.fetchTranslationsBatch(
      keys: keys,
    );

    final Map<String, TokenCore> translationMap = {};
    for (final entry in entries) {
      final key = entry.showWord.toLowerCase();

      // 同じキーが複数あれば isShow が true のものを優先して保持する
      final bool alreadyHasShowEntry = translationMap[key]?.isShow ?? false;
      if (!alreadyHasShowEntry) translationMap[key] = entry;
    }

    return translationMap;
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

    // 5. DB検索（必要な分だけ）
    final translationMap = await _fetchTranslationMap(lookupKeys);

    // 6. トークンに訳語を割り当てる
    final List<TokenData> resultTokens = [];
    for (int i = 0; i < finalTokens.length; i++) {
      final token = finalTokens[i];

      if (affectedIndices.contains(i)) {
        // 新規/変更されたトークン → 辞書引き直し
        final entry = translationMap[token.word];

        resultTokens.add(
          token.copyWith(
            id: i,
            vocabId: entry?.vocabId ?? -1,
            nowShow: entry?.isShow ?? false,
            translation: entry?.translation ?? '',
          ),
        );
      } else if (token.id != i) {
        // 中身は同じだが位置だけずれた → idだけ更新、訳語は保持
        resultTokens.add(token.copyWith(id: i));
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
    final tokens = _tokenizeText(text: text);

    // 2. 一括検索のためのユニークキー収集
    final Set<String> lookupKeys = tokens
        .where((t) => t.isWord && t.showWord.isNotEmpty)
        .map((t) => t.word)
        .toSet();

    // 3. 訳語の一括検索
    final translationMap = await _fetchTranslationMap(lookupKeys);

    // 4. トークンに訳語を割り当てる
    final List<TokenData> translatedTokens = [];
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      // 単語でない、または単語帳に存在しない場合は ID のみ更新して追加
      final entry = translationMap[token.word];
      if (!token.isWord || entry == null) {
        translatedTokens.add(token.copyWith(id: i));
        continue;
      }

      // 単語帳の登録内容から ID と表示フラグを適用
      translatedTokens.add(
        token.copyWith(
          id: i,
          vocabId: entry.vocabId,
          nowShow: entry.isShow,
          translation: entry.translation,
        ),
      );
    }

    return translatedTokens;
  }
}
