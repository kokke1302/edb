import 'package:edb/presentation/pages/wordbook/list/card_list.dart';
import 'package:edb/presentation/pages/wordbook/search/silver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_throttle_it/just_throttle_it.dart';

import 'package:edb/domain/entity/value/sync_status.dart';
import 'package:edb/presentation/pages/wordbook/list/initial_error.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';
import 'package:edb/presentation/view_models/book_notifier.dart';

class MyBookScreen extends HookConsumerWidget {
  const MyBookScreen({super.key});

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
          data: (wordListState) => CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              const MyBookSliverAppBar(),
              MyBookCardList(state: wordListState),
            ],
          ),
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
