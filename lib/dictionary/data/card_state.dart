enum Based { vocabularies, dictionary, init }

class CardEntry {
  final int id;
  final String word;
  final String translation;
  final bool isShow; // default
  final bool nowShow;
  final String memo;
  final Based based;

  CardEntry({
    required this.id,
    required this.word,
    required this.translation,
    required this.isShow,
    required this.nowShow,
    required this.memo,
    required this.based,
  });

  CardEntry copyWith({
    int? id,
    String? word,
    String? translation,
    bool? isShow,
    bool? nowShow,
    String? memo,
    Based? based,
  }) {
    return CardEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      nowShow: nowShow ?? this.nowShow,
      memo: memo ?? this.memo,
      based: based ?? this.based,
    );
  }

  // CardEntryオブジェクトからJSON形式へ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'isShow': isShow,
      'nowShow': nowShow,
      'memo': memo,
      'based': based.toString().split('.').last, // enumを文字列に変換
    };
  }

  // JSON形式からCardEntryオブジェクトへ
  factory CardEntry.fromJson(Map<String, dynamic> json) {
    Based parseBased(String value) {
      return Based.values.firstWhere(
        (e) => e.toString() == 'Based.$value',
        orElse: () => Based.init,
      );
    }

    return CardEntry(
      id: json['id'] as int,
      word: json['word'] as String,
      translation: json['translation'] as String,
      isShow: json['isShow'] as bool,
      nowShow: json['nowShow'] as bool,
      memo: json['memo'] as String,
      based: parseBased(json['based'] as String),
    );
  }
}
