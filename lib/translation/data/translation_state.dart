import 'package:edb/translation/data/token_data.dart';

class TranslationState {
  final String originalText;
  final List<TokenData> tokens;

  TranslationState({required this.originalText, required this.tokens});

  TranslationState copyWith({String? originalText, List<TokenData>? tokens}) {
    return TranslationState(
      originalText: originalText ?? this.originalText,
      tokens: tokens ?? this.tokens,
    );
  }
}
