import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/list_notifier.dart';
import '../../state/search_word.dart';

// MySearchBar ウィジェットの定義
class MySearchBar extends HookConsumerWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 確定文字列やWordListに付随する関数
    final searchQueryNotifier = ref.read(searchWordProvider.notifier);
    final wordListNotifier = ref.read(wordListProvider.notifier);

    final searchQuery = ref.watch(searchWordProvider);

    final textEditingController = useTextEditingController(text: searchQuery);

    Widget refreshIcon() {
      if (textEditingController.text.isNotEmpty) {
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // 入力内容をクリアし、検索を再実行
            textEditingController.text = '';
          },
        );
      } else {
        return SizedBox.shrink();
      }
    }

    return TextField(
      // Row/Expandedを削除し、TextFieldを直接配置
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: '検索キーワード',
        border: const OutlineInputBorder(), // constを追加
        prefixIcon: const Icon(Icons.search),
        // clearボタンをSuffixIconとして統合
        suffixIcon: refreshIcon(), // refreshIconをsuffixIconに設定
      ),
      // 確定ボタン（Enter）を押したとき
      onSubmitted: (text) {
        searchQueryNotifier.setSearchQuery(text);
        wordListNotifier.reload(queryText: text);
        // ダイアログ内のTextFieldでEnterを押した後もダイアログを閉じる
        Navigator.pop(context);
      },
    );
  }
}
