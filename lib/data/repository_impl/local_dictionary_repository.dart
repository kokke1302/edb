import 'package:drift/drift.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/vocab_mapper.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/repository_abstract/dictionary_repository.dart';

class LocalDictionaryRepository implements DictionaryRepository {
  final AppDatabase db;
  LocalDictionaryRepository(this.db);

  // ===============================================
  // R: Read (特定の単語に対する単語帳エントリ)
  // ===============================================
  // 単語帳（Vocabularies）から特定の英単語に対応する訳語を取得
  @override
  Future<List<VocabEntry>> fetchVocabularies({required String word}) async {
    try {
      final query = db.select(db.vocabularies)
        ..where((v) => v.englishWord.lower().equals(word.toLowerCase()));

      final rows = await query.get();

      return rows
          .map((row) => VocabMapper.fromVocabularies(vocabulary: row))
          .toList();
    } catch (e) {
      throw Exception('Failed to read vocabularies: $e');
    }
  }

  // ===============================================
  // R: Read (特定の単語に対する内部辞書エントリ)
  // ===============================================
  // 内部辞書（InternalDictionaries）から特定の単語に対応する訳語を取得
  @override
  Future<List<VocabEntry>> fetchDictionaries({required String word}) async {
    try {
      final query = db.select(db.internalDictionaries)
        ..where((d) => d.key.lower().equals(word.toLowerCase()));

      final rows = await query.get();

      return rows
          .map((row) => VocabMapper.fromDictionary(dictionary: row))
          .toList();
    } catch (e) {
      throw Exception('Failed to read vocabularies: $e');
    }
  }
}
