import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/translation/presentation/text_field.dart';
import 'package:edb/translation/presentation/word_block.dart';
import 'package:edb/translation/presentation/translate_fab.dart';

class TranslationModePage extends ConsumerWidget {
  const TranslationModePage({super.key});

  // 改行ロジック
  List<Widget> _buildWordBlocksWithBreaks({required List<Token> tokens}) {
    final List<Widget> widgets = [];

    for (final token in tokens) {
      // 本来の単語ブロックを追加
      widgets.add(WordBlock(id: token.id));

      // 【改行条件】Tokenがピリオド(.)の場合、その直後に改行用ダミーtokenを挿入する
      if (token.word == '.') {
        widgets.add(const SizedBox(width: double.infinity));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final chain = ref.watch(translationProvider);

    return Scaffold(
      body: Column(
        children: [
          // 英文入力エリア
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const MyTextField(),
          ),

          // 単語ブロック表示エリア
          Expanded(
            child: chain.isProcessing
                ? const Center(child: CircularProgressIndicator())
                // 垂直スクロールできるようにする
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    // 横並び・自動改行
                    child: Wrap(
                      alignment: WrapAlignment.center, // 中央揃え
                      spacing: 8.0, // 単語ブロック間の水平方向の間隔
                      runSpacing: 8.0, // 単語ブロック行間の垂直方向の間隔
                      children: _buildWordBlocksWithBreaks(
                        tokens: chain.tokens,
                      ), // 改行を含む
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min, // Column が占有する高さを最小限に抑える
        crossAxisAlignment: CrossAxisAlignment.end, // ボタンを右端に寄せる
        children: [
          const MyTranslateFab(),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'fab_bookmark_sentence',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('英文を保存します')));
            },
            child: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
    );
  }
}
