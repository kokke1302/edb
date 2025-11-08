import 'package:flutter/material.dart';

import 'package:edb/dictionary/data/card_state.dart';

class DictionaryCard extends StatelessWidget {
  final CardEntry card;

  const DictionaryCard({super.key, required this.card});

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
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('登録画面へ')));
                  },
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
