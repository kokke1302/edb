enum Based { vocabularies, dictionary }

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

  CardEntry nowShowChange({bool? nowShow}) {
    return CardEntry(
      id: id,
      translation: translation,
      isShow: isShow,
      nowShow: nowShow ?? this.nowShow,
      memo: memo,
      based: based,
    );
  }
}
