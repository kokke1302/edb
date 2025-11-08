import 'package:edb/translation/data/base_style.dart';

class Token {
  // wordブロック
  final String word; // 元の単語または句読点
  final String resolvedTranslation; // 最終的に表示される訳語
  final bool isWord; // 単語であるかどうか (true: 単語, false: 句読点など)
  // DB検索
  final int id; // 固有ID
  final String lookupKey; // 辞書検索用の小文字の単語 (句読点の場合は空文字)
  // cardリスト
  final bool isShow;
  final bool nowShow;
  final Based based;

  Token({
    required this.id,
    required this.word,
    this.lookupKey = '',
    this.resolvedTranslation = '',
    this.isShow = false,
    this.nowShow = false,
    required this.isWord,
    required this.based,
  });

  // JSON形式からTokenオブジェクトへ
  // factory Token.fromJson(Map<String, dynamic> json) {
  //   return Token(
  //     word: json['word'] as String,
  //     lookupKey: json['lookup_key'] as String?,
  //     resolvedTranslation: json['resolved_translation'] as String?,
  //     isWord: json['is_word'] as bool,
  //   );
  // }

  // 訳語を変更
  Token copyWith({
    int? id,
    String? word,
    String? lookupKey,
    String? resolvedTranslation,
    bool? isShow,
    bool? nowShow,
    bool? isWord,
    Based? based,
  }) {
    return Token(
      id: id ?? this.id,
      word: word ?? this.word,
      lookupKey: lookupKey ?? this.lookupKey,
      resolvedTranslation: resolvedTranslation ?? this.resolvedTranslation,
      isShow: isShow ?? this.isShow,
      nowShow: nowShow ?? this.nowShow,
      isWord: isWord ?? this.isWord,
      based: based ?? this.based,
    );
  }
}
