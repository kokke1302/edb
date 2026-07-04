import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_book_repository.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalBookRepository(db);
});

abstract interface class BookRepository {
  Future<List<VocabEntry>> fetchVocabulariesWithPaging({
    required int offset,
    required SortingData sorter,
  });
}
