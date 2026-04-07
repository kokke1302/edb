class TileData {
  final int id;
  final String text;

  TileData({required this.id, required this.text});

  TileData copyWith({String? text}) {
    return TileData(id: id, text: text ?? this.text);
  }
}
