import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/dictionary/domain/card_repository.dart';
import 'package:edb/translation/data/base_style.dart';
import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/translation_notifier.dart';

// Riverpod Providerの定義
final cardListProvider =
    AsyncNotifierProvider.autoDispose<CardListNotifier, CardListState>(
      () => CardListNotifier(),
    );

// 訳語リストを管理するNotifier
class CardListNotifier extends AsyncNotifier<CardListState> {
  @override
  Future<CardListState> build() async {
    final targetId = ref.read(tokenIdProvider);
    final token = ref.read(translationProvider).targetToken(id: targetId);

    // 単語帳DBからRead
    final List<CardEntry> allVocabularyWords =
        await ref
            .read(cardRepositoryProvider)
            .fetchVocabularyEntries(token.lookupKey) ??
        [];

    // 辞書DBからRead
    final List<CardEntry> dictionaryWords =
        await ref
            .read(cardRepositoryProvider)
            .fetchDictionaryEntries(token.lookupKey) ??
        [];

    // Case 1: 非表示の場合 (token.nowShow が false)
    if (!token.nowShow) {
      final resetVocabularyWords = allVocabularyWords
          .map((entry) => entry.copyWith(nowShow: false))
          .toList();

      return CardListState(
        showWord: null,
        vocabularyWords: resetVocabularyWords,
        dictionaryWords: dictionaryWords,
      );
    }

    // Case 2: テキスト処理由来の場合 (最初の解析結果)
    if (token.based == Based.process) {
      final CardEntry? defaultShowWord = allVocabularyWords
          .where((entry) => entry.translation == token.resolvedTranslation)
          .firstOrNull;

      // 正常時
      if (defaultShowWord != null) {
        final vocabularyWords = allVocabularyWords
            .where((entry) => entry.id != defaultShowWord.id)
            .map((entry) => entry.copyWith(nowShow: false))
            .toList();

        return CardListState(
          showWord: defaultShowWord.copyWith(nowShow: true),
          vocabularyWords: vocabularyWords,
          dictionaryWords: dictionaryWords,
        );
      }
      // Token に resolvedTranslation があるが、単語帳DBに見つからない場合
      else {
        // 一旦 Case 1 に近い状態で返す。
        final resetVocabularyWords = allVocabularyWords
            .map((entry) => entry.copyWith(nowShow: false))
            .toList();

        return CardListState(
          showWord: null,
          vocabularyWords: resetVocabularyWords,
          dictionaryWords: dictionaryWords,
        );
      }
    }

    // Case 3: 単語帳操作由来の場合 (toggleVisibility 実行後)
    if (token.based == Based.vocabularies) {
      // Token に設定されている訳語と一致する CardEntry を探す
      final CardEntry? nowEntry = allVocabularyWords
          .where((entry) => entry.translation == token.resolvedTranslation)
          .firstOrNull;

      if (nowEntry != null) {
        // showWord 以外のエントリ (nowShow: false にリセット)
        final vocabularyWords = allVocabularyWords
            .where((entry) => entry.id != nowEntry.id)
            .map((entry) => entry.copyWith(nowShow: false))
            .toList();

        // showWord は nowShow: true にして返す
        return CardListState(
          showWord: nowEntry.copyWith(nowShow: true),
          vocabularyWords: vocabularyWords,
          dictionaryWords: dictionaryWords,
        );
      }
    }

    // 上記のどのケースにも当てはまらない、またはデータが見つからなかった場合のフォールバック
    final resetVocabularyWords = allVocabularyWords
        .map((entry) => entry.copyWith(nowShow: false))
        .toList();

    return CardListState(
      showWord: null,
      vocabularyWords: resetVocabularyWords,
      dictionaryWords: dictionaryWords,
    );
  }

  // 訳の表示/非表示の切り替え
  void toggleVisibility({required CardEntry entry}) {
    final targetId = ref.read(tokenIdProvider);
    final token = ref.read(translationProvider).targetToken(id: targetId);
    final translationNotifier = ref.read(translationProvider.notifier);

    if (entry.based != Based.vocabularies) return; // 単語帳以外からは受け付けない

    // 表示させる順番を変更
    state.whenData((currentList) {
      CardEntry? newShowWord = currentList.showWord;
      List<CardEntry> newVocabularyWords = List.from(
        currentList.vocabularyWords,
      );
      Token updatedToken = token;

      // 対象のentryが現在のshowWordの場合
      if (entry == currentList.showWord) {
        // 表示を消す
        updatedToken = token.copyWith(resolvedTranslation: '', nowShow: false);

        // nowShowをfalseにしてnewVocabularyWordsに加える
        newVocabularyWords.add(entry.copyWith(nowShow: false));
        // newShowWordを消去
        newShowWord = null;
      }
      // 対象のentryがvocabularyWordsのリストに含まれる場合
      else {
        final index = newVocabularyWords.indexOf(entry);

        if (index != -1) {
          // tokenの更新
          updatedToken = token.copyWith(
            resolvedTranslation: entry.translation,
            nowShow: true,
            based: Based.vocabularies, // 単語帳由来に設定
          );

          // 新しいshowWordは、選択されたエントリのnowShowをtrueにしたもの
          newShowWord = newVocabularyWords
              .removeAt(index)
              .copyWith(nowShow: true);
          // 現在のshowWordをnowShowがfalseになった状態でvocabularyWordsに追加する
          if (currentList.showWord != null) {
            final oldShowWord = currentList.showWord!.copyWith(nowShow: false);
            newVocabularyWords.add(oldShowWord);
          }
        }
      }

      translationNotifier.updateToken(updatedToken: updatedToken);

      state = AsyncValue.data(
        currentList.copyWith(
          showWord: newShowWord,
          vocabularyWords: newVocabularyWords,
        ),
      );
    });
  }

  // // 新規作成
  // Future<void> createEntry(VocabularyEntry newEntry) async {
  //   // TODO: 単語帳DBからCreate
  //   await Future.delayed(const Duration(milliseconds: 300));

  //   state.whenData((currentList) {
  //     final newList = List<VocabularyEntry>.from(currentList)..add(newEntry);
  //     state = AsyncValue.data(newList);
  //   });
  // }

  // // 単語帳エントリの編集
  // Future<void> updateEntry(VocabularyEntry updatedEntry) async {
  //   // TODO: 単語帳DBからUpdate
  //   await Future.delayed(const Duration(milliseconds: 300));

  //   state.whenData((currentList) {
  //     final index = currentList.indexWhere(
  //       (e) =>
  //           e.id == updatedEntry.id &&
  //           e.isRegistered == updatedEntry.isRegistered,
  //     );

  //     if (index != -1) {
  //       final newList = List<VocabularyEntry>.from(currentList);
  //       newList[index] = updatedEntry; // 置き換え
  //       state = AsyncValue.data(newList);
  //     }
  //   });
  // }

  // // 削除
  // Future<void> deleteEntry(VocabularyEntry entry) async {
  //   // TODO: 単語帳DBからDelete
  //   await Future.delayed(const Duration(milliseconds: 300));

  //   state.whenData((currentList) {
  //     final newList = currentList
  //         .where(
  //           (e) => !(e.id == entry.id && e.isRegistered == entry.isRegistered),
  //         )
  //         .toList();

  //     state = AsyncValue.data(newList);
  //   });
  // }
}
