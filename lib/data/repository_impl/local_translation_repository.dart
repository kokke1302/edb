import 'package:drift/drift.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/repository_abstract/transelation_repository.dart';

// 一括で単語の訳語を取得する
class LocalTranslationRepository implements TranslationRepository {
  final AppDatabase db;
  LocalTranslationRepository(this.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  @override
  Future<List<({int id, String word, bool isShow})>> fetchTranslationsBatch(
    Set<String> lookupKeys,
  ) async {
    if (lookupKeys.isEmpty) return [];

    try {
      // englishWord が lookupKeys に含まれているか
      final query = db.select(db.vocabularies)
        ..where((v) => v.englishWord.lower().isIn(lookupKeys));

      final rows = await query.get();

      return rows
          .map((v) => (id: v.id, word: v.englishWord, isShow: !v.isHidden))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch translations batch: $e');
    }
  }
}
