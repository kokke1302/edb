import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/presentation/view_models/translation_notifier.dart';
import 'package:edb/presentation/pages/dictionary/dictionary_sheet.dart';
import 'package:edb/presentation/view_models/selected_token_notifier.dart';

class WordBlock extends ConsumerWidget {
  final int id;
  const WordBlock({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 特定の id を持つトークンだけを抽出して監視する
    final token = ref.watch(tokenProvider(id));

    // 単語ブロック全体をGestureDetectorでラップし、タップで辞書機能シートへ遷移
    return InkWell(
      onTap: () {
        if (token.isWord) {
          ref.read(selectedTokenProvider.notifier).selectNew(token: token);
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true, // 高さ可変
            builder: (BuildContext context) => const MyVocabularyInputSheet(),
          ).then((_) {
            FocusManager.instance.primaryFocus?.unfocus();
          });
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap内で占有サイズを最小化
          children: [
            // 上段に英単語
            Text(
              token.showWord,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // 下段に日本語訳
            token.nowShow
                ? Text(
                    token.translation,
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                  )
                : const Text(
                    '-',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}
