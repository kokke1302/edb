class RegistrationState {
  final String englishWord; // 登録・編集対象の英単語
  final String japaneseTranslation; // ユーザーが入力した日本語訳
  final bool isHidden; // 訳を「非表示」するかどうかの設定
  final String memo; // ユーザーが入力したメモ
  final int existingVocId; // 既存エントリを編集する場合はそのID、新規登録時は-1
  final bool isProcessing; // 処理中フラグ

  const RegistrationState({
    required this.englishWord,
    required this.japaneseTranslation,
    required this.memo,
    required this.isHidden,
    required this.existingVocId,
    required this.isProcessing,
  });

  // 状態を変更した新しいインスタンスを返すメソッド
  RegistrationState copyWith({
    String? englishWord,
    String? japaneseTranslation,
    String? memo,
    bool? isHidden,
    int? existingVocId,
    bool? isProcessing,
  }) {
    return RegistrationState(
      englishWord: englishWord ?? this.englishWord,
      japaneseTranslation: japaneseTranslation ?? this.japaneseTranslation,
      memo: memo ?? this.memo,
      isHidden: isHidden ?? this.isHidden,
      existingVocId: existingVocId ?? this.existingVocId,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
