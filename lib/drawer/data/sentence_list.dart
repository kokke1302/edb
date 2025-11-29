import 'package:edb/drawer/data/sentence.dart';

class TileState {
  final List<Tile> list;
  final bool isProcessing; // 処理中かどうか

  TileState({required this.list, required this.isProcessing});

  TileState copyWith({List<Tile>? list, bool? isProcessing}) {
    return TileState(
      list: list ?? this.list,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
