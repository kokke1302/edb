import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/tile_mapper.dart';
import 'package:edb/domain/entity/carry/tile_detail.dart';
import 'package:edb/domain/entity/carry/tile_data.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';

class LocalTilesRepository implements TilesRepository {
  final AppDatabase db;
  LocalTilesRepository(this.db);

  // ===============================================
  // C: Create (書き込み)
  // ===============================================
  // 新しいタイルをデータベースに追加
  @override
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
  @override
  Future<List<TileData>> fetchAllTiles() async {
    try {
      // 抽出するカラムを選択
      final query = db.selectOnly(db.englishTexts)
        ..addColumns([db.englishTexts.id, db.englishTexts.originalText]);

      final rows = await query.get();

      return rows.map((row) {
        final id = row.read(db.englishTexts.id)!;
        final text = row.read(db.englishTexts.originalText)!;
        return TileMapper.toTileData(id: id, text: text);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching tiles: $e');
    }
  }

  @override
  Future<TileDetail> fetchTileDetail({required int id}) async {
    try {
      // 抽出する行を選択
      final query = db.select(db.englishTexts)..where((t) => t.id.equals(id));
      final row = await query.getSingle();

      return TileMapper.toTileDetail(et: row);
    } catch (e) {
      throw Exception('Failed to fetch tile detail (ID: $id): $e');
    }
  }

  // ===============================================
  // D: Delete
  // ===============================================

  // 指定されたIDの英文データ（Tile）をデータベースから削除
  @override
  Future<int> deleteTile({required int id}) async {
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
