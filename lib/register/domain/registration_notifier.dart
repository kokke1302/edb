import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/register/data/registration_state.dart';
import 'package:edb/register/domain/vocaburary_repository.dart';

NotifierProvider<RegistrationNotifier, RegistrationState> registrationProvider({
  required String initialEnglishWord,
  CardEntry? existingState,
}) {
  return NotifierProvider<RegistrationNotifier, RegistrationState>(
    () => RegistrationNotifier(
      targetWord: initialEnglishWord,
      cardState: existingState,
    ),
  );
}

// 画面の状態を管理するRiverpod Notifier
class RegistrationNotifier extends Notifier<RegistrationState> {
  final String targetWord;
  final CardEntry? cardState;
  RegistrationNotifier({required this.targetWord, required this.cardState});

  @override
  RegistrationState build() {
    if (cardState == null) {
      return RegistrationState(
        englishWord: targetWord,
        japaneseTranslation: '',
        memo: '',
        isHidden: false,
        existingVocId: -1,
        isProcessing: false,
      );
    } else {
      return RegistrationState(
        englishWord: targetWord,
        japaneseTranslation: cardState!.translation,
        memo: cardState!.memo,
        isHidden: !cardState!.isShow,
        existingVocId: cardState!.id < 0 ? -1 : cardState!.id,
        isProcessing: false,
      );
    }
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

  // 責務: 訳語の表示設定を切り替える
  void toggleIsShowing(bool isHidden) {
    state = state.copyWith(isHidden: isHidden);
  }

  // 責務: 入力値を検証し、Repository経由でデータベースに保存する
  Future<void> save() async {
    // 1. 入力値検証 (例: 必須項目チェック)
    if (state.japaneseTranslation.isEmpty) {
      // エラー処理 (例: SnackBar表示)
      return;
    }

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
    }
  }
}
