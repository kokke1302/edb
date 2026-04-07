import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/wordbook/domain/sort_notifier.dart';

class MySearchBar extends HookConsumerWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索バー内の文字列（初期値は現在の検索文字列）
    final currentQuery = ref.watch(
      sortSettingProvider.select((s) => s.typingWord),
    );

    final notifier = ref.read(sortSettingProvider.notifier);

    // 初回
    final textController = useTextEditingController(
      text: ref.read(sortSettingProvider).searchWord,
    );

    ref.listen(sortSettingProvider.select((s) => s.typingWord), (
      previous,
      next,
    ) {
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
        suffixIcon: currentQuery.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => notifier.setTypeWord(''),
              ),
      ),

      onTapOutside: (_) => FocusScope.of(context).unfocus(), // 外側タップで閉じる

      onChanged: (text) => notifier.setTypeWord(text),

      // Enterを押したとき
      onSubmitted: (text) {
        notifier.setTypeWord(text);
        // 検索文字列の確定
        notifier.setSearchWord(text);
        // データベースにクエリを投げる
        ref.read(wordListProvider.notifier).reload();
        // Enterでキーボードを閉じる
        FocusScope.of(context).unfocus();
      },
    );
  }
}
