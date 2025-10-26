import 'package:edb/translation/data/token.dart';

class TranslationState {
  final String originalText;
  final List<Token> tokens;
  final bool isProcessing; // 処理中かどうか

  TranslationState({
    this.originalText = '',
    this.tokens = const [],
    this.isProcessing = false,
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
}
