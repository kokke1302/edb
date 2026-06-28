import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/repository_impl/local_text_processor.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';
import 'package:edb/domain/entity/token_data.dart';

final textProcessorProvider = Provider<TextProcessor>((ref) {
  final db = ref.watch(translationRepositoryProvider);
  return LocalTextProcessor(db);
});

abstract interface class TextProcessor {
  Future<List<TokenData>> partTranslation({
    required List<TokenData> nowTokens,
    required String newText,
  });
  Future<List<TokenData>> fullTranslation({required String text});
}
