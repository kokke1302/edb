import 'package:edb/domain/model/value_object/token_data.dart';

class TileDetail {
  final String title;
  final List<TokenData> chain;

  TileDetail({required this.title, required this.chain});
}
