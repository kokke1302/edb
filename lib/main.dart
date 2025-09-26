import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'drawer.dart';
import 'translation.dart';
import 'wordbook/presentation/list/wordbook_screen.dart';
import 'wordbook/presentation/setting_fab/setting_fab.dart';

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
        GoRoute(path: '/words', builder: (context, state) => WordbookScreen()),
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

void main() async {
  // ウィジェットバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();

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
            FloatingActionButton(
              heroTag: 'fab_start_translation',
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('翻訳を開始します')));
              },
              child: const Icon(Icons.play_arrow),
            ),
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
            MySettingFab(),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'fab_add_word',
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('新規登録します')));
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
