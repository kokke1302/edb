// -----------------------------------------------------------------------------
// - 正常系:
//   - fetchVocabulariesWithPaging が currentCount を offset に、sorter をそのまま引数に1回呼ばれること
//   - 返り値のリスト件数が fetchVocabulariesWithPaging の返り値と一致すること
//   - 各 CardData の vocab が対応する VocabCore と一致すること
//   - 各 CardData の nowShow が対応する VocabCore の isShow と一致すること
//   - fetchVocabulariesWithPaging が空リストを返したとき、空リストが返ること
//
// - 異常系:
//   - fetchVocabulariesWithPaging が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/fetch_bookdata_usecase.dart';
import 'package:edb/domain/repository_abstract/book_repository.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/enum/sort_field.dart';
import 'package:edb/domain/model/enum/sort_order.dart';
import 'package:edb/domain/model/enum/base_status.dart';
import 'package:edb/domain/model/value_object/sorting_data.dart';

// BookRepositoryのモッククラスを作成
class MockBookRepository extends Mock implements BookRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SortingData());
  });

  late MockBookRepository mockRepository;
  late FetchBookDataUseCase useCase;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = FetchBookDataUseCase(mockRepository);
  });

  group('FetchBookDataUseCase', () {
    // 引数用の共通ダミーデータ
    const testCurrentCount = 20;
    const testSorter = SortingData(
      field: SortField.englishWord,
      order: SortOrder.desc,
      searchWord: 'a',
    );

    // リポジトリが返却するダミーのデータリスト
    final testVocabs = [
      VocabCore(
        id: 1,
        word: 'apple',
        translation: 'りんご',
        isShow: true,
        memo: 'memo1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        based: Based.init,
      ),
      VocabCore(
        id: 5,
        word: 'banana',
        translation: 'バナナ',
        isShow: false,
        memo: 'memo5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        based: Based.init,
      ),
    ];

    group('正常系', () {
      test(
        'fetchVocabulariesWithPaging が正しい引数で1回呼ばれ、VocabCore のリストが返ること',
        () async {
          // Arrange(準備): リポジトリがダミーのVocabCoreリストを返すように設定
          when(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: any(named: 'offset'),
              sorter: any(named: 'sorter'),
            ),
          ).thenAnswer((_) async => testVocabs);

          // Act(実行): ユースケースの実行
          final result = await useCase.execute(
            currentCount: testCurrentCount,
            sorter: testSorter,
          );

          // Assert(検証):
          // 1. fetchVocabulariesWithPaging が currentCount を offset に、sorter をそのまま引数に1回呼ばれること
          verify(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: testCurrentCount,
              sorter: testSorter,
            ),
          ).called(1);

          // 2. 返り値のリスト件数が fetchVocabulariesWithPaging の返り値と一致すること
          expect(result.length, testVocabs.length);

          // 3. 各 CardData の vocab が対応する VocabCore と一致すること
          expect(result[0], equals(testVocabs[0]));
          expect(result[1], equals(testVocabs[1]));

          // 4. 各 CardData の nowShow が対応する VocabCore の isShow と一致すること
          expect(result[0].isShow, isTrue);
          expect(result[1].isShow, isFalse);
        },
      );

      test('fetchVocabulariesWithPaging が空リストを返したとき、空リストが返ること', () async {
        // Arrange(準備): リポジトリが空リストを返すように設定
        when(
          () => mockRepository.fetchVocabulariesWithPaging(
            offset: any(named: 'offset'),
            sorter: any(named: 'sorter'),
          ),
        ).thenAnswer((_) async => <VocabCore>[]);

        // Act(実行): ユースケースの実行
        final result = await useCase.execute(
          currentCount: testCurrentCount,
          sorter: testSorter,
        );

        expect(result, isEmpty);
      });
    });

    group('異常系', () {
      test(
        'fetchVocabulariesWithPaging が Exception を throw したとき、ユースケースもそのまま例外を投げること',
        () async {
          // Arrange(準備): リポジトリが例外を投げるように設定
          final testException = Exception('データ取得に失敗しました');
          when(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: any(named: 'offset'),
              sorter: any(named: 'sorter'),
            ),
          ).thenThrow(testException);

          // Act & Assert(実行と検証): 例外がそのまま再スローされることを検証
          expect(
            () => useCase.execute(
              currentCount: testCurrentCount,
              sorter: testSorter,
            ),
            throwsA(equals(testException)),
          );
        },
      );
    });
  });
}
