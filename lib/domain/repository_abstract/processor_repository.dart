import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/repository_impl/local_text_processor.dart';
import 'package:edb/data/repository_impl/remote_text_processor.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';
import 'package:edb/domain/model/value_object/token_data.dart';

// 設定画面の「API URL」と「翻訳でAPIを使用する」に従って切り替える
// （URLが空、またはスイッチがオフならローカル処理のみ）。
// 設定の保存時にinvalidateされ、次回の翻訳から反映される。
final textProcessorProvider = Provider<TextProcessor>((ref) {
  final translationRepository = ref.watch(translationRepositoryProvider);
  final local = LocalTextProcessor(translationRepository);
  final settings = ref.watch(settingRepositoryProvider).load();

  final canUseTranslationApi = settings.hasUrl && settings.useTranslationApi;
  if (!canUseTranslationApi) return local;

  return RemoteTextProcessor(
    local: local,
    endpoint: settings.translateEndpoint,
  );
});

abstract interface class TextProcessor {
  Future<List<TokenData>> partTranslation({
    required List<TokenData> nowTokens,
    required String newText,
  });
  Future<List<TokenData>> fullTranslation({required String text});
}
