import 'package:edb/domain/entity/model/token_data.dart';

class TokenMapper {
  // // JSON形式からTokenオブジェクトへ
  static TokenData fromJson(Map<String, dynamic> json) {
    return TokenData(
      id: json['id'] as int,
      vocabId: json['vocabId'] as int,
      showWord: json['showWord'] as String,
      nowShow: json['nowShow'] as bool,
      translation: json['translation'] as String,
    );
  }
}
