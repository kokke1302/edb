import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/model/value_object/token_core.dart';
import 'package:edb/domain/model/value_object/token_data.dart';

class TokenMapper {
  // JSON形式からTokenオブジェクトへ
  static TokenData fromJson({required Map<String, dynamic> json}) {
    return TokenData(
      id: json['id'] as int,
      vocabId: json['vocabId'] as int,
      showWord: json['showWord'] as String,
      nowShow: json['nowShow'] as bool,
      translation: json['translation'] as String,
    );
  }

  static TokenCore fromVocabularies({required Vocabulary voc}) {
    return TokenCore(
      vocabId: voc.id,
      showWord: voc.englishWord,
      translation: voc.japaneseTranslation,
      isShow: !voc.isHidden,
    );
  }
}
