// -----------------------------------------------------------------------------
// - 正常系:
//   - fetchTileDetail が指定した id を引数に1回呼ばれること
//   - fetchTileDetail の返り値がそのまま返ること
//
// - 異常系:
//   - fetchTileDetail が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/fetch_tile_detail_usecase.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';
import 'package:edb/domain/entity/carry/tile_detail.dart';
import 'package:edb/domain/entity/model/token_data.dart';

// TilesRepositoryのモッククラスを作成
class MockTilesRepository extends Mock implements TilesRepository {}

void main() {
  late MockTilesRepository mockRepository;
  late FetchTileDetailUseCase useCase;

  setUp(() {
    mockRepository = MockTilesRepository();
    useCase = FetchTileDetailUseCase(mockRepository);
  });

  group('FetchTileDetailUseCase', () {
    const targetId = 42;

    // テスト共通で使用するダミーデータのセットアップ
    final testTileDetail = TileDetail(
      title: 'Hello World',
      chain: [
        TokenData(
          id: 1,
          vocabId: 10,
          showWord: 'Hello',
          nowShow: true,
          translation: 'こんにちは',
        ),
        TokenData(
          id: 2,
          vocabId: 11,
          showWord: 'World',
          nowShow: true,
          translation: '世界',
        ),
      ],
    );

    group('正常系', () {
      test(
        'fetchTileDetail が指定した id を引数に1回呼ばれ、取得した TileDetail がそのまま返ること',
        () async {
          // Arrange(準備): 指定したIDでリポジトリがダミーデータを返すよう設定
          when(
            () => mockRepository.fetchTileDetail(id: any(named: 'id')),
          ).thenAnswer((_) async => testTileDetail);

          // Act(実行): ユースケースの実行
          final result = await useCase.execute(id: targetId);

          // Assert(検証):
          // 1. fetchTileDetail が targetId を引数に1回呼ばれていること
          verify(() => mockRepository.fetchTileDetail(id: targetId)).called(1);

          // 2. 返り値がリポジトリの返却したものと完全に一致すること
          expect(result, equals(testTileDetail));
          expect(result.title, 'Hello World');
          expect(result.chain.length, 2);
          expect(result.chain[0].showWord, 'Hello');
        },
      );
    });

    group('異常系', () {
      test(
        'fetchTileDetail が Exception を throw とき、ユースケースもそのまま例外を投げること',
        () async {
          // Arrange(準備): 例外を投げるよう戻り値の設定
          final testException = Exception('タイルの詳細取得に失敗しました');
          when(
            () => mockRepository.fetchTileDetail(id: any(named: 'id')),
          ).thenThrow(testException);

          // Act & Assert: 例外がそのまま再スローされることを検証
          expect(
            () => useCase.execute(id: targetId),
            throwsA(equals(testException)),
          );

          // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
          verify(() => mockRepository.fetchTileDetail(id: targetId)).called(1);
        },
      );
    });
  });
}
