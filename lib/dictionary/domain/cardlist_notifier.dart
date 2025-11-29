import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/dictionary/domain/card_repository.dart';
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
            .fetchVocabularyEntries(token.card.word) ??
        const [];

    // 辞書DBからRead
    final List<CardEntry> dictionaryWords =
        await ref
            .read(cardRepositoryProvider)
            .fetchDictionaryEntries(token.card.word) ??
        const [];

    // =========================================================================
    // 単語帳登録済単語　かつ　nowShow = true　が存在
    // =========================================================================
    if (token.card.nowShow) {
      final CardEntry nowCard = token.card.copyWith(nowShow: true);

      final vocabularyWords = allVocabularyWords
          .where((entry) => entry.id != nowCard.id)
          .map((entry) => entry.copyWith(nowShow: false))
          .toList();

      return CardListState(
        showWord: nowCard,
        vocabularyWords: vocabularyWords,
        dictionaryWords: dictionaryWords,
      );
    }

    // =========================================================================
    // 単語帳未登録単語　または　nowShow = false　または　例外
    // =========================================================================
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
    if (entry.based != Based.vocabularies) return; // 単語帳以外からは受け付けない

    final targetId = ref.read(tokenIdProvider);
    final token = ref.read(translationProvider).targetToken(id: targetId);

    // 表示させる順番を変更
    state.whenData((currentList) {
      CardEntry? newShowWord = currentList.showWord;
      List<CardEntry> newVocabularyWords = List.from(
        currentList.vocabularyWords,
      );
      Token updatedToken = token;

      // =======================================================================
      // 対象のentryが現在のshowWordの場合
      // =======================================================================
      if (entry == currentList.showWord) {
        final newCard = entry.copyWith(nowShow: false);

        // newShowWordを消去
        newShowWord = null;
        // nowShowをfalseにしてnewVocabularyWordsに加える
        newVocabularyWords.add(newCard);

        // 表示を更新
        updatedToken = token.copyWith(card: newCard);
      }
      // =======================================================================
      // 対象のentryがvocabularyWordsのリストに含まれる場合
      // =======================================================================
      else {
        // どちらにも存在しない、エラー的なカードは処理しない
        final index = newVocabularyWords.indexOf(entry);
        if (index == -1) return;

        // 新しいshowWordは、選択されたエントリのnowShowをtrueにしたもの
        newShowWord = newVocabularyWords
            .removeAt(index) // return: 該当するCardEntry
            .copyWith(nowShow: true);

        // showWordが元から存在する場合、vocabularyWordsに追加する
        if (currentList.showWord != null) {
          final oldShowWord = currentList.showWord!.copyWith(nowShow: false);
          newVocabularyWords.add(oldShowWord);
        }

        // 表示を更新
        updatedToken = token.copyWith(card: newShowWord);
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

  // 更新
  void updateEntry() {
    state.whenData((currentList) {
      final targetId = ref.read(tokenIdProvider);
      final token = ref.read(translationProvider).targetToken(id: targetId);

      final newToken = token.copyWith(card: currentList.showWord);

      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: newToken);
    });
  }
}
