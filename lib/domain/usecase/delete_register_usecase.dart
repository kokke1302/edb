import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';

final deleteRegisterUseCaseProvider = Provider(
  (ref) => DeleteRegisterUseCase(ref.watch(registerRepositoryProvider)),
);

class DeleteRegisterUseCase {
  final RegisterRepository _repository;
  DeleteRegisterUseCase(this._repository);

  Future<TokenData> execute({
    required VocabCore vocab,
    required TokenData token,
  }) async {
    // DBから削除
    await _repository.deleteVocabulary(id: vocab.id);

    // 削除後の初期状態のモデルを生成して返す
    return token.copyWith(vocabId: -1, nowShow: false);
  }
}
