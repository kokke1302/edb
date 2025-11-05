import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/db/vocaburary_repository.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CardRepository(db);
});

class CardRepository extends VocabularyRepository {
  CardRepository(super.db);

  // ===============================================
  // R: Read ()
  // ===============================================
  Future<List<Vocabulary>> fetchTranslationsBatch(
    Set<String> lookupKeys,
  ) async {
    final query = db.select(db.vocabularies)
      ..where((v) {
        return v.englishWord.isIn(lookupKeys);
      });

    // 必要なカラムのみを選択的に取得（パフォーマンス改善）
    return await query.get();
  }
}
