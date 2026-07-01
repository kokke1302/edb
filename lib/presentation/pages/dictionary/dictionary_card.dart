import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';

class MyDictionaryCard extends ConsumerWidget {
  final CardData card;

  const MyDictionaryCard({super.key, required this.card});

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
                Expanded(
                  child: Text(
                    card.vocab.translation,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(regiDataReceiver.notifier)
                        .receiveDictionaryCard(card: card);
                    context.pop();
                    context.push('/registration');
                  },
                  icon: const Icon(Icons.book_outlined),
                ),
              ],
            ),

            // 下段
            if (card.vocab.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  card.vocab.memo,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: colorScheme.outline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
