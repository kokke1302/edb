import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/share/data/card_data.dart';

// RegistrationNotifierの初期状態を決めるハンドラの提供
final regiDataReceiver = NotifierProvider<RegiDataReceiver, CardData>(
  () => RegiDataReceiver(),
);

class RegiDataReceiver extends Notifier<CardData> {
  @override
  CardData build() {
    // 初期状態（空の状態）を定義
    return _initialCard();
  }

  CardData _initialCard({String word = ''}) {
    return CardData.fromIntt(word: word);
  }

  void receiveRegisteredCard({required CardData card}) {
    state = card.copyWith(updatedAt: DateTime.now());
  }

  // 辞書データから受け取る
  void receiveDictionaryCard({required VocabEntry ve}) {
    state = CardData.fromDctionaries(ve: ve);
  }

  // 新規作成
  void receiveNew({String word = ''}) {
    state = _initialCard(word: word);
  }
}
