import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
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
  // 1ページあたりの件数
  final int _pageSize = 20;

  // 状態の初期化と最初のロード
  @override
  Future<WordListState> build() async {
    // 最初のページを要求
    final initialList = await _fetchData(
      offset: 0,
      limit: _pageSize,
      queryText: '',
    );

    // 初期ロードの結果を返す
    return WordListState(
      words: initialList,
      endStatus: EndStatus.normal,
      isDataEnd: initialList.length < _pageSize, // 最初のロードでページサイズ未満なら終端
    );
  }

  // 次のページをロードするメソッド
  Future<void> loadNextPage() async {
    // 初回起動中は処理を中断
    if (!state.hasValue) return;

    final currentState = state.value!;

    // 途中ロードの重複呼び出し、またはデータ終端の場合はスキップ
    if (currentState.endStatus == EndStatus.loading || currentState.isDataEnd) {
      return;
    }

    // 途中ロードへ遷移
    state = AsyncData(currentState.copyWith(endStatus: EndStatus.loading));

    try {
      // データの取得を待機
      final newEntries = await _fetchData(
        offset: currentState.words.length,
        limit: _pageSize,
        queryText: ref.read(sortSettingProvider).searchWord,
      );

      // 新しいリストと状態を更新
      final updatedWords = [...currentState.words, ...newEntries];

      state = AsyncData(
        WordListState(
          words: updatedWords,
          endStatus: EndStatus.normal,
          isDataEnd: newEntries.length < _pageSize,
        ),
      );
    }
    // エラーが発生した場合
    catch (e, stack) {
      state = AsyncError<WordListState>(e, stack)
          // 既存のリストを保持したままエラーフラグを立てる
          .whenData((data) => data.copyWith(endStatus: EndStatus.error));
    }
  }

  // リロード (フィルタ・ソート変更時やPull-to-Refreshで使用)
  Future<void> reload() async {
    // リロード中
    state = const AsyncValue.loading();

    final searchQuery = ref.read(sortSettingProvider).searchWord;
    ref.read(sortSettingProvider.notifier).setTypeWord(searchQuery);

    // 最初のページを再取得
    state = await AsyncValue.guard(() async {
      final initialList = await _fetchData(
        offset: 0,
        limit: _pageSize,
        queryText: ref.read(sortSettingProvider).searchWord,
      );

      return WordListState(
        words: initialList,
        endStatus: EndStatus.normal,
        isDataEnd: initialList.length < _pageSize,
      );
    });
  }

  // Repositoryからデータを取得
  Future<List<Vocabulary>> _fetchData({
    required int offset,
    required int limit,
    required String queryText,
  }) async {
    final repository = ref.read(listRepositoryProvider);
    final sortSetting = ref.read(sortSettingProvider);

    // TODO: 遅延をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));

    // ページングメソッド
    final entries = await repository.fetchVocabulariesWithPaging(
      offset: offset,
      limit: limit,
      queryText: queryText,
      sorter: sortSetting,
    );

    // 実行ログ
    print(
      'DBから offset:$offset, limit:$limit, query:$queryText, sortField:${sortSetting.field.name}, sortOrder:${sortSetting.order.name} で ${entries.length} 件取得しました。',
    );

    return entries;
  }
}
