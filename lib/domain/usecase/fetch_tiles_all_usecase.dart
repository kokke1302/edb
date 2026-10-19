import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/model/value_object/tile_data.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';

final fetchAllTilesUseCaseProvider = Provider(
  (ref) => FetchAllTilesUseCase(ref.watch(tilesRepositoryProvider)),
);

class FetchAllTilesUseCase {
  final TilesRepository _repository;
  FetchAllTilesUseCase(this._repository);

  Future<List<TileData>> execute() async {
    return await _repository.fetchAllTiles();
  }
}
