import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/presentation/view_models/sorting_notifier.dart';
import 'package:edb/domain/entity/value/sort_order.dart';

// 順序（order）を変更するボタン
class MySortOrderButton extends ConsumerWidget {
  const MySortOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrder = ref.watch(sortingProvider.select((s) => s.order));

    // 次のソート順序
    final nextOrder = currentOrder == SortOrder.asc
        ? SortOrder.desc
        : SortOrder.asc;

    // 現在のソート順序に対応するアイコン
    final icon = currentOrder == SortOrder.asc
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // ソート順序を変更
        ref.read(sortingProvider.notifier).setOrder(nextOrder);
      },
    );
  }
}
