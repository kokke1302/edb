class TokenEntry {
  final int vocabId;
  final String showWord;
  final bool isShow;
  final String translation;

  TokenEntry({
    required this.vocabId,
    required this.showWord,
    required this.translation,
    required this.isShow,
  });

  TokenEntry copyWith({
    int? vocabId,
    String? showWord,
    String? translation,
    bool? isShow,
  }) {
    return TokenEntry(
      vocabId: vocabId ?? this.vocabId,
      showWord: showWord ?? this.showWord,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
    );
  }
}
