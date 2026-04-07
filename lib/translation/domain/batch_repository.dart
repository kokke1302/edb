import 'package:drift/drift.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/translation/data/dbsourse_switch.dart';

// 一括で単語の訳語を取得する
class LocalBatchRepository implements TranslationDBSource {
  final AppDatabase db;
  LocalBatchRepository(this.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  @override
  Future<List<Vocabulary>> fetchTranslationsBatch(
    Set<String> lookupKeys,
  ) async {
    if (lookupKeys.isEmpty) return [];

    try {
      final query = db.select(db.vocabularies)
        // englishWord が lookupKeys に含まれている
        ..where((v) => v.englishWord.lower().isIn(lookupKeys));

      return await query.get();
    } catch (e) {
      throw Exception('Failed to fetch translations batch: $e');
    }
  }
}
