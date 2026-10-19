import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:edb/data/mapper/token_mapper.dart';
import 'package:edb/data/repository_impl/local_text_processor.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/repository_abstract/processor_repository.dart';

// 英文全体の解析（トークン化＋訳語の付与）を外部APIに任せる実装
//
// - fullTranslation: APIでトークン化・訳語取得
// - partTranslation: 入力のたびに走る差分更新なので、通信せずローカルで処理する
//
// API仕様
//   POST {endpoint}  Content-Type: application/json
//   リクエスト : {"text": "I like apples."}
//   レスポンス : 原文の出現順に並べたトークンの配列
//     [{"showWord":"I","translation":"私は"},
//      {"showWord":"like","translation":"好む"},
//      {"showWord":"apples","translation":"りんご"},
//      {"showWord":".","translation":""}]
//   - showWord    : 原文どおりの表層形（ローカルのトークン化規則と同じ切り方）
//   - translation : 訳語。無い場合は空文字（キーの省略も可）

class RemoteTextProcessor implements TextProcessor {
  final LocalTextProcessor _local;
  final Uri _endpoint;
  final http.Client _client;
  final Duration _timeout;

  RemoteTextProcessor({
    required LocalTextProcessor local,
    required Uri endpoint,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
  }) : _local = local,
       _endpoint = endpoint,
       _client = client ?? http.Client(),
       _timeout = timeout;

  // 入力のたびに走る差分更新なので通信せず、ローカルで処理する
  @override
  Future<List<TokenData>> partTranslation({
    required List<TokenData> nowTokens,
    required String newText,
  }) {
    return _local.partTranslation(nowTokens: nowTokens, newText: newText);
  }

  // 通信失敗・不正なレスポンスのときはローカル処理にフォールバックする
  @override
  Future<List<TokenData>> fullTranslation({required String text}) async {
    try {
      return await _fetchTokens(text: text);
    } catch (_) {
      // オフライン・サーバー不調時もアプリが使えるようにローカル処理へ
      return _local.fullTranslation(text: text);
    }
  }

  Future<List<TokenData>> _fetchTokens({required String text}) async {
    final response = await _client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'text': text}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Translate API error: ${response.statusCode}');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    final tokens = decoded
        .map((e) => TokenMapper.fromRemoteJson(json: e as Map<String, dynamic>))
        .where((t) => t.showWord.trim().isNotEmpty) // 空白のみ・空文字のトークンは、無視する
        .toList();

    for (var i = 0; i < tokens.length; i++) {
      tokens[i] = tokens[i].copyWith(id: i);
    }

    return tokens;
  }
}
