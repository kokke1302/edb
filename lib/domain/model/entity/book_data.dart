import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/enum/sync_status.dart';

// 単語リストと状態を保持するクラス
class BookData {
  final List<VocabCore> vocabs; // 単語リスト本体
  final SyncStatus tailStatus; // 下部に表示すべき状態
  final bool isDataEnd; // 全てのデータがロードされたか

  BookData({
    this.vocabs = const [],
    this.tailStatus = SyncStatus.normal,
    this.isDataEnd = false,
  });

  // 状態の一部を更新するためのメソッド
  BookData copyWith({
    List<VocabCore>? vocabs,
    SyncStatus? tailStatus,
    bool? isDataEnd,
  }) {
    return BookData(
      vocabs: vocabs ?? this.vocabs,
      tailStatus: tailStatus ?? this.tailStatus,
      isDataEnd: isDataEnd ?? this.isDataEnd,
    );
  }
}
