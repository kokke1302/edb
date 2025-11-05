import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';

// 辞書機能シート
class VocabularyInputSheet extends ConsumerWidget {
  final Token token;
  const VocabularyInputSheet({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  data: (list) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // isShow
                        if (list.showWord != null)
                          RegisteredListTile(
                            token: token,
                            card: list.showWord!,
                          ),

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
                          return RegisteredListTile(token: token, card: entry);
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
                          return DictionaryListTile(card: entry);
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

                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Center(child: Text('エラー: $err')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisteredListTile extends ConsumerWidget {
  final Token token;
  final CardEntry card;

  const RegisteredListTile({
    super.key,
    required this.token,
    required this.card,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: card.isShow ? 4 : 1, // 影
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    card.translation,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 訳を表示するかどうか (Switch) - isRegisteredの場合のみ表示
                    if (card.isRegistered) ...[
                      IconButton(
                        onPressed: () {
                          // シートのリスト管理
                          ref
                              .watch(cardListProvider.notifier)
                              .toggleVisibility(entry: card);
                          // token配列更新
                          ref
                              .watch(translationProvider.notifier)
                              .updateTokenTranslation(
                                target: token,
                                card: card,
                              );
                        },
                        icon: card.isShow
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        tooltip: card.isShow ? '訳語を非表示にする' : '訳語を表示する',
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.book,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      tooltip: '単語帳を編集/確認',
                    ),
                  ],
                ),
              ],
            ),
            // Memoの表示
            if (card.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'メモ: ${card.memo}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: colorScheme.outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DictionaryListTile extends StatelessWidget {
  final CardEntry card;

  const DictionaryListTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(card.translation, style: const TextStyle(fontSize: 16)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.book_outlined),
                ),
              ],
            ),
            // Memoの表示
            if (card.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Memo: ${card.memo}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
