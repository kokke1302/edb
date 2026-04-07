import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/drawer/data/tile_data.dart';
import 'package:edb/drawer/domain/tilelist_notifier.dart';
import 'package:edb/drawer/domain/tile_message_resiver.dart';

class MyTile extends ConsumerWidget {
  final TileData tile;
  const MyTile({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String>(tileMessageProvider, (previous, next) {
      if (next.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        // 修正：Providerの状態を空文字に戻す
        ref.read(tileMessageProvider.notifier).setString(text: '');
      }
    });

    return ListTile(
      leading: const Icon(Icons.history),
      // 英文テキストを表示
      title: Text(tile.text),
      onTap: () async {
        // 非同期処理を開始
        await ref.read(tileListProvider.notifier).makeTokenChain(id: tile.id);

        // mounted チェック
        if (!context.mounted) return;

        // エラーメッセージがない（＝成功）場合のみ閉じる
        if (ref.read(tileMessageProvider).isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${tile.text}を復元しました')));
          Navigator.of(context).pop();
        }
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete), // 削除アイコン
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${tile.text} を削除しました。')));

          // 削除処理
          ref.read(tileListProvider.notifier).deleteTile(id: tile.id);
        },
      ),
    );
  }
}
