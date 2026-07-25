import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/presentation/pages/wordbook/search/searchbar.dart';
import 'package:edb/presentation/pages/wordbook/search/sort_dropdown.dart';
import 'package:edb/presentation/pages/wordbook/search/sort_order.dart';
import 'package:edb/presentation/view_models/book_notifier.dart';
import 'package:edb/presentation/view_models/sorting_notifier.dart';

class MyBookSliverAppBar extends HookConsumerWidget {
  const MyBookSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppBar状態管理
    final isSearching = useState(false);

    return SliverAppBar(
      // バーの挙動
      pinned: false,
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,

      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),

        child: isSearching.value
            // ------------------------------------
            // 検索モード時のUI
            // ------------------------------------
            ? Row(
                key: const ValueKey('SearchingBar'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => isSearching.value = false,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: "戻る",
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: MySearchBar()),
                ],
              )
            // ------------------------------------
            // 通常時のUI
            // ------------------------------------
            : Row(
                key: const ValueKey('NormalBar'),
                children: [
                  // 検索展開アイコン
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => isSearching.value = true,
                    tooltip: '検索',
                  ),

                  // 並べ替えアイコン
                  const MySortOrderButton(),
                  const MySortDropdownMenu(),
                  const SizedBox(width: 10),

                  // アクションアイコン
                  IconButton(
                    onPressed: () {
                      ref.invalidate(sortingProvider);
                      ref.invalidate(bookProvider);
                    },
                    icon: const Icon(Icons.home),
                    tooltip: "初期状態へ戻す",
                  ),
                  IconButton(
                    onPressed: () => ref.read(bookProvider.notifier).reload(),
                    icon: const Icon(Icons.loop),
                    tooltip: "再取得",
                  ),
                  const SizedBox(width: 10),
                ],
              ),
      ),
    );
  }
}
