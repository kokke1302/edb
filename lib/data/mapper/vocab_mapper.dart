import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';

class VocabMapper {
  static VocabEntry fromVocabularies({required Vocabulary vocabulary}) {
    return VocabEntry(
      id: vocabulary.id,
      word: vocabulary.englishWord,
      translation: vocabulary.japaneseTranslation,
      isShow: !vocabulary.isHidden,
      memo: vocabulary.memo,
      createdAt: vocabulary.createdAt,
      updatedAt: vocabulary.updatedAt,
      based: Based.vocabularies,
    );
  }

  static VocabEntry fromDictionary({required InternalDictionary dictionary}) {
    return VocabEntry(
      id: -1,
      word: dictionary.word.toLowerCase(),
      translation: dictionary.mean,
      isShow: true,
      memo: dictionary.memo ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      based: Based.dictionary,
    );
  }
}
