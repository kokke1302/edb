class Token {
  final int id; // 固有ID
  final String word; // 元の単語または句読点
  final String lookupKey; // 辞書検索用の小文字の単語 (句読点の場合は空文字)
  final String resolvedTranslation; // 最終的に表示される訳語
  final bool isWord; // 単語であるかどうか (true: 単語, false: 句読点など)

  Token({
    required this.id,
    required this.word,
    this.lookupKey = '',
    this.resolvedTranslation = '',
    required this.isWord,
  });

  // JSON形式からTokenオブジェクトへ
  // factory Token.fromJson(Map<String, dynamic> json) {
  //   return Token(
  //     word: json['word'] as String,
  //     lookupKey: json['lookup_key'] as String?,
  //     resolvedTranslation: json['resolved_translation'] as String?,
  //     isWord: json['is_word'] as bool,
  //   );
  // }

  // 訳語を変更
  Token changeTranslation({required String newTranslation}) {
    return Token(
      id: id,
      word: word,
      lookupKey: lookupKey,
      resolvedTranslation: newTranslation,
      isWord: isWord,
    );
  }
}
