// -----------------------------------------------------------------------------
// - 正常系:
//   - createTile が originalText と tokens を JSON エンコードした文字列を引数に1回呼ばれること
//   - tokens の各要素が toJson() で変換されて chain に含まれていること
//   - 返り値の id が createTile の返り値になること
//   - 返り値の text が originalText になること
//
// - 異常系:
//   - createTile が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/save_tile_usecase.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';
import 'package:edb/domain/entity/model/token_data.dart';

// TilesRepositoryのモッククラスを作成
class MockTilesRepository extends Mock implements TilesRepository {}

void main() {
  late MockTilesRepository mockRepository;
  late SaveTileUseCase useCase;

  setUp(() {
    mockRepository = MockTilesRepository();
    useCase = SaveTileUseCase(mockRepository);
  });

  group('SaveTileUseCase', () {
    // テスト共通で使用するデータのセットアップ
    const testOriginalText = 'Hello world';
    final testTokens = [
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
        showWord: 'world',
        nowShow: true,
        translation: '世界',
      ),
    ];

    // tokens が toJson() 経由で JSONエンコードされた際に期待される文字列
    final expectedChainJson = json.encode(
      testTokens.map((t) => t.toJson()).toList(),
    );

    group('正常系', () {
      test('createTile が正しい引数で1回呼ばれ、期待通りの TileData が返却されること', () async {
        // Arrange(準備): リポジトリが新しいタイルID（例: 77）を返すよう設定
        const expectedTileId = 77;
        when(
          () => mockRepository.createTile(
            text: any(named: 'text'),
            chain: any(named: 'chain'),
          ),
        ).thenAnswer((_) async => expectedTileId);

        // Act(実行): ユースケースの実行
        final result = await useCase.execute(
          originalText: testOriginalText,
          tokens: testTokens,
        );

        // Assert(検証):
        // 1. createTile が originalText とエンコードされた JSON文字列 を引数に1回呼ばれること
        // 2. tokens の各要素が toJson() で変換されて chain に含まれていること
        verify(
          () => mockRepository.createTile(
            text: testOriginalText,
            chain: expectedChainJson,
          ),
        ).called(1);

        // 3. 返り値の id が createTile の返り値（expectedTileId）になること
        expect(result.id, expectedTileId);

        // 4. 返り値の text が originalText になること
        expect(result.text, testOriginalText);
      });
    });

    group('異常系', () {
      test('repositoryが例外をスローしたとき、ユースケースもそのまま例外を投げること', () async {
        // Arrange(準備): 例外を投げるよう戻り値の設定
        final testException = Exception('データベースの保存に失敗しました');
        when(
          () => mockRepository.createTile(
            text: any(named: 'text'),
            chain: any(named: 'chain'),
          ),
        ).thenThrow(testException);

        // Act & Assert: 例外がそのまま再スローされることを検証
        expect(
          () => useCase.execute(
            originalText: testOriginalText,
            tokens: testTokens,
          ),
          throwsA(equals(testException)),
        );

        // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
        verify(
          () => mockRepository.createTile(
            text: testOriginalText,
            chain: expectedChainJson,
          ),
        ).called(1);
      });
    });
  });
}
