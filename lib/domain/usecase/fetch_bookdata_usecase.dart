import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/value_object/sorting_data.dart';
import 'package:edb/domain/repository_abstract/book_repository.dart';

final fetchBookDataUseCaseProvider = Provider(
  (ref) => FetchBookDataUseCase(ref.watch(bookRepositoryProvider)),
);

class FetchBookDataUseCase {
  final BookRepository _repository;
  FetchBookDataUseCase(this._repository);

  Future<List<VocabCore>> execute({
    required int currentCount,
    required SortingData sorter,
  }) async {
    return await _repository.fetchVocabulariesWithPaging(
      offset: currentCount,
      sorter: sorter,
    );
  }
}
