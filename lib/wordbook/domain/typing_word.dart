import 'package:flutter_riverpod/flutter_riverpod.dart';

// 検索キーワードの状態を管理する Provider
final typingWordProvider =
    NotifierProvider.autoDispose<TypingWordNotifier, String>(
      () => TypingWordNotifier(),
    );

// 確定済みの検索クエリを管理する Notifier
class TypingWordNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  // 確定クエリをクリアする
  void refresh() {
    state = '';
  }

  // 確定クエリを設定する
  void setQuery(String text) {
    // クエリが変わっていなければ何もしない
    if (state == text) return;
    state = text;
  }
}
