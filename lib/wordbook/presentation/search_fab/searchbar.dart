import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/wordbook/domain/search_word.dart';
import 'package:edb/wordbook/domain/typing_word.dart';

class MySearchBar extends HookConsumerWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索文字列
    final searchQuery = ref.watch(searchWordProvider);
    // 検索バー内の文字列（初期値は現在の検索文字列）
    final textEditingController = useTextEditingController(text: searchQuery);

    Widget refreshIcon() {
      if (textEditingController.text.isNotEmpty) {
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // 入力内容をクリア
            textEditingController.text = '';
            ref.read(searchWordProvider.notifier).refresh();
            ref.read(typingWordProvider.notifier).refresh();
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return TextField(
      controller: textEditingController,

      // 見た目を検索バーっぽくする
      decoration: InputDecoration(
        labelText: '検索キーワード',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: refreshIcon(),
      ),

      onChanged: (text) {
        ref.read(typingWordProvider.notifier).setQuery(text);
      },

      // Enterを押したとき
      onSubmitted: (text) {
        // 検索文字列の確定
        ref.read(searchWordProvider.notifier).setSearchQuery(text);
        // データベースにクエリを投げる
        ref.read(wordListProvider.notifier).reload(queryText: text);
        // シートを閉じる
        Navigator.pop(context);
      },
    );
  }
}
