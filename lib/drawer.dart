import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('履歴1: I have a pen.'),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('履歴1を復元します')));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete), // 削除アイコン
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('履歴1を削除します')),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('履歴2: I have an apple.'),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('履歴2を復元します')));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete), // 削除アイコン
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('履歴2を削除します')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
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
