import 'package:edb/dictionary/data/card_state.dart';

class Token {
  final int id; // 固有ID
  final bool isWord; // 単語であるかどうか (true: 単語, false: 句読点など)
  final CardEntry card;
  // id,
  // word, 表示する単語（大文字OK）
  // translation,
  // isShow,
  // nowShow,
  // memo,
  // based,

  Token({required this.id, required this.isWord, required this.card});

  // 訳語を変更
  Token copyWith({int? id, bool? isWord, CardEntry? card}) {
    return Token(
      id: id ?? this.id,
      isWord: isWord ?? this.isWord,
      card: card ?? this.card,
    );
  }

  // TokenオブジェクトからJSON形式へ
  Map<String, dynamic> toJson() {
    return {'id': id, 'isWord': isWord, 'card': card.toJson()};
  }

  // JSON形式からTokenオブジェクトへ
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'] as int,
      isWord: json['isWord'] as bool,
      card: CardEntry.fromJson(json['card'] as Map<String, dynamic>),
    );
  }
}
