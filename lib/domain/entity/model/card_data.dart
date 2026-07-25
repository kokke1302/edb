import 'package:edb/domain/entity/carry/vocab_entry.dart';

class CardData {
  final bool nowShow;
  final VocabEntry vocab;
  // VocabEntry: (id, word, translation, isShow, memo, createdAt, updatedAt, based)

  CardData({required this.nowShow, required this.vocab});

  // 訳語を変更
  CardData copyWith({bool? nowShow, VocabEntry? vocab}) {
    return CardData(
      nowShow: nowShow ?? this.nowShow,
      vocab: vocab ?? this.vocab,
    );
  }

  factory CardData.init({String word = ''}) {
    final ve = VocabEntry.init(word: word);
    return CardData(nowShow: ve.isShow, vocab: ve);
  }

  factory CardData.fromVocabEntry({required VocabEntry ve}) {
    return CardData(nowShow: ve.isShow, vocab: ve);
  }
}
