import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import '../../state/list_notifier.dart';
import '../../state/list_state.dart';
import '../../state/search_word.dart';
import 'list_footer.dart';
import 'card.dart';

class WordbookScreen extends HookConsumerWidget {
  const WordbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 入力済み文字列
    final searchQuery = ref.watch(searchWordProvider);
    // 単語リストを監視
    final wordListState = ref.watch(wordListProvider);
    final wordListNotifier = ref.read(wordListProvider.notifier);
    // スクロールコントローラとリスナーの準備
    final scrollController = useScrollController();

    // スクロールリスナーを設定（無限スクロールのトリガー）
    useEffect(() {
      void scrollListener() {
        final position = scrollController.position;
        final bool isEnd = position.pixels >= position.maxScrollExtent;

        // 発火時のWordListStateと入力済文字列について
        final currentList = ref.read(wordListProvider).value;
        final currentQuery = ref.read(searchWordProvider);
        if (currentList != null && // 初期ロード中・初期エラーではない
            // 初期エラーはAsyncErrorを持つが、WordListStateを持たないため、.valueプロパティはnullを返す。
            currentList.endStatus == EndStatus.normal && // 途中ロード中・途中エラーでない
            !currentList.isDataEnd && // データ終端でない
            isEnd) {
          // データロードメソッドを呼び出す
          Throttle.milliseconds(
            500,
            () => wordListNotifier.loadNextPage(queryText: currentQuery),
          );
        }
      }

      scrollController.addListener(scrollListener);

      // クリーンアップ関数（リスナー解除）
      return () => scrollController.removeListener(scrollListener);
    }, const []);

    return Scaffold(
      // AsyncValueの状態に基づいてUIを構築
      body: RefreshIndicator(
        onRefresh: () async {
          await wordListNotifier.reload(queryText: searchQuery);
        },
        child: wordListState.when(
          // 初回ロード中
          loading: () => const Center(child: CircularProgressIndicator()),

          // 初回エラー
          error: (err, stack) => _MyInitialError(err),

          // データあり（WordListState）
          data: (wordListState) {
            final wordEntries = wordListState.words;

            // データ終端であり、リストが空の場合
            if (wordEntries.isEmpty && wordListState.isDataEnd) {
              final message = searchQuery.isEmpty
                  ? '単語帳にはまだ単語が登録されていません。'
                  : '「$searchQuery」に一致する単語は見つかりませんでした。';
              return Center(child: Text(message));
            }

            // // フッター用にアイテム数+1
            final itemCount = wordEntries.length + 1;

            // 単語データをカードにしていく
            return ListView.builder(
              controller: scrollController,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // フッター部分の処理
                if (index == wordEntries.length) return MyListFooter();

                // 通常の単語エントリーの表示
                final entry = wordEntries[index];
                return MyWordCard(entry: entry);
              },
            );
          },
        ),
      ),
    );
  }
}

// ===============================================
// 初回ロード　デザイン
// ===============================================

class _MyInitialError extends ConsumerWidget {
  final Object error;
  const _MyInitialError(this.error);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('データの初期ロードに失敗しました。'),
          Text(error.toString()),
          ElevatedButton(
            onPressed: () => ref.invalidate(wordListProvider),
            child: const Text('リトライ'),
          ),
        ],
      ),
    );
  }
}
