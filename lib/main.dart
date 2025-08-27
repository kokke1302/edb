import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// 1. Riverpod State Management
// -----------------------------------------------------------------------------
final currentIndexProvider = StateNotifierProvider<CurrentIndexNotifier, int>((
  ref,
) {
  return CurrentIndexNotifier();
});

class CurrentIndexNotifier extends StateNotifier<int> {
  CurrentIndexNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

// -----------------------------------------------------------------------------
// 2. GoRouter Setup with ShellRoute
//    - ShellRouteを使って共通のScaffoldを定義し、内部のページを切り替えます。
// -----------------------------------------------------------------------------
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/page1',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // MainScreenが共通のUI（Scaffold）を提供します。
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/page1',
            name: 'page1',
            builder: (context, state) => const PageScreen(pageIndex: 0),
          ),
          GoRoute(
            path: '/page2',
            name: 'page2',
            builder: (context, state) => const PageScreen(pageIndex: 1),
          ),
          GoRoute(
            path: '/page3',
            name: 'page3',
            builder: (context, state) => const PageScreen(pageIndex: 2),
          ),
        ],
      ),
    ],
  );
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Flutter Navigation with Riverpod & GoRouter',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: goRouter,
    );
  }
}

// -----------------------------------------------------------------------------
// 3. MainScreen (共通のScaffold)
//    - childウィジェットをbodyとして受け取り、表示します。
// -----------------------------------------------------------------------------
class MainScreen extends ConsumerWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final String appBarTitle;
    final FloatingActionButton? fab;

    // 現在のインデックスに基づいてAppBarのタイトルとFABを決定
    switch (currentIndex) {
      case 0:
        appBarTitle = 'ホーム';
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
        appBarTitle = '設定';
        fab = FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('FAB on Settings Page!')),
            );
          },
          child: const Icon(Icons.settings),
        );
        break;
      case 2:
        appBarTitle = 'プロフィール';
        fab = null;
        break;
      default:
        appBarTitle = 'Unknown';
        fab = null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'メニュー',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('ホーム'),
              selected: currentIndex == 0,
              onTap: () {
                ref.read(currentIndexProvider.notifier).setIndex(0);
                context.go('/page1');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              selected: currentIndex == 1,
              onTap: () {
                ref.read(currentIndexProvider.notifier).setIndex(1);
                context.go('/page2');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('プロフィール'),
              selected: currentIndex == 2,
              onTap: () {
                ref.read(currentIndexProvider.notifier).setIndex(2);
                context.go('/page3');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: child, // ここが重要: go_routerから渡されるchildウィジェットを表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentIndexProvider.notifier).setIndex(index);
          switch (index) {
            case 0:
              context.go('/page1');
              break;
            case 1:
              context.go('/page2');
              break;
            case 2:
              context.go('/page3');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
      ),
      floatingActionButton: fab,
    );
  }
}

// -----------------------------------------------------------------------------
// 4. PageScreen (各ページの実際のコンテンツ)
// -----------------------------------------------------------------------------
class PageScreen extends StatelessWidget {
  final int pageIndex;
  const PageScreen({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    String pageContent = '';
    switch (pageIndex) {
      case 0:
        pageContent = 'これはページ1のコンテンツです。';
        break;
      case 1:
        pageContent = 'これはページ2のコンテンツです。';
        break;
      case 2:
        pageContent = 'これはページ3のコンテンツです。';
        break;
      default:
        pageContent = 'コンテンツがありません。';
    }

    return Center(
      child: Text(
        pageContent,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}
