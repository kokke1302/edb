import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/presentation/view_models/book_notifier.dart';

class MyInitialError extends ConsumerWidget {
  final Object error;
  const MyInitialError({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('データの初期ロードに失敗しました。'),
          Text(error.toString()),
          ElevatedButton(
            onPressed: () => ref.invalidate(bookProvider),
            child: const Text('リトライ'),
          ),
        ],
      ),
    );
  }
}
