import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/model/value_object/token_core.dart';
import 'package:edb/domain/model/value_object/token_data.dart';

class TokenMapper {
  // JSON形式からTokenオブジェクトへ（履歴の復元用）
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

  // 外部APIのレスポンスの1要素（{"showWord": ..., "translation": ...}）からTokenオブジェクトへ
  static TokenData fromRemoteJson({required Map<String, dynamic> json}) {
    final showWord = json['showWord'] as String;
    final translation = (json['translation'] as String?) ?? '';
    final token = TokenData.init(showWord: showWord);

    // 単語でない（句読点など）、または訳語がない場合は未登録トークンのまま
    if (!token.isWord || translation.trim().isEmpty) return token;

    return token.copyWith(
      vocabId: TokenData.remoteVocabId,
      nowShow: true,
      translation: translation,
    );
  }
}
