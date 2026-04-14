import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/carry/tile_data.dart';
import 'package:edb/domain/entity/token_data.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';

final saveTileUseCaseProvider = Provider(
  (ref) => SaveTileUseCase(ref.watch(tilesRepositoryProvider)),
);

class SaveTileUseCase {
  final TilesRepository _repository;
  SaveTileUseCase(this._repository);

  Future<TileData> execute({
    required String originalText,
    required List<TokenData> tokens,
  }) async {
    // データの加工
    final List<Map<String, dynamic>> tokenMaps = tokens
        .map((t) => t.toJson())
        .toList();
    final jsonString = json.encode(tokenMaps);

    final tileId = await _repository.createTile(
      text: originalText,
      chain: jsonString,
    );

    return TileData(id: tileId, text: originalText);
  }
}
