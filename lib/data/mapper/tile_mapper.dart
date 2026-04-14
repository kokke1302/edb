import 'dart:convert';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/token_mapper.dart';
import 'package:edb/domain/entity/carry/tile_detail.dart';
import 'package:edb/domain/entity/carry/tile_data.dart';

class TileMapper {
  static TileData toTileData({required int id, required String text}) {
    return TileData(id: id, text: text);
  }

  static TileDetail toTileDetail({required EnglishText et}) {
    final List<dynamic> decodedList = json.decode(et.parsedWordsJson);
    final chain = decodedList
        .map((item) => TokenMapper.fromJson(item))
        .toList();

    return TileDetail(title: et.originalText, chain: chain);
  }
}
