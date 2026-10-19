// -----------------------------------------------------------------------------
// - 正常系（新規登録: based が vocabularies 以外）:
//   - addVocabulary が card.vocab を引数に1回呼ばれること
//   - updateVocabulary が呼ばれないこと
//   - 返り値の vocabId が addVocabulary の返り値の id になること
//   - 返り値の nowShow が card.nowShow になること
//   - 元の TokenData の id / showWord / translation が変わらないこと
//
// - 正常系（新規登録: based が remote）:
//   - addVocabulary が card.vocab を引数に1回呼ばれること
//   - updateVocabulary が呼ばれないこと
//   - 返り値の vocabId が addVocabulary の返り値の id になり、remote のトークンではなくなること（isRemote が false）
//   - 返り値の nowShow が card.nowShow になること
//   - 返り値の translation が addVocabulary の返り値の translation になること
//   - 元の TokenData の id / showWord が変わらないこと
//
// - 正常系（更新: based が vocabularies）:
//   - updateVocabulary が card.vocab を引数に1回呼ばれること
//   - addVocabulary が呼ばれないこと
//   - 返り値の vocabId が updateVocabulary の返り値の id になること
//   - 返り値の nowShow が card.nowShow になること
//   - 元の TokenData の id / showWord / translation が変わらないこと
//
// - 異常系:
//   - addVocabulary が Exception をthrowしたとき、usecase もそのまま投げること
//   - updateVocabulary が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/save_register_usecase.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/enum/base_status.dart';

// RegisterRepositoryのモッククラスを作成
class MockRegisterRepository extends Mock implements RegisterRepository {}

// mocktailで any() を独自クラスに適用するためのFakeクラス
class FakeVocabCore extends Fake implements VocabCore {}

void main() {
  late MockRegisterRepository mockRepository;
  late SaveRegisterUseCase useCase;

  setUpAll(() {
    // mocktailで any(named: 'vocab') を使用するために必要
    registerFallbackValue(FakeVocabCore());
  });

  setUp(() {
    mockRepository = MockRegisterRepository();
    useCase = SaveRegisterUseCase(mockRepository);
  });

  group('SaveRegisterUseCase', () {
    // テスト共通で使用するダミーデータのベース
    final now = DateTime.now();

    final baseVocab = VocabCore(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'test memo',
      createdAt: now,
      updatedAt: now,
      based: Based.init,
    );

    final testToken = TokenData(
      id: 1,
      vocabId: 10,
      showWord: 'Apple',
      nowShow: true,
      translation: 'りんご',
    );

    group('正常系（新規登録: based が vocabularies 以外）', () {
      test('addVocabulary が呼ばれ、期待通りのTokenDataが返却されること', () async {
        // Arrange: basedをvocabularies以外（dictionaryなど）に設定
        final testVocab = baseVocab.copyWith(based: Based.dictionary);
        // リポジトリから返される想定の新しいVocabCore（IDが採番されたと仮定）
        final expectedVocabCore = testVocab.copyWith(id: 999);

        when(
          () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
        ).thenAnswer((_) async => expectedVocabCore);

        // Act: ユースケースの実行
        final result = await useCase.execute(
          vocab: testVocab,
          token: testToken,
        );

        // Assert:
        // 1. addVocabulary が vocab を引数に1回呼ばれること
        verify(() => mockRepository.addVocabulary(vocab: testVocab)).called(1);

        // 2. updateVocabulary が呼ばれないこと
        verifyNever(
          () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
        );

        // 3. 返り値の vocabId が addVocabulary の返り値の id になること
        expect(result.vocabId, 999);

        // 4. 返り値の nowShow が card.nowShow になること
        expect(result.nowShow, testToken.nowShow);

        // 5. 元の TokenData の id / showWord / translation が変わらないこと
        expect(result.id, testToken.id);
        expect(result.showWord, testToken.showWord);
        expect(result.translation, testToken.translation);
      });
    });

    group('正常系（新規登録: based が remote）', () {
      test('addVocabulary が呼ばれ、remote のトークンが通常の登録済みトークンになって返却されること', () async {
        // Arrange: 外部APIの訳を表示中のトークン（vocabId: -2）から、登録用の VocabCore を作る
        final remoteToken = TokenData(
          id: 1,
          vocabId: TokenData.remoteVocabId,
          showWord: 'Apple',
          nowShow: true,
          translation: 'API訳',
        );
        final testVocab = VocabCore.fromToken(
          remoteToken,
        ).copyWith(isShow: true, memo: 'api memo');
        expect(testVocab.based, Based.remote); // 前提の確認

        // リポジトリから返される想定の新しいVocabCore（IDが採番され、単語帳の行になる）
        final expectedVocabCore = testVocab.copyWith(
          id: 777,
          based: Based.vocabularies,
        );

        when(
          () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
        ).thenAnswer((_) async => expectedVocabCore);

        // Act: ユースケースの実行
        final result = await useCase.execute(
          vocab: testVocab,
          token: remoteToken,
        );

        // Assert:
        // 1. addVocabulary が vocab を引数に1回呼ばれること
        verify(() => mockRepository.addVocabulary(vocab: testVocab)).called(1);

        // 2. updateVocabulary が呼ばれないこと
        verifyNever(
          () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
        );

        // 3. 返り値の vocabId が採番された id になり、remote のトークンではなくなること
        expect(result.vocabId, 777);
        expect(result.isRemote, isFalse);
        expect(result.isNoRegistered, isFalse);

        // 4. 返り値の nowShow が card.nowShow になること
        expect(result.nowShow, remoteToken.nowShow);

        // 5. 返り値の translation が addVocabulary の返り値の translation になること
        expect(result.translation, expectedVocabCore.translation);

        // 6. 元の TokenData の id / showWord が変わらないこと
        expect(result.id, remoteToken.id);
        expect(result.showWord, remoteToken.showWord);
      });
    });

    group('正常系（更新: based が vocabularies）', () {
      test('updateVocabulary が呼ばれ、期待通りのTokenDataが返却されること', () async {
        // Arrange: basedをvocabulariesに設定
        final testVocab = baseVocab.copyWith(based: Based.vocabularies);
        final expectedVocabCore = testVocab.copyWith(id: 888);

        when(
          () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
        ).thenAnswer((_) async => expectedVocabCore);

        // Act: ユースケースの実行
        final result = await useCase.execute(
          vocab: testVocab,
          token: testToken,
        );

        // Assert:
        // 1. updateVocabulary が card.vocab を引数に1回呼ばれること
        verify(
          () => mockRepository.updateVocabulary(vocab: testVocab),
        ).called(1);

        // 2. addVocabulary が呼ばれないこと
        verifyNever(
          () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
        );

        // 3. 返り値の vocabId が updateVocabulary の返り値の id になること
        expect(result.vocabId, 888);

        // 4. 返り値の nowShow が card.nowShow になること
        expect(result.nowShow, testToken.nowShow);

        // 5. 元の TokenData の id / showWord / translation が変わらないこと
        expect(result.id, testToken.id);
        expect(result.showWord, testToken.showWord);
        expect(result.translation, testToken.translation);
      });
    });

    group('異常系', () {
      test(
        'addVocabulary が Exception を throw したとき、usecase もそのまま投げること',
        () async {
          // Arrange: 新規登録ルートを通るデータを用意
          final testVocab = baseVocab.copyWith(based: Based.init);
          final testException = Exception('レポジトリでの新規登録エラー');

          when(
            () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッドが呼ばれたかを検証
          expect(
            () => useCase.execute(vocab: testVocab, token: testToken),
            throwsA(equals(testException)),
          );
        },
      );

      test(
        'updateVocabulary が Exception を throw したとき、usecase もそのまま投げること',
        () async {
          // Arrange: 更新ルートを通るデータを用意
          final testVocab = baseVocab.copyWith(based: Based.vocabularies);
          final testException = Exception('レポジトリでの更新エラー');

          when(
            () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッドが呼ばれたかを検証
          expect(
            () => useCase.execute(vocab: testVocab, token: testToken),
            throwsA(equals(testException)),
          );
        },
      );
    });
  });
}
