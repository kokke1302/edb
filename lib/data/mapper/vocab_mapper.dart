import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/enum/base_status.dart';

class VocabMapper {
  static VocabCore fromVocabularies({required Vocabulary vocabulary}) {
    return VocabCore(
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

  static VocabCore fromDictionary({required InternalDictionary dictionary}) {
    return VocabCore(
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
