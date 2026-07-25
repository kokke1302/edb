import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/repository_abstract/book_repository.dart';

final fetchBookDataUseCaseProvider = Provider(
  (ref) => FetchBookDataUseCase(ref.watch(bookRepositoryProvider)),
);

class FetchBookDataUseCase {
  final BookRepository _repository;
  FetchBookDataUseCase(this._repository);

  Future<List<CardData>> execute({
    required int currentCount,
    required SortingData sorter,
  }) async {
    final vocabs = await _repository.fetchVocabulariesWithPaging(
      offset: currentCount,
      sorter: sorter,
    );

    return vocabs.map((vocab) => CardData.fromVocabEntry(ve: vocab)).toList();
  }
}
