import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/register/domain/registration_notifier.dart';

// 訳の表示可否スイッチ
class VisibilitySwitchCard extends ConsumerWidget {
  const VisibilitySwitchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRegiData = ref.watch(registrationProvider);
    final regiData = asyncRegiData.requireValue;

    final Widget show = IconButton(
      icon: const Icon(Icons.visibility),
      onPressed: () =>
          ref.read(registrationProvider.notifier).toggleIsShowing(false),
    );

    final Widget hidden = IconButton(
      icon: const Icon(Icons.visibility_off),
      onPressed: () =>
          ref.read(registrationProvider.notifier).toggleIsShowing(true),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              regiData.vocab.isShow ? '常に翻訳でこの訳を用いる' : '翻訳でこの訳を使わない',
              style: const TextStyle(fontSize: 16),
            ),
            regiData.vocab.isShow ? show : hidden,
          ],
        ),
      ),
    );
  }
}
