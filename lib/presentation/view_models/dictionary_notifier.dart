import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/dictionary_data.dart';
import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/domain/usecase/fetch_dictionarydata_usecase.dart';
import 'package:edb/domain/usecase/toggle_card_visibility_usecase.dart';
import 'package:edb/presentation/view_models/selected_token_notifier.dart';
import 'package:edb/presentation/view_models/translation_notifier.dart';

final dictionaryProvider =
    AsyncNotifierProvider.autoDispose<DictionaryNotifier, DictionaryData>(
      () => DictionaryNotifier(),
    );

// 訳語リストの管理
class DictionaryNotifier extends AsyncNotifier<DictionaryData> {
  @override
  Future<DictionaryData> build() async {
    final token = ref.read(selectedTokenProvider);
    return ref.read(dictionaryUseCaseProvider).execute(token);
  }

  // 訳の表示/非表示の切り替え
  Future<void> toggleVisibility({required CardData card}) async {
    // 単語帳以外からは受け付けない & バリデーション
    if (card.vocab.based != Based.vocabularies || state.isLoading) return;

    state = await AsyncValue.guard(() async {
      final currentData = state.requireValue;
      final token = ref.read(selectedTokenProvider);

      // データの取得
      final (updatedData, newToken) = ref
          .read(toggleCardVisibilityUseCaseProvider)
          .execute(
            currentData: currentData,
            targetCard: card,
            currentToken: token,
          );

      // 副作用
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);

      return updatedData;
    });
  }
}
