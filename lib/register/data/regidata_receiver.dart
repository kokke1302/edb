import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/register/data/registration_state.dart';

// 検索キーワードの状態を管理する Provider
final regiDataReceiver = NotifierProvider<RegiDataReceiver, RegistrationState>(
  () => RegiDataReceiver(),
);

// 確定済みの検索クエリを管理する Notifier
class RegiDataReceiver extends Notifier<RegistrationState> {
  @override
  RegistrationState build() {
    return RegistrationState(
      id: -1,
      englishWord: '',
      japaneseTranslation: '',
      isHidden: true,
      memo: '',
      based: Based.init,
      isProcessing: false,
    );
  }

  void receiveCard({required CardEntry card}) {
    state = RegistrationState(
      id: card.id,
      englishWord: card.word,
      japaneseTranslation: card.translation,
      isHidden: !card.isShow,
      memo: card.memo,
      based: card.based,
      isProcessing: false,
    );
  }

  void receiveList({required Vocabulary entry}) {
    state = RegistrationState(
      id: entry.id,
      englishWord: entry.englishWord,
      japaneseTranslation: entry.japaneseTranslation,
      isHidden: entry.isHidden,
      memo: entry.memo,
      based: Based.vocabularies,
      isProcessing: false,
    );
  }

  void reciveOriginal({required String englishWord}) {
    state = RegistrationState(
      id: -1,
      englishWord: englishWord,
      japaneseTranslation: "",
      isHidden: false,
      memo: "",
      based: Based.init,
      isProcessing: false,
    );
  }

  void reciveNew() {
    state = RegistrationState(
      id: -1,
      englishWord: "",
      japaneseTranslation: "",
      isHidden: false,
      memo: "",
      based: Based.init,
      isProcessing: false,
    );
  }
}
