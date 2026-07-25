import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/usecase/delete_register_usecase.dart';
import 'package:edb/domain/usecase/save_register_usecase.dart';
import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/presentation/view_models/selected_token_notifier.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';
import 'package:edb/presentation/view_models/book_notifier.dart';
import 'package:edb/presentation/view_models/translation_notifier.dart';

final registerProvider =
    AsyncNotifierProvider.autoDispose<RegisterNotifier, CardData>(
      () => RegisterNotifier(),
    );

// 画面の状態を管理するRiverpod Notifier
class RegisterNotifier extends AsyncNotifier<CardData> {
  @override
  Future<CardData> build() async {
    final initialData = ref.watch(regiDataReceiver);
    return initialData;
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

    state = await AsyncValue.guard(() async {
      final selected = ref.read(selectedTokenProvider);
      final newToken = await ref
          .read(saveRegisterUseCaseProvider)
          .execute(card: data, token: selected);

      // オーケストレーション
      // 翻訳モードのトークン表示を更新
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);
      // 単語帳リストをリロード
      ref.read(bookProvider.notifier).reload();
      // データ受け渡し用のレシーバーを初期化
      ref.read(regiDataReceiver.notifier).initialCard();

      return data;
    });
  }

  Future<void> delete() async {
    final data = state.value;
    if (data == null || state.isLoading) return;

    // 既存のIDがない（新規作成中など）場合は削除処理の必要がない
    if (data.vocab.based != Based.vocabularies) return;

    // 処理中フラグ
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final selected = ref.read(selectedTokenProvider);
      final newToken = await ref
          .read(deleteRegisterUseCaseProvider)
          .execute(card: data, token: selected);

      // 翻訳モードの更新
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);
      // 単語帳の更新
      ref.read(bookProvider.notifier).reload();
      // レシーバーを初期状態に戻す
      ref.read(regiDataReceiver.notifier).initialCard();

      return data;
    });
  }

  // 内部のVocabEntryを更新するための共通ヘルパー
  void _updateVocab(VocabEntry Function(VocabEntry oldVocab) update) {
    final currentData = state.value;
    if (currentData == null) return;

    state = AsyncData(currentData.copyWith(vocab: update(currentData.vocab)));
  }
}
