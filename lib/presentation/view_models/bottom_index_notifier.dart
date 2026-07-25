import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, int>(
  () => BottomNavIndexNotifier(),
);

// ボトムナビゲーションバーの選択状態を管理
class BottomNavIndexNotifier extends Notifier<int> {
  // stateの初期値を設定
  @override
  int build() {
    return 0;
  }

  // stateを更新するメソッド
  void setIndex(int newIndex) {
    state = newIndex;
  }
}
