import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/share/data/card_data.dart';
import 'package:edb/share/data/sync_status.dart';
import 'package:edb/wordbook/data/list_state.dart';
import 'package:edb/wordbook/domain/list_repository.dart';
import 'package:edb/wordbook/domain/sort_notifier.dart';

// Provider を定義 (AsyncNotifier<WordListState> に型変更)
final wordListProvider =
    AsyncNotifierProvider.autoDispose<WordListNotifier, WordListState>(
      () => WordListNotifier(),
    );

/// WordListStateとロジックを管理
class WordListNotifier extends AsyncNotifier<WordListState> {
  // 状態の初期化と最初のロード
  @override
  Future<WordListState> build() async {
    // 更新の監視
    final (searchWord, field, order) = ref.watch(
      sortSettingProvider.select((s) => (s.searchWord, s.field, s.order)),
    );

    // 1ページあたりの件数（TODO: 設定Providerを参照させる）
    const initialPageSize = 20;

    // 最初のページを要求
    final initialList = await _fetchData(
      offset: 0,
      limit: initialPageSize,
      queryText: searchWord,
    );

    // 初期ロードの結果を返す
    return WordListState(
      pageSize: initialPageSize,
      words: initialList,
      tailStatus: SyncStatus.normal,
      isDataEnd: initialList.length < initialPageSize, // 最初のロードでページサイズ未満なら終端
    );
  }

  // 次のページをロードするメソッド
  Future<void> loadNextPage() async {
    // 初回起動中は処理を中断
    if (state.isLoading || !state.hasValue) return;

    final currentState = state.value!;

    // 途中ロードの重複呼び出し、またはデータ終端の場合はスキップ
    if (currentState.tailStatus == SyncStatus.load || currentState.isDataEnd) {
      return;
    }

    // 途中ロードへ遷移
    state = AsyncData(currentState.copyWith(tailStatus: SyncStatus.load));

    try {
      // データの取得を待機
      final newEntries = await _fetchData(
        offset: currentState.words.length,
        limit: currentState.pageSize,
        queryText: ref.read(sortSettingProvider).searchWord,
      );

      // 新しいリストと状態を更新
      final updatedWords = [...currentState.words, ...newEntries];

      state = AsyncData(
        currentState.copyWith(
          words: updatedWords,
          tailStatus: SyncStatus.normal,
          isDataEnd: newEntries.length < currentState.pageSize,
        ),
      );
    }
    // エラーが発生した場合
    catch (e) {
      state = AsyncData(currentState.copyWith(tailStatus: SyncStatus.err));
    }
  }

  // リロード (Pull-to-Refreshで使用)
  Future<void> reload() async {
    // 入力途中の言葉は確定文字列で上書き
    final currentWord = ref.read(sortSettingProvider).searchWord;
    ref.read(sortSettingProvider.notifier).setTypeWord(currentWord);

    state = const AsyncLoading();

    // build() が再実行され、最新の sortSetting 結果に基づいてデータが引かれる
    ref.invalidateSelf();
    // 完了待ち
    await future;
  }

  // Repositoryからデータを取得
  Future<List<CardData>> _fetchData({
    required int offset,
    required int limit,
    required String queryText,
  }) async {
    final repository = ref.read(listRepositoryProvider);
    final sortSetting = ref.read(sortSettingProvider);

    // ページングメソッド
    try {
      final entries = await repository.fetchVocabulariesWithPaging(
        offset: offset,
        limit: limit,
        queryText: queryText,
        sorter: sortSetting,
      );

      // 実行ログ
      // print(
      //   'DBから offset:$offset, limit:$limit, query:$queryText, sortField:${sortSetting.field.name}, sortOrder:${sortSetting.order.name} で ${entries.length} 件取得しました。',
      // );

      return entries
          .map((e) => CardData.fromVocabularies(vocabulary: e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
