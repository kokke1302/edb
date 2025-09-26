import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortField { createdAt, title }

enum SortOrder { asc, desc }

// ソート設定を格納するクラス
class SortSetting {
  final SortField field;
  final SortOrder order;

  const SortSetting({required this.field, required this.order});

  // 変更用メソッド
  SortSetting copyWith({SortField? field, SortOrder? order}) {
    return SortSetting(field: field ?? this.field, order: order ?? this.order);
  }
}

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

// ソート設定の状態を管理する
final sortSettingProvider = NotifierProvider<SortSettingNotifier, SortSetting>(
  () => SortSettingNotifier(),
);
