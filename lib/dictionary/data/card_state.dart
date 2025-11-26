enum Based { vocabularies, dictionary, init }

class CardEntry {
  final int id;
  final String translation;
  final bool isShow; // default
  final bool nowShow;
  final String memo;
  final Based based;

  CardEntry({
    required this.id,
    required this.translation,
    required this.isShow,
    required this.nowShow,
    required this.memo,
    required this.based,
  });

  CardEntry copyWith({
    int? id,
    String? translation,
    bool? isShow,
    bool? nowShow,
    String? memo,
    Based? based,
  }) {
    return CardEntry(
      id: id ?? this.id,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      nowShow: nowShow ?? this.nowShow,
      memo: memo ?? this.memo,
      based: based ?? this.based,
    );
  }
}
