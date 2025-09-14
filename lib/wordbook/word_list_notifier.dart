import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_helper.dart';

class WordEntry {
  final int id;
  final String title;
  final String memo;

  const WordEntry({required this.id, required this.title, required this.memo});
}

// 全てのデータがロードされたかどうかを示す StateProvider
class IsDataEndNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setDataEnd() {
    state = true;
  }

  void resetDataEnd() {
    state = false;
  }
}

final isDataEndProvider = NotifierProvider<IsDataEndNotifier, bool>(
  () => IsDataEndNotifier(),
);

class LastErrorNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void nowError() {
    state = true;
  }

  void nowNonError() {
    state = false;
  }
}

final lastErrorProvider = NotifierProvider<LastErrorNotifier, bool>(
  () => LastErrorNotifier(),
);

class WordListNotifier extends AsyncNotifier<List<WordEntry>> {
  final int _pageSize = 20; // 1ページあたりの件数

  // 状態の初期化
  @override
  Future<List<WordEntry>> build() async {
    // 起動時に最初のデータを非同期でロード
    // この処理が完了するまで、UI側では自動的に Loading 状態になる
    return _fetchData(offset: 0, limit: _pageSize);
  }

  // 次のページをロードするメソッド
  Future<void> loadNextPage() async {
    // ロード中の重複呼び出しを避けるための処理
    if (state.isLoading || ref.read(isDataEndProvider)) return;
    ref.read(lastErrorProvider.notifier).nowNonError();

    final currentList = state.value ?? [];

    // UIにローディング中であることを伝える
    state = const AsyncValue.loading();

    try {
      // データの取得を待機
      final newEntries = await _fetchData(
        offset: currentList.length,
        limit: _pageSize,
      );

      // 🚩 データ終端の判定と状態更新
      if (newEntries.isEmpty) {
        ref.read(isDataEndProvider.notifier).setDataEnd();
      }

      // 既存のリストと新しいリストを結合し、AsyncDataで状態を更新
      state = AsyncData([...currentList, ...newEntries]);
    } catch (e, stack) {
      // エラーが発生した場合、UIにエラーを伝える
      ref.read(lastErrorProvider.notifier).nowError();
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    // リフレッシュ中は現在の状態をAsyncLoadingで置き換え
    state = const AsyncValue.loading();

    // エラーとデータ終端の状態をリセット
    ref.read(lastErrorProvider.notifier).nowNonError();
    ref.read(isDataEndProvider.notifier).resetDataEnd();

    // 最初のページを再取得
    state = await AsyncValue.guard(
      () => _fetchData(offset: 0, limit: _pageSize),
    );
  }

  // 非同期データ取得関数
  Future<List<WordEntry>> _fetchData({
    required int offset,
    required int limit,
  }) async {
    // データベースアクセス/ネットワーク遅延をシミュレート (デバッグ用に残しても良い)
    await Future.delayed(const Duration(milliseconds: 1000));

    // 🚩 3. デバッグ用のエラー発生コード
    // if (offset > 30) {
    //   throw Exception('デバッグ用エラー');
    // }

    // DatabaseHelper の fetchWordEntries メソッドを呼び出す
    final entries = await DatabaseHelper.instance.fetchWordEntries(
      offset: offset,
      limit: limit,
    );

    // 実際に取得した件数をコンソールに出力
    print('DBから offset:$offset, limit:$limit で ${entries.length} 件取得しました。');

    return entries;
  }
}

// Provider を定義
final wordListProvider =
    AsyncNotifierProvider<WordListNotifier, List<WordEntry>>(
      () => WordListNotifier(),
    );
