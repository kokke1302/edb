import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/model/enum/base_status.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';

final saveRegisterUseCaseProvider = Provider(
  (ref) => SaveRegisterUseCase(ref.watch(registerRepositoryProvider)),
);

// Notifierクラスを定義
class SaveRegisterUseCase {
  final RegisterRepository _repository;
  SaveRegisterUseCase(this._repository);

  Future<TokenData> execute({
    required VocabCore vocab,
    required TokenData token,
  }) async {
    // 新規か更新かを判定
    final VocabCore newVocab;
    if (vocab.based != Based.vocabularies) {
      newVocab = await _repository.addVocabulary(vocab: vocab);
    } else {
      newVocab = await _repository.updateVocabulary(vocab: vocab);
    }

    // 変換して返す
    return token.copyWith(
      vocabId: newVocab.id,
      nowShow: token.nowShow,
      translation: newVocab.translation,
    );
  }
}
