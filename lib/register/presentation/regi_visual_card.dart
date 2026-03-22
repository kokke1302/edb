import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/register/domain/registration_notifier.dart';

// 訳の表示可否スイッチ
class VisibilitySwitchCard extends ConsumerWidget {
  const VisibilitySwitchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regiData = ref.watch(registrationProvider);

    final Widget show = IconButton(
      icon: const Icon(Icons.visibility),
      onPressed: () =>
          ref.read(registrationProvider.notifier).toggleIsShowing(true),
    );

    final Widget hidden = IconButton(
      icon: const Icon(Icons.visibility_off),
      onPressed: () =>
          ref.read(registrationProvider.notifier).toggleIsShowing(false),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              regiData.isHidden ? '翻訳でこの訳を使わない' : '常に翻訳でこの訳を用いる',
              style: const TextStyle(fontSize: 16),
            ),
            regiData.isHidden ? hidden : show,
          ],
        ),
      ),
    );
  }
}
