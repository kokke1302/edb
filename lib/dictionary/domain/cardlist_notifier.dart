import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';

// Riverpod Providerの定義
final cardListProvider = AsyncNotifierProvider<CardListNotifier, CardListState>(
  () => CardListNotifier(),
);

// 訳語リストを管理するNotifier
class CardListNotifier extends AsyncNotifier<CardListState> {
  @override
  Future<CardListState> build() async {
    // TODO: 単語帳DB・辞書DBからRead
    await Future.delayed(const Duration(milliseconds: 500));

    final CardEntry showWord = CardEntry(
      isRegistered: true,
      translation: 'イエス・キリスト',
      isShow: true,
      memo: '宗教的な固有名詞',
    );

    final List<CardEntry> vocabularyWords = [
      CardEntry(
        isRegistered: true,
        translation: '〜だ/〜である',
        isShow: false,
        memo: '',
      ),
      CardEntry(
        isRegistered: true,
        translation: 'あいうえお',
        isShow: false,
        memo: 'ひらがな',
      ),
    ];

    final List<CardEntry> dictionaryWords = [
      CardEntry(
        isRegistered: false,
        translation: '〜だ/〜である (内部辞書)',
        isShow: false,
        memo: '使用頻度の高い訳',
      ),
      CardEntry(
        isRegistered: false,
        translation: 'イエス・キリスト (内部辞書)',
        isShow: false,
        memo: '宗教的な固有名詞',
      ),
    ];

    // 今はダミーデータを返す
    return CardListState(
      showWord: showWord,
      vocabularyWords: vocabularyWords,
      dictionaryWords: dictionaryWords,
    );
  }

  // 訳の表示/非表示の切り替え
  Future<void> toggleVisibility({required CardEntry entry}) async {
    if (!entry.isRegistered) return; // 辞書からは受け付けない

    // TODO: 単語帳DBへUpdate処理
    // await Future.delayed(const Duration(milliseconds: 500));

    // 表示させる順番を変更
    state.whenData((currentList) {
      CardEntry? newShowWord = currentList.showWord;
      List<CardEntry> newVocabularyWords = List.from(
        currentList.vocabularyWords,
      );

      if (entry == currentList.showWord) {
        // 対象のentryが現在のshowWordの場合
        // isShowをfalseにしてnewVocabularyWordsに加える
        newVocabularyWords.add(entry.copyWith(isShow: false));
        // newShowWordを消去
        newShowWord = null;
      } else {
        // 対象のentryがvocabularyWordsのリストに含まれる場合
        final index = newVocabularyWords.indexOf(entry);

        if (index != -1) {
          // 新しいshowWordは、選択されたエントリのisShowをtrueにしたもの
          newShowWord = newVocabularyWords
              .removeAt(index)
              .copyWith(isShow: true);

          // 現在のshowWordをisShowがfalseになった状態でvocabularyWordsに追加する
          if (currentList.showWord != null) {
            final oldShowWord = currentList.showWord!.copyWith(isShow: false);
            newVocabularyWords.add(oldShowWord);
          }

          newVocabularyWords.remove(entry);
        }
      }

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
