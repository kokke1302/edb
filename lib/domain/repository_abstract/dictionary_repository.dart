import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_dictionary_repository.dart';
import 'package:edb/data/repository_impl/remote_dictionary.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';

// 設定画面の「API URL」と「辞書でAPIを使用する」に従って切り替える
// （URLが空、またはスイッチがオフならローカル処理のみ）。
// 設定の保存時にinvalidateされ、次回の辞書検索から反映される。
final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final local = LocalDictionaryRepository(db);
  final settings = ref.watch(settingRepositoryProvider).load();

  final canUseDictionaryApi = settings.hasUrl && settings.useDictionaryApi;
  if (!canUseDictionaryApi) return local;

  return RemoteDictionaryRepository(
    local: local,
    endpoint: settings.dictionaryEndpoint,
  );
});

abstract interface class DictionaryRepository {
  Future<List<VocabCore>> fetchVocabularies({required String word});
  Future<List<VocabCore>> fetchDictionaries({required String word});
}
