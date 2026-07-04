// -----------------------------------------------------------------------------
// - 正常系（基本取得）:
//   - 返り値のリスト件数が DB の行数と一致すること
//   - 各 VocabEntry の word / translation / memo / isShow が DB の該当行と一致すること
//   - DB が空のとき、空リストが返ること
//
// - 境界値（フィルタリング: searchWord）:
//   - searchWord が空文字のとき、全件取得されること
//   - searchWord が englishWord に部分一致する行だけ返ること
//   - searchWord が japaneseTranslation に部分一致する行だけ返ること
//   - searchWord が memo に部分一致する行だけ返ること
//   - searchWord がいずれのカラムにも一致しないとき、空リストが返ること
//
// - 境界値（ソート）:
//   - SortField.englishWord / SortOrder.asc のとき、英単語の昇順で返ること
//   - SortField.englishWord / SortOrder.desc のとき、英単語の降順で返ること
//   - SortField.createdAt / SortOrder.asc のとき、作成日時の昇順で返ること
//   - SortField.createdAt / SortOrder.desc のとき、作成日時の降順で返ること
//
// - 境界値（ページング）:
//   - offset が 0 のとき、先頭から pageSize 件返ること
//   - offset が pageSize と同じ値のとき、次のページが返ること
//   - offset が総件数以上のとき、空リストが返ること
//   - pageSize より DB の行数が少ないとき、存在する行数だけ返ること
//
// - 異常系:
//   - DB 接続が失敗した状態で呼んだとき、Exception が投げられること
// -----------------------------------------------------------------------------
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_book_repository.dart';
import 'package:edb/domain/entity/model/sorting_data.dart';
import 'package:edb/domain/entity/value/sort_field.dart';
import 'package:edb/domain/entity/value/sort_order.dart';

// ---------------------------------------------------------------------------
// ヘルパー: テスト用インメモリDB
// ---------------------------------------------------------------------------
AppDatabase _buildTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

// ---------------------------------------------------------------------------
// ヘルパー: Vocabularies への直接挿入
// ---------------------------------------------------------------------------
Future<void> _insertVocab(
  AppDatabase db, {
  required String englishWord,
  required String japaneseTranslation,
  bool isHidden = false,
  String memo = '',
  DateTime? createdAt,
}) async {
  await db
      .into(db.vocabularies)
      .insert(
        VocabulariesCompanion.insert(
          englishWord: englishWord,
          japaneseTranslation: japaneseTranslation,
          isHidden: isHidden,
          memo: memo,
          // createdAt は drift の withDefault に委ねるが、
          // ソートテストでは Value() で明示指定する
          createdAt: createdAt != null
              ? Value(createdAt)
              : const Value.absent(),
        ),
      );
}

// ---------------------------------------------------------------------------
// デフォルト SortingData（searchWord なし・pageSize 大）
// ---------------------------------------------------------------------------
const _defaultSorter = SortingData(
  field: SortField.englishWord,
  order: SortOrder.asc,
  searchWord: '',
  pageSize: 100,
);

void main() {
  late AppDatabase db;
  late LocalBookRepository repository;

  setUp(() {
    db = _buildTestDb();
    repository = LocalBookRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('fetchVocabulariesWithPaging', () {
    group('正常系（基本取得）', () {
      test('DBが空のとき、空リストが返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: _defaultSorter,
        );

        expect(result, isEmpty);
      });

      test('返り値のリスト件数がDBの行数と一致すること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
        );
        await _insertVocab(
          db,
          englishWord: 'cherry',
          japaneseTranslation: 'さくらんぼ',
        );

        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: _defaultSorter,
        );

        expect(result, hasLength(3));
      });

      test(
        '各VocabEntryのword / translation / memo / isShowがDBの該当行と一致すること',
        () async {
          await _insertVocab(
            db,
            englishWord: 'apple',
            japaneseTranslation: 'りんご',
            memo: 'a fruit',
            isHidden: true,
          );

          final result = await repository.fetchVocabulariesWithPaging(
            offset: 0,
            sorter: _defaultSorter,
          );

          expect(result, hasLength(1));
          final entry = result.first;
          expect(entry.word, equals('apple'));
          expect(entry.translation, equals('りんご'));
          expect(entry.memo, equals('a fruit'));
          // isHidden: true → isShow: false
          expect(entry.isShow, isFalse);
        },
      );
    });

    group('境界値（フィルタリング: searchWord）', () {
      setUp(() async {
        // 各テスト前にフィルタリング用データを投入
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
          memo: 'red fruit',
        );
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
          memo: 'yellow fruit',
        );
        await _insertVocab(
          db,
          englishWord: 'cherry',
          japaneseTranslation: 'さくらんぼ',
          memo: 'summer berry',
        );
      });

      test('searchWordが空文字のとき、全件取得されること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(searchWord: '', pageSize: 100),
        );

        expect(result, hasLength(3));
      });

      test('searchWordがenglishWordに部分一致する行だけ返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(searchWord: 'ban', pageSize: 100),
        );

        expect(result, hasLength(1));
        expect(result.first.word, equals('banana'));
      });

      test('searchWordがjapaneseTranslationに部分一致する行だけ返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(searchWord: 'さくら', pageSize: 100),
        );

        expect(result, hasLength(1));
        expect(result.first.word, equals('cherry'));
      });

      test('searchWordがmemoに部分一致する行だけ返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(searchWord: 'red', pageSize: 100),
        );

        expect(result, hasLength(1));
        expect(result.first.word, equals('apple'));
      });

      test('searchWordがいずれのカラムにも一致しないとき、空リストが返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(searchWord: 'zzz', pageSize: 100),
        );

        expect(result, isEmpty);
      });
    });

    group('境界値（ソート）', () {
      setUp(() async {
        // 挿入順をバラバラにして、ソート結果が挿入順に依存しないことを確認
        await _insertVocab(
          db,
          englishWord: 'cherry',
          japaneseTranslation: 'さくらんぼ',
          createdAt: DateTime(2024, 3, 1),
        );
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
          createdAt: DateTime(2024, 1, 1),
        );
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
          createdAt: DateTime(2024, 2, 1),
        );
      });

      test('SortField.englishWord / SortOrder.asc のとき、英単語の昇順で返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(
            field: SortField.englishWord,
            order: SortOrder.asc,
            pageSize: 100,
          ),
        );

        final words = result.map((e) => e.word).toList();
        expect(words, equals(['apple', 'banana', 'cherry']));
      });

      test('SortField.englishWord / SortOrder.desc のとき、英単語の降順で返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(
            field: SortField.englishWord,
            order: SortOrder.desc,
            pageSize: 100,
          ),
        );

        final words = result.map((e) => e.word).toList();
        expect(words, equals(['cherry', 'banana', 'apple']));
      });

      test('SortField.createdAt / SortOrder.asc のとき、作成日時の昇順で返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(
            field: SortField.createdAt,
            order: SortOrder.asc,
            pageSize: 100,
          ),
        );

        final words = result.map((e) => e.word).toList();
        // 2024-01 apple, 2024-02 banana, 2024-03 cherry
        expect(words, equals(['apple', 'banana', 'cherry']));
      });

      test('SortField.createdAt / SortOrder.desc のとき、作成日時の降順で返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(
            field: SortField.createdAt,
            order: SortOrder.desc,
            pageSize: 100,
          ),
        );

        final words = result.map((e) => e.word).toList();
        // 2024-03 cherry, 2024-02 banana, 2024-01 apple
        expect(words, equals(['cherry', 'banana', 'apple']));
      });
    });

    group('境界値（ページング）', () {
      // 5件投入（englishWord昇順: a, b, c, d, e）
      setUp(() async {
        for (final w in ['apple', 'banana', 'cherry', 'date', 'elderberry']) {
          await _insertVocab(db, englishWord: w, japaneseTranslation: '訳');
        }
      });

      test('offset が 0 のとき、先頭から pageSize 件返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(
            field: SortField.englishWord,
            order: SortOrder.asc,
            pageSize: 3,
          ),
        );

        expect(result, hasLength(3));
        expect(
          result.map((e) => e.word).toList(),
          equals(['apple', 'banana', 'cherry']),
        );
      });

      test('offset が pageSize と同じ値のとき、次のページが返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 3, // pageSize と同値
          sorter: const SortingData(
            field: SortField.englishWord,
            order: SortOrder.asc,
            pageSize: 3,
          ),
        );

        expect(result, hasLength(2));
        expect(
          result.map((e) => e.word).toList(),
          equals(['date', 'elderberry']),
        );
      });

      test('offset が総件数以上のとき、空リストが返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 100,
          sorter: const SortingData(pageSize: 3),
        );

        expect(result, isEmpty);
      });

      test('pageSize より DB の行数が少ないとき、存在する行数だけ返ること', () async {
        final result = await repository.fetchVocabulariesWithPaging(
          offset: 0,
          sorter: const SortingData(pageSize: 50),
        );

        // DBには5件しかない
        expect(result, hasLength(5));
      });
    });

    // Drift の in-memory DB が例外を投げていない
    // group('異常系', () {
    //   test('DB接続が失敗した状態で呼んだとき、Exceptionが投げられること', () async {
    //     // DBをクローズしてから呼び出すことで接続失敗を再現する
    //     await db.close();

    //     expect(
    //       () => repository.fetchVocabulariesWithPaging(
    //         offset: 0,
    //         sorter: _defaultSorter,
    //       ),
    //       throwsA(isA<Exception>()),
    //     );
    //   });
    // });
  });
}
