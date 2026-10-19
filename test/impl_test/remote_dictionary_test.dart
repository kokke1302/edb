// -----------------------------------------------------------------------------
// - 正常系（fetchDictionaries: リクエスト）:
//   - endpoint に POST され、Content-Type と body({"word": ...}) が正しく送られること
//
// - 正常系（fetchDictionaries: レスポンスの変換）:
//   - レスポンスの順序どおりに VocabCore が返ること
//   - 各 VocabCore の word がリクエストした単語、id が -1、isShow が true、based が Based.remote になること
//   - translation / memo がレスポンスの値になること
//   - memo が空文字・null・キー省略のとき、memo が空文字になること
//   - translation が空文字・空白のみ・null・キー省略の要素が除外されること
//   - すべての要素が除外されたとき空リストを返し、ローカルにフォールバックしないこと
//   - UTF-8 の日本語が文字化けせずに取得できること
//   - 空配列のレスポンスは空リストを返し、ローカルにフォールバックしないこと
//   - 成功時はローカルの fetchDictionaries を呼ばないこと
//
// - 異常系（fetchDictionaries: ローカル処理へのフォールバック）:
//   - HTTP ステータスが 200 以外のとき、ローカル処理の結果が返ること
//   - 不正な JSON / 配列でないレスポンス / 要素の型が不正なとき、ローカル処理の結果が返ること
//   - 通信例外・想定外の例外・タイムアウトのとき、ローカル処理の結果が返ること
//   - フォールバック先(ローカル)が Exception を throw したとき、そのまま投げること
//
// - 正常系（fetchVocabularies）:
//   - 通信せずローカル処理に委譲され、その結果がそのまま返ること（HTTP リクエストが 0 回）
//
// - 異常系（fetchVocabularies）:
//   - ローカルが Exception を throw したとき、そのまま投げること
// -----------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/data/repository_impl/local_dictionary_repository.dart';
import 'package:edb/data/repository_impl/remote_dictionary.dart';
import 'package:edb/domain/model/enum/base_status.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';

// ---------------------------------------------------------------------------
// モック
// ---------------------------------------------------------------------------
class MockLocalDictionaryRepository extends Mock
    implements LocalDictionaryRepository {}

// ---------------------------------------------------------------------------
// 定数・ヘルパー
// ---------------------------------------------------------------------------
final Uri _endpoint = Uri.parse('https://example.com/dictionary');

// API のレスポンスを組み立てる（日本語を含むので UTF-8 の bytes で返す）
http.Response _jsonResponse(Object body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(body is String ? body : jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

// ローカル(DB)が返す VocabCore を組み立てる
VocabCore _makeLocalVocab({
  int id = 1,
  String word = 'apple',
  String translation = 'ローカルの訳',
  Based based = Based.dictionary,
}) {
  final now = DateTime.now();
  return VocabCore(
    id: id,
    word: word,
    translation: translation,
    isShow: true,
    memo: '',
    createdAt: now,
    updatedAt: now,
    based: based,
  );
}

// remote 由来の VocabCore の全フィールドを検証する
void _expectRemoteVocab(
  VocabCore actual, {
  required String word,
  required String translation,
  required String memo,
}) {
  expect(actual.id, -1, reason: 'id');
  expect(actual.word, word, reason: 'word');
  expect(actual.translation, translation, reason: 'translation');
  expect(actual.memo, memo, reason: 'memo');
  expect(actual.isShow, isTrue, reason: 'isShow');
  expect(actual.based, Based.remote, reason: 'based');
}

// ---------------------------------------------------------------------------
// テスト
// ---------------------------------------------------------------------------
void main() {
  late MockLocalDictionaryRepository mockLocal;
  late List<http.Request> requests;

  // MockClient を差し込んだ RemoteDictionaryRepository を作る
  RemoteDictionaryRepository buildRepository(
    Future<http.Response> Function(http.Request request) handler, {
    Duration timeout = const Duration(seconds: 60),
  }) {
    final client = MockClient((request) async {
      requests.add(request);
      return handler(request);
    });
    return RemoteDictionaryRepository(
      local: mockLocal,
      endpoint: _endpoint,
      client: client,
      timeout: timeout,
    );
  }

  setUp(() {
    mockLocal = MockLocalDictionaryRepository();
    requests = [];

    // デフォルトは「ローカルに何も無い」
    when(
      () => mockLocal.fetchDictionaries(word: any(named: 'word')),
    ).thenAnswer((_) async => []);
    when(
      () => mockLocal.fetchVocabularies(word: any(named: 'word')),
    ).thenAnswer((_) async => []);
  });

  // =========================================================================
  // fetchDictionaries
  // =========================================================================
  group('fetchDictionaries', () {
    group('正常系 - リクエスト', () {
      test('endpoint に POST され、Content-Type と body が正しく送られること', () async {
        final repository = buildRepository((_) async => _jsonResponse([]));

        await repository.fetchDictionaries(word: 'apple');

        expect(requests.length, 1);
        final request = requests.single;
        expect(request.method, 'POST');
        expect(request.url, _endpoint);
        expect(
          request.headers['Content-Type'],
          'application/json; charset=utf-8',
        );
        expect(jsonDecode(request.body), {'word': 'apple'});
      });
    });

    group('正常系 - レスポンスの変換', () {
      test('レスポンスの順序どおりに remote の VocabCore が返ること', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': 'りんご', 'memo': '果物'},
            {'translation': 'アップル', 'memo': 'IT企業名'},
          ]),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expect(result.length, 2);
        _expectRemoteVocab(
          result[0],
          word: 'apple',
          translation: 'りんご',
          memo: '果物',
        );
        _expectRemoteVocab(
          result[1],
          word: 'apple',
          translation: 'アップル',
          memo: 'IT企業名',
        );
      });

      test('memo が空文字・null・キー省略のとき、memo が空文字になること', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': '訳1', 'memo': ''},
            {'translation': '訳2', 'memo': null},
            {'translation': '訳3'},
          ]),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expect(result.length, 3);
        expect(result.map((v) => v.memo), ['', '', '']);
        expect(result.map((v) => v.translation), ['訳1', '訳2', '訳3']);
      });

      test('translation が空文字・空白のみ・null・キー省略の要素が除外されること', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': 'りんご'},
            {'translation': ''},
            {'translation': '   '},
            {'translation': null},
            {'memo': '訳なし'},
            {'translation': 'アップル'},
          ]),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        // 残った要素の順序は変わらない
        expect(result.map((v) => v.translation), ['りんご', 'アップル']);
      });

      test('すべての要素が除外されたとき空リストを返し、ローカルにフォールバックしないこと', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': ''},
            {'translation': '  '},
          ]),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expect(result, isEmpty);
        verifyNever(
          () => mockLocal.fetchDictionaries(word: any(named: 'word')),
        );
      });

      test('UTF-8 の日本語が文字化けせずに取得できること', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': 'りんご／林檎', 'memo': 'バラ科の果樹・果実'},
          ]),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expect(result.single.translation, 'りんご／林檎');
        expect(result.single.memo, 'バラ科の果樹・果実');
      });

      test('空配列のレスポンスは空リストを返し、ローカルにフォールバックしないこと', () async {
        final repository = buildRepository((_) async => _jsonResponse([]));

        final result = await repository.fetchDictionaries(word: 'apple');

        expect(result, isEmpty);
        verifyNever(
          () => mockLocal.fetchDictionaries(word: any(named: 'word')),
        );
      });

      test('成功時はローカルの fetchDictionaries を呼ばないこと', () async {
        final repository = buildRepository(
          (_) async => _jsonResponse([
            {'translation': 'りんご'},
          ]),
        );

        await repository.fetchDictionaries(word: 'apple');

        verifyNever(
          () => mockLocal.fetchDictionaries(word: any(named: 'word')),
        );
      });
    });

    group('異常系 - ローカル処理へのフォールバック', () {
      // フォールバックしたことを確かめるため、ローカルに辞書データを用意しておく
      final localVocab = _makeLocalVocab(id: -1, translation: 'ローカルの訳');

      void stubLocalWithVocab() {
        when(
          () => mockLocal.fetchDictionaries(word: any(named: 'word')),
        ).thenAnswer((_) async => [localVocab]);
      }

      void expectFellBackToLocal(List<VocabCore> result) {
        expect(result.length, 1);
        expect(result.first, same(localVocab));
        verify(() => mockLocal.fetchDictionaries(word: 'apple')).called(1);
      }

      for (final status in [500, 404, 429]) {
        test('HTTP ステータスが $status のとき、ローカル処理の結果が返ること', () async {
          stubLocalWithVocab();
          final repository = buildRepository(
            (_) async => _jsonResponse([
              {'translation': 'りんご'},
            ], status: status),
          );

          final result = await repository.fetchDictionaries(word: 'apple');

          expectFellBackToLocal(result);
        });
      }

      final invalidResponses = <String, http.Response>{
        'JSON として不正な文字列': _jsonResponse('not json'),
        '空のボディ': _jsonResponse(''),
        '配列ではなくオブジェクト': _jsonResponse({'translation': 'りんご'}),
        '要素が Map ではない': _jsonResponse(['りんご', 'アップル']),
        'translation が文字列でない': _jsonResponse([
          {'translation': 1},
        ]),
        'memo が文字列でない': _jsonResponse([
          {'translation': 'りんご', 'memo': 1},
        ]),
      };

      invalidResponses.forEach((name, response) {
        test('不正なレスポンス（$name）のとき、ローカル処理の結果が返ること', () async {
          stubLocalWithVocab();
          final repository = buildRepository((_) async => response);

          final result = await repository.fetchDictionaries(word: 'apple');

          expectFellBackToLocal(result);
        });
      });

      test('通信例外のとき、ローカル処理の結果が返ること', () async {
        stubLocalWithVocab();
        final repository = buildRepository(
          (_) async => throw http.ClientException('network down'),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expectFellBackToLocal(result);
      });

      test('想定外の例外のとき、ローカル処理の結果が返ること', () async {
        stubLocalWithVocab();
        final repository = buildRepository(
          (_) async => throw Exception('unexpected'),
        );

        final result = await repository.fetchDictionaries(word: 'apple');

        expectFellBackToLocal(result);
      });

      test('タイムアウトのとき、ローカル処理の結果が返ること', () async {
        stubLocalWithVocab();
        final repository = buildRepository((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return _jsonResponse([
            {'translation': 'りんご'},
          ]);
        }, timeout: const Duration(milliseconds: 20));

        final result = await repository.fetchDictionaries(word: 'apple');

        expectFellBackToLocal(result);
      });

      test('フォールバック先(ローカル)が Exception を throw したとき、そのまま投げること', () async {
        when(
          () => mockLocal.fetchDictionaries(word: any(named: 'word')),
        ).thenAnswer((_) async => throw Exception('db error'));
        final repository = buildRepository(
          (_) async => _jsonResponse([], status: 500),
        );

        expect(
          () => repository.fetchDictionaries(word: 'apple'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  // =========================================================================
  // fetchVocabularies
  // =========================================================================
  group('fetchVocabularies', () {
    group('正常系', () {
      test('通信せずローカル処理に委譲され、その結果がそのまま返ること', () async {
        final localVocab = _makeLocalVocab(
          id: 42,
          translation: '単語帳の訳',
          based: Based.vocabularies,
        );
        when(
          () => mockLocal.fetchVocabularies(word: any(named: 'word')),
        ).thenAnswer((_) async => [localVocab]);
        final repository = buildRepository((_) async => _jsonResponse([]));

        final result = await repository.fetchVocabularies(word: 'apple');

        expect(result.length, 1);
        expect(result.first, same(localVocab));
        verify(() => mockLocal.fetchVocabularies(word: 'apple')).called(1);
        expect(requests, isEmpty);
      });
    });

    group('異常系', () {
      test('ローカルが Exception を throw したとき、そのまま投げること', () async {
        when(
          () => mockLocal.fetchVocabularies(word: any(named: 'word')),
        ).thenAnswer((_) async => throw Exception('db error'));
        final repository = buildRepository((_) async => _jsonResponse([]));

        expect(
          () => repository.fetchVocabularies(word: 'apple'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
