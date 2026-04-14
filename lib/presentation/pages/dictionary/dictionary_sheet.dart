import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/model/dictionary_data.dart';
import 'package:edb/presentation/view_models/dictionary_notifier.dart';
import 'package:edb/presentation/pages/dictionary/registered_card.dart';
import 'package:edb/presentation/pages/dictionary/dictionary_card.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';
import 'package:edb/presentation/view_models/selected_token_notifier.dart';

// 辞書機能シート
class VocabularyInputSheet extends ConsumerWidget {
  const VocabularyInputSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(selectedTokenProvider);
    final headerWord = token.word;

    // CardListStateを正常に読み込めた場合
    Widget buildCardList({
      required String headerWord,
      required DictionaryData list,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (list.showCard != null) RegisteredCared(card: list.showCard!),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const Text('単語帳からの候補', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 登録済みリストを展開
          ...list.vocabularyCards.map((card) {
            return RegisteredCared(card: card);
          }),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const Text(
            '内部辞書からの候補',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 内部辞書リストを展開
          ...list.dictionaryCards.map((card) {
            return DictionaryCard(card: card);
          }),

          // オリジナル登録フィールドへ遷移するセクション（リストの最後に配置）
          const SizedBox(height: 8),
          ListTile(
            title: const Text('オリジナル訳語を登録'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              ref.read(regiDataReceiver.notifier).initialCard(word: headerWord);
              context.pop();
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
                onPressed: () => context.pop(),
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
                    final cards = ref.watch(dictionaryProvider);

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
