import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/register/data/card_receiver.dart';

class DictionaryCard extends ConsumerWidget {
  final String englishWord;
  final CardEntry card;

  const DictionaryCard({
    super.key,
    required this.englishWord,
    required this.card,
  });

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
                Text(
                  card.translation,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(cardReceiver.notifier)
                        .receiveCard(
                          newCard: card.copyWith(isShow: true),
                          newWord: englishWord,
                        );
                    context.push('/registration');
                  },
                  icon: const Icon(Icons.book_outlined),
                ),
              ],
            ),

            // 下段
            if (card.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  card.memo,
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
