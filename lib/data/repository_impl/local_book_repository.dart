import 'package:drift/drift.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/vocab_mapper.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/sort_field.dart';
import 'package:edb/domain/entity/value/sort_order.dart';
import 'package:edb/domain/repository_abstract/book_repository.dart';

class LocalBookRepository implements BookRepository {
  final AppDatabase db;
  LocalBookRepository(this.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  // 検索キーワードとページングを適用して単語リストを取得する
  @override
  Future<List<VocabEntry>> fetchVocabulariesWithPaging({
    required int offset,
    required SortingData sorter,
  }) async {
    try {
      // クエリの開始
      final query = db.select(db.vocabularies);

      // フィルタリング条件の動的適用
      if (sorter.searchWord.isNotEmpty) {
        final likeArgument = '%${sorter.searchWord}%';
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
      query.limit(sorter.pageSize, offset: offset);

      final rows = await query.get();

      // データの取得を実行
      return rows
          .map((row) => VocabMapper.fromVocabularies(vocabulary: row))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch paging vocabularies: $e');
    }
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
