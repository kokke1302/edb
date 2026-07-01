import 'package:edb/domain/entity/carry/vocab_entry.dart';

class CardData {
  final bool nowShow;
  final VocabEntry vocab;
  // (id, word, translation, isShow, nowShow, memo, createdAt, updatedAt, based)

  CardData({bool? nowShow, required this.vocab})
    : nowShow = nowShow ?? vocab.isShow;

  // 訳語を変更
  CardData copyWith({bool? nowShow, VocabEntry? vocab}) {
    return CardData(
      nowShow: nowShow ?? this.nowShow,
      vocab: vocab ?? this.vocab,
    );
  }

  static CardData fromVocabEntry({required VocabEntry ve}) {
    return CardData(vocab: ve);
  }
}
