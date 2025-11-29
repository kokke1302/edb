import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';

class MyTextField extends HookConsumerWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final chain = ref.watch(translationProvider);
    // textField内文字列
    final textController = useTextEditingController(text: chain.originalText);

    // chain.originalText の変更を監視し、controllerに反映させる
    useEffect(() {
      if (textController.text != chain.originalText) {
        // 現在のカーソル/選択範囲を保存
        final currentSelection = textController.selection;

        // 新しいテキストの長さ
        final newTextLength = chain.originalText.length;
        // カーソル位置を調整
        final newOffset = currentSelection.baseOffset > newTextLength
            ? newTextLength
            : currentSelection.baseOffset;

        // Text value と Selection value を同時に更新
        textController.value = textController.value.copyWith(
          text: chain.originalText,
          selection: TextSelection.collapsed(offset: newOffset),
          composing: TextRange.empty,
        );
      }
      return null;
    }, [chain.originalText]);

    Widget refreshIcon() {
      if (textController.text.isNotEmpty) {
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            textController.text = '';
            // 英文格納Stateにリセットを通知
            ref
                .read(translationProvider.notifier)
                .updateOriginalText(newText: '');
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
        ref
            .read(translationProvider.notifier)
            .updateOriginalText(newText: text);
      },
    );
  }
}
