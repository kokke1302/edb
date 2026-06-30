class TokenData {
  final int id; // 固有ID
  final int vocabId;
  final String showWord;
  final bool nowShow;
  final String translation;

  TokenData({
    required this.id,
    required this.vocabId,
    required this.showWord,
    required this.nowShow,
    required this.translation,
  });

  // 単語であるかどうか (true: 単語, false: 句読点など)
  bool get isWord => RegExp(r'\w').hasMatch(showWord);
  String get word => showWord.toLowerCase();

  // 訳語を変更
  TokenData copyWith({
    int? id,
    int? vocabId,
    String? showWord,
    bool? nowShow,
    String? translation,
  }) {
    return TokenData(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      showWord: showWord ?? this.showWord,
      nowShow: nowShow ?? this.nowShow,
      translation: translation ?? this.translation,
    );
  }

  // TokenオブジェクトからJSON形式へ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vocabId': vocabId,
      'showWord': showWord,
      'nowShow': nowShow,
      'translation': translation,
    };
  }

  factory TokenData.fromInit({String showWord = ''}) {
    return TokenData(
      id: -1,
      vocabId: -1,
      showWord: showWord,
      nowShow: false,
      translation: '',
    );
  }
}
