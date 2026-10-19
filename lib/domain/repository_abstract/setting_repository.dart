import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/repository_impl/local_setting_repository.dart';
import 'package:edb/domain/model/value_object/setting_data.dart';

final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  return LocalSettingRepository(ref.watch(sharedPreferencesProvider));
});

abstract interface class SettingRepository {
  // 保存済みの設定を返す。保存済みの値がない項目は、ApiSettingsの初期値になる。
  // Providerの構築時（textProcessorProviderなど）に同期的に使うため、Futureにしない。
  SettingData load();
  Future<void> save({required SettingData settings});
}
