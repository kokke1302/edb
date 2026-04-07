import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/register/domain/registration_notifier.dart';

// 訳語入力フィールド
class TranslationCard extends HookConsumerWidget {
  const TranslationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRegiData = ref.watch(registrationProvider);
    final regiData = asyncRegiData.requireValue;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: '日本語訳 *',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 10.0,
            ),
          ),
          controller: useTextEditingController(
            text: regiData.vocab.translation,
          ),
          keyboardType: TextInputType.text,
          onChanged: ref.read(registrationProvider.notifier).updateTranslation,
        ),
      ),
    );
  }
}
