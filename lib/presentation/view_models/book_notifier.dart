import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/book_data.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/entity/value/sync_status.dart';
import 'package:edb/domain/usecase/fetch_bookdata_usecase.dart';
import 'package:edb/presentation/view_models/sorting_notifier.dart';

final bookProvider = AsyncNotifierProvider.autoDispose<BookNotifier, BookData>(
  () => BookNotifier(),
);

/// BookDataの管理
class BookNotifier extends AsyncNotifier<BookData> {
  // 状態の初期化と最初のロード
  @override
  Future<BookData> build() async {
    // 更新の監視
    final (searchWord, field, order) = ref.watch(
      sortingProvider.select((s) => (s.searchWord, s.field, s.order)),
    );

    // 1ページあたりの件数（TODO: 設定Providerを参照させる）
    const initialPageSize = 20;

    // 最初のページを要求
    final initialList = await ref
        .read(bookUseCaseProvider)
        .execute(
          currentCount: 0,
          pageSize: initialPageSize,
          sorter: SortingData(
            field: field,
            order: order,
            searchWord: searchWord,
          ),
        );

    // 初期ロードの結果を返す
    return BookData(pageSize: initialPageSize, cards: initialList);
  }

  // 次のページをロードするメソッド
  Future<void> loadNextPage() async {
    // 初回起動中は処理を中断
    if (state.isLoading || !state.hasValue) return;
    final currentState = state.requireValue;

    // 途中ロードの重複呼び出し、またはデータ終端の場合はスキップ
    if (currentState.tailStatus == SyncStatus.load || currentState.isDataEnd) {
      return;
    }

    // 途中ロードへ遷移
    state = AsyncData(currentState.copyWith(tailStatus: SyncStatus.load));

    try {
      // データの取得
      final newCards = await ref
          .read(bookUseCaseProvider)
          .execute(
            currentCount: currentState.cards.length,
            pageSize: currentState.pageSize,
            sorter: ref.read(sortingProvider),
          );

      // 新しいリストと状態を更新
      state = AsyncData(
        currentState.copyWith(
          words: [...currentState.cards, ...newCards],
          tailStatus: SyncStatus.normal,
        ),
      );
    } catch (e) {
      // エラーが発生した場合
      state = AsyncData(currentState.copyWith(tailStatus: SyncStatus.err));
    }
  }

  // リロード (Pull-to-Refreshで使用)
  Future<void> reload() async {
    // 入力途中の言葉は確定文字列で上書き
    final currentWord = ref.read(sortingProvider).searchWord;
    ref.read(sortingProvider.notifier).setTypeWord(currentWord);

    state = const AsyncValue.loading();

    // build() が再実行され、最新の sorting 結果に基づいてデータが引かれる
    ref.invalidateSelf();
    // 完了待ち
    await future;
  }
}
