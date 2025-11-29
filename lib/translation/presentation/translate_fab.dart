import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';

class MyTranslateFab extends ConsumerWidget {
  const MyTranslateFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationProvider);

    if (state.isProcessing) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.loop),
        onPressed: () {},
        label: const Text('翻訳中'),
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
