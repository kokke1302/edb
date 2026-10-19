import 'package:edb/domain/model/value_object/vocab_core.dart';

class CardData {
  final bool nowShow;
  final VocabCore vocab;
  // VocabCore: (id, word, translation, isShow, memo, createdAt, updatedAt, based)

  CardData({required this.nowShow, required this.vocab});

  // 訳語を変更
  CardData copyWith({bool? nowShow, VocabCore? vocab}) {
    return CardData(
      nowShow: nowShow ?? this.nowShow,
      vocab: vocab ?? this.vocab,
    );
  }
}
