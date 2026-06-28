import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/token_data.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';

final processTranslationUseCaseProvider = Provider(
  (ref) => ProcessTranslationUseCase(ref.watch(textProcessorProvider)),
);

class ProcessTranslationUseCase {
  final TextProcessor _processor;
  ProcessTranslationUseCase(this._processor);

  Future<List<TokenData>> execute({
    required String text,
    required List<TokenData> currentTokens,
    required bool isFullScan,
  }) async {
    if (text.isEmpty) return [];

    if (isFullScan) {
      return await _processor.fullTranslation(text: text);
    } else {
      // 部分更新のロジック
      return await _processor.partTranslation(
        nowTokens: currentTokens,
        newText: text,
      );
    }
  }
}
