import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/sort_setting.dart';

// 順序（order）を変更するボタン (例としてIconButton)
class SortOrderButton extends ConsumerWidget {
  const SortOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSetting = ref.watch(sortSettingProvider);
    final sortSettingNotifier = ref.read(sortSettingProvider.notifier);

    // 次のソート順序
    final nextOrder = currentSetting.order == SortOrder.asc
        ? SortOrder.desc
        : SortOrder.asc;

    // 現在のソート順序に対応するアイコン
    final icon = currentSetting.order == SortOrder.asc
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // ソート順序を変更
        sortSettingNotifier.setOrder(nextOrder);
      },
    );
  }
}

/// ソート項目と順序を選択するドロップダウンメニュー
class SortDropdownMenu extends ConsumerWidget {
  const SortDropdownMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のソート設定
    final currentSetting = ref.watch(sortSettingProvider);
    // ソート設定
    final sortSettingNotifier = ref.read(sortSettingProvider.notifier);

    return DropdownButton<SortField>(
      value: currentSetting.field,
      icon: const Icon(Icons.sort),
      onChanged: (SortField? newField) {
        if (newField != null && newField != currentSetting.field) {
          // ソート項目を変更
          sortSettingNotifier.setField(newField);
        }
      },
      items: const <DropdownMenuItem<SortField>>[
        DropdownMenuItem(value: SortField.createdAt, child: Text('作成日時')),
        DropdownMenuItem(value: SortField.title, child: Text('単語タイトル')),
      ],
    );
  }
}
