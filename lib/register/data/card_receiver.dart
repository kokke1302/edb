import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';

// 検索キーワードの状態を管理する Provider
final cardReceiver = NotifierProvider<CardReceiver, ReceivedData>(
  () => CardReceiver(),
);

class ReceivedData {
  final CardEntry card;
  final String englishWord;
  ReceivedData({required this.card, required this.englishWord});
}

// 確定済みの検索クエリを管理する Notifier
class CardReceiver extends Notifier<ReceivedData> {
  @override
  ReceivedData build() {
    return ReceivedData(
      card: CardEntry(
        id: -1,
        translation: '',
        isShow: false,
        nowShow: false,
        memo: '',
        based: Based.init,
      ),
      englishWord: '',
    );
  }

  void receiveCard({required CardEntry newCard, required String newWord}) {
    // 変わっていなければ何もしない
    if (state.card == newCard && state.englishWord == newWord) return;
    state = ReceivedData(card: newCard, englishWord: newWord);
  }
}
