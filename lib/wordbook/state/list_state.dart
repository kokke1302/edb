import '../../db/app_database.dart';

enum EndStatus { normal, loading, error }

/// 単語リストと状態を保持するクラス
class WordListState {
  final List<Vocabulary> words; // 単語リスト本体
  final EndStatus endStatus; // 下部に表示すべき状態
  final bool isDataEnd; // 全てのデータがロードされたか

  WordListState({
    required this.words,
    this.endStatus = EndStatus.normal,
    this.isDataEnd = false,
  });

  /// 状態の一部を更新するためのメソッド
  WordListState copyWith({
    List<Vocabulary>? words,
    EndStatus? endStatus,
    bool? isDataEnd,
  }) {
    return WordListState(
      words: words ?? this.words,
      endStatus: endStatus ?? this.endStatus,
      isDataEnd: isDataEnd ?? this.isDataEnd,
    );
  }
}
