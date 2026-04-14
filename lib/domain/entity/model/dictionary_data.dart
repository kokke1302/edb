import 'package:edb/domain/entity/model/card_data.dart';

// 単語カードと順番を保持するクラス
class DictionaryData {
  final CardData? showCard;
  final List<CardData> vocabularyCards;
  final List<CardData> dictionaryCards;

  DictionaryData({
    this.showCard,
    this.vocabularyCards = const [],
    this.dictionaryCards = const [],
  });

  // 状態の一部を更新するためのメソッド
  DictionaryData copyWith({
    CardData? showCard,
    List<CardData>? vocabularyCards,
    List<CardData>? dictionaryCards,
  }) {
    return DictionaryData(
      showCard: showCard,
      vocabularyCards: vocabularyCards ?? this.vocabularyCards,
      dictionaryCards: dictionaryCards ?? this.dictionaryCards,
    );
  }
}
