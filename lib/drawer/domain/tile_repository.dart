import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final tileRepositoryProvider = Provider<TileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TileRepository(db);
});

class TileRepository {
  final AppDatabase db;
  TileRepository(this.db);

  // ===============================================
  // C: Create (書き込み)
  // ===============================================

  /// 新しい英文データ（Tile）をデータベースに追加します。
  Future<int> createTile({required String text, required String chain}) async {
    try {
      // 仮で行を作る
      final companion = EnglishTextsCompanion.insert(
        originalText: text,
        parsedWordsJson: chain,
      );

      // 作った仮の行をDBに挿入
      return await db.into(db.englishTexts).insert(companion);
    } catch (e) {
      throw Exception('Failed to create tile: $e');
    }
  }

  // ===============================================
  // R: Read (読み込み)
  // ===============================================
  Future<List<Map<String, dynamic>>> fetchAllTile() async {
    try {
      // 抽出するカラムを選択
      final query = db.selectOnly(db.englishTexts)
        ..addColumns([db.englishTexts.id, db.englishTexts.originalText]);

      final rows = await query.get();

      return rows.map((row) {
        return {
          'id': row.read(db.englishTexts.id),
          'text': row.read(db.englishTexts.originalText),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching tiles: $e');
    }
  }

  Future<EnglishText> fetchTileDetail(int id) async {
    try {
      // 抽出する行を選択
      final query = db.select(db.englishTexts)..where((t) => t.id.equals(id));

      return await query.getSingle();
    } catch (e) {
      throw Exception('Failed to fetch tile detail (ID: $id): $e');
    }
  }

  // ===============================================
  // D: Delete
  // ===============================================

  /// 指定されたIDの英文データ（Tile）をデータベースから削除します。
  Future<int> deleteTile(int id) async {
    try {
      // 行を選択
      final query = db.delete(db.englishTexts)..where((t) => t.id.equals(id));
      final deletedCount = await query.go();

      if (deletedCount == 0) throw Exception('Tile with ID $id not found');

      return deletedCount;
    } catch (e) {
      throw Exception('Failed to delete tile: $e');
    }
  }
}
