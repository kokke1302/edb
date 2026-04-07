import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/translation/domain/batch_repository.dart';
import 'package:edb/translation/domain/text_processor.dart';

abstract interface class TranslationDBSource {
  Future<List<Vocabulary>> fetchTranslationsBatch(Set<String> keys);
}

// 依存関係注入のためのProvider
final textProcessorProvider = Provider((ref) {
  final dataSource = ref.watch(localBatchRepositoryProvider);
  return TextProcessor(dataSource);
});

final localBatchRepositoryProvider = Provider<LocalBatchRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalBatchRepository(db);
});
