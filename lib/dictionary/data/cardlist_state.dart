import 'package:edb/dictionary/data/card_state.dart';

/// 単語カードと順番を保持するクラス
class CardListState {
  final CardEntry? showWord;
  final List<CardEntry> vocabularyWords;
  final List<CardEntry> dictionaryWords;

  CardListState({
    this.showWord,
    this.vocabularyWords = const [],
    this.dictionaryWords = const [],
  });

  /// 状態の一部を更新するためのメソッド
  CardListState copyWith({
    required CardEntry? showWord,
    List<CardEntry>? vocabularyWords,
    List<CardEntry>? dictionaryWords,
  }) {
    return CardListState(
      showWord: showWord,
      vocabularyWords: vocabularyWords ?? this.vocabularyWords,
      dictionaryWords: dictionaryWords ?? this.dictionaryWords,
    );
  }
}
