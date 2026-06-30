import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/carry/tile_detail.dart';
import 'package:edb/domain/repository_abstract/tiles_repository.dart';

final fetchTileDetailUseCaseProvider = Provider(
  (ref) => FetchTileDetailUseCase(ref.watch(tilesRepositoryProvider)),
);

class FetchTileDetailUseCase {
  final TilesRepository _repository;
  FetchTileDetailUseCase(this._repository);

  Future<TileDetail> execute({required int id}) async {
    return await _repository.fetchTileDetail(id: id);
  }
}
