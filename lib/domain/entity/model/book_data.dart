import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/value/sync_status.dart';

/// 単語リストと状態を保持するクラス
class BookData {
  final int pageSize; // 1ページあたりの件数
  final List<CardData> cards; // 単語リスト本体
  final SyncStatus tailStatus; // 下部に表示すべき状態

  BookData({
    required this.pageSize,
    required this.cards,
    this.tailStatus = SyncStatus.normal,
  });

  // 全てのデータがロードされたか
  bool get isDataEnd => cards.length < pageSize; // 最初のロードでページサイズ未満なら終端

  /// 状態の一部を更新するためのメソッド
  BookData copyWith({
    int? pageSize,
    List<CardData>? words,
    SyncStatus? tailStatus,
  }) {
    return BookData(
      pageSize: pageSize ?? this.pageSize,
      cards: words ?? cards,
      tailStatus: tailStatus ?? this.tailStatus,
    );
  }
}
