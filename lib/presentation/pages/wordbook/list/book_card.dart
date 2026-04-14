import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/presentation/view_models/regidata_receiver.dart';

class MyBookCard extends ConsumerWidget {
  final CardData card;
  const MyBookCard({super.key, required this.card});

  // 日付を「YYYY/MM/DD」形式でフォーマットするヘルパー関数
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedDate = _formatDate(card.vocab.updatedAt);

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
                      card.vocab.word,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
                      card.vocab.translation,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,

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
                    card.vocab.memo,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),

                // isHidden (非表示フラグ) アイコン
                if (!card.vocab.isShow)
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

                // 編集アイコン
                IconButton(
                  onPressed: () {
                    ref
                        .read(regiDataReceiver.notifier)
                        .receiveRegisteredCard(card: card);
                    context.push('/registration');
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
