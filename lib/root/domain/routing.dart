import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/translation/presentation/translation.dart';
import 'package:edb/wordbook/presentation/list/wordbook_screen.dart';
import 'package:edb/root/presentation/main_screen.dart';

// -----------------------------------------------------------------------------
// GoRouter ルーティングの設定
//  - ShellRoute = 共通するUIの部分（MainScreen）
// -----------------------------------------------------------------------------

class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  static final _router = GoRouter(
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
            builder: (context, state) => const WordbookScreen(),
          ),
        ],
      ),
      // 独立した画面
      GoRoute(
        path: '/setting',
        builder: (context, state) => const SettingPage(),
      ),
      GoRoute(path: '/help', builder: (context, state) => const HelpPage()),
    ],
  );

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
