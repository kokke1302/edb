import 'package:flutter/material.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/dictionary/presentation/dictionary_sheet.dart';

class WordBlock extends StatelessWidget {
  final Token token;
  const WordBlock({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // 単語ブロック全体をGestureDetectorでラップし、タップで辞書機能シートへ遷移
    return InkWell(
      onTap: () {
        if (token.isWord) {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true, // 高さが可変になるように設定
            builder: (BuildContext context) {
              // 作成したVocabularyInputSheetを呼び出す
              return VocabularyInputSheet(token: token);
            },
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
              token.word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // 下段に日本語訳
            token.resolvedTranslation.isNotEmpty
                ? Text(
                    token.resolvedTranslation,
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
