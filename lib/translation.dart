import 'package:flutter/material.dart';

// 翻訳モード画面
class TranslationModePage extends StatelessWidget {
  const TranslationModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '翻訳モード',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
