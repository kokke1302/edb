import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/register/domain/regidata_receiver.dart';
import 'package:edb/share/data/vocab_entry.dart';

class DictionaryCard extends ConsumerWidget {
  final VocabEntry ve;

  const DictionaryCard({super.key, required this.ve});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: ve.nowShow ? 4 : 1, // 影
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
                    ve.translation,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(regiDataReceiver.notifier)
                        .receiveDictionaryCard(ve: ve);
                    context.push('/registration');
                  },
                  icon: const Icon(Icons.book_outlined),
                ),
              ],
            ),

            // 下段
            if (ve.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  ve.memo,
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
