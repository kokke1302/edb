import 'package:edb/share/data/card_data.dart';
import 'package:edb/share/data/sync_status.dart';

/// 単語リストと状態を保持するクラス
class WordListState {
  final int pageSize; // 1ページあたりの件数
  final List<CardData> words; // 単語リスト本体
  final SyncStatus tailStatus; // 下部に表示すべき状態
  final bool isDataEnd; // 全てのデータがロードされたか

  WordListState({
    required this.pageSize,
    required this.words,
    required this.tailStatus,
    required this.isDataEnd,
  });

  /// 状態の一部を更新するためのメソッド
  WordListState copyWith({
    int? pageSize,
    List<CardData>? words,
    SyncStatus? tailStatus,
    bool? isDataEnd,
  }) {
    return WordListState(
      pageSize: pageSize ?? this.pageSize,
      words: words ?? this.words,
      tailStatus: tailStatus ?? this.tailStatus,
      isDataEnd: isDataEnd ?? this.isDataEnd,
    );
  }
}
