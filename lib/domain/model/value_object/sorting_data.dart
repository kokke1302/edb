import 'package:edb/domain/model/enum/sort_field.dart';
import 'package:edb/domain/model/enum/sort_order.dart';

// ソート設定を格納するクラス
class SortingData {
  final SortField field;
  final SortOrder order;
  final String searchWord;
  final int pageSize;

  const SortingData({
    this.field = SortField.englishWord,
    this.order = SortOrder.desc,
    this.searchWord = '',
    this.pageSize = 20,
  });

  // 変更用メソッド
  SortingData copyWith({
    SortField? field,
    SortOrder? order,
    String? searchWord,
    int? pageSize,
  }) {
    return SortingData(
      field: field ?? this.field,
      order: order ?? this.order,
      searchWord: searchWord ?? this.searchWord,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
