import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/share/data/card_data.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/domain/token_id.dart';
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
    final token = ref.read(targetToken(targetId));

    // 単語帳DBからRead
    final vocabularyEntries = await ref
        .read(cardRepositoryProvider)
        .fetchVocabularyEntries(token.vocab.word);
    final allCardData = vocabularyEntries
        .map((v) => CardData.fromVocabularies(vocabulary: v))
        .toList();

    // 辞書DBからRead
    final dictionaryEntries = await ref
        .read(cardRepositoryProvider)
        .fetchDictionaryEntries(token.vocab.word);
    final dictionaryWords = dictionaryEntries
        .map((d) => VocabEntry.fromDictionary(dictionary: d))
        .toList();

    // =========================================================================
    // 単語帳登録済単語　かつ　nowShow = true　が存在
    // =========================================================================
    if (token.vocab.nowShow) {
      CardData? currentShowCard;
      final List<CardData> otherCards = [];

      for (var card in allCardData) {
        // ※ token.id は動的なので、内容の一致で判定
        // word と translation が一致するものを「現在表示中のカード」とみなす
        if (card.vocab.word.toLowerCase() == token.vocab.word.toLowerCase() &&
            card.vocab.translation == token.vocab.translation) {
          currentShowCard = card.copyWith(
            vocab: card.vocab.copyWith(nowShow: true),
          );
        } else {
          otherCards.add(
            card.copyWith(vocab: card.vocab.copyWith(nowShow: false)),
          );
        }
      }

      return CardListState(
        showWord: currentShowCard, // 特定できた場合は CardData、できなければ null
        vocabularyWords: otherCards,
        dictionaryWords: dictionaryWords,
      );
    }

    // =========================================================================
    // 単語帳未登録単語　または　nowShow = false　または　例外
    // =========================================================================
    final resetVocabularyWords = allCardData
        .map(
          (card) => card.copyWith(vocab: card.vocab.copyWith(nowShow: false)),
        )
        .toList();

    return CardListState(
      showWord: null,
      vocabularyWords: resetVocabularyWords,
      dictionaryWords: dictionaryWords,
    );
  }

  // 訳の表示/非表示の切り替え
  Future<void> toggleVisibility({required CardData card}) async {
    // 単語帳以外からは受け付けない
    if (card.vocab.based != Based.vocabularies) return;
    // カード句
    if (state.isLoading) return;

    state = await AsyncValue.guard(() async {
      final currentList = state.requireValue;
      final targetId = ref.read(tokenIdProvider);
      final token = ref.read(targetToken(targetId));

      CardData? newShowCard = currentList.showWord;
      List<CardData> newVocabularyWords = List.from(
        currentList.vocabularyWords,
      );
      VocabEntry updatedVocab = token.vocab;

      // =======================================================================
      // 対象のentryが現在のshowWordの場合 -> 非表示にする
      // =======================================================================
      if (newShowCard != null && card.id == newShowCard.id) {
        // ラベルを非表示へ
        final deactivatedCard = card.copyWith(
          vocab: card.vocab.copyWith(nowShow: false),
        );
        // newShowWordを消去
        newShowCard = null;
        // nowShowをfalseにしてnewVocabularyWordsに加える
        newVocabularyWords.add(deactivatedCard);
        // 表示を更新
        updatedVocab = deactivatedCard.vocab;
      }
      // =======================================================================
      // 対象のentryがリストに含まれる場合 -> 表示する
      // =======================================================================
      else {
        // idが同じカードを探す
        final index = newVocabularyWords.indexWhere((c) => c.id == card.id);
        // indexが見つからない場合は、現在の状態をそのまま返す
        if (index == -1) return currentList;
        // リストから削除
        final targetCard = newVocabularyWords.removeAt(index);

        // 以前表示していたカードがあればリストに戻す
        if (currentList.showWord != null) {
          newVocabularyWords.add(
            currentList.showWord!.copyWith(
              vocab: currentList.showWord!.vocab.copyWith(nowShow: false),
            ),
          );
        }

        // 新しく表示するカードを設定
        newShowCard = targetCard.copyWith(
          vocab: targetCard.vocab.copyWith(nowShow: true),
        );
        updatedVocab = newShowCard.vocab;
      }

      // 外部の翻訳ステートを更新（UI側の表示に反映）
      ref
          .read(translationProvider.notifier)
          .updateToken(updatedToken: token.copyWith(vocab: updatedVocab));

      return currentList.copyWith(
        showWord: newShowCard,
        vocabularyWords: newVocabularyWords,
      );
    });
  }
}
