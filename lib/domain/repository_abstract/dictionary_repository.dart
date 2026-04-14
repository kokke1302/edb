import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_dictionary_repository.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalDictionaryRepository(db);
});

abstract interface class DictionaryRepository {
  Future<List<VocabEntry>> fetchVocabularies({required String word});
  Future<List<VocabEntry>> fetchDictionaries({required String word});
}
