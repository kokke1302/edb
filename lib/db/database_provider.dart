import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import '../wordbook/list_repository.dart';

// AppDatabaseのインスタンスを提供する
// シングルトンのような振る舞いをする
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// VocabularyRepositoryのインスタンスを提供する
// すべてのビジネスロジック（CRUD, ページング）を担当する
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyRepository(db);
});
