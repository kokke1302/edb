import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/batch_repository.dart';

// 依存関係注入のためのProvider
final textProcessorProvider = Provider<TextProcessor>((ref) {
  return TextProcessor(ref);
});

/// 英文の解析、トークン化、辞書検索、訳語割り当てのロジックを実装するクラス
class TextProcessor {
  final Ref ref;
  TextProcessor(this.ref);

  /// 英文を解析し、訳語が割り当てられたTokenのリストを返す
  Future<List<Token>> tokenizeAndTranslate(String text) async {
    final List<Token> initialTokens = [];

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

      final Token token = Token(
        id: currentId,
        word: tokenText,
        isWord: RegExp(r'\w').hasMatch(tokenText),

        // 辞書検索後のフィールド
        resolvedTranslation: '',
        nowShow: false,
        vocId: -1,
      );

      // Token.fromText ファクトリで初期Tokenを生成
      initialTokens.add(token);
      currentId++;
    }

    // 2. 一括検索のためのユニークキー収集
    final Set<String> lookupKeys = initialTokens
        .where((t) => t.isWord && t.word.isNotEmpty)
        .map((t) => t.word.toLowerCase())
        .toSet();

    // 3. DictionaryServiceによる訳語の一括検索
    final List<Vocabulary> vocabularyEntries = await ref
        .read(batchRepositoryProvider)
        .fetchTranslationsBatch(lookupKeys);

    // 4. <検索キー: 単語帳DBエントリー>のMapを作成
    final Map<String, Vocabulary> translationMap = {
      for (var entry in vocabularyEntries) entry.englishWord: entry,
    };

    // 5. トークンに訳語を割り当てる
    List<Token> translatedTokens = initialTokens.map((initialToken) {
      // MapからVocabularyエントリを取得。
      final Vocabulary? vocabularyEntry =
          translationMap[initialToken.word.toLowerCase()];

      // 辞書検索が不要/失敗した場合は、初期Tokenをそのまま返す
      if (!initialToken.isWord || vocabularyEntry == null) return initialToken;

      return initialToken.copyWith(
        // 辞書検索後のフィールド追加
        resolvedTranslation: vocabularyEntry.japaneseTranslation,
        nowShow: !vocabularyEntry.isHidden,
        vocId: vocabularyEntry.id,
      );
    }).toList();

    return translatedTokens;
  }
}
