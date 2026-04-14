import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/model/card_data.dart';

// RegistrationNotifierの初期状態を決めるハンドラの提供
final regiDataReceiver = NotifierProvider<RegiDataReceiver, CardData>(
  () => RegiDataReceiver(),
);

class RegiDataReceiver extends Notifier<CardData> {
  @override
  CardData build() {
    // 初期状態（空の状態）を定義
    return initialCard();
  }

  // 新規作成
  CardData initialCard({String word = ''}) {
    return CardData(vocab: VocabEntry.init(word: word));
  }

  // 単語帳
  void receiveRegisteredCard({required CardData card}) {
    state = card.copyWith(
      vocab: card.vocab.copyWith(updatedAt: DateTime.now()),
    );
  }

  // 内部辞書から受け取る
  void receiveDictionaryCard({required CardData card}) {
    state = CardData(vocab: card.vocab);
  }
}
