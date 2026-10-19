import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/presentation/view_models/book_notifier.dart';
import 'package:edb/presentation/view_models/sorting_notifier.dart';

class MySearchBar extends HookConsumerWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingNotifier = ref.read(typingWordProvider.notifier);

    // クリアボタンの表示判定だけに使う（空かどうかが変わったときだけ再描画）
    final isTypingEmpty = ref.watch(
      typingWordProvider.select((s) => s.isEmpty),
    );

    // 初期値は入力途中の文字列（確定済みの検索文字列ではない）
    final textController = useTextEditingController(
      text: ref.read(typingWordProvider),
    );

    ref.listen(typingWordProvider, (previous, next) {
      if (next != textController.text) {
        // 現在の入力内容と異なる場合のみ更新（無限ループ防止）
        textController.text = next;

        // 外部からの強制更新時は、カーソルを末尾に移動
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: next.length),
        );
      }
    });

    return TextField(
      controller: textController,
      textAlignVertical: TextAlignVertical.center,

      // 見た目を検索バーっぽくする
      decoration: InputDecoration(
        hintText: "検索キーワードを入力",
        // コンテンツに合わせて高さを最適化
        isDense: true,
        // 大きさを持たせる
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: const UnderlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: isTypingEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => typingNotifier.set(''),
              ),
      ),

      onTapOutside: (_) => FocusScope.of(context).unfocus(), // 外側タップで閉じる

      onChanged: (text) => typingNotifier.set(text),

      // Enterを押したとき
      onSubmitted: (text) {
        // 検索文字列の確定
        ref.read(sortingProvider.notifier).setSearchWord(text);
        // データベースにクエリを投げる
        ref.read(bookProvider.notifier).reload();
        // Enterでキーボードを閉じる
        FocusScope.of(context).unfocus();
      },
    );
  }
}
