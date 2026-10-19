// -----------------------------------------------------------------------------
// - 正常系（load）:
//   - 何も保存されていないとき、SettingData の初期値が返ること
//   - 保存済みの値（apiUrl / useTranslationApi / useDictionaryApi）が返ること
//   - 一部の項目だけが保存されているとき、残りの項目は初期値になること
//
// - 正常系（save）:
//   - 3つの項目が、決められたキー（api_url / use_translation_api / use_dictionary_api）で保存されること
//   - save したあとに load すると、同じ内容が返ること
//   - 保存済みの設定を、別の内容で上書きできること
//   - 空文字の apiUrl を保存したとき、load でも空文字が返ること（初期値に戻らない）
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edb/data/repository_impl/local_setting_repository.dart';
import 'package:edb/domain/model/value_object/setting_data.dart';

// ---------------------------------------------------------------------------
// 定数・ヘルパー
// ---------------------------------------------------------------------------
// 端末に保存されるキー。変更すると、保存済みの設定が読めなくなるため、ここで固定して検証する
const _urlKey = 'api_url';
const _translationKey = 'use_translation_api';
const _dictionaryKey = 'use_dictionary_api';

// 初期値を差し込んだ SharedPreferences（インメモリ）と、それを使うリポジトリを作る
Future<(SharedPreferences, LocalSettingRepository)> _build([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return (prefs, LocalSettingRepository(prefs));
}

// ---------------------------------------------------------------------------
// テスト
// ---------------------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalSettingRepository', () {
    group('load', () {
      test('何も保存されていないとき、SettingData の初期値が返ること', () async {
        final (_, repository) = await _build();

        final result = repository.load();

        const defaults = SettingData();
        expect(result.apiUrl, defaults.apiUrl);
        expect(result.useTranslationApi, defaults.useTranslationApi);
        expect(result.useDictionaryApi, defaults.useDictionaryApi);
      });

      test('保存済みの値が返ること', () async {
        final (_, repository) = await _build({
          _urlKey: 'https://example.com',
          _translationKey: true,
          _dictionaryKey: true,
        });

        final result = repository.load();

        expect(result.apiUrl, 'https://example.com');
        expect(result.useTranslationApi, isTrue);
        expect(result.useDictionaryApi, isTrue);
      });

      test('一部の項目だけが保存されているとき、残りの項目は初期値になること', () async {
        final (_, repository) = await _build({_translationKey: true});

        final result = repository.load();

        const defaults = SettingData();
        expect(result.useTranslationApi, isTrue);
        expect(result.apiUrl, defaults.apiUrl);
        expect(result.useDictionaryApi, defaults.useDictionaryApi);
      });
    });

    group('save', () {
      test('3つの項目が、決められたキーで保存されること', () async {
        final (prefs, repository) = await _build();

        await repository.save(
          settings: const SettingData(
            apiUrl: 'https://example.com',
            useTranslationApi: true,
            useDictionaryApi: false,
          ),
        );

        expect(prefs.getString(_urlKey), 'https://example.com');
        expect(prefs.getBool(_translationKey), isTrue);
        expect(prefs.getBool(_dictionaryKey), isFalse);
      });

      test('save したあとに load すると、同じ内容が返ること', () async {
        final (_, repository) = await _build();
        const saved = SettingData(
          apiUrl: 'http://192.168.0.1:8000',
          useTranslationApi: false,
          useDictionaryApi: true,
        );

        await repository.save(settings: saved);
        final result = repository.load();

        expect(result, saved);
      });

      test('保存済みの設定を、別の内容で上書きできること', () async {
        final (_, repository) = await _build({
          _urlKey: 'https://old.example.com',
          _translationKey: true,
          _dictionaryKey: true,
        });
        const updated = SettingData(
          apiUrl: 'https://new.example.com',
          useTranslationApi: false,
          useDictionaryApi: false,
        );

        await repository.save(settings: updated);
        final result = repository.load();

        expect(result, updated);
      });

      test('空文字の apiUrl を保存したとき、load でも空文字が返ること', () async {
        final (_, repository) = await _build({_urlKey: 'https://example.com'});

        await repository.save(settings: const SettingData(apiUrl: ''));
        final result = repository.load();

        // 「未保存」ではなく「空文字を保存した」ので、初期値（API_URL）には戻らない
        expect(result.apiUrl, '');
        expect(result.hasUrl, isFalse);
      });
    });
  });
}
