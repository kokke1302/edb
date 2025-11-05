import 'package:flutter/material.dart';

import 'package:edb/wordbook/presentation/search_fab/setting_dialog.dart';

class MySettingFab extends StatelessWidget {
  const MySettingFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: '検索とフィルタ',
      child: const Icon(Icons.search),
      onPressed: () {
        // Dialogを表示するメソッド
        showDialog(
          context: context,
          barrierDismissible: true, // ダイアログの外側をタップして閉じれる
          builder: (BuildContext dialogContext) {
            return SettingsSheet();
          },
        );
      },
    );
  }
}
