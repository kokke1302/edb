import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/wordbook/data/sort_setting.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final listRepositoryProvider = Provider<ListRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ListRepository(db);
});

class ListRepository {
  final AppDatabase db;
  ListRepository(this.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  /// 検索キーワードとページングを適用して単語リストを取得する
  Future<List<Vocabulary>> fetchVocabulariesWithPaging({
    required int offset,
    required int limit,
    required String queryText,
    required SortSetting sorter,
  }) async {
    // クエリの開始
    final query = db.select(db.vocabularies);

    // フィルタリング条件の動的適用
    if (queryText.isNotEmpty) {
      final likeArgument = '%$queryText%';
      query.where(
        (v) =>
            v.englishWord.like(likeArgument) |
            v.japaneseTranslation.like(likeArgument) |
            v.memo.like(likeArgument),
      );
    }

    // ソート条件の動的適用
    final expression = _getSortExpression(sorter.field);
    final mode = _getSortMode(sorter.order);
    query.orderBy([(v) => OrderingTerm(expression: expression, mode: mode)]);

    // ページング条件の適用
    query.limit(limit, offset: offset);

    // データの取得を実行
    return query.get();
  }

  Expression _getSortExpression(SortField field) {
    switch (field) {
      case SortField.createdAt:
        return db.vocabularies.createdAt;
      case SortField.englishWord:
        return db.vocabularies.englishWord;
    }
  }

  OrderingMode _getSortMode(SortOrder order) {
    switch (order) {
      case SortOrder.desc:
        return OrderingMode.desc;
      case SortOrder.asc:
        return OrderingMode.asc;
    }
  }
}
