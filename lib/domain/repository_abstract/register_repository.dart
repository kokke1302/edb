import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_register_repository.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalRegisterRepository(db);
});

abstract interface class RegisterRepository {
  Future<VocabCore> addVocabulary({required VocabCore vocab});
  Future<VocabCore> updateVocabulary({required VocabCore vocab});
  Future<void> deleteVocabulary({required int id});
}
