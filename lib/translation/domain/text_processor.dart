import 'package:diffutil_dart/diffutil.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/translation/data/token_data.dart';
import 'package:edb/translation/data/dbsourse_switch.dart';

/// 英文の解析、トークン化、辞書検索、訳語割り当てのロジックを実装するクラス
class TextProcessor {
  final TranslationDBSource ds;
  TextProcessor(this.ds);

  // テキストをトークン化し、検索キーを生成する共通ロジック
  List<TokenData> _tokenizeText({required String text}) {
    final List<TokenData> initialTokens = [];

    // (ハイフン単語 | アポストロフィ単語 | シンプル単語 | 句読点 | 空白)のまとまりに分ける
    final matches = RegExp(
      r"(\w+-\w+|\w+'\w+|\w+|[^\w\s]+|\s+)",
    ).allMatches(text);

    // 1. テキストのトークン化と検索キーの生成
    int currentId = 1;
    for (final match in matches) {
      final String tokenText = match.group(0)!;

      // 空白のみのトークンは無視
      if (tokenText.trim().isEmpty) continue;

      final TokenData token = TokenData.fromString(
        id: currentId,
        text: tokenText,
      );

      // Token.fromText ファクトリで初期Tokenを生成
      initialTokens.add(token);
      currentId++;
    }
    return initialTokens;
  }

  Future<List<TokenData>> incrementalTranslation({
    required List<TokenData> nowTokens,
    required String newText,
  }) async {
    // 1. テキストのトークン化
    final List<TokenData> newTokensInitial = _tokenizeText(text: newText);

    // 2. 差分計算のためのリストを準備 (Tokenの word 文字列のリスト)
    final List<String> oldWords = nowTokens.map((t) => t.vocab.word).toList();
    final List<String> newWords = newTokensInitial
        .map((t) => t.vocab.word)
        .toList();

    // 3. 文字列リストで差分を計算
    final diffResult = calculateListDiff<String>(oldWords, newWords);

    // このリストに差分操作を適用し、構造を変更していく
    List<TokenData> finalTranslatedTokens = List.from(nowTokens);
    // 新しく翻訳が必要なトークンのリスト
    Map<int, TokenData> tokensToTranslate = {};

    // 4. 差分操作を逆順に適用
    for (final update in diffResult.getUpdates().toList().reversed) {
      update.when(
        // [挿入] 新しいトークンを指定位置に追加
        insert: (pos, count) {
          final List<TokenData> insertedTokens = newTokensInitial.sublist(
            pos,
            pos + count,
          );

          // 最終Token配列に追加
          finalTranslatedTokens.insertAll(pos, insertedTokens);
          // 翻訳タスクを追加
          for (int i = 0; i < insertedTokens.length; i++) {
            tokensToTranslate[pos + i] = insertedTokens[i];
          }
        },

        // [削除] 指定位置の古いトークンを削除
        remove: (pos, count) =>
            finalTranslatedTokens.removeRange(pos, pos + count),

        // [変更] 指定位置のトークンを、新しいトークンで置き換える。
        change: (pos, payload) {
          // insert/remove になるため、changeは発生しないか、無視できるはず
          // もし発生しても、そのトークンは新しく翻訳が必要なトークンとして扱う
          final TokenData newToken = newTokensInitial[pos];
          finalTranslatedTokens[pos] = newToken;
          tokensToTranslate[pos] = newToken;
        },

        // [移動] トークンの移動insert(to) で挿入する。
        move: (from, to) {
          // removeAt(from): 削除, 対象をreturn
          final TokenData movedToken = finalTranslatedTokens.removeAt(from);
          // insert(to): 挿入
          finalTranslatedTokens.insert(to, movedToken);
        },
      );
    }

    // 5. 辞書検索が必要なTokenのユニークキーを収集
    final Set<String> lookupKeys = tokensToTranslate.values
        .where((t) => t.isWord && t.vocab.word.isNotEmpty)
        .map((t) => t.vocab.word.toLowerCase())
        .toSet();

    // 6. DictionaryServiceによる訳語の一括検索
    final List<Vocabulary> vocabularyEntries;
    try {
      vocabularyEntries = await ds.fetchTranslationsBatch(lookupKeys);
    } catch (e) {
      rethrow;
    }

    // 7. <検索キー: 単語帳DBエントリー>のMapを作成
    final Map<String, Vocabulary> translationMap = {};
    for (final entry in vocabularyEntries) {
      final key = entry.englishWord.toLowerCase();

      final bool shouldReplace =
          translationMap[key] == null ||
          (translationMap[key]!.isHidden && !entry.isHidden);
      if (shouldReplace) translationMap[key] = entry;
    }

    // トークンに訳語を割り当てる
    for (final entry in tokensToTranslate.entries) {
      final int pos = entry.key;
      final TokenData tokenToUpdate = entry.value;

      // MapからVocabularyエントリを取得。
      final Vocabulary? vocabularyEntry =
          translationMap[tokenToUpdate.vocab.word.toLowerCase()];

      // 辞書検索が不要した場合は、更新せずにスキップ
      if (!tokenToUpdate.isWord) continue;

      // 最終リスト内のトークンを、訳語情報を割り当てた新しいインスタンスで置き換える
      if (vocabularyEntry == null) {
        // 辞書検索が失敗した場合
        final newCard = tokenToUpdate.vocab.copyWith(
          translation: '',
          isShow: false,
          nowShow: false,
          memo: '',
          based: Based.init,
        );

        finalTranslatedTokens[pos] = tokenToUpdate.copyWith(vocab: newCard);
      } else {
        // 辞書検索が成功した場合
        final newCard = tokenToUpdate.vocab.copyWith(
          translation: vocabularyEntry.japaneseTranslation,
          isShow: !vocabularyEntry.isHidden,
          nowShow: !vocabularyEntry.isHidden,
          memo: vocabularyEntry.memo,
          based: Based.vocabularies,
        );
        finalTranslatedTokens[pos] = tokenToUpdate.copyWith(vocab: newCard);
      }
    }

    return finalTranslatedTokens;
  }

  Future<List<TokenData>> fullTranslation({required String text}) async {
    // 1. テキストのトークン化
    final List<TokenData> initialTokens = _tokenizeText(text: text);

    // 2. 一括検索のためのユニークキー収集
    final Set<String> lookupKeys = initialTokens
        .where((t) => t.isWord && t.vocab.word.isNotEmpty)
        .map((t) => t.vocab.word.toLowerCase())
        .toSet();

    // 3. DictionaryServiceによる訳語の一括検索
    final List<Vocabulary> vocabularyEntries;
    try {
      vocabularyEntries = await ds.fetchTranslationsBatch(lookupKeys);
    } catch (e) {
      // print('DB Fetch Error in TextProcessor: $e');
      rethrow;
    }

    // 4. <検索キー: 単語帳DBエントリー>のMapを作成
    final Map<String, Vocabulary> translationMap = {};
    for (final entry in vocabularyEntries) {
      final key = entry.englishWord.toLowerCase();

      // isHiddenでないentryを優先表示する
      final bool shouldReplace =
          translationMap[key] == null ||
          (translationMap[key]!.isHidden && !entry.isHidden);
      if (shouldReplace) translationMap[key] = entry;
    }

    // 5. トークンに訳語を割り当てる
    List<TokenData> translatedTokens = initialTokens.map((initialToken) {
      // MapからVocabularyエントリを取得。
      final Vocabulary? vocabularyEntry =
          translationMap[initialToken.vocab.word.toLowerCase()];

      // 辞書検索が不要/失敗した場合は、初期Tokenをそのまま返す
      if (!initialToken.isWord || vocabularyEntry == null) return initialToken;

      final newCard = initialToken.vocab.copyWith(
        translation: vocabularyEntry.japaneseTranslation,
        isShow: !vocabularyEntry.isHidden,
        nowShow: !vocabularyEntry.isHidden,
        memo: vocabularyEntry.memo,
        based: Based.vocabularies,
      );

      return initialToken.copyWith(vocab: newCard);
    }).toList();

    return translatedTokens;
  }
}
