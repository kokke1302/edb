import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/dictionary/data/cardlist_state.dart';
import 'package:edb/dictionary/domain/token_id.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/dictionary/presentation/registered_card.dart';
import 'package:edb/dictionary/presentation/dictionary_card.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/register/domain/regidata_receiver.dart';

// 辞書機能シート
class VocabularyInputSheet extends ConsumerWidget {
  const VocabularyInputSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(tokenIdProvider);
    final token = ref.watch(targetToken(currentId));
    final headerWord = token.vocab.word;

    // CardListStateを正常に読み込めた場合
    Widget buildCardList({
      required String headerWord,
      required CardListState list,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (list.showWord != null) RegisteredCared(card: list.showWord!),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const Text('単語帳からの候補', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 登録済みリストを展開
          ...list.vocabularyWords.map((card) {
            return RegisteredCared(card: card);
          }),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const Text(
            '内部辞書からの候補',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 内部辞書リストを展開
          ...list.dictionaryWords.map((ve) {
            return DictionaryCard(ve: ve);
          }),

          // オリジナル登録フィールドへ遷移するセクション（リストの最後に配置）
          const SizedBox(height: 8),
          ListTile(
            title: const Text('オリジナル訳語を登録'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              ref.read(regiDataReceiver.notifier).receiveNew(word: headerWord);
              context.push('/registration');
            },
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 英単語表示部 (見出し)
              Flexible(
                // 単語が長い場合に備え Flexible で包む
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    headerWord,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // バッテンボタン（Close Button）
              IconButton(
                icon: const Icon(Icons.close),
                // ナビゲーターを使ってシートを閉じる
                onPressed: () => Navigator.of(context).pop(),
                // M3では、色をonSurface系にすると統一感が出ます
                // color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),

          // 下部
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                // 状態が変わる「カードリスト」だけを Consumer で包む
                child: Consumer(
                  builder: (context, ref, child) {
                    final cards = ref.watch(cardListProvider);

                    return cards.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Center(child: Text('エラー: $err')),
                      data: (list) =>
                          buildCardList(headerWord: headerWord, list: list),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
