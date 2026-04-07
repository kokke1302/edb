import 'package:edb/drawer/data/tile_data.dart';

class TileState {
  final List<TileData> list;

  TileState({required this.list});

  TileState copyWith({List<TileData>? list}) {
    return TileState(list: list ?? this.list);
  }
}
