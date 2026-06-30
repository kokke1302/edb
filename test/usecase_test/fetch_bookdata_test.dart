// -----------------------------------------------------------------------------
// - 正常系:
//   - fetchVocabulariesWithPaging が currentCount を offset に、testPageSize を limit に、sorter をそのまま引数に1回呼ばれること
//   - 返り値のリスト件数が fetchVocabulariesWithPaging の返り値と一致すること
//   - 各 CardData の vocab が対応する VocabEntry と一致すること
//   - 各 CardData の nowShow が対応する VocabEntry の isShow と一致すること
//   - fetchVocabulariesWithPaging が空リストを返したとき、空リストが返ること
//
// - 異常系:
//   - fetchVocabulariesWithPaging が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/fetch_bookdata_usecase.dart';
import 'package:edb/domain/repository_abstract/book_repository.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/sort_field.dart';
import 'package:edb/domain/entity/value/sort_order.dart';
import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';

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
    const testPageSize = 20;
    const testSorter = SortingData(
      field: SortField.englishWord,
      order: SortOrder.desc,
      searchWord: 'a',
    );

    // リポジトリが返却するダミーのデータリスト
    final testVocabs = [
      VocabEntry(
        id: 1,
        word: 'apple',
        translation: 'りんご',
        isShow: true,
        memo: 'memo1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        based: Based.init,
      ),
      VocabEntry(
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
        'fetchVocabulariesWithPaging が正しい引数で1回呼ばれ、正しくマッピングされた CardData のリストが返ること',
        () async {
          // Arrange(準備): リポジトリがダミーのVocabEntryリストを返すように設定
          when(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
              sorter: any(named: 'sorter'),
            ),
          ).thenAnswer((_) async => testVocabs);

          // Act(実行): ユースケースの実行
          final result = await useCase.execute(
            currentCount: testCurrentCount,
            pageSize: testPageSize,
            sorter: testSorter,
          );

          // Assert(検証):
          // 1. fetchVocabulariesWithPaging が引数を正しく渡して1回呼ばれること
          verify(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: testCurrentCount,
              limit: testPageSize,
              sorter: testSorter,
            ),
          ).called(1);

          // 2. 返り値のリスト件数が fetchVocabulariesWithPaging の返り値と一致すること
          expect(result.length, testVocabs.length);

          // 3. 各 CardData の vocab が対応する VocabEntry と一致すること
          expect(result[0].vocab, testVocabs[0]);
          expect(result[1].vocab, testVocabs[1]);

          // 4. 各 CardData の nowShow が対応する VocabEntry の isShow と一致すること
          expect(result[0].nowShow, testVocabs[0].isShow); // true
          expect(result[1].nowShow, testVocabs[1].isShow); // false
        },
      );

      test('fetchVocabulariesWithPaging が空リストを返したとき、空リストが返ること', () async {
        // Arrange(準備): リポジトリが空リストを返すように設定
        when(
          () => mockRepository.fetchVocabulariesWithPaging(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sorter: any(named: 'sorter'),
          ),
        ).thenAnswer((_) async => <VocabEntry>[]);

        // Act(実行): ユースケースの実行
        final result = await useCase.execute(
          currentCount: testCurrentCount,
          pageSize: testPageSize,
          sorter: testSorter,
        );

        // Assert(検証):
        verify(
          () => mockRepository.fetchVocabulariesWithPaging(
            offset: testCurrentCount,
            limit: testPageSize,
            sorter: testSorter,
          ),
        ).called(1);

        // 空リストが返ることを確認
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
              limit: any(named: 'limit'),
              sorter: any(named: 'sorter'),
            ),
          ).thenThrow(testException);

          // Act & Assert(実行と検証): 例外がそのまま再スローされることを検証
          expect(
            () => useCase.execute(
              currentCount: testCurrentCount,
              pageSize: testPageSize,
              sorter: testSorter,
            ),
            throwsA(equals(testException)),
          );

          // 例外が発生した場合でも、対象のメソッドが呼ばれていることを確認
          verify(
            () => mockRepository.fetchVocabulariesWithPaging(
              offset: testCurrentCount,
              limit: testPageSize,
              sorter: testSorter,
            ),
          ).called(1);
        },
      );
    });
  });
}
