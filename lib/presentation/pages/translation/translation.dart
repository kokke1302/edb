import 'package:flutter/material.dart';

import 'package:edb/presentation/pages/translation/text_field.dart';
import 'package:edb/presentation/pages/translation/translate_fab.dart';
import 'package:edb/presentation/pages/translation/bookmark_fab.dart';
import 'package:edb/presentation/pages/translation/block_field.dart';

class TranslationModePage extends StatelessWidget {
  const TranslationModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 英文入力エリア
          Padding(padding: EdgeInsets.all(16.0), child: MyTextField()),

          // ボタン達
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              // vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
              children: [
                MyTranslateFab(),
                SizedBox(width: 10),
                MyBookmarkFab(),
              ],
            ),
          ),

          MyBlockField(),
        ],
      ),
    );
  }
}
