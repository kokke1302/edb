import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';

final fetchSettingUseCaseProvider = Provider(
  (ref) => FetchSettingsUseCase(ref.watch(settingRepositoryProvider)),
);

class FetchSettingsUseCase {
  final SettingRepository _repository;
  FetchSettingsUseCase(this._repository);

  SettingData execute() {
    return _repository.load();
  }
}
