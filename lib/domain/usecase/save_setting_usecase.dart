import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';

final saveSettingUseCaseProvider = Provider(
  (ref) => SaveApiSettingsUseCase(ref.watch(settingRepositoryProvider)),
);

class SaveApiSettingsUseCase {
  final SettingRepository _repository;
  SaveApiSettingsUseCase(this._repository);

  // URLを整えて検証し、問題がなければ保存する。保存した（整形後の）設定を返す。
  Future<SettingData> execute({required SettingData settings}) async {
    final url = SettingData.normalizeUrl(settings.apiUrl);
    if (!SettingData.isValidUrl(url)) {
      throw FormatException('APIのURLが正しくありません: ${settings.apiUrl}');
    }

    final normalizedSetting = settings.copyWith(apiUrl: url);
    await _repository.save(settings: normalizedSetting);
    return normalizedSetting;
  }
}
