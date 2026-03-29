import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/domain/cardlist_notifier.dart';
import 'package:edb/register/data/regidata_receiver.dart';

class RegisteredCared extends ConsumerWidget {
  final CardEntry card;

  const RegisteredCared({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: card.nowShow ? 4 : 1, // 影
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上段
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左上
                Flexible(
                  child: Text(
                    card.translation,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 右上
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 訳を表示するかどうか
                    if (card.based == Based.vocabularies) ...[
                      IconButton(
                        onPressed: () {
                          ref
                              .read(cardListProvider.notifier)
                              .toggleVisibility(entry: card);
                        },
                        icon: card.nowShow
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        tooltip: card.nowShow ? '訳語を非表示にする' : '訳語を表示する',
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () {
                        ref
                            .read(regiDataReceiver.notifier)
                            .receiveCard(card: card);
                        context.push('/registration');
                      },
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

            // 下段
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (card.isShow) ...[
                    Icon(Icons.visibility, color: colorScheme.outline),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    card.memo,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: colorScheme.outline),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
