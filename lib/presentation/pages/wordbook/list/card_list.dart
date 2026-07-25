import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/domain/entity/model/book_data.dart';
import 'package:edb/presentation/pages/wordbook/list/book_card.dart';
import 'package:edb/presentation/pages/wordbook/list/book_footer.dart';
import 'package:edb/presentation/view_models/sorting_notifier.dart';

class MyBookCardList extends ConsumerWidget {
  const MyBookCardList({super.key, required this.state});

  final BookData state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordEntries = state.cards;

    // リストが空の場合
    final searchQuery = ref.watch(sortingProvider).searchWord;
    final displayQuery = searchQuery.length > 50
        ? '${searchQuery.substring(0, 50)}...'
        : searchQuery;
    final message = displayQuery.isEmpty
        ? '単語帳にはまだ単語が登録されていません。'
        : '「$displayQuery」に一致する単語は見つかりませんでした。';

    // 検索結果・データが空の場合
    if (state.isDataEnd && wordEntries.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(message)),
      );
    }

    // データがある場合
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == wordEntries.length) return const MyBookFooter();
        return MyBookCard(card: wordEntries[index]);
      }, childCount: wordEntries.length + 1),
    );
  }
}
