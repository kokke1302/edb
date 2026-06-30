// -----------------------------------------------------------------------------
// - 正常系:
//   - deleteTile が指定した id を引数に1回呼ばれること
//   - 正常終了すること（例外が投げられないこと）
//
// - 異常系:
//   - deleteTile が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/delete_tile_usecase.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';

// RegisterRepositoryの例と同様に、モッククラスを作成
class MockTilesRepository extends Mock implements TilesRepository {}

void main() {
  late MockTilesRepository mockTilesRepository;
  late DeleteTileUseCase useCase;

  setUp(() {
    mockTilesRepository = MockTilesRepository();
    useCase = DeleteTileUseCase(mockTilesRepository);
  });

  group('DeleteTileUseCase', () {
    const targetId = 42;

    group('正常系', () {
      test('deleteTile が指定した id を引数に1回呼ばれ、正常終了すること', () async {
        // Arrange(準備): 戻り値の設定（Future<void> なので thenAnswer で空のFutureを返す）
        when(
          () => mockTilesRepository.deleteTile(id: any(named: 'id')),
        ).thenAnswer((_) async {});

        // Act(実行) & Assert(検証): 例外が投げられずに正常終了すること
        expect(
          () async => await useCase.execute(id: targetId),
          returnsNormally,
        );

        // Assert(検証): 指定したidで1回呼ばれたこと
        verify(() => mockTilesRepository.deleteTile(id: targetId)).called(1);
      });
    });

    group('異常系', () {
      test(
        'deleteTile が Exception を throw 外部したとき、usecase もそのまま投げること',
        () async {
          // Arrange(準備): 例外を投げるよう戻り値の設定
          final testException = Exception('リポジトリでの削除エラー');
          when(
            () => mockTilesRepository.deleteTile(id: any(named: 'id')),
          ).thenThrow(testException);

          // Act & Assert: 例外がそのまま再スローされることを検証
          expect(
            () async => await useCase.execute(id: targetId),
            throwsA(equals(testException)),
          );

          // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
          verify(() => mockTilesRepository.deleteTile(id: targetId)).called(1);
        },
      );
    });
  });
}
