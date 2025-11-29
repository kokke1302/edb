import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/drawer/domain/tilelist_notifier.dart';

class MyBookmarkFab extends ConsumerWidget {
  const MyBookmarkFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.bookmark_add),
      onPressed: () {
        ref.read(tileListProvider.notifier).addTile();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('英文とその訳を保存しました。')));
      },
      label: const Text('保存'),
    );
  }
}
