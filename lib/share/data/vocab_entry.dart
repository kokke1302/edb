import 'package:edb/db/app_database.dart';

enum Based { vocabularies, dictionary, init }

class VocabEntry {
  final String word;
  final String translation;
  final bool isShow; // default
  final bool nowShow;
  final String memo;
  final Based based;

  VocabEntry({
    required this.word,
    required this.translation,
    required this.isShow,
    required this.nowShow,
    required this.memo,
    required this.based,
  });

  VocabEntry copyWith({
    String? word,
    String? translation,
    bool? isShow,
    bool? nowShow,
    String? memo,
    Based? based,
  }) {
    return VocabEntry(
      word: word ?? this.word,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      nowShow: nowShow ?? this.nowShow,
      memo: memo ?? this.memo,
      based: based ?? this.based,
    );
  }

  factory VocabEntry.fromVocabularies({required Vocabulary vocabulary}) {
    return VocabEntry(
      word: vocabulary.englishWord,
      translation: vocabulary.japaneseTranslation,
      isShow: !vocabulary.isHidden,
      nowShow: false,
      memo: vocabulary.memo,
      based: Based.vocabularies,
    );
  }

  factory VocabEntry.fromInit({required String text}) {
    return VocabEntry(
      word: text.toLowerCase(),
      translation: '',
      isShow: false,
      nowShow: false,
      memo: '',
      based: Based.init,
    );
  }

  factory VocabEntry.fromDictionary({required InternalDictionary dictionary}) {
    return VocabEntry(
      word: dictionary.word,
      translation: dictionary.mean,
      isShow: false,
      nowShow: false,
      memo: dictionary.memo ?? '',
      based: Based.dictionary,
    );
  }

  // VocabEntryオブジェクトからJSON形式へ
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'translation': translation,
      'isShow': isShow,
      'nowShow': nowShow,
      'memo': memo,
      'based': based.toString().split('.').last, // enumを文字列に変換
    };
  }

  // // JSON形式からVocabEntryオブジェクトへ
  factory VocabEntry.fromJson(Map<String, dynamic> json) {
    // Enumのパース部分を抽出
    final basedString = json['based'] as String;
    final basedValue = Based.values.firstWhere(
      (e) => e.name == basedString,
      orElse: () => Based.init,
    );

    return VocabEntry(
      word: json['word'] as String,
      translation: json['translation'] as String,
      isShow: json['isShow'] as bool,
      nowShow: json['nowShow'] as bool,
      memo: json['memo'] as String,
      based: basedValue,
    );
  }
}
