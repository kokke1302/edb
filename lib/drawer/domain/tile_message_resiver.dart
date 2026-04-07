import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providerを定義
final tileMessageProvider = NotifierProvider<TileMessageNotifier, String>(
  () => TileMessageNotifier(),
);

// Notifierクラスを定義
class TileMessageNotifier extends Notifier<String> {
  // stateの初期値を設定
  @override
  String build() {
    return '';
  }

  // stateを更新するメソッド
  void setString({required String text}) {
    state = text;
  }
}
