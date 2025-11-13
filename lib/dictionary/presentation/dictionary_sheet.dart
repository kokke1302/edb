import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/dictionary/presentation/registered_card.dart';
import 'package:edb/dictionary/presentation/dictionary_card.dart';

// 辞書機能シート
class VocabularyInputSheet extends ConsumerWidget {
  const VocabularyInputSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(tokenIdProvider);
    final cards = ref.watch(cardListProvider);
    final token = ref.watch(translationProvider).targetToken(id: currentId);

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

                  data: (list) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (list.showWord != null)
                          RegisteredCared(card: list.showWord!),

                        Divider(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const Text(
                          '単語帳からの候補',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // 登録済みリストを展開
                        ...list.vocabularyWords.map((entry) {
                          return RegisteredCared(card: entry);
                        }),

                        Divider(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const Text(
                          '内部辞書からの候補',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // 内部辞書リストを展開
                        ...list.dictionaryWords.map((entry) {
                          return DictionaryCard(card: entry);
                        }),

                        // オリジナル登録フィールドへ遷移するセクション（リストの最後に配置）
                        const SizedBox(height: 8),
                        ListTile(
                          title: const Text('オリジナル訳語を登録'),
                          trailing: const Icon(Icons.edit),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('TODO: オリジナル登録画面へ遷移'),
                              ),
                            );
                          },
                        ),
                      ],
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
