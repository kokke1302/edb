import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/drawer.dart';
import 'package:edb/root/data/bottom_index.dart';
import 'package:edb/root/presentation/setting_fab.dart';
import 'package:edb/root/presentation/translate_fab.dart';

// -----------------------------------------------------------------------------
// MainScreen (共通のScaffold)
//  - childウィジェットをbodyとして受け取り、表示
// -----------------------------------------------------------------------------

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final String appBarTitle;
    final Widget fab;

    // 現在のインデックスに基づいてAppBarのタイトルとFABを決定
    switch (currentIndex) {
      case 0:
        appBarTitle = '翻訳モード';
        fab = Column(
          key: const ValueKey<int>(0),
          mainAxisSize: MainAxisSize.min, // Column が占有する高さを最小限に抑える
          crossAxisAlignment: CrossAxisAlignment.end, // ボタンを右端に寄せる
          children: [
            MyTranslateFab(),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'fab_bookmark_sentence',
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('英文を保存します')));
              },
              child: const Icon(Icons.bookmark_add_outlined),
            ),
          ],
        );
        break;
      case 1:
        appBarTitle = '単語帳モード';
        fab = Column(
          key: const ValueKey<int>(1),
          mainAxisSize: MainAxisSize.min, // Column が占有する高さを最小限に抑える
          crossAxisAlignment: CrossAxisAlignment.end, // ボタンを右端に寄せる
          children: [
            const MySettingFab(),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'fab_add_word',
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('単語帳を追加します')));
              },
              child: const Icon(Icons.add),
            ),
          ],
        );
        break;
      default:
        appBarTitle = 'Unknown';
        fab = const SizedBox.shrink(key: ValueKey<int>(-1));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        scrolledUnderElevation: 0,
      ),
      drawer: const MyDrawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int newIndex) {
          // Riverpodでインデックスを更新
          ref.read(bottomNavIndexProvider.notifier).setIndex(newIndex);
          // GoRouterで新しいパスに遷移
          switch (newIndex) {
            case 0:
              context.go('/translate');
              break;
            case 1:
              context.go('/words');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: '翻訳モード'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '単語帳モード'),
        ],
      ),
      // floatingActionButton: fab,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // アニメーションの時間を設定
        child: fab,
        // デフォルトではフェードアニメーション。必要に応じて transitionBuilder を設定
        transitionBuilder: (Widget child, Animation<double> animation) {
          // フェードとサイズ変更のアニメーションを組み合わせる例
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // 右からスライドイン
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}
