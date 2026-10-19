// -----------------------------------------------------------------------------
// - 正常系（URL の整形）:
//   - URL の前後の空白と末尾の「/」が取り除かれ、整形後の設定が save に1回渡されること
//   - 返り値が整形後の設定になること
//   - 整形の必要がない URL はそのまま保存されること
//   - 空文字の URL は有効として、そのまま保存されること
//   - 空白のみの URL は空文字に整形されて保存されること
//
// - 正常系（URL 以外の項目）:
//   - useTranslationApi / useDictionaryApi が変更されずに保存されること
//
// - 異常系（URL の検証）:
//   - スキームがない・http/https 以外・ホストがない URL のとき、FormatException が投げられること
//   - そのとき例外メッセージに入力された URL が含まれること
//   - そのとき save が呼ばれないこと
//
// - 異常系（保存の失敗）:
//   - save が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/domain/repository_abstract/setting_repository.dart';
import 'package:edb/domain/usecase/save_setting_usecase.dart';

// SettingRepositoryのモッククラスを作成
class MockSettingRepository extends Mock implements SettingRepository {}

void main() {
  late MockSettingRepository mockRepository;
  late SaveSettingsUseCase useCase;

  setUpAll(() {
    // mocktailで any(named: 'settings') を使用するために必要
    registerFallbackValue(const SettingData(apiUrl: ''));
  });

  setUp(() {
    mockRepository = MockSettingRepository();
    useCase = SaveSettingsUseCase(mockRepository);

    // デフォルトは「保存に成功する」
    when(
      () => mockRepository.save(settings: any(named: 'settings')),
    ).thenAnswer((_) async {});
  });

  group('SaveApiSettingsUseCase', () {
    group('正常系（URL の整形）', () {
      test('URL の前後の空白と末尾の「/」が取り除かれ、整形後の設定が save に1回渡されること', () async {
        // Arrange
        const input = SettingData(
          apiUrl: '  https://example.com///  ',
          useTranslationApi: true,
          useDictionaryApi: true,
        );

        // Act
        await useCase.execute(settings: input);

        // Assert
        verify(
          () => mockRepository.save(
            settings: const SettingData(
              apiUrl: 'https://example.com',
              useTranslationApi: true,
              useDictionaryApi: true,
            ),
          ),
        ).called(1);
      });

      test('返り値が整形後の設定になること', () async {
        // Arrange
        const input = SettingData(
          apiUrl: ' https://example.com/api/ ',
          useTranslationApi: true,
          useDictionaryApi: false,
        );

        // Act
        final result = await useCase.execute(settings: input);

        // Assert
        expect(result.apiUrl, 'https://example.com/api');
        expect(result.useTranslationApi, isTrue);
        expect(result.useDictionaryApi, isFalse);
      });

      test('整形の必要がない URL はそのまま保存されること', () async {
        // Arrange
        const input = SettingData(apiUrl: 'http://192.168.0.1:8000');

        // Act
        final result = await useCase.execute(settings: input);

        // Assert
        expect(result.apiUrl, 'http://192.168.0.1:8000');
        verify(() => mockRepository.save(settings: result)).called(1);
      });

      test('空文字の URL は有効として、そのまま保存されること', () async {
        // Arrange
        const input = SettingData(apiUrl: '');

        // Act
        final result = await useCase.execute(settings: input);

        // Assert
        expect(result.apiUrl, '');
        verify(() => mockRepository.save(settings: result)).called(1);
      });

      test('空白のみの URL は空文字に整形されて保存されること', () async {
        // Arrange
        const input = SettingData(apiUrl: '   ');

        // Act
        final result = await useCase.execute(settings: input);

        // Assert
        expect(result.apiUrl, '');
        verify(
          () => mockRepository.save(settings: const SettingData(apiUrl: '')),
        ).called(1);
      });
    });

    group('正常系（URL 以外の項目）', () {
      final combinations = <(bool, bool)>[
        (false, false),
        (true, false),
        (false, true),
        (true, true),
      ];

      for (final (translation, dictionary) in combinations) {
        test(
          'useTranslationApi: $translation / useDictionaryApi: $dictionary が変更されずに保存されること',
          () async {
            // Arrange
            final input = SettingData(
              apiUrl: 'https://example.com',
              useTranslationApi: translation,
              useDictionaryApi: dictionary,
            );

            // Act
            final result = await useCase.execute(settings: input);

            // Assert
            expect(result.useTranslationApi, translation);
            expect(result.useDictionaryApi, dictionary);
            verify(() => mockRepository.save(settings: input)).called(1);
          },
        );
      }
    });

    group('異常系（URL の検証）', () {
      final invalidUrls = <String>[
        'example.com', // スキームがない
        'localhost:8000', // スキームがない（ポート付きのホスト名）
        'ftp://example.com', // http / https 以外
        'http://', // ホストがない
        '/api', // 相対パス
      ];

      for (final url in invalidUrls) {
        test('URL が「$url」のとき、FormatException を投げ、save は呼ばれないこと', () async {
          // Arrange
          final input = SettingData(apiUrl: url);

          // Act & Assert: 例外の種類と、入力された URL がメッセージに含まれること
          await expectLater(
            useCase.execute(settings: input),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains(url),
              ),
            ),
          );

          // 検証に失敗したときは保存しない
          verifyNever(
            () => mockRepository.save(settings: any(named: 'settings')),
          );
        });
      }
    });

    group('異常系（保存の失敗）', () {
      test('save が Exception を throw したとき、usecase もそのまま投げること', () async {
        // Arrange
        final testException = Exception('設定の保存エラー');
        when(
          () => mockRepository.save(settings: any(named: 'settings')),
        ).thenThrow(testException);

        // Act & Assert
        await expectLater(
          useCase.execute(
            settings: const SettingData(apiUrl: 'https://example.com'),
          ),
          throwsA(equals(testException)),
        );

        // 例外が発生した場合でも、save が呼ばれていることを確認
        verify(
          () => mockRepository.save(settings: any(named: 'settings')),
        ).called(1);
      });
    });
  });
}
