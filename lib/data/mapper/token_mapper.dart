import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/entity/carry/token_entry.dart';
import 'package:edb/domain/entity/model/token_data.dart';

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

  static TokenEntry fromVocabularies({required Vocabulary voc}) {
    return TokenEntry(
      vocabId: voc.id,
      showWord: voc.englishWord,
      translation: voc.japaneseTranslation,
      isShow: !voc.isHidden,
    );
  }
}
