import 'package:edb/domain/entity/carry/tile_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/repository_impl/local_tiles_repository.dart';
import 'package:edb/domain/entity/carry/tile_data.dart';

final tilesRepositoryProvider = Provider<TilesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalTilesRepository(db);
});

abstract interface class TilesRepository {
  Future<int> createTile({required String text, required String chain});
  Future<List<TileData>> fetchAllTiles();
  Future<TileDetail> fetchTileDetail({required int id});
  Future<void> deleteTile({required int id});
}
