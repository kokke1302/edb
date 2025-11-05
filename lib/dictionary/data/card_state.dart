class CardEntry {
  final String translation;
  final bool isShow;
  final String memo;
  final bool isRegistered;

  CardEntry({
    required this.translation,
    required this.isShow,
    this.memo = '',
    required this.isRegistered,
  });

  CardEntry copyWith({
    String? translation,
    bool? isShow,
    String? memo,
    bool? isRegistered,
  }) {
    return CardEntry(
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      memo: memo ?? this.memo,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
