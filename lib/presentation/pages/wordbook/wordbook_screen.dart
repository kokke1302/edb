import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/domain/entity/value/sync_status.dart';
import 'package:edb/domain/entity/model/book_data.dart';
import 'package:edb/presentation/view_models/book_notifier.dart';
import 'package:edb/presentation/view_models/sorting_notifier.dart';
import 'package:edb/presentation/pages/wordbook/list/initial_error.dart';
import 'package:edb/presentation/pages/wordbook/list/book_footer.dart';
import 'package:edb/presentation/pages/wordbook/list/book_card.dart';
import 'package:edb/presentation/pages/wordbook/search/searchbar.dart';
import 'package:edb/presentation/pages/wordbook/search/sort_dropdown.dart';
import 'package:edb/presentation/pages/wordbook/search/sort_order.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';

class WordbookScreen extends HookConsumerWidget {
  const WordbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 単語リストを監視
    final wordListState = ref.watch(bookProvider);
    // スクロールコントローラとリスナーの準備
    final scrollController = useScrollController();

    // スクロールリスナーを設定（無限スクロールのトリガー）
    useEffect(() {
      void scrollListener() {
        final position = scrollController.position;
        final bool isEnd = position.pixels >= position.maxScrollExtent;

        // 発火時のWordListStateと入力済文字列について
        final currentList = ref.read(bookProvider).value;
        if (currentList == null) return; // 初期ロード中・初期エラー時はスキップ

        if (currentList.tailStatus == SyncStatus.normal && // 途中ロード中・途中エラーでない
            !currentList.isDataEnd && // データ終端でない
            isEnd) {
          // データロードメソッドを呼び出す
          Throttle.milliseconds(500, () {
            ref.read(bookProvider.notifier).loadNextPage();
          });
        }
      }

      scrollController.addListener(scrollListener);

      // クリーンアップ関数（リスナー解除）
      return () => scrollController.removeListener(scrollListener);
    }, const []);

    Widget showCards({required BookData state}) {
      final wordEntries = state.cards;

      // リストが空の場合
      final searchQuery = ref.read(sortingProvider).searchWord;
      final displayQuery = searchQuery.length > 50
          ? '${searchQuery.substring(0, 50)}...'
          : searchQuery;
      final message = displayQuery.isEmpty
          ? '単語帳にはまだ単語が登録されていません。'
          : '「$displayQuery」に一致する単語は見つかりませんでした。';

      final Widget mainContentSliver;
      if (state.isDataEnd && wordEntries.isEmpty) {
        // 検索結果が空の場合
        mainContentSliver = SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(message)),
        );
      } else {
        // データがある場合
        mainContentSliver = SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: wordEntries.length + 1,
            (context, index) {
              if (index == wordEntries.length) return const MyBookFooter();
              return MyBookCard(card: wordEntries[index]);
            },
          ),
        );
      }

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
            title: const MySearchBar(),
            // 左
            actions: <Widget>[
              const SortOrderButton(),
              const SortDropdownMenu(),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => {
                  ref.invalidate(sortingProvider),
                  ref.invalidate(bookProvider),
                },
                icon: const Icon(Icons.home),
              ),
              IconButton(
                onPressed: () => ref.read(bookProvider.notifier).reload(),
                icon: const Icon(Icons.loop),
              ),
              const SizedBox(width: 10),
            ],
          ),

          mainContentSliver,
        ],
      );
    }

    return Scaffold(
      // AsyncValueの状態に基づいてUIを構築
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bookProvider.notifier).reload();
        },
        child: wordListState.when(
          // 初回ロード中
          loading: () => const Center(child: CircularProgressIndicator()),

          // 初回エラー
          error: (err, stack) => MyInitialError(error: err),

          // データあり（WordListState）
          data: (wordListState) => showCards(state: wordListState),
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min, // Column が占有する高さを最小限に抑える
        crossAxisAlignment: CrossAxisAlignment.end, // ボタンを右端に寄せる
        children: [
          FloatingActionButton(
            onPressed: () {
              ref.read(regiDataReceiver.notifier).initialCard();
              context.push('/registration');
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
