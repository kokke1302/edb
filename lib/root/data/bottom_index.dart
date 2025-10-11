import 'package:flutter_riverpod/flutter_riverpod.dart';

// -----------------------------------------------------------------------------
// Riverpod 状態管理
//  - BottomNavIndexNotifier = ボトムナビゲーションバーの選択状態を管理
//  - bottomNavIndexProvider = インスタンス化
// -----------------------------------------------------------------------------

// Providerを定義
final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, int>(
  () => BottomNavIndexNotifier(),
);

// Notifierクラスを定義
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
