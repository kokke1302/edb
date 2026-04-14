import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/presentation/view_models/sorting_notifier.dart';
import 'package:edb/domain/entity/value/sort_field.dart';

/// ソート項目と順序を選択するドロップダウンメニュー
class SortDropdownMenu extends ConsumerWidget {
  const SortDropdownMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のソート設定
    final currentSetting = ref.watch(sortingProvider);

    return DropdownButton<SortField>(
      value: currentSetting.field,
      icon: const Icon(Icons.sort),
      onChanged: (SortField? newField) {
        if (newField != null && newField != currentSetting.field) {
          // ソート項目を変更
          ref.read(sortingProvider.notifier).setField(newField);
        }
      },
      items: const <DropdownMenuItem<SortField>>[
        DropdownMenuItem(value: SortField.createdAt, child: Text('作成日時')),
        DropdownMenuItem(value: SortField.englishWord, child: Text('単語タイトル')),
      ],
    );
  }
}
