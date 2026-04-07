import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/drawer/domain/tilelist_notifier.dart';

class MyBookmarkFab extends ConsumerWidget {
  const MyBookmarkFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationProvider);

    final VoidCallback? onPressed = state.isLoading
        ? null
        : () {
            ref.read(tileListProvider.notifier).addTile();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('英文とその訳を保存しました。')));
          };

    return ElevatedButton.icon(
      icon: const Icon(Icons.bookmark_add),
      label: const Text('保存'),
      onPressed: onPressed,
    );
  }
}
