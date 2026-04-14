import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/presentation/view_models/translation_notifier.dart';

class MyTranslateFab extends ConsumerWidget {
  const MyTranslateFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationProvider);

    if (state.isLoading) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.loop),
        label: const Text('翻訳中'),
        onPressed: null,
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text('再翻訳'),
        onPressed: () {
          ref.read(translationProvider.notifier).pushTriggerButton();
        },
      );
    }
  }
}
