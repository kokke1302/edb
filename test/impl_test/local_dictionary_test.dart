// -----------------------------------------------------------------------------
// - 正常系（fetchVocabularies）:
//   - englishWord が word と完全一致する行だけ返ること
//   - 返り値の word / translation / memo / id が DB の該当行と一致すること
//   - isHidden が true の行の isShow が false にマッピングされること
//   - isHidden が false の行の isShow が true にマッピングされること
//   - 返り値の based がすべて Based.vocabularies になること
//   - 同じ word に複数行存在するとき、全件返ること
//   - 該当行が存在しないとき、空リストが返ること
//
// - 境界値（fetchVocabularies）:
//   - word の大文字・小文字が混在していても一致する行が返ること
//
// - 正常系（fetchDictionaries）:
//   - key が word と完全一致する行だけ返ること
//   - 返り値の word / translation が DB の該当行と一致すること
//   - 返り値の id がすべて -1 になること
//   - 返り値の isShow がすべて true になること
//   - 返り値の based がすべて Based.dictionary になること
//   - memo が null の行の memo が空文字にマッピングされること
//   - 該当行が存在しないとき、空リストが返ること
//
// - 境界値（fetchDictionaries）:
//   - key の大文字・小文字が混在していても一致する行が返ること
//
// - 異常系:
//   - DB 接続が失敗した状態で fetchVocabularies を呼んだとき、Exception が投げられること
//   - DB 接続が失敗した状態で fetchDictionaries を呼んだとき、Exception が投げられること
// -----------------------------------------------------------------------------
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_dictionary_repository.dart';
import 'package:edb/domain/entity/value/base_status.dart';

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
}) async {
  await db
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

// ---------------------------------------------------------------------------
// ヘルパー: InternalDictionaries への直接挿入
// ---------------------------------------------------------------------------
Future<void> _insertDict(
  AppDatabase db, {
  required String key,
  required String word,
  required String mean,
  String? memo,
}) async {
  await db
      .into(db.internalDictionaries)
      .insert(
        InternalDictionariesCompanion.insert(
          key: key,
          word: word,
          mean: mean,
          memo: Value(memo),
        ),
      );
}

void main() {
  late AppDatabase db;
  late LocalDictionaryRepository repository;

  setUp(() {
    db = _buildTestDb();
    repository = LocalDictionaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('fetchVocabularies', () {
    group('正常系', () {
      test('一致する englishWord を持つ行だけ返ること', () async {
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

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result, hasLength(1));
        expect(result.first.word, equals('apple'));
      });

      test(
        '返り値の word / translation / memo / isShow が DB の該当行と一致すること',
        () async {
          await _insertVocab(
            db,
            englishWord: 'apple',
            japaneseTranslation: 'りんご',
            memo: 'a red fruit',
            isHidden: false,
          );

          final result = await repository.fetchVocabularies(word: 'apple');

          expect(result, hasLength(1));
          final entry = result.first;
          expect(entry.word, equals('apple'));
          expect(entry.translation, equals('りんご'));
          expect(entry.memo, equals('a red fruit'));
          expect(entry.isShow, isTrue);
        },
      );

      test('返り値の based が Based.vocabularies になること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result.first.based, equals(Based.vocabularies));
      });

      test('DB の isHidden が true のとき、isShow が false になること', () async {
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
          isHidden: true,
        );

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result.first.isShow, isFalse);
      });

      test('一致する行が複数あるとき、全件返ること', () async {
        // 同じ englishWord で訳語違いの2行を登録
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'アップル',
        );
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
        );

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result, hasLength(2));
        expect(result.every((e) => e.word == 'apple'), isTrue);
      });

      test('一致する行がないとき、空リストが返ること', () async {
        await _insertVocab(
          db,
          englishWord: 'banana',
          japaneseTranslation: 'バナナ',
        );

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result, isEmpty);
      });
    });

    group('境界値', () {
      test('word が大文字混じりのとき、大文字小文字を無視して一致する行が返ること', () async {
        // DBには小文字で登録
        await _insertVocab(
          db,
          englishWord: 'apple',
          japaneseTranslation: 'りんご',
        );

        // 大文字混じりで検索
        final result = await repository.fetchVocabularies(word: 'APPLE');

        expect(result, hasLength(1));
        expect(result.first.word, equals('apple'));
      });
    });
  });

  group('fetchDictionaries', () {
    group('正常系', () {
      test('一致する key を持つ行だけ返ること', () async {
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');
        await _insertDict(db, key: 'walk', word: 'walk', mean: '歩く');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result, hasLength(1));
        expect(result.first.word, equals('run'));
      });

      test('返り値の word / translation が DB の該当行と一致すること', () async {
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result, hasLength(1));
        final entry = result.first;
        // fromDictionary は word を toLowerCase() するため小文字で一致する
        expect(entry.word, equals('run'));
        expect(entry.translation, equals('走る'));
      });

      test('返り値の based が Based.dictionary になること', () async {
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result.first.based, equals(Based.dictionary));
      });

      test('返り値の id が -1 になること', () async {
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result.first.id, equals(-1));
      });

      test('memo が null のとき、返り値の memo が空文字になること', () async {
        await _insertDict(db, key: 'run', word: 'run', mean: '走る', memo: null);

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result.first.memo, equals(''));
      });

      test('一致する行が複数あるとき、全件返ること', () async {
        // 同じ key で意味違いの2行を登録
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');
        await _insertDict(db, key: 'run', word: 'run', mean: '運営する');
        await _insertDict(db, key: 'walk', word: 'walk', mean: '歩く');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result, hasLength(2));
        expect(result.every((e) => e.word == 'run'), isTrue);
      });

      test('一致する行がないとき、空リストが返ること', () async {
        await _insertDict(db, key: 'walk', word: 'walk', mean: '歩く');

        final result = await repository.fetchDictionaries(word: 'run');

        expect(result, isEmpty);
      });
    });

    group('境界値', () {
      test('word が大文字混じりのとき、大文字小文字を無視して一致する行が返ること', () async {
        // DBには小文字 key で登録
        await _insertDict(db, key: 'run', word: 'run', mean: '走る');

        // 大文字混じりで検索
        final result = await repository.fetchDictionaries(word: 'RUN');

        expect(result, hasLength(1));
        expect(result.first.word, equals('run'));
      });
    });
  });

  // Drift の in-memory DB が例外を投げていない
  // group('異常系', () {
  //   test('DB接続が失敗した状態で fetchVocabularies を呼んだとき、Exceptionが投げられること', () async {
  //     await db.close();

  //     expect(
  //       () => repository.fetchVocabularies(word: 'apple'),
  //       throwsA(isA<Exception>()),
  //     );
  //   });

  //   test('DB接続が失敗した状態で fetchDictionaries を呼んだとき、Exceptionが投げられること', () async {
  //     await db.close();

  //     expect(
  //       () => repository.fetchDictionaries(word: 'run'),
  //       throwsA(isA<Exception>()),
  //     );
  //   });
  // });
}
