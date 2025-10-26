import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';

class MyTranslateFab extends ConsumerWidget {
  const MyTranslateFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationProvider);

    if (state.isProcessing) {
      return FloatingActionButton(
        tooltip: '翻訳中',
        child: const Icon(Icons.loop),
        onPressed: () {},
      );
    } else {
      return FloatingActionButton(
        tooltip: '翻訳開始',
        child: const Icon(Icons.play_arrow),
        onPressed: () {
          ref.read(translationProvider.notifier).pushTriggerButton();
        },
      );
    }
  }
}
