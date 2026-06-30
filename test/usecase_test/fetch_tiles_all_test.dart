// -----------------------------------------------------------------------------
// - 正常系:
//   - fetchAllTiles が1回呼ばれること
//   - fetchAllTiles の返り値がそのまま返ること
//   - fetchAllTiles が空リストを返したとき、空リストが返ること
//
// - 異常系:
//   - fetchAllTiles が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/fetch_tiles_all_usecase.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';
import 'package:edb/domain/entity/carry/tile_data.dart';

// TilesRepositoryのモッククラスを作成
class MockTilesRepository extends Mock implements TilesRepository {}

void main() {
  late MockTilesRepository mockRepository;
  late FetchAllTilesUseCase useCase;

  setUp(() {
    mockRepository = MockTilesRepository();
    useCase = FetchAllTilesUseCase(mockRepository);
  });

  group('FetchAllTilesUseCase', () {
    // テスト共通で使用するダミーデータのセットアップ
    final testTileList = [
      TileData(id: 1, text: 'Hello World'),
      TileData(id: 2, text: 'Flutter Test'),
    ];

    group('正常系', () {
      test('fetchAllTiles が1回呼ばれ、取得した TileData のリストがそのまま返ること', () async {
        // Arrange(準備): リポジトリがモックのリストデータを返すよう設定
        when(
          () => mockRepository.fetchAllTiles(),
        ).thenAnswer((_) async => testTileList);

        // Act(実行): ユースケースの実行
        final result = await useCase.execute();

        // Assert(検証):
        // 1. fetchAllTiles が1回呼ばれていること
        verify(() => mockRepository.fetchAllTiles()).called(1);

        // 2. 返り値の要素数や中身がリポジトリのものと完全に一致すること
        expect(result, equals(testTileList));
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[1].id, 2);
        expect(result[0].text, 'Hello World');
        expect(result[1].text, 'Flutter Test');
      });

      test('fetchAllTiles が空リストを返したとき、ユースケースからも空リストが返ること', () async {
        // Arrange(準備): リポジトリが空のリストを返すよう設定
        when(
          () => mockRepository.fetchAllTiles(),
        ).thenAnswer((_) async => <TileData>[]);

        // Act(実行): ユースケースの実行
        final result = await useCase.execute();

        // Assert(検証):
        // 1. fetchAllTiles が1回呼ばれていること
        verify(() => mockRepository.fetchAllTiles()).called(1);

        // 2. 返り値が空のリストであること
        expect(result, []);
      });
    });

    group('異常系', () {
      test(
        'fetchAllTiles が Exception を throw したとき、ユースケースもそのまま例外を投げること',
        () async {
          // Arrange(準備): 例外を投げるよう戻り値の設定
          final testException = Exception('タイルの全件取得に失敗しました');
          when(() => mockRepository.fetchAllTiles()).thenThrow(testException);

          // Act & Assert: 例外がそのまま再スローされることを検証
          expect(() => useCase.execute(), throwsA(equals(testException)));

          // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
          verify(() => mockRepository.fetchAllTiles()).called(1);
        },
      );
    });
  });
}
