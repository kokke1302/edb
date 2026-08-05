import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/model/translation_data.dart';
import 'package:edb/presentation/view_models/translation_notifier.dart';
import 'package:edb/presentation/pages/translation/word_block.dart';

class MyBlockField extends HookConsumerWidget {
  const MyBlockField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // トークン配列を監視
    final state = ref.watch(translationProvider);

    // 直前に取得成功したデータ
    final previousData = useRef<TranslationData?>(null);
    state.whenData((data) => previousData.value = data);

    // インジケータを表示するかのフラグ
    final showLoadingIndicator = useState(false);
    useEffect(() {
      if (!state.isLoading) {
        showLoadingIndicator.value = false;
        return null;
      }

      // ロード中インジケータを表示するまでの猶予時間。
      final timer = Timer(Duration(milliseconds: 300), () {
        showLoadingIndicator.value = true;
      });

      // 300ms以内にロードが終わればタイマーをキャンセルし、インジケータは出さない
      return () {
        timer.cancel();
        showLoadingIndicator.value = false;
      };
    }, [state.isLoading]);

    return state.when(
      data: (data) => _TokenWrap(tokens: data.tokens),
      loading: () => _LoadingContent(
        previousData: previousData.value,
        showLoadingIndicator: showLoadingIndicator.value,
      ),
      error: (err, stack) => const _ErrorMessage(),
    );
  }
}

class _TokenWrap extends StatelessWidget {
  const _TokenWrap({required this.tokens});

  final List<TokenData> tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: _buildWordBlocksWithBreaks(tokens),
      ),
    );
  }

  // トークンをWordBlockに変換し、ピリオド(.)の直後に改行用のダミーウィジェットを挿入する。
  List<Widget> _buildWordBlocksWithBreaks(List<TokenData> tokens) {
    final widgets = <Widget>[];

    for (var i = 0; i < tokens.length; i++) {
      widgets.add(WordBlock(id: i));

      final isSentenceEnd = tokens[i].word == '.';
      if (isSentenceEnd) {
        widgets.add(const SizedBox(width: double.infinity));
      }
    }

    return widgets;
  }
}

// 1. 直前のデータがあれば、それを表示し続ける
// 2. データがなく、300ms以上経過していればインジケータを表示
// 3. データがなく、300ms未満ならまだ何も表示しない
class _LoadingContent extends StatelessWidget {
  const _LoadingContent({
    required this.previousData,
    required this.showLoadingIndicator,
  });

  final TranslationData? previousData;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    if (previousData != null) {
      return _TokenWrap(tokens: previousData!.tokens);
    }

    if (showLoadingIndicator) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Text('エラーが検出されました。入力した文字列を確認し、再翻訳を行ってください。'),
    );
  }
}
