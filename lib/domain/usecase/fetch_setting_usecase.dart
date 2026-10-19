import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';

final fetchSettingUseCaseProvider = Provider(
  (ref) => FetchSettingUseCase(ref.watch(settingRepositoryProvider)),
);

class FetchSettingUseCase {
  final SettingRepository _repository;
  FetchSettingUseCase(this._repository);

  SettingData execute() {
    return _repository.load();
  }
}
