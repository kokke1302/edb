import 'package:edb/db/app_database.dart';
import 'package:edb/share/data/vocab_entry.dart';

class TokenData {
  final int id; // 固有ID
  final bool isWord; // 単語であるかどうか (true: 単語, false: 句読点など)
  final String showWord;
  // 英語が持つ基本情報(id, word, translation, isShow, nowShow, memo, based)
  final VocabEntry vocab;

  TokenData({
    required this.id,
    required this.isWord,
    required this.showWord,
    required this.vocab,
  });

  // 訳語を変更
  TokenData copyWith({bool? isWord, String? showWord, VocabEntry? vocab}) {
    return TokenData(
      id: id, // トークンIDの変更は許可されない
      isWord: isWord ?? this.isWord,
      showWord: showWord ?? this.showWord,
      vocab: vocab ?? this.vocab,
    );
  }

  factory TokenData.fromString({required int id, required String text}) {
    return TokenData(
      id: id,
      isWord: RegExp(r'\w').hasMatch(text),
      showWord: text,
      vocab: VocabEntry.fromInit(text: text),
    );
  }

  factory TokenData.fromVocabularies({required Vocabulary vocabulary}) {
    return TokenData(
      id: vocabulary.id,
      isWord: true,
      showWord: vocabulary.englishWord,
      vocab: VocabEntry.fromVocabularies(vocabulary: vocabulary),
    );
  }

  // JSON形式からTokenオブジェクトへ
  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      id: json['id'] as int,
      isWord: json['isWord'] as bool,
      showWord: json['showWord'] as String,
      vocab: VocabEntry.fromJson(json['card'] as Map<String, dynamic>),
    );
  }

  // TokenオブジェクトからJSON形式へ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isWord': isWord,
      'showWord': showWord,
      'card': vocab.toJson(),
    };
  }
}
