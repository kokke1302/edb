import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/repository_abstract/tiles_repository.dart';

final deleteTileUseCaseProvider = Provider(
  (ref) => DeleteTileUseCase(ref.watch(tilesRepositoryProvider)),
);

class DeleteTileUseCase {
  final TilesRepository _repository;
  DeleteTileUseCase(this._repository);

  Future<void> execute({required int id}) async {
    // DBから削除
    await _repository.deleteTile(id: id);
  }
}
