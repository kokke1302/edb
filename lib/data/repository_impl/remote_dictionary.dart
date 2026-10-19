import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:edb/data/mapper/vocab_mapper.dart';
import 'package:edb/data/repository_impl/local_dictionary_repository.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/repository_abstract/dictionary_repository.dart';

// 単語の辞書情報を外部APIから取得する実装
//
// - fetchVocabularies: ローカルから語彙データを取得する
// - fetchDictionaries: 外部APIに単語の意味を問い合わせ、取得したデータをVocabCoreに変換する
//
// API仕様
//   POST {endpoint}  Content-Type: application/json
//   リクエスト : {"word": "apple"}
//   レスポンス : 該当単語に対する訳語などの情報の配列
//     [{"translation":"りんご","memo":"果物"},
//      {"translation":"アップル","memo":"IT企業名"}]
//   - translation : 訳語。無い場合は空文字（キーの省略も可）
//   - memo : その訳語が使われる主な文脈、ニュアンス、または補足説明（品詞やカテゴリなど）。

class RemoteDictionaryRepository implements DictionaryRepository {
  final LocalDictionaryRepository _local;
  final Uri _endpoint;
  final http.Client _client;
  final Duration _timeout;

  RemoteDictionaryRepository({
    required LocalDictionaryRepository local,
    required Uri endpoint,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
  }) : _local = local,
       _endpoint = endpoint,
       _client = client ?? http.Client(),
       _timeout = timeout;

  @override
  Future<List<VocabCore>> fetchVocabularies({required String word}) {
    return _local.fetchVocabularies(word: word);
  }

  // 通信失敗・不正なレスポンスのときはローカル処理にフォールバックする
  @override
  Future<List<VocabCore>> fetchDictionaries({required String word}) async {
    try {
      return await _fetchVocabs(word: word);
    } catch (_) {
      // オフライン・サーバー不調時もアプリが使えるようにローカル処理へ
      return _local.fetchDictionaries(word: word);
    }
  }

  Future<List<VocabCore>> _fetchVocabs({required String word}) async {
    final response = await _client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'word': word}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Translate API error: ${response.statusCode}');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    final vocabs = decoded
        .map(
          (e) => VocabMapper.fromRemoteJson(
            word: word,
            json: e as Map<String, dynamic>,
          ),
        )
        .where((v) => v.translation.trim().isNotEmpty) // 空白のみ・空文字のトークンは、無視する
        .toList();

    return vocabs;
  }
}
