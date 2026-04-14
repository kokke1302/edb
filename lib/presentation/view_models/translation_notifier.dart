import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/domain/entity/token_data.dart';
import 'package:edb/domain/entity/model/translation_data.dart';
import 'package:edb/domain/usecase/process_translation_usecase.dart';

final translationProvider =
    AsyncNotifierProvider<TranslationNotifier, TranslationData>(
      () => TranslationNotifier(),
    );

final tokenProvider = Provider.family.autoDispose<TokenData, int>((ref, id) {
  return ref.watch(translationProvider.select((s) => s.value!.tokens[id]));
});

class TranslationNotifier extends AsyncNotifier<TranslationData> {
  @override
  TranslationData build() {
    return TranslationData();
  }

  // ドロワーからの復元
  void restore({required String text, required List<TokenData> chain}) {
    state = AsyncData(TranslationData(originalText: text, tokens: chain));
  }

  // 特定の単語の訳語を更新
  void updateToken({required TokenData updatedToken}) {
    state = state.whenData((current) {
      final newTokens = current.tokens
          .map((token) => token.id == updatedToken.id ? updatedToken : token)
          .toList();
      return current.copyWith(tokens: newTokens);
    });
  }

  // 英文入力エリアの更新時
  void updateOriginalText({required String newText}) {
    final current = state.value;
    if (current == null || current.originalText == newText) return;

    state = AsyncData(current.copyWith(originalText: newText));

    Throttle.milliseconds(10, () => _runTranslation(isFullScan: false));
  }

  // トリガーボタンが押されたとき
  void pushTriggerButton() {
    Throttle.milliseconds(10, _runTranslation);
  }

  // 解析のトリガー
  Future<void> _runTranslation({bool isFullScan = true}) async {
    final current = state.value;
    if (current == null || current.originalText.isEmpty) return;

    // ぐるぐるの表示
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 処理プロセスの呼び出し
      final newTokens = await ref
          .read(processTranselationUseCaseProvider)
          .execute(
            text: current.originalText,
            currentTokens: current.tokens,
            isFullScan: isFullScan,
          );

      return current.copyWith(tokens: newTokens);
    });
  }
}
