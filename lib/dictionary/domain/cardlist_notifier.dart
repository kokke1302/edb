import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/dictionary/domain/card_repository.dart';
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
            .fetchVocabularyEntries(token.word) ??
        [];

    // 辞書DBからRead
    final List<CardEntry> dictionaryWords =
        await ref
            .read(cardRepositoryProvider)
            .fetchDictionaryEntries(token.word) ??
        [];

    // ===============================================
    // 単語帳登録済単語　かつ　nowShow = true
    // ===============================================
    if (token.vocId >= 0 && token.nowShow) {
      final CardEntry? nowEntry = allVocabularyWords
          .where((entry) => entry.id == token.vocId)
          .firstOrNull;

      if (nowEntry != null) {
        final vocabularyWords = allVocabularyWords
            .where((entry) => entry.id != nowEntry.id)
            .map((entry) => entry.nowShowChange(nowShow: false))
            .toList();

        return CardListState(
          showWord: nowEntry.nowShowChange(nowShow: true),
          vocabularyWords: vocabularyWords,
          dictionaryWords: dictionaryWords,
        );
      }
    }

    // ===============================================
    // 単語帳未登録単語　または　nowShow = false　または　例外
    // ===============================================
    final resetVocabularyWords = allVocabularyWords
        .map((entry) => entry.nowShowChange(nowShow: false))
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
        // 表示を更新
        updatedToken = token.copyWith(resolvedTranslation: '', nowShow: false);

        // newShowWordを消去
        newShowWord = null;

        // nowShowをfalseにしてnewVocabularyWordsに加える
        newVocabularyWords.add(entry.nowShowChange(nowShow: false));
      }
      // 対象のentryがvocabularyWordsのリストに含まれる場合
      else {
        // どちらにも存在しない、エラー的なカードは処理しない
        final index = newVocabularyWords.indexOf(entry);
        if (index == -1) return;

        // 表示を更新
        updatedToken = token.copyWith(
          resolvedTranslation: entry.translation,
          nowShow: true,
        );

        // 新しいshowWordは、選択されたエントリのnowShowをtrueにしたもの
        newShowWord = newVocabularyWords
            .removeAt(index) // return: 該当するCardEntry
            .nowShowChange(nowShow: true);

        // showWordが元から存在する場合、vocabularyWordsに追加する
        if (currentList.showWord != null) {
          final oldShowWord = currentList.showWord!.nowShowChange(
            nowShow: false,
          );
          newVocabularyWords.add(oldShowWord);
        }
      }

      // 翻訳ブロックの表示を更新
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: updatedToken);

      // カードリストの表示を更新
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
