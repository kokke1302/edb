import 'package:edb/translation/data/token.dart';

class Tile {
  final int id;
  final String text;
  final List<Token> chain;

  Tile({required this.id, required this.text, required this.chain});

  Tile copyWith({int? id, String? text, List<Token>? chain}) {
    return Tile(
      id: id ?? this.id,
      text: text ?? this.text,
      chain: chain ?? this.chain,
    );
  }
}
