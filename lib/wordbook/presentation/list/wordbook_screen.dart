import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/wordbook/data/list_state.dart';
import 'package:edb/wordbook/domain/search_word.dart';
import 'package:edb/wordbook/domain/typing_word.dart';
import 'package:edb/wordbook/presentation/list/initial_error.dart';
import 'package:edb/wordbook/presentation/list/list_footer.dart';
import 'package:edb/wordbook/presentation/list/card2.dart';
import 'package:edb/wordbook/presentation/list/setting_fab.dart';

class WordbookScreen extends HookConsumerWidget {
  const WordbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 入力済み文字列
    final searchQuery = ref.watch(searchWordProvider);
    // 入力中の文字列（Dialog用）
    final _ = ref.watch(typingWordProvider);
    // 単語リストを監視
    final wordListState = ref.watch(wordListProvider);
    // スクロールコントローラとリスナーの準備
    final scrollController = useScrollController();

    // スクロールリスナーを設定（無限スクロールのトリガー）
    useEffect(() {
      void scrollListener() {
        final position = scrollController.position;
        final bool isEnd = position.pixels >= position.maxScrollExtent;

        // 発火時のWordListStateと入力済文字列について
        final currentList = ref.read(wordListProvider).value;
        if (currentList == null) return; // 初期ロード中・初期エラー時はスキップ

        if (currentList.endStatus == EndStatus.normal && // 途中ロード中・途中エラーでない
            !currentList.isDataEnd && // データ終端でない
            isEnd) {
          // データロードメソッドを呼び出す
          Throttle.milliseconds(500, () {
            final currentQuery = ref.read(searchWordProvider);
            ref
                .read(wordListProvider.notifier)
                .loadNextPage(queryText: currentQuery);
          });
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
          await ref
              .read(wordListProvider.notifier)
              .reload(queryText: searchQuery);
        },
        child: wordListState.when(
          // 初回ロード中
          loading: () => const Center(child: CircularProgressIndicator()),

          // 初回エラー
          error: (err, stack) => MyInitialError(error: err),

          // データあり（WordListState）
          data: (wordListState) {
            final wordEntries = wordListState.words;

            // データ終端であり、リストが空の場合
            if (wordListState.isDataEnd && wordEntries.isEmpty) {
              final message = searchQuery.isEmpty
                  ? '単語帳にはまだ単語が登録されていません。'
                  : '「$searchQuery」に一致する単語は見つかりませんでした。';
              return Center(child: Text(message));
            }

            // 単語データをカードにしていく
            return ListView.builder(
              controller: scrollController,
              itemCount: wordEntries.length + 1, // フッター用にアイテム数+1
              itemBuilder: (context, index) {
                // フッター部分の処理
                if (index == wordEntries.length) return const MyListFooter();

                // 通常の単語エントリーの表示
                return MyWordCard(entry: wordEntries[index]);
              },
            );
          },
        ),
      ),

      floatingActionButton: Column(
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
              ).showSnackBar(const SnackBar(content: Text('単語を登録します')));
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
