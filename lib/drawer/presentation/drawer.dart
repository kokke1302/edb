import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/drawer/domain/tilelist_notifier.dart';
import 'package:edb/drawer/presentation/tile.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileListAsync = ref.watch(tileListProvider);

    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity, // 幅を親の最大値に設定
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: const Text(
                  '保存した英文',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),

          Expanded(
            // AsyncValueを使って、ローディング/エラー/データを処理
            child: tileListAsync.when(
              // エラー時の表示
              error: (err, stack) => Center(child: Text('Error: $err')),
              // ローディング時の表示
              loading: () => const Center(child: CircularProgressIndicator()),
              // データ取得成功時の表示
              data: (tileState) {
                // TileState.listからListTileを作成
                if (tileState.list.isEmpty) {
                  return const Center(child: Text('保存された英文はありません。'));
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: tileState.list.length,
                  itemBuilder: (context, index) {
                    final tile = tileState.list[index];

                    return MyTile(tile: tile);
                  },
                );
              },
            ),
          ),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              // ドロワーを閉じる
              Navigator.of(context).pop();
              context.push('/setting');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('ヘルプ'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/help');
            },
          ),
        ],
      ),
    );
  }
}
