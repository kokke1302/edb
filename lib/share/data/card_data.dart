import 'package:edb/db/app_database.dart';
import 'package:edb/share/data/vocab_entry.dart';

class CardData {
  final int id; // 固有ID
  final String showWord;
  final DateTime createdAt;
  final DateTime updatedAt;
  // 英語が持つ基本情報(id, word, translation, isShow, nowShow, memo, based)
  final VocabEntry vocab;

  CardData({
    required this.id,
    required this.showWord,
    required this.createdAt,
    required this.updatedAt,
    required this.vocab,
  });

  // 訳語を変更
  CardData copyWith({
    bool? isWord,
    String? showWord,
    DateTime? createdAt,
    DateTime? updatedAt,
    VocabEntry? vocab,
  }) {
    return CardData(
      id: id, // トークンIDの変更は許可されない
      showWord: showWord ?? this.showWord,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vocab: vocab ?? this.vocab,
    );
  }

  factory CardData.fromVocabularies({required Vocabulary vocabulary}) {
    return CardData(
      id: vocabulary.id,
      showWord: vocabulary.englishWord,
      createdAt: vocabulary.createdAt,
      updatedAt: vocabulary.updatedAt,
      vocab: VocabEntry.fromVocabularies(vocabulary: vocabulary),
    );
  }

  factory CardData.fromDctionaries({required VocabEntry ve}) {
    return CardData(
      id: -1,
      showWord: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      vocab: ve,
    );
  }

  factory CardData.fromIntt({String word = ''}) {
    return CardData(
      id: -1,
      showWord: word,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      vocab: VocabEntry.fromInit(text: word),
    );
  }
}
