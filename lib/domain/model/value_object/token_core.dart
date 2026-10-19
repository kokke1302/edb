class TokenCore {
  final int vocabId;
  final String showWord;
  final bool isShow;
  final String translation;

  TokenCore({
    required this.vocabId,
    required this.showWord,
    required this.translation,
    required this.isShow,
  });

  TokenCore copyWith({
    int? vocabId,
    String? showWord,
    String? translation,
    bool? isShow,
  }) {
    return TokenCore(
      vocabId: vocabId ?? this.vocabId,
      showWord: showWord ?? this.showWord,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
    );
  }
}
