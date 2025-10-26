import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';

class MyTextField extends HookConsumerWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final state = ref.watch(translationProvider);
    // textField内文字列
    final textController = useTextEditingController(text: state.originalText);

    Widget refreshIcon() {
      if (textController.text.isNotEmpty) {
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            textController.text = '';
            // 英文格納Stateにリセットを通知
            ref.read(translationProvider.notifier).updateOriginalText('');
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return TextField(
      controller: textController,
      maxLines: null, // 複数行対応
      decoration: InputDecoration(
        hintText: 'テキストを入力', // 薄いテキスト表示
        border: OutlineInputBorder(),
        suffixIcon: refreshIcon(),
      ),
      onChanged: (text) {
        ref.read(translationProvider.notifier).updateOriginalText(text);
      },
    );
  }
}
