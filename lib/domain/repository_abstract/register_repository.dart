import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_register_repository.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalRegisterRepository(db);
});

abstract interface class RegisterRepository {
  Future<VocabEntry> addVocabulary({required VocabEntry vocab});
  Future<VocabEntry> updateVocabulary({required VocabEntry vocab});
  Future<void> deleteVocabulary({required int id});
}
