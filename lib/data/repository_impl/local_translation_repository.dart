import 'package:drift/drift.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/token_mapper.dart';
import 'package:edb/domain/entity/carry/token_entry.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';

// 一括で単語の訳語を取得する
class LocalTranslationRepository implements TranslationRepository {
  final AppDatabase db;
  LocalTranslationRepository(this.db);

  // ===============================================
  // R: Read (ページングとフィルタリング)
  // ===============================================
  @override
  Future<List<TokenEntry>> fetchTranslationsBatch({
    required Set<String> keys,
  }) async {
    if (keys.isEmpty) return [];

    final lowerKeys = keys.map((k) => k.toLowerCase()).toSet();

    try {
      final query = db.select(db.vocabularies)
        ..where(
          (v) =>
              // englishWord が lookupKeys に含まれているか
              v.englishWord.lower().isIn(lowerKeys) &
              // isHidden: true は return させない
              v.isHidden.equals(false),
        );

      final rows = await query.get();

      return rows.map((v) => TokenMapper.fromVocabularies(voc: v)).toList();
    } catch (e) {
      throw Exception('Failed to fetch translations batch: $e');
    }
  }
}
