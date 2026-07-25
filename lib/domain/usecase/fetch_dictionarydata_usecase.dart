import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/dictionary_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/repository_abstract/dictionary_repository.dart';

final fetchDictionaryDataUseCaseProvider = Provider(
  (ref) => FetchDictionaryDataUseCase(ref.watch(dictionaryRepositoryProvider)),
);

class FetchDictionaryDataUseCase {
  final DictionaryRepository _repository;
  FetchDictionaryDataUseCase(this._repository);

  Future<DictionaryData> execute(TokenData token) async {
    // 1. データ取得
    final vocabularyWords = await _repository.fetchVocabularies(
      word: token.word,
    );
    final dictionaryWords = await _repository.fetchDictionaries(
      word: token.word,
    );

    // 2. マッピング
    final allCardData = vocabularyWords
        .map((ve) => CardData.fromVocabEntry(ve: ve))
        .toList();
    final dictionaryCards = dictionaryWords
        .map((ve) => CardData.fromVocabEntry(ve: ve))
        .toList();

    // 3. 表示・非表示の振り分けロジック
    CardData? showCard;
    final List<CardData> vocabularyCards = [];

    for (var card in allCardData) {
      if (token.nowShow && card.vocab.id == token.vocabId) {
        // 単語帳登録済単語　かつ　nowShow = true　が存在
        showCard = card.copyWith(nowShow: true);
      } else {
        // 単語帳未登録単語　または　nowShow = false　または　例外
        vocabularyCards.add(card.copyWith(nowShow: false));
      }
    }

    return DictionaryData(
      showCard: showCard,
      vocabularyCards: vocabularyCards,
      dictionaryCards: dictionaryCards,
    );
  }
}
