import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/carry/tile_data.dart';
import 'package:edb/presentation/view_models/tiles_notifier.dart';

class MyTile extends ConsumerWidget {
  final TileData tile;
  const MyTile({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(tile.text),
      leading: const Icon(Icons.history),

      onTap: () async {
        final navigator = GoRouter.of(context);

        try {
          // 非同期処理を開始
          await ref.read(tilesProvider.notifier).makeTokenChain(id: tile.id);

          // Drawerを閉じる
          navigator.pop();
        } catch (e) {
          // 失敗時
          if (context.mounted) {
            _showErrorDialog(context, '復元に失敗しました。', e);
          }
        }
      },

      trailing: IconButton(
        icon: const Icon(Icons.delete), // 削除アイコン
        onPressed: () async {
          try {
            // 削除処理
            await ref.read(tilesProvider.notifier).deleteTile(id: tile.id);
          } catch (e) {
            if (context.mounted) {
              _showErrorDialog(context, '削除に失敗しました。', e);
            }
          }
        },
      ),
    );
  }

  // エラーダイアログを表示する共通メソッド
  void _showErrorDialog(BuildContext context, String message, Object e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラーが発生しました'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(message),
              const SizedBox(height: 8),
              Text('Log: $e'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
