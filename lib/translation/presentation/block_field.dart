import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/translation/data/token_data.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/translation/presentation/word_block.dart';

class MyBlockField extends ConsumerWidget {
  const MyBlockField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final state = ref.watch(translationProvider);

    // 改行ロジック
    List<Widget> buildWordBlocksWithBreaks({required List<TokenData> tokens}) {
      final List<Widget> widgets = [];

      for (final token in tokens) {
        // 本来の単語ブロックを追加
        widgets.add(WordBlock(id: token.id));

        // 【改行条件】Tokenがピリオド(.)の場合、その直後に改行用ダミーtokenを挿入する
        if (token.vocab.word == '.') {
          widgets.add(const SizedBox(width: double.infinity));
        }
      }

      return widgets;
    }

    // return部
    return state.when(
      // 1. データが正常にある場合
      data: (state) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: buildWordBlocksWithBreaks(tokens: state.tokens),
        ),
      ),

      // 2. ロード中の場合
      loading: () => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      ),

      // 3. エラーが発生した場合
      error: (err, stack) => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('エラーが検出されました。入力した文字列を確認し、再翻訳を行ってください。'),
      ),
    );
  }
}
