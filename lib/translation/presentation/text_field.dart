import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';

class MyTextField extends HookConsumerWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初回
    final textController = useTextEditingController(
      text: ref.read(translationProvider).value?.originalText ?? '',
    );

    // コントローラーの値を監視し、変更があればこの Widget を再描画する
    // これにより、textController.text.isNotEmpty が最新の状態になります
    useValueListenable(textController);

    // Provider からの外部変更を同期
    ref.listen(translationProvider.select((s) => s.value?.originalText), (
      previous,
      next,
    ) {
      if (next != null && next != textController.text) {
        textController.text = next;
      }
    });

    return TextField(
      controller: textController,
      maxLines: null, // 複数行対応
      decoration: InputDecoration(
        hintText: '英文を入力', // 薄いテキスト表示
        // コンテンツに合わせて高さを最適化
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: textController.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textController.clear();
                  ref.invalidate(translationProvider);
                },
              ),
      ),

      onChanged: (text) {
        // ユーザーが入力した文字を Notifier に送る
        ref
            .read(translationProvider.notifier)
            .updateOriginalText(newText: text);
      },
      onTapOutside: (_) => FocusScope.of(context).unfocus(), // 外側タップで閉じる
    );
  }
}
