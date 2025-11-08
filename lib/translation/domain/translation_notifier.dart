import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/data/translation_state.dart';
import 'package:edb/translation/domain/text_processor.dart';

final translationProvider =
    NotifierProvider<TranslationNotifier, TranslationState>(
      () => TranslationNotifier(),
    );

class TranslationNotifier extends Notifier<TranslationState> {
  @override
  TranslationState build() {
    return TranslationState();
  }

  // 特定の単語の訳語を更新するメソッドを追加
  void updateToken({required Token updatedToken}) {
    state = state.copyWith(
      tokens: state.tokens.map((token) {
        return token.id == updatedToken.id ? updatedToken : token;
      }).toList(),
    );
  }

  // 英文入力エリアの更新時
  void updateOriginalText(String newText) {
    if (state.originalText == newText) return;
    state = state.copyWith(originalText: newText);

    Throttle.milliseconds(500, () {
      _processTranslation();
    });
  }

  // トリガーボタンが押されたとき
  void pushTriggerButton() {
    Throttle.milliseconds(500, () {
      _processTranslation();
    });
  }

  // 解析のトリガー
  void _processTranslation() async {
    final textToProcess = state.originalText.trim();
    if (state.isProcessing) return;
    if (textToProcess.isEmpty) {
      state = state.copyWith(tokens: []);
    }

    // 処理中フラグを立ててUIをブロック/インジケータ表示
    state = state.copyWith(isProcessing: true);

    try {
      // TextProcessorを呼び出して、トークン化と訳語の割り当てを同時に行う
      final List<Token> newTokens = await ref
          .read(textProcessorProvider)
          .tokenizeAndTranslate(textToProcess);

      // 処理結果で状態を更新
      state = state.copyWith(tokens: newTokens);
    } catch (e) {
      print('テキスト処理中にエラーが発生しました: $e');
      state = state.copyWith(tokens: [], isProcessing: false);
    } finally {
      // 処理完了後にフラグを解除
      state = state.copyWith(isProcessing: false);
    }
  }
}
