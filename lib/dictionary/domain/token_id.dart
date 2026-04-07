import 'package:flutter_riverpod/flutter_riverpod.dart';

// 検索キーワードの状態を管理する Provider
final tokenIdProvider = NotifierProvider<TokenIdNotifier, int>(
  () => TokenIdNotifier(),
);

// 確定済みの検索クエリを管理する Notifier
class TokenIdNotifier extends Notifier<int> {
  @override
  int build() {
    return -1;
  }

  void updateNum(int num) {
    // 変わっていなければ何もしない
    if (state == num) return;
    state = num;
  }
}
