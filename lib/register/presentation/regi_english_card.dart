import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/register/domain/registration_notifier.dart';

// 英単語のフィールド
class EnglishCard extends HookConsumerWidget {
  const EnglishCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regiData = ref.watch(registrationProvider);
    final isEntry = regiData.based != Based.vocabularies;

    final isEditingState = useState(isEntry);
    final isEditing = isEditingState.value;

    void dialog() {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('英単語の変更'),
            content: const Text('単語を変更すると、正常に翻訳できなくなる可能性があります。変更を続行しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // 編集モードに切り替え
                  isEditingState.value = true;
                },
                child: const Text('続行'),
              ),
            ],
          );
        },
      );
    }

    final Widget englishEditing = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: '英単語 *', // 必須マークを追加
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 10.0,
            ),
          ),
          controller: useTextEditingController(text: regiData.englishWord),
          keyboardType: TextInputType.text,
          onChanged: ref.read(registrationProvider.notifier).updateEnglish,
        ),
      ],
    );

    final Widget englishTitle = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('英単語', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              regiData.englishWord,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // 編集ボタン
        TextButton(onPressed: dialog, child: const Text('編集')),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing ? englishEditing : englishTitle,
      ),
    );
  }
}
