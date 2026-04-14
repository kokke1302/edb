import 'package:edb/domain/entity/carry/tile_data.dart';

class TilesData {
  final List<TileData> list;

  TilesData({this.list = const []});

  TilesData copyWith({List<TileData>? list}) {
    return TilesData(list: list ?? this.list);
  }
}
