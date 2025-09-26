import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'state/sort_setting.dart';

class VocabularyRepository {
  // 💡 コンストラクタでAppDatabaseを受け取る
  final AppDatabase _db;
  VocabularyRepository(this._db);

  // ===============================================
  // C: Create (単語の挿入)
  // ===============================================

  // 新しく挿入された単語データを返す
  Future<Vocabulary> addVocabulary({
    required String title,
    String? memo,
  }) async {
    // VocabularyCompanion: 仮で行を作る
    final companion = VocabulariesCompanion.insert(
      title: title,
      memo: Value(memo), // Value(): null対策
      // createdAt: デフォルト値 currentDayAndTime を使用するため、指定不要
    );

    // 仮の行を実際に挿入し、挿入された場所のIDを受け取る
    final id = await _db.into(_db.vocabularies).insert(companion);

    // そのIDを使って、挿入後の完全なデータを取得し返す
    final query = _db.select(_db.vocabularies)..where((v) => v.id.equals(id));
    return query.getSingle();
  }

  // ===============================================
  // U: Update (単語の更新)
  // ===============================================

  // 更新された行の数を返す
  Future<int> updateVocabulary({required int id, String? title, String? memo}) {
    // 更新したい行のidを探す
    final query = _db.update(_db.vocabularies)..where((v) => v.id.equals(id));

    // どう変更するか
    final companion = VocabulariesCompanion(
      id: Value.absent(),
      title: title != null ? Value(title) : const Value.absent(),
      memo: memo != null ? Value(memo) : const Value.absent(),
    );

    // 上書き
    return query.write(companion);
  }

  // ===============================================
  // D: Delete (単語の削除)
  // ===============================================

  // 消去された行の数を返す
  Future<int> deleteVocabulary(int id) {
    // 削除したい行のidを探す
    final query = _db.delete(_db.vocabularies)..where((v) => v.id.equals(id));
    // 実行
    return query.go();
  }

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
    final query = _db.select(_db.vocabularies);

    // フィルタリング条件の動的適用
    if (queryText.isNotEmpty) {
      final likeArgument = '%$queryText%';
      query.where(
        (v) => v.title.like(likeArgument) | v.memo.like(likeArgument),
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
        return _db.vocabularies.createdAt;
      case SortField.title:
        return _db.vocabularies.title;
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
