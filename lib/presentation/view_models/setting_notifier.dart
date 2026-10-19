import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/repository_abstract/dictionary_repository.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';
import 'package:edb/domain/usecase/fetch_setting_usecase.dart';
import 'package:edb/domain/usecase/save_setting_usecase.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingData>(
  () => SettingsNotifier(),
);

// 保存済みのAPI設定を管理
class SettingsNotifier extends Notifier<SettingData> {
  @override
  SettingData build() {
    return ref.watch(fetchSettingUseCaseProvider).execute();
  }

  // 設定を保存し、翻訳・辞書の処理を新しい設定で作り直す
  Future<void> save({required SettingData settings}) async {
    final saved = await ref
        .read(saveSettingUseCaseProvider)
        .execute(settings: settings);
    state = saved;

    // 次回の翻訳・辞書検索から、新しい設定が使われるようにする
    ref.invalidate(textProcessorProvider);
    ref.invalidate(dictionaryRepositoryProvider);
  }
}
