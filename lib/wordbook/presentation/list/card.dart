import 'package:flutter/material.dart';

import 'package:edb/db/app_database.dart';

class MyWordCard extends StatelessWidget {
  final Vocabulary entry;
  const MyWordCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // 最終更新日時と作成日時から日付部分のみをフォーマット
    final createdDate =
        '${entry.createdAt.year}/${entry.createdAt.month}/${entry.createdAt.day}';
    final updatedDate =
        '${entry.updatedAt.year}/${entry.updatedAt.month}/${entry.updatedAt.day}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1行目: ID, English Word, isHidden
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ID
                Text(
                  'ID: ${entry.id}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                // isHidden (非表示フラグ)
                if (entry.isHidden)
                  const Icon(Icons.visibility_off, color: Colors.red, size: 16),
              ],
            ),
            const SizedBox(height: 4),

            // 2行目: English Word (Title)
            Text(
              entry.englishWord,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),

            // 3行目: Japanese Translation (Subtitle)
            Text(
              entry.japaneseTranslation,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const Divider(height: 16),

            // 4行目: Memo
            Text(
              'メモ: ${entry.memo ?? 'メモなし'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),

            // 5行目: Created At / Updated At
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '作成: $createdDate',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const SizedBox(width: 8),
                Text(
                  '更新: $updatedDate',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
