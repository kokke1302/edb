import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// RegistrationNotifierの初期状態を決めるハンドラの提供
final regiDataReceiver = NotifierProvider<RegiDataReceiver, VocabCore>(
  () => RegiDataReceiver(),
);

class RegiDataReceiver extends Notifier<VocabCore> {
  @override
  VocabCore build() {
    // 初期状態（空の状態）を定義
    return VocabCore.init();
  }

  // 単語帳
  void receiveRegiData({required VocabCore vocab}) {
    if (state == vocab) return;
    state = vocab;
  }
}
