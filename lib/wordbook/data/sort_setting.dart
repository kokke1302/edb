enum SortField { createdAt, englishWord }

enum SortOrder { asc, desc }

// ソート設定を格納するクラス
class SortSetting {
  final SortField field;
  final SortOrder order;

  const SortSetting({required this.field, required this.order});

  // 変更用メソッド
  SortSetting copyWith({SortField? field, SortOrder? order}) {
    return SortSetting(field: field ?? this.field, order: order ?? this.order);
  }
}
