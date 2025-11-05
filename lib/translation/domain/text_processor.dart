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
    // 1. テキストのトークン化と検索キーの生成
    List<Token> tokens = _tokenizeAndGenerateKeys(text);

    // 2. 一括検索のためのユニークキー収集
    final Set<String> lookupKeys = tokens
        .where((t) => t.isWord && t.lookupKey.isNotEmpty)
        .map((t) => t.lookupKey)
        .toSet();

    // 3. DictionaryServiceによる訳語の一括検索
    final List<Vocabulary> vocabularyEntries = await ref
        .read(batchRepositoryProvider)
        .fetchTranslationsBatch(lookupKeys);

    // 4. <検索キー: 訳語>のMapを作成
    final Map<String, String?> translationMap = {
      for (var entry in vocabularyEntries)
        // 非表示指示の場合、訳語を代入しない
        if (entry.isHidden == false)
          entry.englishWord: entry.japaneseTranslation,
    };

    // 5. トークンに訳語を割り当てる (メモリ内処理)
    List<Token> translatedTokens = tokens.map((token) {
      // 句読点や訳語検索不要なものはそのまま
      if (!token.isWord || token.lookupKey.isEmpty) return token;

      // Mapから訳語を取得。非表示単語は空文字を投入。
      final String assignedTranslation = translationMap[token.lookupKey] ?? '';

      // 訳語がMap内に存在すれば割り当てる
      return token.changeTranslation(newTranslation: assignedTranslation);
    }).toList();

    return translatedTokens;
  }

  /// 英文を単語と句読点に分割し、検索キー（小文字）を生成する。
  List<Token> _tokenizeAndGenerateKeys(String text) {
    // (ハイフン単語 | アポストロフィ単語 | シンプル単語 | 句読点 | 空白)のまとまりに分ける
    final RegExp regex = RegExp(r"(\w+-\w+|\w+'\w+|\w+|[^\w\s]+|\s+)");
    final matches = regex.allMatches(text);

    final List<Token> tokens = [];
    int id = 1;
    for (final match in matches) {
      final String tokenText = match.group(0)!;

      // トークンが空白文字のみの場合はスキップ
      if (tokenText.trim().isEmpty) continue;

      // 単語であることの判定（トークンに\w(単語文字)が含まれているか）
      final bool isWord = RegExp(r'\w').hasMatch(tokenText);

      // 検索キーとして小文字化
      final String lookupKey = isWord ? tokenText.toLowerCase() : '';

      tokens.add(
        Token(id: id, word: tokenText, lookupKey: lookupKey, isWord: isWord),
      );

      id++;
    }

    return tokens;
  }
}
