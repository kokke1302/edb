import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/entity/value/sort_field.dart';
import 'package:edb/domain/entity/value/sort_oder.dart';

final sortingProvider = NotifierProvider<SortingNotifier, SortingData>(
  () => SortingNotifier(),
);

// ソート設定の状態を管理
class SortingNotifier extends Notifier<SortingData> {
  @override
  SortingData build() {
    // 初期状態
    return const SortingData();
  }

  // ソート項目のみを変更
  void setField(SortField newField) {
    state = state.copyWith(field: newField);
  }

  // ソート順序のみを変更
  void setOrder(SortOrder newOrder) {
    state = state.copyWith(order: newOrder);
  }

  void setSearchWord(String text) {
    state = state.copyWith(searchWord: text);
  }

  void setTypeWord(String text) {
    state = state.copyWith(typingWord: text);
  }
}
