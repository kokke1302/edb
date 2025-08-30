import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// Riverpod 状態管理
//  - bottomNavIndexProvider = ボトムナビゲーションバーの選択状態を管理
// -----------------------------------------------------------------------------

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

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
          builder: (context, state) => const WordbookModePage(),
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
          ref.read(bottomNavIndexProvider.notifier).state = newIndex;
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

// ドロワーの中身
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              '保存した英文',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
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

// 翻訳モード画面
class TranslationModePage extends StatelessWidget {
  const TranslationModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '翻訳モード',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// 単語帳モード画面
class WordbookModePage extends StatelessWidget {
  const WordbookModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '単語帳モード',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

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
