import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';

final saveRegisterUseCaseProvider = Provider(
  (ref) => SaveRegisterUseCase(ref.watch(registerRepositoryProvider)),
);

// Notifierクラスを定義
class SaveRegisterUseCase {
  final RegisterRepository _repository;
  SaveRegisterUseCase(this._repository);

  Future<TokenData> execute({
    required CardData card,
    required TokenData token,
  }) async {
    // 新規か更新かを判定
    final VocabEntry vocabEntry;
    if (card.vocab.based != Based.vocabularies) {
      vocabEntry = await _repository.addVocabulary(vocab: card.vocab);
    } else {
      vocabEntry = await _repository.updateVocabulary(vocab: card.vocab);
    }

    // 変換して返す
    return token.copyWith(
      vocabId: vocabEntry.id,
      nowShow: card.nowShow,
      translation: vocabEntry.translation,
    );
  }
}
