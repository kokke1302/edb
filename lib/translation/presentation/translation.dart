import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/translation/presentation/text_field.dart';
import 'package:edb/translation/presentation/word_block.dart';
import 'package:edb/translation/presentation/translate_fab.dart';
import 'package:edb/translation/presentation/bookmark_fab.dart';

class TranslationModePage extends ConsumerWidget {
  const TranslationModePage({super.key});

  // 改行ロジック
  List<Widget> _buildWordBlocksWithBreaks({required List<Token> tokens}) {
    final List<Widget> widgets = [];

    for (final token in tokens) {
      // 本来の単語ブロックを追加
      widgets.add(WordBlock(id: token.id));

      // 【改行条件】Tokenがピリオド(.)の場合、その直後に改行用ダミーtokenを挿入する
      if (token.card.word == '.') {
        widgets.add(const SizedBox(width: double.infinity));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final chain = ref.watch(translationProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 英文入力エリア
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const MyTextField(),
          ),

          // ボタン達
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              // vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
              children: [
                const MyTranslateFab(),
                const SizedBox(width: 10),
                const MyBookmarkFab(),
              ],
            ),
          ),

          // 単語ブロック表示エリア
          if (chain.isProcessing)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildWordBlocksWithBreaks(tokens: chain.tokens),
              ),
            ),
        ],
      ),
    );
  }
}
