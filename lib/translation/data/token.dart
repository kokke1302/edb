class Token {
  // 固有ID
  final int id;
  // wordブロック
  final String word; // 表示する単語（大文字OK）
  final bool isWord; // 単語であるかどうか (true: 単語, false: 句読点など)
  final String resolvedTranslation; // 最終的に表示される訳語
  // cardリスト
  final bool nowShow;
  final int vocId;

  Token({
    required this.id,
    required this.word,
    required this.resolvedTranslation,
    required this.isWord,
    required this.nowShow,
    required this.vocId,
  });

  // 訳語を変更
  Token copyWith({String? resolvedTranslation, bool? nowShow, int? vocId}) {
    return Token(
      id: id,
      word: word,
      isWord: isWord,
      resolvedTranslation: resolvedTranslation ?? this.resolvedTranslation,
      nowShow: nowShow ?? this.nowShow,
      vocId: vocId ?? this.vocId,
    );
  }

  // JSON形式からTokenオブジェクトへ
  // factory Token.fromJson(Map<String, dynamic> json) {
  //   return Token(
  //     word: json['word'] as String,
  //     lookupKey: json['lookup_key'] as String?,
  //     resolvedTranslation: json['resolved_translation'] as String?,
  //     isWord: json['is_word'] as bool,
  //   );
  // }
}
