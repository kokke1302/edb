import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'drawer.dart';
import 'translation.dart';
import 'wordbook/wordbook.dart';

// -----------------------------------------------------------------------------
// Riverpod 状態管理
//  - BottomNavIndexNotifier = ボトムナビゲーションバーの選択状態を管理
//  - bottomNavIndexProvider = インスタンス化
// -----------------------------------------------------------------------------

// Notifierクラスを定義
class BottomNavIndexNotifier extends Notifier<int> {
  // stateの初期値を設定
  @override
  int build() {
    return 0;
  }

  // stateを更新するメソッド
  void setIndex(int newIndex) {
    state = newIndex;
  }
}

// Providerを定義
final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, int>(
  () => BottomNavIndexNotifier(),
);

// -----------------------------------------------------------------------------
// GoRouter ルーティングの設定
//  - ShellRoute = 共通するUIの部分（MainScreen）
// -----------------------------------------------------------------------------

final _router = GoRouter(
  initialLocation: '/translate',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        // ボトムナビゲーションバーで切り替える画面
        GoRoute(
          path: '/translate',
          builder: (context, state) => const TranslationModePage(),
        ),
        GoRoute(
          path: '/words',
          builder: (context, state) => WordbookModePage(),
        ),
      ],
    ),
    // 独立した画面
    GoRoute(path: '/setting', builder: (context, state) => const SettingPage()),
    GoRoute(path: '/help', builder: (context, state) => const HelpPage()),
  ],
);

// -----------------------------------------------------------------------------
// アプリケーションのエントリーポイント
// -----------------------------------------------------------------------------

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ProviderScope(child: EnglishLearningApp()));
}

class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Tailwind CSSの指示に合わせ、Interフォントを仮定
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

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
    final FloatingActionButton? fab;

    // 現在のインデックスに基づいてAppBarのタイトルとFABを決定
    switch (currentIndex) {
      case 0:
        appBarTitle = '翻訳モード';
        fab = FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('FAB on Home Page!')));
          },
          child: const Icon(Icons.add),
        );
        break;
      case 1:
        appBarTitle = '単語帳モード';
        fab = null;
        break;
      default:
        appBarTitle = 'Unknown';
        fab = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: MyDrawer(),
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
      floatingActionButton: fab,
    );
  }
}

// -----------------------------------------------------------------------------
// 画面の定義
// -----------------------------------------------------------------------------

// 設定画面
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          '設定画面',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// ヘルプ画面
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'ヘルプ画面',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
