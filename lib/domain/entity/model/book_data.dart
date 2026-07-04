import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/value/sync_status.dart';

/// 単語リストと状態を保持するクラス
class BookData {
  final int pageSize; // 直近のリクエストで実際に取得した件数
  final List<CardData> cards; // 単語リスト本体
  final SyncStatus tailStatus; // 下部に表示すべき状態
  final bool isDataEnd; // 全てのデータがロードされたか

  BookData({
    required this.pageSize,
    required this.cards,
    this.tailStatus = SyncStatus.normal,
    this.isDataEnd = false,
  });

  /// 状態の一部を更新するためのメソッド
  BookData copyWith({
    int? pageSize,
    List<CardData>? cards,
    SyncStatus? tailStatus,
    bool? isDataEnd,
  }) {
    return BookData(
      pageSize: pageSize ?? this.pageSize,
      cards: cards ?? this.cards,
      tailStatus: tailStatus ?? this.tailStatus,
      isDataEnd: isDataEnd ?? this.isDataEnd,
    );
  }
}
