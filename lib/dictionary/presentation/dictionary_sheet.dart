import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/dictionary/presentation/registered_card.dart';
import 'package:edb/dictionary/presentation/dictionary_card.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/register/data/card_receiver.dart';

// 辞書機能シート
class VocabularyInputSheet extends ConsumerWidget {
  const VocabularyInputSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(tokenIdProvider);
    final token = ref.watch(translationProvider).targetToken(id: currentId);
    final cards = ref.watch(cardListProvider);

    // 以下のContainerがモーダルシート全体を占める
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 高さは基本最小
        crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 英単語表示部 (見出し)
              Flexible(
                // 単語が長い場合に備え Flexible で包む
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    token.word,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // バッテンボタン（Close Button）
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // ナビゲーターを使ってシートを閉じます
                  Navigator.of(context).pop();
                },
                // M3では、色をonSurface系にすると統一感が出ます
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),

          // 必要に応じてスクロール
          Flexible(
            child: ConstrainedBox(
              // スクロール領域の最大高さを設定
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              // コンテンツの高さがmaxHeightを超えるときのみスクロールを有効にする
              child: SingleChildScrollView(
                child: cards.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                  error: (err, stack) => Center(child: Text('エラー: $err')),

                  data: (list) => _buildCardList(
                    context: context,
                    ref: ref,
                    tokenWord: token.word,
                    list: list,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CardListStateを正常に読み込めた場合
  Widget _buildCardList({
    required BuildContext context,
    required WidgetRef ref,
    required String tokenWord,
    required CardListState list,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (list.showWord != null)
          RegisteredCared(englishWord: tokenWord, card: list.showWord!),

        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const Text('単語帳からの候補', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // 登録済みリストを展開
        ...list.vocabularyWords.map((entry) {
          return RegisteredCared(englishWord: tokenWord, card: entry);
        }),

        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const Text('内部辞書からの候補', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // 内部辞書リストを展開
        ...list.dictionaryWords.map((entry) {
          return DictionaryCard(englishWord: tokenWord, card: entry);
        }),

        // オリジナル登録フィールドへ遷移するセクション（リストの最後に配置）
        const SizedBox(height: 8),
        ListTile(
          title: const Text('オリジナル訳語を登録'),
          trailing: const Icon(Icons.edit),
          onTap: () {
            ref
                .read(cardReceiver.notifier)
                .receiveCard(
                  newCard: CardEntry(
                    id: -1,
                    translation: '',
                    isShow: true,
                    nowShow: false,
                    memo: '',
                    based: Based.init,
                  ),
                  newWord: tokenWord,
                );
            context.push('/registration');
          },
        ),
      ],
    );
  }
}
