import 'package:edb/domain/entity/value/base_status.dart';

class VocabEntry {
  final int id;
  final String word;
  final String translation;
  final bool isShow;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Based based;

  VocabEntry({
    required this.id,
    required this.word,
    required this.translation,
    required this.isShow,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
    required this.based,
  });

  VocabEntry copyWith({
    int? id,
    String? word,
    String? translation,
    bool? isShow,
    String? memo,
    DateTime? updatedAt,
    Based? based,
  }) {
    return VocabEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      based: based ?? this.based,
    );
  }

  factory VocabEntry.init({String word = ''}) {
    return VocabEntry(
      id: -1,
      word: word.toLowerCase(),
      translation: '',
      isShow: true,
      memo: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      based: Based.init,
    );
  }
}
