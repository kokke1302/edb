// -----------------------------------------------------------------------------
// - 正常系:
//   - deleteVocabulary が card.vocab.id を引数に1回呼ばれること
//   - 返り値の vocabId が -1 になること
//   - 返り値の nowShow が false になること
//   - 元の TokenData の id / showWord / translation が変わらないこと
//
// - 異常系:
//   - deleteVocabulary が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/delete_register_usecase.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';

// RegisterRepositoryのモッククラスを作成
class MockRegisterRepository extends Mock implements RegisterRepository {}

void main() {
  late MockRegisterRepository mockRepository;
  late DeleteRegisterUseCase useCase;

  setUp(() {
    mockRepository = MockRegisterRepository();
    useCase = DeleteRegisterUseCase(mockRepository);
  });

  group('DeleteRegisterUseCase', () {
    // テスト共通で使用するダミーデータのセットアップ
    final testVocab = VocabEntry(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'test memo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      based: Based.init,
    );

    final testCard = CardData(nowShow: true, vocab: testVocab);

    final testToken = TokenData(
      id: 1,
      vocabId: 42,
      showWord: 'Apple',
      nowShow: true,
      translation: 'りんご',
    );

    group('正常系', () {
      test('削除が正常に行われ、期待通りのTokenDataが返却されること', () async {
        // Arrange(準備): 戻り値の設定
        when(
          () => mockRepository.deleteVocabulary(id: any(named: 'id')),
        ).thenAnswer((_) async {});

        // Act(実行): ユースケースの実行
        final result = await useCase.execute(card: testCard, token: testToken);

        // Assert(検証):
        // 1. deleteVocabulary が card.vocab.id を引数に1回呼ばれること
        verify(
          () => mockRepository.deleteVocabulary(id: testCard.vocab.id),
        ).called(1);

        // 2. 返り値の vocabId が -1 になること
        expect(result.vocabId, -1);

        // 3. 返り値の nowShow が false になること
        expect(result.nowShow, false);

        // 4. 元の TokenData の id / showWord / translation が変わらないこと
        expect(result.id, testToken.id);
        expect(result.showWord, testToken.showWord);
        expect(result.translation, testToken.translation);
      });
    });

    group('異常系', () {
      test('repositoryが例外をスローしたとき、ユースケースもそのまま例外を投げること', () async {
        // Arrange(準備): 例外を投げるよう戻り値の設定
        final testException = Exception('データベースの削除に失敗しました');
        when(
          () => mockRepository.deleteVocabulary(id: any(named: 'id')),
        ).thenThrow(testException);

        // Act & Assert: 例外がそのまま再スローされることを検証
        expect(
          () => useCase.execute(card: testCard, token: testToken),
          throwsA(equals(testException)),
        );

        // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
        verify(
          () => mockRepository.deleteVocabulary(id: testCard.vocab.id),
        ).called(1);
      });
    });
  });
}
