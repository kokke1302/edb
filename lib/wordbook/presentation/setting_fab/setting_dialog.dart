import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/wordbook/state/list_notifier.dart';
import '../../state/search_word.dart';
import '../../state/sort_setting.dart';
import 'searchbar.dart';
import 'sort_dropdown.dart';

// Riverpodを使う準備として ConsumerWidget を継承しておきます
class FilterSettingsWidget extends ConsumerWidget {
  const FilterSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListNotifier = ref.read(wordListProvider.notifier);
    // 検索バーやフィルタ設定 UI の内容をここに記述します
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 36.0,
          right: 36.0,
          bottom: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                '検索とフィルタの設定',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            const MySearchBar(),
            const SizedBox(height: 20),

            // ソート設定
            const Text('ソート設定', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[SortOrderButton(), SortDropdownMenu()],
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // ボタンを右寄せにする
              children: <Widget>[
                // 設定・順序を既定値にリセット
                TextButton(
                  onPressed: () {
                    ref.read(searchWordProvider.notifier).refresh();
                    ref.read(sortSettingProvider.notifier).reset();
                    wordListNotifier.reload(queryText: '');
                    Navigator.pop(context);
                  },
                  child: const Text('リセット'),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  // 決定ボタン
                  onPressed: () {
                    final searchWord = ref.read(
                      searchWordProvider,
                    ); // .notifier が不要
                    wordListNotifier.reload(queryText: searchWord);
                    Navigator.pop(context); // 決定後はダイアログを閉じる
                  },
                  child: const Text('決定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
