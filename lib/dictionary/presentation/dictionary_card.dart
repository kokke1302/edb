import 'package:flutter/material.dart';

import 'package:edb/dictionary/data/card_state.dart';

class DictionaryCard extends StatelessWidget {
  final CardEntry card;
  final VoidCallback onEditPressed;

  const DictionaryCard({
    super.key,
    required this.card,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: onEditPressed,
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
