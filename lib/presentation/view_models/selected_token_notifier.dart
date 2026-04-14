import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/token_data.dart';

// 検索キーワードの状態を管理する Provider
final selectedTokenProvider =
    NotifierProvider<SelectedTokenNotifier, TokenData>(
      () => SelectedTokenNotifier(),
    );

// 確定済みの検索クエリを管理する Notifier
class SelectedTokenNotifier extends Notifier<TokenData> {
  @override
  TokenData build() {
    return TokenData.fromInit();
  }

  void selectNew({required TokenData token}) {
    if (state == token) return;
    state = token;
  }
}
