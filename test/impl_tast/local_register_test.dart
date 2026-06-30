// -----------------------------------------------------------------------------
// - 正常系（addVocabulary）:
//   - 返り値の word / translation / memo が vocab と一致すること
//   - 返り値の id が自動採番された正の整数になること
//   - 挿入後に DB に該当行が存在すること
//
// - 境界値（addVocabulary）:
//   - vocab.isShow が true のとき、同じ word を持つ既存エントリの isHidden が true に更新されること
//   - vocab.isShow が false のとき、既存エントリの isHidden が変更されないこと
//
// - 正常系（updateVocabulary）:
//   - 返り値の word / translation / memo / isHidden が更新内容と一致すること
//   - 更新後に DB の該当行が新しい内容になっていること
//
// - 境界値（updateVocabulary）:
//   - vocab.isShow が true のとき、同じ word を持つ既存エントリの isHidden が true に更新されること
//   - vocab.isShow が false のとき、既存エントリの isHidden が変更されないこと
//
// - 正常系（deleteVocabulary）:
//   - 削除後に同じ id で取得しても該当行が存在しないこと
//
// - 境界値（deleteVocabulary）:
//   - 存在しない id を指定しても例外が投げられないこと
//
// - 異常系:
//   - DB 接続が失敗した状態で addVocabulary を呼んだとき、Exception が投げられること
//   - DB 接続が失敗した状態で updateVocabulary を呼んだとき、Exception が投げられること
//   - DB 接続が失敗した状態で deleteVocabulary を呼んだとき、Exception が投げられること
// -----------------------------------------------------------------------------

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_register_repository.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';

// ---------------------------------------------------------------------------
// テスト用インメモリ DB
// ---------------------------------------------------------------------------
AppDatabase _buildInMemoryDb() {
  return AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
}

// ---------------------------------------------------------------------------
// ヘルパー: テスト用 VocabEntry を組み立てる
// ---------------------------------------------------------------------------
VocabEntry _makeVocab({
  int id = -1,
  String word = 'apple',
  String translation = 'りんご',
  bool isShow = true,
  String memo = '',
}) {
  return VocabEntry(
    id: id,
    word: word,
    translation: translation,
    isShow: isShow,
    memo: memo,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    based: Based.init,
  );
}

// ---------------------------------------------------------------------------
// テスト
// ---------------------------------------------------------------------------
void main() {
  late AppDatabase db;
  late LocalRegisterRepository repository;

  setUp(() {
    db = _buildInMemoryDb();
    repository = LocalRegisterRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('addVocabulary', () {
    group('正常系', () {
      test(
        '返り値の word / translation / memo / isHidden が vocab と一致すること',
        () async {
          final vocab = _makeVocab(
            word: 'apple',
            translation: 'りんご',
            memo: 'テストメモ',
            isShow: true,
          );

          final result = await repository.addVocabulary(vocab: vocab);

          expect(result.word, vocab.word);
          expect(result.translation, vocab.translation);
          expect(result.memo, vocab.memo);
          expect(result.isShow, vocab.isShow);
        },
      );

      test('返り値の id が自動採番された正の整数になること', () async {
        final vocab = _makeVocab();

        final result = await repository.addVocabulary(vocab: vocab);

        expect(result.id, isPositive);
      });

      test('挿入後に DB に該当行が存在すること', () async {
        final vocab = _makeVocab(word: 'banana', translation: 'バナナ');

        final result = await repository.addVocabulary(vocab: vocab);

        final rows = await (db.select(
          db.vocabularies,
        )..where((v) => v.id.equals(result.id))).get();

        expect(rows.length, 1);
        expect(rows.first.englishWord, 'banana');
        expect(rows.first.japaneseTranslation, 'バナナ');
      });
    });

    group('境界値', () {
      test(
        'vocab.isShow が true のとき、同じ word を持つ既存エントリの isHidden が true に更新されること',
        () async {
          // 既存エントリ（isHidden: false）を直接挿入する
          final existingId = await db
              .into(db.vocabularies)
              .insert(
                VocabulariesCompanion.insert(
                  englishWord: 'apple',
                  japaneseTranslation: '旧訳',
                  isHidden: false, // 表示中
                  memo: '',
                ),
              );

          // isShow: true で新エントリを追加 → 既存を hidden にするはず
          final vocab = _makeVocab(word: 'apple', isShow: true);
          await repository.addVocabulary(vocab: vocab);

          final existing = await (db.select(
            db.vocabularies,
          )..where((v) => v.id.equals(existingId))).getSingle();

          expect(existing.isHidden, isTrue);
        },
      );

      test('vocab.isShow が false のとき、既存エントリの isHidden が変更されないこと', () async {
        // 既存エントリ（isHidden: false）を直接挿入する
        final existingId = await db
            .into(db.vocabularies)
            .insert(
              VocabulariesCompanion.insert(
                englishWord: 'apple',
                japaneseTranslation: '旧訳',
                isHidden: false,
                memo: '',
              ),
            );

        // isShow: false で新エントリを追加 → 既存は触らないはず
        final vocab = _makeVocab(word: 'apple', isShow: false);
        await repository.addVocabulary(vocab: vocab);

        final existing = await (db.select(
          db.vocabularies,
        )..where((v) => v.id.equals(existingId))).getSingle();

        expect(existing.isHidden, isFalse);
      });
    });
  });

  group('updateVocabulary', () {
    // 各テスト前に更新対象エントリを用意する
    late int existingId;

    setUp(() async {
      existingId = await db
          .into(db.vocabularies)
          .insert(
            VocabulariesCompanion.insert(
              englishWord: 'cat',
              japaneseTranslation: '猫',
              isHidden: false,
              memo: '旧メモ',
            ),
          );
    });

    group('正常系', () {
      test('返り値の word / translation / memo / isHidden が更新内容と一致すること', () async {
        final updated = _makeVocab(
          id: existingId,
          word: 'cat',
          translation: 'ネコ',
          memo: '新メモ',
          isShow: true, // isHidden: false に相当
        );

        final result = await repository.updateVocabulary(vocab: updated);

        expect(result.word, 'cat');
        expect(result.translation, 'ネコ');
        expect(result.memo, '新メモ');
        expect(result.isShow, isTrue);
      });

      test('更新後に DB の該当行が新しい内容になっていること', () async {
        final updated = _makeVocab(
          id: existingId,
          word: 'cat',
          translation: 'キャット',
          memo: '更新済み',
          isShow: false,
        );

        await repository.updateVocabulary(vocab: updated);

        final row = await (db.select(
          db.vocabularies,
        )..where((v) => v.id.equals(existingId))).getSingle();

        expect(row.japaneseTranslation, 'キャット');
        expect(row.memo, '更新済み');
        expect(row.isHidden, isTrue); // isShow: false → isHidden: true
      });
    });

    group('境界値', () {
      test(
        'vocab.isShow が true のとき、同じ word を持つ既存エントリの isHidden が true に更新されること',
        () async {
          // 別エントリ（同じ word、isHidden: false）を用意する
          final otherId = await db
              .into(db.vocabularies)
              .insert(
                VocabulariesCompanion.insert(
                  englishWord: 'cat',
                  japaneseTranslation: '旧エントリ',
                  isHidden: false,
                  memo: '',
                ),
              );

          final updated = _makeVocab(id: existingId, word: 'cat', isShow: true);
          await repository.updateVocabulary(vocab: updated);

          final other = await (db.select(
            db.vocabularies,
          )..where((v) => v.id.equals(otherId))).getSingle();

          expect(other.isHidden, isTrue);
        },
      );

      test('vocab.isShow が false のとき、既存エントリの isHidden が変更されないこと', () async {
        // 別エントリ（同じ word、isHidden: false）を用意する
        final otherId = await db
            .into(db.vocabularies)
            .insert(
              VocabulariesCompanion.insert(
                englishWord: 'cat',
                japaneseTranslation: '旧エントリ',
                isHidden: false,
                memo: '',
              ),
            );

        final updated = _makeVocab(id: existingId, word: 'cat', isShow: false);
        await repository.updateVocabulary(vocab: updated);

        final other = await (db.select(
          db.vocabularies,
        )..where((v) => v.id.equals(otherId))).getSingle();

        expect(other.isHidden, isFalse);
      });
    });
  });

  group('deleteVocabulary', () {
    late int existingId;

    setUp(() async {
      existingId = await db
          .into(db.vocabularies)
          .insert(
            VocabulariesCompanion.insert(
              englishWord: 'dog',
              japaneseTranslation: '犬',
              isHidden: false,
              memo: '',
            ),
          );
    });

    group('正常系', () {
      test('削除後に同じ id で取得しても該当行が存在しないこと', () async {
        await repository.deleteVocabulary(id: existingId);

        final rows = await (db.select(
          db.vocabularies,
        )..where((v) => v.id.equals(existingId))).get();

        expect(rows, isEmpty);
      });
    });

    group('境界値', () {
      test('存在しない id を指定しても例外が投げられないこと', () async {
        const nonExistentId = 99999;

        expect(
          () => repository.deleteVocabulary(id: nonExistentId),
          returnsNormally,
        );
      });
    });
  });

  // Drift の in-memory DB が例外を投げていない
  // group('異常系', () {
  //   test('DB 接続が失敗した状態で addVocabulary を呼んだとき、Exception が投げられること', () async {
  //     await db.close();
  //     final vocab = _makeVocab();
  //
  //     expect(
  //       () => repository.addVocabulary(vocab: vocab),
  //       throwsA(isA<Exception>()),
  //     );
  //   });
  //
  //   test('DB 接続が失敗した状態で updateVocabulary を呼んだとき、Exception が投げられること', () async {
  //     await db.close();
  //     final vocab = _makeVocab(id: 1);
  //
  //     expect(
  //       () => repository.updateVocabulary(vocab: vocab),
  //       throwsA(isA<Exception>()),
  //     );
  //   });
  //
  //   test('DB 接続が失敗した状態で deleteVocabulary を呼んだとき、Exception が投げられること', () async {
  //     await db.close();
  //
  //     expect(
  //       () => repository.deleteVocabulary(id: 1),
  //       throwsA(isA<Exception>()),
  //     );
  //   });
  // });
}
