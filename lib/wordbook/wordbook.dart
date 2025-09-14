import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'word_list_notifier.dart';

// 翻訳モード画面
class WordbookModePage extends HookConsumerWidget {
  const WordbookModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final notifier = ref.read(wordListProvider.notifier);

    // useEffect でリスナーの追加と解除を一括管理
    useEffect(() {
      // 初期化処理（リスナー登録）
      void scrollListener() {
        final scrollPosition = scrollController.position;
        final bool isEnd =
            scrollPosition.pixels >= scrollPosition.maxScrollExtent;
        final bool hasError = ref.watch(lastErrorProvider);

        if (isEnd && !hasError) {
          // Notifier のデータロードメソッドを呼び出す
          Throttle.milliseconds(500, () => notifier.loadNextPage());
        }
      }

      scrollController.addListener(scrollListener);

      // クリーンアップ関数（リスナー解除）
      return () {
        // ウィジェット破棄時（dispose）に自動で呼び出される
        scrollController.removeListener(scrollListener);
      };
    }, const []);

    // AsyncValue<List<WordEntry>> を watch
    final wordEntriesAsync = ref.watch(wordListProvider);
    final isDataEnd = ref.watch(isDataEndProvider);
    final hasErrorMore = ref.watch(lastErrorProvider);

    final wordEntries = wordEntriesAsync.value ?? [];
    final isLoadingInitial = wordEntriesAsync.isLoading && wordEntries.isEmpty;
    final isLoadingMore = wordEntriesAsync.isLoading && wordEntries.isNotEmpty;

    // 1. 初回ロード中の場合
    if (isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. 初回ロードでエラーの場合（データがない）
    if (wordEntriesAsync.hasError && wordEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('初回ロードでエラーが発生しました: ${wordEntriesAsync.error}'),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(wordListProvider), // Notifier全体をリビルド
              child: const Text('リトライ'),
            ),
          ],
        ),
      );
    }

    // 3. データあり、リストビューを構築
    return RefreshIndicator(
      onRefresh: () async {
        await notifier.refresh();
      },
      child: _buildListView(
        context: context,
        wordEntries: wordEntries,
        scrollController: scrollController,
        isLoadingMore: isLoadingMore,
        isDataEnd: isDataEnd,
        onRetry: notifier.loadNextPage,
        hasErrorMore: hasErrorMore,
      ),
    );
  }
}

// リストビューの構築をヘルパーメソッドに切り出します
Widget _buildListView({
  required BuildContext context,
  required List<WordEntry> wordEntries,
  required ScrollController scrollController,
  required bool isLoadingMore,
  required bool isDataEnd,
  required VoidCallback onRetry,
  required bool hasErrorMore,
}) {
  // ローディング中に追加で表示する項目（インジケーター）の数を計算
  final shouldShowFooter = isLoadingMore || isDataEnd || hasErrorMore;
  final itemCount = wordEntries.length + (shouldShowFooter ? 1 : 0);

  return ListView.builder(
    controller: scrollController,
    itemCount: itemCount,
    itemBuilder: (context, index) {
      // 最後の項目で
      if (index == wordEntries.length) {
        if (isLoadingMore) {
          // ローディング中
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (isDataEnd) {
          // データ終端
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('全ての単語を読み込みました')),
          );
        } else if (hasErrorMore) {
          // 🚩 6. エラーウィジェットを表示
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('データの読み込みに失敗しました。'),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: onRetry, child: const Text('リトライ')),
              ],
            ),
          );
        }
      }

      // 通常の WordEntry の表示
      final entry = wordEntries[index];
      return Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(
            entry.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            entry.memo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(entry.id.toString()),
        ),
      );
    },
  );
}
