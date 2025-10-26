import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/translation/presentation/text_field.dart';
import 'package:edb/translation/presentation/word_block.dart';

class TranslationModePage extends ConsumerWidget {
  const TranslationModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final state = ref.watch(translationProvider);
    // MainScreenのFABと連携するため、この画面側で処理をキックする
    // TODO: MainScreenのFABのonPressedから、このNotifierのprocessTranslation()を呼び出すロジックを実装する必要がある

    return Column(
      children: [
        // 英文入力エリア
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const MyTextField(),
        ),

        // 単語ブロック表示エリア
        Expanded(
          child: state.isProcessing
              ? const Center(child: CircularProgressIndicator())
              // 垂直スクロールできるようにする
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _WordBlocksArea(tokens: state.tokens),
                ),
        ),
      ],
    );
  }
}

// 改行ロジック
class _WordBlocksArea extends StatelessWidget {
  final List<Token> tokens;
  const _WordBlocksArea({required this.tokens});

  List<Widget> buildWordBlocksWithBreaks() {
    final List<Widget> widgets = [];

    for (final token in tokens) {
      // 本来の単語ブロックを追加
      widgets.add(WordBlock(token: token));

      // 【改行条件】Tokenがピリオド(.)の場合、その直後に改行用ダミーtokenを挿入する
      if (token.word == '.') {
        widgets.add(const SizedBox(width: double.infinity));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      // 横並び・自動改行
      alignment: WrapAlignment.center, // 中央揃え
      spacing: 8.0, // 単語ブロック間の水平方向の間隔
      runSpacing: 8.0, // 単語ブロック行間の垂直方向の間隔
      // 内部メソッドで生成したウィジェットリストを使用
      children: buildWordBlocksWithBreaks(),
    );
  }
}
