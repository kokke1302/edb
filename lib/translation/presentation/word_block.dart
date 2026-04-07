import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/dictionary/presentation/dictionary_sheet.dart';
import 'package:edb/dictionary/domain/token_id.dart';

class WordBlock extends ConsumerWidget {
  final int id;
  const WordBlock({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 特定の id を持つトークンだけを抽出して監視する
    final token = ref.watch(
      translationProvider.select(
        (asyncState) => asyncState.value?.tokens.firstWhere((t) => t.id == id),
      ),
    );

    // データがロード中などで取得できない場合のガード
    if (token == null) return const SizedBox.shrink();

    // 単語ブロック全体をGestureDetectorでラップし、タップで辞書機能シートへ遷移
    return InkWell(
      onTap: () {
        if (token.isWord) {
          ref.read(tokenIdProvider.notifier).updateNum(id);
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true, // 高さ可変
            builder: (BuildContext context) => const VocabularyInputSheet(),
          );
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
            token.vocab.nowShow
                ? Text(
                    token.vocab.translation,
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
