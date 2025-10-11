import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/wordbook/data/list_state.dart';
import 'package:edb/wordbook/data/search_word.dart';
import 'package:edb/wordbook/domain/list_notifier.dart';

// ===============================================
// 途中ロード　判定ロジック
// ===============================================

class MyListFooter extends ConsumerWidget {
  const MyListFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WordListクラスを取り出す
    final asyncState = ref.watch(wordListProvider);

    if (asyncState case AsyncData(:final value)) {
      // 終端での状態判定
      switch (value.endStatus) {
        // 途中ロード中
        case EndStatus.loading:
          return const _MyLoadingFooter();

        // 途中エラー場合
        case EndStatus.error:
          return const _MyErrorFooter();

        // 通常時
        case EndStatus.normal:
          // isDataEndがtrueの場合は最終端、スクロール中
          return value.isDataEnd
              ? const _MyEndFooter()
              : const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }
}

// ===============================================
// 途中ロード　デザイン
// ===============================================

// 途中ロード中
class _MyLoadingFooter extends StatelessWidget {
  const _MyLoadingFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// 途中エラー
class _MyErrorFooter extends ConsumerWidget {
  const _MyErrorFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('データの読み込みに失敗しました。'),
          const SizedBox(width: 8),
          ElevatedButton(
            // リトライ時は、loadNextPageを再試行させる
            child: const Text('リトライ'),
            onPressed: () {
              final wordListNotifier = ref.read(wordListProvider.notifier);
              final searchQuery = ref.read(searchWordProvider);
              wordListNotifier.loadNextPage(queryText: searchQuery);
            },
          ),
        ],
      ),
    );
  }
}

// 最終端
class _MyEndFooter extends StatelessWidget {
  const _MyEndFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: Text('全ての単語を読み込みました')),
    );
  }
}
