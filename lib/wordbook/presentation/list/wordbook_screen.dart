import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/wordbook/data/list_state.dart';
import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/wordbook/domain/sort_notifier.dart';
import 'package:edb/wordbook/presentation/list/initial_error.dart';
import 'package:edb/wordbook/presentation/list/list_footer.dart';
import 'package:edb/wordbook/presentation/list/card2.dart';
import 'package:edb/wordbook/presentation/search/searchbar.dart';
import 'package:edb/wordbook/presentation/search/sort_dropdown.dart';

class WordbookScreen extends HookConsumerWidget {
  const WordbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ref.read(wordListProvider.notifier).loadNextPage();
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
          await ref.read(wordListProvider.notifier).reload();
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
              // 入力済み文字列
              final searchQuery = ref.read(sortSettingProvider).searchWord;
              final message = searchQuery.isEmpty
                  ? '単語帳にはまだ単語が登録されていません。'
                  : '「$searchQuery」に一致する単語は見つかりませんでした。';
              return Center(child: Text(message));
            }

            // 単語データをカードにしていく
            return CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),

              slivers: <Widget>[
                SliverAppBar(
                  // バーの挙動
                  floating: true,
                  pinned: false,
                  snap: true,

                  // 右
                  title: const SizedBox(
                    height: 40, // 検索バーの高さ
                    child: MySearchBar(),
                  ),

                  // 左
                  actions: <Widget>[
                    const SortOrderButton(),
                    const SortDropdownMenu(),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => {
                        ref.read(wordListProvider.notifier).reload(),
                      },
                      icon: const Icon(Icons.loop),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: wordEntries.length + 1, // フッター用にアイテム数+1
                    (context, index) {
                      // フッター部分の処理
                      if (index == wordEntries.length) {
                        return const MyListFooter();
                      }

                      // 通常の単語エントリーの表示
                      return MyWordCard(entry: wordEntries[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min, // Column が占有する高さを最小限に抑える
        crossAxisAlignment: CrossAxisAlignment.end, // ボタンを右端に寄せる
        children: [
          FloatingActionButton(
            onPressed: () {
              context.push('/registration');
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
