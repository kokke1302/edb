import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';

// main()で取得したインスタンスを overrideWithValue して使う
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider は main() で overrideWithValue してください',
  );
});

// 端末内（SharedPreferences）に設定を保存する実装
class LocalSettingRepository implements SettingRepository {
  final SharedPreferences _prefs;
  LocalSettingRepository(this._prefs);

  static const _urlKey = 'api_url';
  static const _translationKey = 'use_translation_api';
  static const _dictionaryKey = 'use_dictionary_api';

  @override
  SettingData load() {
    const defaults = SettingData();
    return SettingData(
      apiUrl: _prefs.getString(_urlKey) ?? defaults.apiUrl,
      useTranslationApi:
          _prefs.getBool(_translationKey) ?? defaults.useTranslationApi,
      useDictionaryApi:
          _prefs.getBool(_dictionaryKey) ?? defaults.useDictionaryApi,
    );
  }

  @override
  Future<void> save({required SettingData settings}) async {
    await _prefs.setString(_urlKey, settings.apiUrl);
    await _prefs.setBool(_translationKey, settings.useTranslationApi);
    await _prefs.setBool(_dictionaryKey, settings.useDictionaryApi);
  }
}
