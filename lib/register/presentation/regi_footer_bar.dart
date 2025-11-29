import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/register/domain/registration_notifier.dart';

// フッター（保存・キャンセル・削除ボタン）
class FooterBar extends ConsumerWidget {
  const FooterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regiData = ref.watch(registrationProvider);

    final bool newEntry = regiData.based != Based.vocabularies;

    // 削除ボタン
    Widget buildDeleteButton() {
      void deleteAction() async {
        // 削除処理
        await ref.read(registrationProvider.notifier).delete();
        // 処理の成功を待つ
        if (!context.mounted) return;
        context.pop();
      }

      // 新規作成時
      if (regiData.based == Based.vocabularies) {
        return ElevatedButton(
          onPressed: newEntry ? null : deleteAction,
          child: const Text('消去'),
        );
      }
      // 既存のカードを編集している場合
      else {
        return const SizedBox.shrink();
      }
    }

    // 保存ボタン
    Widget buildSaveButton() {
      // ボタン無効化の判定ロジック
      bool isActionDisabled =
          // 処理中ではない
          regiData.isProcessing ||
          // 日本語訳が空ではない
          regiData.japaneseTranslation.isEmpty ||
          // 新規登録時は英単語の入力は必須
          (regiData.based != Based.vocabularies &&
              regiData.englishWord.isEmpty);

      // くるくる
      const Widget cirular = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      );

      final saveText = newEntry
          ? const Text('新規保存', style: TextStyle(fontSize: 16))
          : const Text('上書き保存', style: TextStyle(fontSize: 16));

      void saveAction() async {
        // 保存処理
        await ref.read(registrationProvider.notifier).save();
        // 処理成功後、前の画面に戻る
        if (!context.mounted) return;
        context.pop();
      }

      return ElevatedButton(
        onPressed: isActionDisabled ? null : saveAction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(100, 48),
        ),
        child: regiData.isProcessing ? cirular : saveText,
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 右
            buildDeleteButton(), // 削除ボタン
            // 左
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // キャンセルボタン
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 12),

                buildSaveButton(), // 保存ボタン
              ],
            ),
          ],
        ),
      ),
    );
  }
}
