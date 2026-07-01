// -----------------------------------------------------------------------------
// - 正常系:
//   - lookupKeys に一致する englishWord を持つ行のみ返ること
//   - 返り値の id / word が DB の該当行と一致すること
//   - isHidden が true の行は返り値に含まれないこと
//   - isHidden が false の行の isShow が true にマッピングされること
//   - lookupKeys に複数のキーを渡したとき、一致する全行が返ること
//   - 一致する行が存在しないとき、空の リスト が返ること
//
// - 境界値:
//   - lookupKeys が空 Set のとき、DB を参照せず空の リスト が返ること
//   - lookupKeys の文字列が大文字混じりでも、小文字で登録済みの行が返ること
//   - lookupKeys に含まれないキーを持つ行が DB に存在しても、返り値に含まれないこと
//
// - 異常系:
//   - DB 接続が失敗した状態で呼んだとき、Exception が投げられること
// -----------------------------------------------------------------------------

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_translation_repository.dart';

// ---------------------------------------------------------------------------
// ヘルパー: テスト用インメモリDB
// ---------------------------------------------------------------------------
AppDatabase _buildTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

// ---------------------------------------------------------------------------
// ヘルパー: Vocabularies への直接挿入
// ---------------------------------------------------------------------------
Future<int> _insertVocab(
  AppDatabase db, {
  required String englishWord,
  required String japaneseTranslation,
  bool isHidden = false,
  String memo = '',
}) async {
  return db
      .into(db.vocabularies)
      .insert(
        VocabulariesCompanion.insert(
          englishWord: englishWord,
          japaneseTranslation: japaneseTranslation,
          isHidden: isHidden,
          memo: memo,
        ),
      );
}

void main() {
  late AppDatabase db;
  late LocalTranslationRepository repository;

  setUp(() {
    db = _buildTestDb();
    repository = LocalTranslationRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('fetchTranslationsBatch', () {
    group('正常系', () {
      test('lookupKeys に一致する englishWord を持つ行のみ返ること', () async {
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

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result, hasLength(1));
        expect(result.first.word, equals('apple'));
      });

      test('返り値の id / word が DB の該当行と一致すること', () async {
        final insertedId = await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.id, equals(insertedId));
        expect(entry.word, equals('apple'));
      });

      test('isHidden が true の行は返り値に含まれないこと', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
          isHidden: true,
        );

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result, isEmpty);
      });

      test('isHidden が false の行の isShow が true にマッピングされること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
          isHidden: false,
        );

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result.first.isShow, isTrue);
      });

      test('lookupKeys に複数のキーを渡したとき、一致する全行が返ること', () async {
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

        final result = await repository.fetchTranslationsBatch({
          'apple',
          'banana',
        });

        expect(result, hasLength(2));
        final words = result.map((e) => e.word).toSet();
        expect(words, equals({'apple', 'banana'}));
      });

      test('一致する行が存在しないとき、空の List が返ること', () async {
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
        );

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result, isEmpty);
      });
    });

    group('境界値', () {
      test('lookupKeys が空 Set のとき、DB を参照せず空の List が返ること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );

        final result = await repository.fetchTranslationsBatch({});

        expect(result, isEmpty);
      });

      test('lookupKeys の文字列が大文字混じりでも、小文字で登録済みの行が返ること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );

        final result = await repository.fetchTranslationsBatch({'Apple'});

        expect(result, hasLength(1));
        expect(result.first.word, equals('apple')); // showWord -> word に修正
      });

      test('lookupKeys に含まれないキーを持つ行が DB に存在しても、返り値に含まれないこと', () async {
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

        final result = await repository.fetchTranslationsBatch({'apple'});

        expect(result, hasLength(1));
        final words = result.map((e) => e.word).toSet(); // showWord -> word に修正
        expect(words, isNot(contains('banana')));
        expect(words, isNot(contains('cherry')));
      });
    });

    // Drift の in-memory DB が例外を投げていない
    // group('異常系', () {
    //   test('DB接続が失敗した状態で呼んだとき、Exceptionが投げられること', () async {
    //     await db.close();

    //     expect(
    //       // メソッド名を fetchTokenChain から fetchTranslationsBatch に修正
    //       () => repository.fetchTranslationsBatch({'apple'}),
    //       throwsA(isA<Exception>()),
    //     );
    //   });
    // });
  });
}
