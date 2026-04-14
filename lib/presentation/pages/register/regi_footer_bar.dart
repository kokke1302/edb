import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/presentation/view_models/register_notifier.dart';

// フッター（保存・キャンセル・削除ボタン）
class FooterBar extends ConsumerWidget {
  const FooterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRegiData = ref.watch(registerProvider);
    final regiData = asyncRegiData.requireValue;

    final bool isProcessing = asyncRegiData.isLoading;
    final bool isNewEntry = regiData.vocab.based != Based.vocabularies;

    // 削除ボタン
    Widget buildDeleteButton() {
      Future<void> deleteAction() async {
        await ref.read(registerProvider.notifier).delete();
        if (!context.mounted) return;

        // エラーがない場合のみ画面を閉じる（AsyncValue.hasErrorで判定可能）
        if (!ref.read(registerProvider).hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('消去しました'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('削除に失敗しました'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // 既存の単語帳データがある場合のみ「消去」ボタンを表示
      if (regiData.vocab.based == Based.vocabularies) {
        return ElevatedButton(
          // 処理中はボタンを無効化
          onPressed: isProcessing ? null : deleteAction,
          // style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('消去'),
        );
      }
      return const SizedBox.shrink();
    }

    // 保存ボタン
    Widget buildSaveButton() {
      // ボタン無効化の判定ロジック
      final bool isActionDisabled =
          isProcessing ||
          regiData.vocab.translation.isEmpty ||
          (isNewEntry && regiData.vocab.word.isEmpty);

      // くるくる
      const Widget circular = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      );

      final saveText = Text(
        isNewEntry ? '新規保存' : '上書き保存',
        style: const TextStyle(fontSize: 16),
      );

      Future<void> saveAction() async {
        await ref.read(registerProvider.notifier).save();
        if (!context.mounted) return;

        // 保存に成功（エラーがない）したら戻る
        if (!ref.read(registerProvider).hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存しました'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存に失敗しました'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      return ElevatedButton(
        onPressed: isActionDisabled ? null : saveAction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(100, 48),
        ),
        // isLoadingの時はくるくるを表示
        child: isProcessing ? circular : saveText,
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
                  // 処理中以外はキャンセル可能
                  onPressed: isProcessing ? null : () => context.pop(),
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
