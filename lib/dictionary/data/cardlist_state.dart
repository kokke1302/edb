import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/share/data/card_data.dart';

/// 単語カードと順番を保持するクラス
class CardListState {
  final CardData? showWord;
  final List<CardData> vocabularyWords;
  final List<VocabEntry> dictionaryWords;

  CardListState({
    this.showWord,
    this.vocabularyWords = const [],
    this.dictionaryWords = const [],
  });

  /// 状態の一部を更新するためのメソッド
  CardListState copyWith({
    required CardData? showWord,
    List<CardData>? vocabularyWords,
    List<VocabEntry>? dictionaryWords,
  }) {
    return CardListState(
      showWord: showWord,
      vocabularyWords: vocabularyWords ?? this.vocabularyWords,
      dictionaryWords: dictionaryWords ?? this.dictionaryWords,
    );
  }
}
