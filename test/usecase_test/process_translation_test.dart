// -----------------------------------------------------------------------------
// - 正常系（早期リターン）:
//   - text が空文字のとき、空リストが返ること
//   - text が空文字のとき、fullTranslation も partTranslation も呼ばれないこと
//
// - 正常系（fullTranslation: isFullScan が true）:
//   - fullTranslation が text を引数に1回呼ばれること
//   - partTranslation が呼ばれないこと
//   - fullTranslation の返り値がそのまま返ること
//
// - 正常系（partTranslation: isFullScan が false）:
//   - partTranslation が currentTokens と text を引数に1回呼ばれること
//   - fullTranslation が呼ばれないこと
//   - partTranslation の返り値がそのまま返ること
//
// - 異常系:
//   - fullTranslation が Exception をthrowしたとき、usecase もそのまま投げること
//   - partTranslation が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/process_translation_usecase.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';
import 'package:edb/domain/entity/model/token_data.dart';

// TextProcessorのモッククラスを作成
class MockTextProcessor extends Mock implements TextProcessor {}

// mocktailで any(named: 'nowTokens') を使用するためのFakeクラス
class FakeTokenData extends Fake implements TokenData {}

void main() {
  late MockTextProcessor mockProcessor;
  late ProcessTranslationUseCase useCase;

  setUpAll(() {
    // mocktailでリスト型やカスタムクラスのany引数を解決するために必要
    registerFallbackValue(FakeTokenData());
  });

  setUp(() {
    mockProcessor = MockTextProcessor();
    useCase = ProcessTranslationUseCase(mockProcessor);
  });

  group('ProcessTranslationUseCase', () {
    // テスト共通で使用するダミーデータ
    final testTokens = [
      TokenData(
        id: 1,
        vocabId: 4,
        showWord: 'Hello',
        nowShow: true,
        translation: 'こんにちは',
      ),
      TokenData(
        id: 2,
        vocabId: 10,
        showWord: 'Apple',
        nowShow: true,
        translation: 'りんご',
      ),
    ];

    final expectedTokens = [
      TokenData(
        id: 1,
        vocabId: 4,
        showWord: 'Hello',
        nowShow: true,
        translation: 'こんにちは',
      ),
      TokenData(
        id: 2,
        vocabId: 5,
        showWord: 'World',
        nowShow: true,
        translation: '世界',
      ),
    ];

    group('正常系（早期リターン）', () {
      test('text が空文字のとき、空リストが返ること、またメソッドが呼ばれないこと', () async {
        // Act: ユースケースの実行（空文字）
        final result = await useCase.execute(
          text: '',
          currentTokens: testTokens,
          isFullScan: true,
        );

        // Assert:
        // 1. text が空文字のとき、空リストが返ること
        expect(result, isEmpty);

        // 2. text が空文字のとき、fullTranslation も partTranslation も呼ばれないこと
        verifyNever(
          () => mockProcessor.fullTranslation(text: any(named: 'text')),
        );
        verifyNever(
          () => mockProcessor.partTranslation(
            nowTokens: any(named: 'nowTokens'),
            newText: any(named: 'newText'),
          ),
        );
      });
    });

    group('正常系（fullTranslation: isFullScan が true）', () {
      test('fullTranslation が適切に呼び出され、その返り値がそのまま返ること', () async {
        // Arrange: isFullScan が true の場合のモック動作を定義
        when(
          () => mockProcessor.fullTranslation(text: any(named: 'text')),
        ).thenAnswer((_) async => expectedTokens);

        // Act: ユースケースの実行
        final result = await useCase.execute(
          text: 'Hello World',
          currentTokens: testTokens,
          isFullScan: true,
        );

        // Assert:
        // 1. fullTranslation が text を引数に1回呼ばれること
        verify(
          () => mockProcessor.fullTranslation(text: 'Hello World'),
        ).called(1);

        // 2. partTranslation が呼ばれないこと
        verifyNever(
          () => mockProcessor.partTranslation(
            nowTokens: any(named: 'nowTokens'),
            newText: any(named: 'newText'),
          ),
        );

        // 3. fullTranslation の返り値がそのまま返ること
        expect(result, expectedTokens);
      });
    });

    group('正常系（partTranslation: isFullScan が false）', () {
      test('partTranslation が適切に呼び出され、その返り値がそのまま返ること', () async {
        // Arrange: isFullScan が false の場合のモック動作を定義
        when(
          () => mockProcessor.partTranslation(
            nowTokens: any(named: 'nowTokens'),
            newText: any(named: 'newText'),
          ),
        ).thenAnswer((_) async => expectedTokens);

        // Act: ユースケースの実行
        final result = await useCase.execute(
          text: 'Hello World',
          currentTokens: testTokens,
          isFullScan: false,
        );

        // Assert:
        // 1. partTranslation が currentTokens と text を引数に1回呼ばれること
        verify(
          () => mockProcessor.partTranslation(
            nowTokens: testTokens,
            newText: 'Hello World',
          ),
        ).called(1);

        // 2. fullTranslation が呼ばれないこと
        verifyNever(
          () => mockProcessor.fullTranslation(text: any(named: 'text')),
        );

        // 3. partTranslation の返り値がそのまま返ること
        expect(result, expectedTokens);
      });
    });

    group('異常系', () {
      test(
        'fullTranslation が Exception をthrowしたとき、usecase もそのまま投げること',
        () async {
          // Arrange: fullTranslation が例外を投げるよう設定
          final testException = Exception('フル翻訳処理のエラー');
          when(
            () => mockProcessor.fullTranslation(text: any(named: 'text')),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッド呼び出しの検証
          expect(
            () => useCase.execute(
              text: 'ErrorText',
              currentTokens: testTokens,
              isFullScan: true,
            ),
            throwsA(equals(testException)),
          );

          verify(
            () => mockProcessor.fullTranslation(text: 'ErrorText'),
          ).called(1);
          verifyNever(
            () => mockProcessor.partTranslation(
              nowTokens: any(named: 'nowTokens'),
              newText: any(named: 'newText'),
            ),
          );
        },
      );

      test(
        'partTranslation が Exception をthrowしたとき、usecase もそのまま投げること',
        () async {
          // Arrange: partTranslation が例外を投げるよう設定
          final testException = Exception('部分翻訳処理のエラー');
          when(
            () => mockProcessor.partTranslation(
              nowTokens: any(named: 'nowTokens'),
              newText: any(named: 'newText'),
            ),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッド呼び出しの検証
          expect(
            () => useCase.execute(
              text: 'ErrorText',
              currentTokens: testTokens,
              isFullScan: false,
            ),
            throwsA(equals(testException)),
          );

          verify(
            () => mockProcessor.partTranslation(
              nowTokens: testTokens,
              newText: 'ErrorText',
            ),
          ).called(1);
          verifyNever(
            () => mockProcessor.fullTranslation(text: any(named: 'text')),
          );
        },
      );
    });
  });
}
