import 'package:edb/dictionary/data/card_state.dart';

class RegistrationState {
  final int id;
  final String englishWord;
  final String japaneseTranslation;
  final bool isHidden;
  final String memo;
  final Based based;
  final bool isProcessing; // 処理中フラグ

  const RegistrationState({
    required this.id,
    required this.englishWord,
    required this.japaneseTranslation,
    required this.isHidden,
    required this.memo,
    required this.based,
    required this.isProcessing,
  });

  // 状態を変更した新しいインスタンスを返すメソッド
  RegistrationState copyWith({
    int? id,
    String? englishWord,
    String? japaneseTranslation,
    bool? isHidden,
    String? memo,
    Based? based,
    bool? isProcessing,
  }) {
    return RegistrationState(
      id: id ?? this.id,
      englishWord: englishWord ?? this.englishWord,
      japaneseTranslation: japaneseTranslation ?? this.japaneseTranslation,
      isHidden: isHidden ?? this.isHidden,
      memo: memo ?? this.memo,
      based: based ?? this.based,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
