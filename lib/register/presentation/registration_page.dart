import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/dictionary/data/token_id.dart';
import 'package:edb/translation/domain/translation_notifier.dart';
import 'package:edb/register/data/registration_state.dart';
import 'package:edb/register/domain/registration_notifier.dart';

// オリジナル訳語の登録・編集画面
class EntryScreen extends ConsumerWidget {
  final CardEntry? initialCardEntry;
  const EntryScreen({super.key, required this.initialCardEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTokenId = ref.watch(tokenIdProvider);
    final token = ref
        .watch(translationProvider)
        .targetToken(id: currentTokenId);

    final state = ref.watch(
      registrationProvider(
        initialEnglishWord: token.word,
        existingState: initialCardEntry,
      ),
    );
    final notifier = ref.read(
      registrationProvider(
        initialEnglishWord: token.word,
        existingState: initialCardEntry,
      ).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('オリジナル訳語を登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'a', hintText: 'あ'),
              controller: TextEditingController(text: state.englishWord),
              onChanged: notifier.updateEnglish,
            ),

            // 訳語入力フィールド
            TextField(
              decoration: const InputDecoration(
                labelText: '日本語訳 (オリジナル)',
                hintText: '必須',
              ),
              controller: TextEditingController(
                text: state.japaneseTranslation,
              ),
              onChanged: notifier.updateTranslation,
            ),
            const SizedBox(height: 16),

            // メモ入力フィールド
            TextField(
              decoration: const InputDecoration(labelText: 'メモ'),
              controller: TextEditingController(text: state.memo),
              onChanged: notifier.updateMemo,
            ),
            const SizedBox(height: 24),

            // 責務: 訳の表示可否スイッチ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('メイン画面で訳を表示'),
                Switch(
                  value: state.isHidden,
                  onChanged: (value) => notifier.toggleIsShowing(value),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // 責務: 操作ボタン
            _buildActionButtons(context, state, notifier),
          ],
        ),
      ),
    );
  }

  // 保存・キャンセルボタンのWidget生成
  Widget _buildActionButtons(
    BuildContext context,
    RegistrationState state,
    RegistrationNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // キャンセルで前の画面に戻る
          child: const Text('キャンセル'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          // 処理中はボタンを無効化
          onPressed: state.isProcessing
              ? null
              : () async {
                  // 保存処理
                  await notifier.save();
                  // 保存成功後、前の画面に戻る
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
          child: state.isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
