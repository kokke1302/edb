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
    final currentQery = ref.watch(sortSettingProvider).typingWord;
    final searchQuery = ref.watch(sortSettingProvider).searchWord;
    final textEditingController = useTextEditingController(text: searchQuery);

    final notifier = ref.read(sortSettingProvider.notifier);

    Widget refreshIcon() {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          // 入力内容をクリア
          textEditingController.text = '';
          notifier.setTypeWord('');
        },
      );
    }

    return TextField(
      controller: textEditingController,

      // 見た目を検索バーっぽくする
      decoration: InputDecoration(
        // labelText: '検索キーワード',
        hintText: currentQery,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: currentQery.isNotEmpty
            ? refreshIcon()
            : const SizedBox.shrink(),
      ),

      onChanged: (text) => notifier.setTypeWord(text),

      // Enterを押したとき
      onSubmitted: (text) {
        notifier.setTypeWord(text);
        // 検索文字列の確定
        notifier.setSearchWord(text);
        // データベースにクエリを投げる
        ref.read(wordListProvider.notifier).reload();
      },
    );
  }
}
