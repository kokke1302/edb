import 'package:flutter/material.dart';

import 'package:edb/db/app_database.dart';

class MyWordCard extends StatelessWidget {
  final Vocabulary entry;
  const MyWordCard({super.key, required this.entry});

  // 日付を「YYYY/MM/DD」形式でフォーマットするヘルパー関数
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final updatedDate = _formatDate(entry.updatedAt);

    return Card(
      elevation: 3, // 少し影を濃くして立体感を出す
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // 周りの余白
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 角を丸くする
      ),

      child: Column(
        children: [
          // 1. 上段: 英単語と日本語訳（左右分割・中央揃え）
          SizedBox(
            height: 100,
            child: Row(
              // 一番高さが大きいウィジェットに子ウィジェットの高さを合わせる
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左側: 英単語
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center, // マス内で中央揃え
                    child: Text(
                      entry.englishWord,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade, // 制限した場合の処理

                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                // 垂直の区切り線
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),

                // 右側: 日本語訳
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text(
                      entry.japaneseTranslation,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,

                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. 下段: メモ、非表示アイコン、日時情報
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // メモ
                Expanded(
                  child: Text(
                    entry.memo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),

                // isHidden (非表示フラグ) アイコン
                if (entry.isHidden)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.visibility_off,
                      color: Colors.grey[700],
                      size: 18,
                    ),
                  ),

                // 更新日時
                Text(
                  '更新: $updatedDate',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
