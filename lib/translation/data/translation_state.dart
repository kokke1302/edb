import 'package:edb/translation/data/token.dart';

class TranslationState {
  final String originalText;
  final List<Token> tokens;
  final bool isProcessing; // 処理中かどうか

  TranslationState({
    required this.originalText,
    required this.tokens,
    required this.isProcessing,
  });

  TranslationState copyWith({
    String? originalText,
    List<Token>? tokens,
    bool? isProcessing,
  }) {
    return TranslationState(
      originalText: originalText ?? this.originalText,
      tokens: tokens ?? this.tokens,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  Token targetToken({required int id}) {
    for (final token in tokens) {
      if (token.id == id) {
        return token;
      }
    }
    throw Exception('Token with id $id not found');
  }
}
