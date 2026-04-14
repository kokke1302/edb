import 'package:edb/domain/entity/token_data.dart';

class TranslationData {
  final String originalText;
  final List<TokenData> tokens;

  TranslationData({this.originalText = '', this.tokens = const []});

  TranslationData copyWith({String? originalText, List<TokenData>? tokens}) {
    return TranslationData(
      originalText: originalText ?? this.originalText,
      tokens: tokens ?? this.tokens,
    );
  }
}
