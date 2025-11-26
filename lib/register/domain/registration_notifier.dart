import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/register/data/card_receiver.dart';
import 'package:edb/register/data/registration_state.dart';
import 'package:edb/register/domain/vocaburary_repository.dart';

final registrationProvider =
    NotifierProvider.autoDispose<RegistrationNotifier, RegistrationState>(
      () => RegistrationNotifier(),
    );

// 画面の状態を管理するRiverpod Notifier
class RegistrationNotifier extends Notifier<RegistrationState> {
  @override
  RegistrationState build() {
    final cardData = ref.watch(cardReceiver);

    final id = cardData.card.based == Based.vocabularies
        ? cardData.card.id
        : -1;

    return RegistrationState(
      englishWord: cardData.englishWord,
      japaneseTranslation: cardData.card.translation,
      memo: cardData.card.memo,
      isHidden: !cardData.card.isShow,
      existingVocId: id,
      isProcessing: false,
    );
  }

  void updateEnglish(String text) {
    state = state.copyWith(englishWord: text);
  }

  void updateTranslation(String text) {
    state = state.copyWith(japaneseTranslation: text);
  }

  void updateMemo(String text) {
    state = state.copyWith(memo: text);
  }

  // 訳語の表示設定を切り替える
  void toggleIsShowing(bool isHidden) {
    state = state.copyWith(isHidden: isHidden);
  }

  // 入力値を検証し、Repository経由でデータベースに保存
  Future<void> save() async {
    // 1. 入力値検証
    final bool isSaveEnabled =
        // 処理中ではない
        state.isProcessing ||
        // 日本語訳が空ではない
        state.japaneseTranslation.isEmpty ||
        // 新規登録時は英単語の入力は必須
        (state.existingVocId < 0 && state.englishWord.isEmpty);
    if (isSaveEnabled) return;

    // 2. 処理中フラグON
    state = state.copyWith(isProcessing: true);

    try {
      // 3. Repositoryを呼び出し、DBへの保存と排他制御を実行
      if (state.existingVocId == -1) {
        await ref
            .read(vocabularyRepositoryProvider)
            .addVocabulary(state: state);
      } else {
        await ref
            .read(vocabularyRepositoryProvider)
            .updateVocabulary(state: state);
      }
    } catch (e) {
      // 4. エラーハンドリング (例: ログ出力、ユーザーへの通知)
      print('単語帳の保存中にエラーが発生しました: $e');
    } finally {
      // 5. 処理中フラグOFF
      state = state.copyWith(isProcessing: false);
      ref.read(translationProvider.notifier).pushTriggerButton();
      ref.invalidate(cardListProvider);
    }
  }

  Future<void> delete() async {
    // 1. 既存のIDがない場合は処理しない
    if (state.existingVocId == -1) return;

    // 2. 処理中フラグON
    state = state.copyWith(isProcessing: true);

    try {
      // 3. Repositoryを呼び出し、DBから単語を削除
      await ref
          .read(vocabularyRepositoryProvider)
          .deleteVocabulary(state.existingVocId);
    } catch (e) {
      // 4. エラーハンドリング (例: ログ出力、ユーザーへの通知)
      print('単語帳の削除中にエラーが発生しました: $e');
    } finally {
      // 5. 処理中フラグOFF
      state = state.copyWith(isProcessing: false);
      ref.read(translationProvider.notifier).pushTriggerButton();
      ref.invalidate(cardListProvider);
    }
  }
}
