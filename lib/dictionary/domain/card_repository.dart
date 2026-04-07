import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CardRepository(db);
});

class CardRepository {
  final AppDatabase db;
  CardRepository(this.db);

  // ===============================================
  // R: Read (特定の単語に対する単語帳エントリ)
  // ===============================================

  // 単語帳（Vocabularies）から特定の英単語に対応する訳語を取得し、VocabEntryのリストとして返す
  Future<List<Vocabulary>> fetchVocabularyEntries(String englishWord) async {
    try {
      final query = db.select(db.vocabularies)
        ..where((v) => v.englishWord.lower().equals(englishWord.toLowerCase()));

      return await query.get();
    } catch (e) {
      throw Exception('Failed to read vocabularies: $e');
    }
  }

  // ===============================================
  // R: Read (特定の単語に対する内部辞書エントリ)
  // ===============================================

  // 内部辞書（InternalDictionaries）から特定の単語に対応する訳語を取得し、VocabEntryのリストとして返す
  Future<List<InternalDictionary>> fetchDictionaryEntries(
    String wordKey,
  ) async {
    try {
      final query = db.select(db.internalDictionaries)
        ..where((d) => d.key.lower().equals(wordKey.toLowerCase()));

      return await query.get();
    } catch (e) {
      throw Exception('Failed to read vocabularies: $e');
    }
  }
}
