import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/presentation/pages/drawer/drawer.dart';
import 'package:edb/presentation/view_models/bottom_index_notifier.dart';

// -----------------------------------------------------------------------------
// CommonScreen (共通のScaffold)
//  - childウィジェットをbodyとして受け取り、表示
// -----------------------------------------------------------------------------

class CommonScreen extends ConsumerWidget {
  const CommonScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final String appBarTitle;

    // 現在のインデックスに基づいてAppBarのタイトルとFABを決定
    switch (currentIndex) {
      case 0:
        appBarTitle = '翻訳モード';
        break;
      case 1:
        appBarTitle = '単語帳モード';
        break;
      default:
        appBarTitle = 'Unknown';
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
    );
  }
}
