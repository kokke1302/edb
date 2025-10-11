import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/wordbook/data/sort_setting.dart';

// ソート設定の状態を管理する
final sortSettingProvider = NotifierProvider<SortSettingNotifier, SortSetting>(
  () => SortSettingNotifier(),
);

class SortSettingNotifier extends Notifier<SortSetting> {
  @override
  SortSetting build() {
    // 初期状態
    return const SortSetting(field: SortField.createdAt, order: SortOrder.desc);
  }

  // ソート項目のみを変更
  void setField(SortField newField) {
    state = state.copyWith(field: newField);
  }

  // ソート順序のみを変更
  void setOrder(SortOrder newOrder) {
    state = state.copyWith(order: newOrder);
  }

  // 状態をリセット
  void reset() {
    state = SortSetting(field: SortField.createdAt, order: SortOrder.desc);
  }
}
