import 'package:edb/domain/entity/value/sort_field.dart';
import 'package:edb/domain/entity/value/sort_oder.dart';

// ソート設定を格納するクラス
class SortingData {
  final SortField field;
  final SortOrder order;
  final String searchWord;
  final String typingWord;

  const SortingData({
    this.field = SortField.englishWord,
    this.order = SortOrder.desc,
    this.searchWord = '',
    this.typingWord = '',
  });

  // 変更用メソッド
  SortingData copyWith({
    SortField? field,
    SortOrder? order,
    String? searchWord,
    String? typingWord,
  }) {
    return SortingData(
      field: field ?? this.field,
      order: order ?? this.order,
      searchWord: searchWord ?? this.searchWord,
      typingWord: typingWord ?? this.typingWord,
    );
  }
}
