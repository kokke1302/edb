import 'package:flutter/material.dart';

// 翻訳モード画面
class WordbookModePage extends StatelessWidget {
  const WordbookModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '単語帳モード',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
