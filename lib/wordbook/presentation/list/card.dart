import 'package:flutter/material.dart';

import '../../../db/app_database.dart';

class MyWordCard extends StatelessWidget {
  final Vocabulary entry;
  const MyWordCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry.memo ?? 'メモなし',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(entry.createdAt.year.toString()),
      ),
    );
  }
}
