import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/wordbook/domain/list_notifier.dart';
import 'package:edb/wordbook/data/search_word.dart';
import 'package:edb/wordbook/domain/sort_notifier.dart';
import 'package:edb/wordbook/presentation/search_fab/searchbar.dart';
import 'package:edb/wordbook/presentation/search_fab/sort_dropdown.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        // 周りの余白
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 25.0,
          right: 25.0,
          bottom: 20.0,
        ),

        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[
            // シート名
            Center(
              child: Text(
                '検索とフィルタの設定',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // 検索バー
            MySearchBar(),
            SizedBox(height: 20),

            Text('ソート設定', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            // ソート設定
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[SortOrderButton(), SortDropdownMenu()],
            ),
            SizedBox(height: 30),

            // 最下部
            _MySheetEnd(),
          ],
        ),
      ),
    );
  }
}

class _MySheetEnd extends ConsumerWidget {
  const _MySheetEnd();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // ボタンを右寄せに
      children: <Widget>[
        // リセットボタン
        TextButton(
          onPressed: () {
            // 検索文字列を初期化
            ref.read(searchWordProvider.notifier).refresh();
            // 順序・対象をリセット
            ref.read(sortSettingProvider.notifier).reset();
            // リストを初期化
            ref.read(wordListProvider.notifier).reload(queryText: '');
            // シートを閉じる
            Navigator.pop(context);
          },
          child: const Text('リセット'),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // キャンセルボタン
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.pop(context), // シートを閉じる
              child: const Text('キャンセル'),
            ),
            const SizedBox(width: 8),

            // 決定ボタン
            ElevatedButton(
              onPressed: () {
                final searchWord = ref.read(searchWordProvider);
                final wordListNotifier = ref.read(wordListProvider.notifier);
                wordListNotifier.reload(queryText: searchWord);
                Navigator.pop(context);
              },
              child: const Text('決定'),
            ),
          ],
        ),
      ],
    );
  }
}
