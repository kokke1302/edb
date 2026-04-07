import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/share/data/card_data.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/register/domain/regidata_receiver.dart';
import 'package:edb/register/domain/vocaburary_repository.dart';
import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/translation/domain/translation_notifier.dart';

final registrationProvider =
    AsyncNotifierProvider.autoDispose<RegistrationNotifier, CardData>(
      () => RegistrationNotifier(),
    );

// 画面の状態を管理するRiverpod Notifier
class RegistrationNotifier extends AsyncNotifier<CardData> {
  @override
  Future<CardData> build() async {
    return ref.read(regiDataReceiver);
  }

  // 内部のVocabEntryを更新するための共通ヘルパー
  void _updateVocab(VocabEntry Function(VocabEntry oldVocab) update) {
    final currentData = state.value;
    if (currentData == null) return;

    state = AsyncData(currentData.copyWith(vocab: update(currentData.vocab)));
  }

  void updateEnglish(String text) {
    _updateVocab((v) => v.copyWith(word: text));
  }

  void updateTranslation(String text) {
    _updateVocab((v) => v.copyWith(translation: text));
  }

  void updateMemo(String text) {
    _updateVocab((v) => v.copyWith(memo: text));
  }

  void toggleIsShowing(bool isShow) {
    _updateVocab((v) => v.copyWith(isShow: isShow));
  }

  // 入力値を検証し、Repository経由でデータベースに保存
  Future<void> save() async {
    final data = state.value;
    if (data == null || state.isLoading) return;

    // 入力バリデーション
    if (data.vocab.word.isEmpty || data.vocab.translation.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (data.vocab.based != Based.vocabularies) {
        // 新規保存
        await ref.read(vocabularyRepositoryProvider).addVocabulary(card: data);
      } else {
        // 更新
        await ref
            .read(vocabularyRepositoryProvider)
            .updateVocabulary(card: data);
      }

      // 単語帳の更新
      ref.read(wordListProvider.notifier).reload();
      // 翻訳モードの更新
      ref.read(translationProvider.notifier).pushTriggerButton();
      // 内部辞書の更新
      ref.invalidate(cardListProvider);
      // レシーバーを初期状態に戻す
      ref.read(regiDataReceiver.notifier).receiveNew();

      return data;
    });
  }

  Future<void> delete() async {
    final currentData = state.value;
    if (currentData == null || state.isLoading) return;

    // 既存のIDがない（新規作成中など）場合は削除処理の必要がない
    if (currentData.vocab.based != Based.vocabularies) return;

    // 処理中フラグ
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Repositoryを呼び出し、DBから単語を削除
      await ref
          .read(vocabularyRepositoryProvider)
          .deleteVocabulary(currentData.id);

      // 単語帳の更新
      ref.read(wordListProvider.notifier).reload();
      // 翻訳モードの更新
      ref.read(translationProvider.notifier).pushTriggerButton();
      // 内部辞書の更新
      ref.invalidate(cardListProvider);
      // レシーバーを初期状態に戻す
      ref.read(regiDataReceiver.notifier).receiveNew();

      return currentData;
    });
  }
}
