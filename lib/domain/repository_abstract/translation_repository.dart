import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/domain/model/value_object/token_core.dart';
import 'package:edb/data/repository_impl/local_translation_repository.dart';

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalTranslationRepository(db);
});

abstract interface class TranslationRepository {
  Future<List<TokenCore>> fetchTranslationsBatch({required Set<String> keys});
}
