import 'package:edb/translation/data/dbsourse_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/translation/data/token_data.dart';
import 'package:edb/translation/data/translation_state.dart';

final translationProvider =
    AsyncNotifierProvider<TranslationNotifier, TranslationState>(
      () => TranslationNotifier(),
    );

final targetToken = Provider.family<TokenData, int>((ref, id) {
  return ref.read(
    translationProvider.select((state) {
      final tokens = state.value?.tokens ?? const [];
      return tokens.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('ID: $id のトークンが見つかりません'),
      );
    }),
  );
});

class TranslationNotifier extends AsyncNotifier<TranslationState> {
  @override
  TranslationState build() {
    return TranslationState(originalText: '', tokens: const []);
  }

  // ドロワーからの復元
  void restore({required String text, required List<TokenData> chain}) {
    final current =
        state.value ?? TranslationState(originalText: '', tokens: const []);

    state = AsyncData(current.copyWith(originalText: text, tokens: chain));
  }

  // 特定の単語の訳語を更新するメソッド
  void updateToken({required TokenData updatedToken}) {
    state = state.whenData((current) {
      final replacedTokens = current.tokens.map((token) {
        return token.id == updatedToken.id ? updatedToken : token;
      }).toList();

      return current.copyWith(tokens: replacedTokens);
    });
  }

  // 英文入力エリアの更新時
  void updateOriginalText({required String newText}) {
    final current = state.value;
    if (current == null || current.originalText == newText) return;

    state = AsyncData(current.copyWith(originalText: newText));

    Throttle.milliseconds(500, _processTranslationWithCurrentTokens);
  }

  // スロットル後の文字列で処理する
  void _processTranslationWithCurrentTokens() {
    _processTranslation(nowTokens: state.value?.tokens);
  }

  // トリガーボタンが押されたとき
  void pushTriggerButton() {
    Throttle.milliseconds(500, _processTranslation);
  }

  // 解析のトリガー
  void _processTranslation({List<TokenData>? nowTokens}) async {
    final current = state.value;
    if (current == null || current.originalText.isEmpty) return;

    // ロード状態にする
    state = const AsyncLoading();

    // guard を使って非同期処理を実行
    state = await AsyncValue.guard(() async {
      final List<TokenData> newTokens;
      if (nowTokens != null) {
        newTokens = await ref
            .read(textProcessorProvider)
            .incrementalTranslation(
              nowTokens: nowTokens,
              newText: current.originalText,
            );
      } else {
        newTokens = await ref
            .read(textProcessorProvider)
            .fullTranslation(text: current.originalText);
      }

      return current.copyWith(tokens: newTokens);
    });
  }
}
