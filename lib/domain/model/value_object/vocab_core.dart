import 'package:edb/domain/model/enum/base_status.dart';
import 'package:edb/domain/model/value_object/token_data.dart';

class VocabCore {
  final int id;
  final String word;
  final String translation;
  final bool isShow;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Based based;

  VocabCore({
    required this.id,
    required this.word,
    required this.translation,
    required this.isShow,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
    required this.based,
  });

  VocabCore copyWith({
    int? id,
    String? word,
    String? translation,
    bool? isShow,
    String? memo,
    DateTime? updatedAt,
    Based? based,
  }) {
    return VocabCore(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      isShow: isShow ?? this.isShow,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      based: based ?? this.based,
    );
  }

  factory VocabCore.init({String word = ''}) {
    return VocabCore(
      id: -1,
      word: word.toLowerCase(),
      translation: '',
      isShow: true,
      memo: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      based: Based.init,
    );
  }

  factory VocabCore.fromToken(TokenData token) {
    final now = DateTime.now();
    if (token.isRemote) {
      return VocabCore(
        id: token.vocabId,
        word: token.word,
        translation: token.translation,
        isShow: false,
        memo: '',
        createdAt: now,
        updatedAt: now,
        based: Based.remote,
      );
    } else {
      return VocabCore(
        id: token.vocabId,
        word: token.word,
        translation: token.translation,
        isShow: false,
        memo: '',
        createdAt: now,
        updatedAt: now,
        based: Based.init,
      );
    }
  }
}
