// -----------------------------------------------------------------------------
// - 正常系（新規登録: based が vocabularies 以外）:
//   - addVocabulary が card.vocab を引数に1回呼ばれること
//   - updateVocabulary が呼ばれないこと
//   - 返り値の vocabId が addVocabulary の返り値の id になること
//   - 返り値の nowShow が card.nowShow になること
//   - 元の TokenData の id / showWord / translation が変わらないこと
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
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';

// RegisterRepositoryのモッククラスを作成
class MockRegisterRepository extends Mock implements RegisterRepository {}

// mocktailで any() を独自クラスに適用するためのFakeクラス
class FakeVocabEntry extends Fake implements VocabEntry {}

void main() {
  late MockRegisterRepository mockRepository;
  late SaveRegisterUseCase useCase;

  setUpAll(() {
    // mocktailで any(named: 'vocab') を使用するために必要
    registerFallbackValue(FakeVocabEntry());
  });

  setUp(() {
    mockRepository = MockRegisterRepository();
    useCase = SaveRegisterUseCase(mockRepository);
  });

  group('SaveRegisterUseCase', () {
    // テスト共通で使用するダミーデータのベース
    final now = DateTime.now();

    final baseVocab = VocabEntry(
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
        final cardVocab = baseVocab.copyWith(based: Based.dictionary);
        final card = CardData(nowShow: false, vocab: cardVocab);

        // リポジトリから返される想定の新しいVocabEntry（IDが採番されたと仮定）
        final expectedVocabEntry = cardVocab.copyWith(id: 999);

        when(
          () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
        ).thenAnswer((_) async => expectedVocabEntry);

        // Act: ユースケースの実行
        final result = await useCase.execute(card: card, token: testToken);

        // Assert:
        // 1. addVocabulary が card.vocab を引数に1回呼ばれること
        verify(() => mockRepository.addVocabulary(vocab: card.vocab)).called(1);

        // 2. updateVocabulary が呼ばれないこと
        verifyNever(
          () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
        );

        // 3. 返り値の vocabId が addVocabulary の返り値の id になること
        expect(result.vocabId, 999);

        // 4. 返り値の nowShow が card.nowShow になること
        expect(result.nowShow, card.nowShow);

        // 5. 元の TokenData の id / showWord / translation が変わらないこと
        expect(result.id, testToken.id);
        expect(result.showWord, testToken.showWord);
        expect(result.translation, testToken.translation);
      });
    });

    group('正常系（更新: based が vocabularies）', () {
      test('updateVocabulary が呼ばれ、期待通りのTokenDataが返却されること', () async {
        // Arrange: basedをvocabulariesに設定
        final cardVocab = baseVocab.copyWith(based: Based.vocabularies);
        final card = CardData(nowShow: true, vocab: cardVocab);

        // リポジトリから返される想定の更新後のVocabEntry
        final expectedVocabEntry = cardVocab.copyWith(id: 888);

        when(
          () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
        ).thenAnswer((_) async => expectedVocabEntry);

        // Act: ユースケースの実行
        final result = await useCase.execute(card: card, token: testToken);

        // Assert:
        // 1. updateVocabulary が card.vocab を引数に1回呼ばれること
        verify(
          () => mockRepository.updateVocabulary(vocab: card.vocab),
        ).called(1);

        // 2. addVocabulary が呼ばれないこと
        verifyNever(
          () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
        );

        // 3. 返り値の vocabId が updateVocabulary の返り値の id になること
        expect(result.vocabId, 888);

        // 4. 返り値の nowShow が card.nowShow になること
        expect(result.nowShow, card.nowShow);

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
          final cardVocab = baseVocab.copyWith(based: Based.init);
          final card = CardData(nowShow: true, vocab: cardVocab);
          final testException = Exception('レポジトリでの新規登録エラー');

          when(
            () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッドが呼ばれたかを検証
          expect(
            () => useCase.execute(card: card, token: testToken),
            throwsA(equals(testException)),
          );
          verify(
            () => mockRepository.addVocabulary(vocab: card.vocab),
          ).called(1);
          verifyNever(
            () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
          );
        },
      );

      test(
        'updateVocabulary が Exception を throw したとき、usecase もそのまま投げること',
        () async {
          // Arrange: 更新ルートを通るデータを用意
          final cardVocab = baseVocab.copyWith(based: Based.vocabularies);
          final card = CardData(nowShow: true, vocab: cardVocab);
          final testException = Exception('レポジトリでの更新エラー');

          when(
            () => mockRepository.updateVocabulary(vocab: any(named: 'vocab')),
          ).thenThrow(testException);

          // Act & Assert: 例外の発生と、意図したメソッドが呼ばれたかを検証
          expect(
            () => useCase.execute(card: card, token: testToken),
            throwsA(equals(testException)),
          );
          verify(
            () => mockRepository.updateVocabulary(vocab: card.vocab),
          ).called(1);
          verifyNever(
            () => mockRepository.addVocabulary(vocab: any(named: 'vocab')),
          );
        },
      );
    });
  });
}
