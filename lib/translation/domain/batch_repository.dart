import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/db/vocaburary_repository.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BatchRepository(db);
});

// 一括で単語の訳語を取得する
class BatchRepository extends VocabularyRepository {
  BatchRepository(super.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  Future<List<Vocabulary>> fetchTranslationsBatch(
    Set<String> lookupKeys,
  ) async {
    final query = db.select(db.vocabularies)
      // englishWord が lookupKeys に含まれている
      ..where((v) => v.englishWord.isIn(lookupKeys));
    return await query.get();
  }
}
