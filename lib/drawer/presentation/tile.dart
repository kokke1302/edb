import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/drawer/data/sentence.dart';
import 'package:edb/drawer/domain/tilelist_notifier.dart';

class MyTile extends ConsumerWidget {
  final Tile tile;
  const MyTile({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.history),
      // 英文テキストを表示
      title: Text(tile.text),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${tile.text}を復元します...')));
        // 代入処理
        ref
            .read(translationProvider.notifier)
            .restore(text: tile.text, chain: tile.chain);

        Navigator.of(context).pop();
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete), // 削除アイコン
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${tile.text} を削除しました。')));

          // 削除処理
          ref.read(tileListProvider.notifier).deleteTile(tile.id);
        },
      ),
    );
  }
}
