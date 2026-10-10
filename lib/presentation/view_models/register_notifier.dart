import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/usecase/delete_register_usecase.dart';
import 'package:edb/domain/usecase/save_register_usecase.dart';
import 'package:edb/domain/model/enum/base_status.dart';
import 'package:edb/presentation/view_models/selected_token_notifier.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';
import 'package:edb/presentation/view_models/book_notifier.dart';
import 'package:edb/presentation/view_models/translation_notifier.dart';

part 'register_notifier.g.dart';

// 画面の状態を管理するRiverpod

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  Future<VocabCore> build() async {
    return await ref.watch(regiDataReceiver);
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
    final vocab = state.requireValue;
    if (state.isLoading) return;
    // 入力バリデーション
    if (vocab.word.isEmpty || vocab.translation.isEmpty) return;

    state = await AsyncValue.guard(() async {
      final selected = ref.read(selectedTokenProvider);
      final newToken = await ref
          .read(saveRegisterUseCaseProvider)
          .execute(vocab: vocab, token: selected);

      // オーケストレーション
      // 翻訳モードのトークン表示を更新
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);
      // 単語帳リストをリロード
      ref.read(bookProvider.notifier).reload();
      // データ受け渡し用のレシーバーを初期化
      ref.invalidate(regiDataReceiver);

      return vocab;
    });
  }

  Future<void> delete() async {
    final vocab = state.requireValue;
    if (state.isLoading) return;

    // 既存のIDがない（新規作成中など）場合は削除処理の必要がない
    if (vocab.based != Based.vocabularies) return;

    // 処理中フラグ
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final selected = ref.read(selectedTokenProvider);
      final newToken = await ref
          .read(deleteRegisterUseCaseProvider)
          .execute(vocab: vocab, token: selected);

      // 翻訳モードの更新
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);
      // 単語帳の更新
      ref.read(bookProvider.notifier).reload();
      // レシーバーを初期状態に戻す
      ref.invalidate(regiDataReceiver);

      return vocab;
    });
  }

  // 内部のVocabCoreを更新するための共通ヘルパー
  void _updateVocab(VocabCore Function(VocabCore oldVocab) update) {
    final currentData = state.value;
    if (currentData == null) return;

    state = AsyncData(update(currentData));
  }
}
