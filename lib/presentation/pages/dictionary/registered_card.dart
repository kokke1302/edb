import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/presentation/view_models/dictionary_notifier.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';

class MyRegisteredCard extends ConsumerWidget {
  final CardData card;

  const MyRegisteredCard({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        // 角丸
        borderRadius: BorderRadius.circular(16),
        // 薄い線で囲う
        side: BorderSide(
          color: card.nowShow
              ? colorScheme.outline.withAlpha(180)
              : colorScheme.outlineVariant.withAlpha(100),
          width: 2,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                    card.vocab.translation,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 右上
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 訳を表示するかどうか
                    if (card.vocab.based == Based.vocabularies) ...[
                      IconButton(
                        onPressed: () {
                          ref
                              .read(dictionaryProvider.notifier)
                              .toggleVisibility(card: card);
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
                            .receiveRegisteredCard(card: card);
                        context.pop();
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
                  if (card.vocab.isShow) ...[
                    Icon(Icons.visibility, color: colorScheme.outline),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    card.vocab.memo,
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
