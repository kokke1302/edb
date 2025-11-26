import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/register/domain/registration_notifier.dart';

// メモ入力フィールド
class MemoCard extends HookConsumerWidget {
  const MemoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regiData = ref.watch(registrationProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // メモ入力フィールド
            TextField(
              decoration: InputDecoration(
                labelText: 'メモ',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 10.0,
                ),
              ),
              controller: useTextEditingController(text: regiData.memo),
              keyboardType: TextInputType.text,
              onChanged: ref
                  .read(registrationProvider.notifier)
                  .updateMemo, // Notifierのメソッドを直接渡す
            ),
          ],
        ),
      ),
    );
  }
}
