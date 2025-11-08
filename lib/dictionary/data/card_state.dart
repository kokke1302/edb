import 'package:edb/translation/data/base_style.dart';

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
    this.memo = '',
    required this.based,
  });

  CardEntry copyWith({
    String? translation,
    bool? nowShow,
    String? memo,
    Based? based,
  }) {
    return CardEntry(
      id: id,
      translation: translation ?? this.translation,
      isShow: isShow,
      nowShow: nowShow ?? this.nowShow,
      memo: memo ?? this.memo,
      based: based ?? this.based,
    );
  }
}
