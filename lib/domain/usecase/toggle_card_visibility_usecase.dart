import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/dictionary_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';

final toggleCardVisibilityUseCaseProvider = Provider((ref) {
  return ToggleCardVisibilityUseCase();
});

class ToggleCardVisibilityUseCase {
  // 現在のデータ状態と対象カードを受け取り、新しい DictionaryData と 更新後の VocabEntry を返す
  (DictionaryData, TokenData) execute({
    required DictionaryData currentData,
    required CardData targetCard,
    required TokenData currentToken,
  }) {
    CardData? newShowCard = currentData.showCard;
    List<CardData> newVocabularyCards = List.from(currentData.vocabularyCards);
    TokenData newToken;

    // showCardが選択された場合 -> 非表示にする
    if (newShowCard != null && targetCard.vocab.id == newShowCard.vocab.id) {
      final deactivatedCard = targetCard.copyWith(nowShow: false);

      newShowCard = null;
      newVocabularyCards.add(deactivatedCard);
      newToken = currentToken.copyWith(nowShow: false);
    }
    // リスト内のカードが選ばれた場合 -> 表示する
    else {
      // リストのどこにあるかを特定
      final index = newVocabularyCards.indexWhere(
        (c) => c.vocab.id == targetCard.vocab.id,
      );
      if (index == -1) return (currentData, currentToken);

      // リストから消去
      final target = newVocabularyCards.removeAt(index);

      // showWordが存在する場合はリストに戻す
      if (currentData.showCard != null) {
        newVocabularyCards.add(currentData.showCard!.copyWith(nowShow: false));
      }

      // showWordに投入
      newShowCard = target.copyWith(nowShow: true);
      newToken = currentToken.copyWith(
        nowShow: true,
        vocabId: targetCard.vocab.id,
        translation: targetCard.vocab.translation,
      );
    }

    final newDictionaryData = currentData.copyWith(
      showCard: newShowCard,
      vocabularyCards: newVocabularyCards,
    );

    return (newDictionaryData, newToken);
  }
}
