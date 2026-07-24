// -----------------------------------------------------------------------------
// - 正常系（createTile）:
//   - 返り値が正の整数の id になること
//   - 挿入後に DB に該当行が存在すること
//   - 挿入された行の originalText / parsedWordsJson が引数と一致すること
//
// - 正常系（fetchAllTiles）:
//   - 返り値のリスト件数が DB の行数と一致すること
//   - 各 TileData の id / text が DB の該当行と一致すること
//   - DB が空のとき、空リストが返ること
//
// - 正常系（fetchTileDetail）:
//   - 指定した id の行の内容が返ること
//
// - 異常系（fetchTileDetail）:
//   - 存在しない id を指定したとき、Exception が投げられること
//
// - 正常系（deleteTile）:
//   - 削除後に同じ id の行が DB に存在しないこと
//   - 返り値が 1（削除件数）になること
//
// - 異常系（deleteTile）:
//   - 存在しない id を指定したとき、Exception が投げられること
// -----------------------------------------------------------------------------

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_tiles_repository.dart';

// ---------------------------------------------------------------------------
// ヘルパー: テスト用インメモリDB
// ---------------------------------------------------------------------------
AppDatabase _buildTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

// ---------------------------------------------------------------------------
// テスト用のparsedWordsJson
// ---------------------------------------------------------------------------
const _sampleChainJson = '''
[
  {
    "id": 1,
    "vocabId": 10,
    "showWord": "Hello",
    "nowShow": false,
    "translation": "こんにちは"
  },
  {
    "id": 2,
    "vocabId": 5,
    "showWord": "World",
    "nowShow": true,
    "translation": "世界"
  }
]
''';

void main() {
  late AppDatabase db;
  late LocalTilesRepository repository;

  setUp(() {
    db = _buildTestDb();
    repository = LocalTilesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // =========================================================================
  // createTile
  // =========================================================================
  group('createTile', () {
    test('返り値が正の整数のIDになること', () async {
      final id = await repository.createTile(
        text: 'Hello world.',
        chain: _sampleChainJson,
      );

      expect(id, isA<int>());
      expect(id, greaterThan(0));
    });

    test('挿入後にDBに該当行が存在すること', () async {
      final id = await repository.createTile(
        text: 'Hello world.',
        chain: _sampleChainJson,
      );

      final rows = await (db.select(
        db.englishTexts,
      )..where((t) => t.id.equals(id))).get();

      expect(rows, hasLength(1));
    });

    test('挿入された行の originalText / parsedWordsJson が引数と一致すること', () async {
      const text = 'Hello world.';
      const chain = _sampleChainJson;

      final id = await repository.createTile(text: text, chain: chain);

      final row = await (db.select(
        db.englishTexts,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(row.originalText, equals(text));
      expect(row.parsedWordsJson, equals(chain));
    });
  });

  // =========================================================================
  // fetchAllTiles
  // =========================================================================
  group('fetchAllTiles', () {
    test('DBが空のとき、空リストが返ること', () async {
      final tiles = await repository.fetchAllTiles();

      expect(tiles, isEmpty);
    });

    test('返り値のリスト件数がDBの行数と一致すること', () async {
      await repository.createTile(text: 'First.', chain: _sampleChainJson);
      await repository.createTile(text: 'Second.', chain: _sampleChainJson);
      await repository.createTile(text: 'Third.', chain: _sampleChainJson);

      final tiles = await repository.fetchAllTiles();

      expect(tiles, hasLength(3));
    });

    test('各TileDataのid / textがDBの該当行と一致すること', () async {
      final id1 = await repository.createTile(
        text: 'Alpha.',
        chain: _sampleChainJson,
      );
      final id2 = await repository.createTile(
        text: 'Beta.',
        chain: _sampleChainJson,
      );

      final tiles = await repository.fetchAllTiles();

      // ID順にソートして比較
      tiles.sort((a, b) => a.id.compareTo(b.id));

      expect(tiles[0].id, equals(id1));
      expect(tiles[0].text, equals('Alpha.'));
      expect(tiles[1].id, equals(id2));
      expect(tiles[1].text, equals('Beta.'));
    });
  });

  // =========================================================================
  // fetchTileDetail
  // =========================================================================
  group('fetchTileDetail', () {
    test('指定したIDの行の内容が返ること', () async {
      const text = 'The quick brown fox.';
      final id = await repository.createTile(
        text: text,
        chain: _sampleChainJson,
      );

      final detail = await repository.fetchTileDetail(id: id);

      // title は originalText と一致する
      expect(detail.title, equals(text));

      // chain には挿入した JSON の TokenData が1件入っている
      expect(detail.chain, hasLength(2));
      expect(detail.chain.first.showWord, equals('Hello'));
      expect(detail.chain.first.translation, equals('こんにちは'));
    });

    test('存在しないIDを指定したとき、Exceptionが投げられること', () async {
      expect(
        () => repository.fetchTileDetail(id: 99999),
        throwsA(isA<Exception>()),
      );
    });
  });

  // =========================================================================
  // deleteTile
  // =========================================================================
  group('deleteTile', () {
    test('削除後に同じIDの行がDBに存在しないこと', () async {
      final id = await repository.createTile(
        text: 'To be deleted.',
        chain: _sampleChainJson,
      );

      await repository.deleteTile(id: id);

      final rows = await (db.select(
        db.englishTexts,
      )..where((t) => t.id.equals(id))).get();

      expect(rows, isEmpty);
    });

    test('返り値が1（削除件数）になること', () async {
      final id = await repository.createTile(
        text: 'To be deleted.',
        chain: _sampleChainJson,
      );

      final deletedCount = await repository.deleteTile(id: id);

      expect(deletedCount, equals(1));
    });

    // -----------------------------------------------------------------------
    // 境界値
    // -----------------------------------------------------------------------
    test('存在しないIDを指定したとき、Exceptionが投げられること', () async {
      expect(() => repository.deleteTile(id: 99999), throwsA(isA<Exception>()));
    });
  });
}
