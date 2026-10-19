// -----------------------------------------------------------------------------
// - 正常系（fullTranslation: リクエスト）:
//   - endpoint に POST され、Content-Type と body({"text": ...}) が正しく送られること
//
// - 正常系（fullTranslation: レスポンスの変換）:
//   - レスポンスの順序どおりにトークンが返り、id が 0 始まりの連番になること
//   - 訳語のある単語が vocabId: -2 / nowShow: true / translation 付きになること
//   - 訳語が空文字・空白のみ・キー省略の単語が未登録トークン(vocabId: -1)になること
//   - 句読点は訳語があっても未登録トークンのままになること
//   - showWord が空・空白のみのトークンが除外され、id が詰めて振り直されること
//   - UTF-8 の日本語訳が文字化けせずに取得できること
//   - 同じ単語が複数回出てきても、それぞれ remote トークンになること
//   - 空配列のレスポンスは空リストを返し、ローカルにフォールバックしないこと
//   - 成功時は単語帳(DB)を参照しないこと
//
// - 異常系（fullTranslation: ローカル処理へのフォールバック）:
//   - HTTP ステータスが 200 以外のとき、ローカル処理の結果が返ること
//   - 不正な JSON / 配列でないレスポンス / 要素の型・キーが不正なとき、ローカル処理の結果が返ること
//   - 通信例外・タイムアウトのとき、ローカル処理の結果が返ること
//   - フォールバック先(DB)が例外を投げたとき、そのまま投げること
//
// - 正常系（partTranslation）:
//   - 通信せずローカル処理に委譲されること（HTTP リクエストが 0 回）
//   - 追加された単語にだけ DB の翻訳が反映されること
//   - 変更のない remote トークンの vocabId / translation / nowShow が保持されること
//   - 変更された単語は DB で引き直され、remote の訳は引き継がれないこと
//
// - 異常系（partTranslation）:
//   - DB が Exception を throw したとき、そのまま投げること
// -----------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/data/repository_impl/local_text_processor.dart';
import 'package:edb/data/repository_impl/remote_text_processor.dart';
import 'package:edb/domain/model/value_object/token_core.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';

// ---------------------------------------------------------------------------
// モック
// ---------------------------------------------------------------------------
class MockTranslationRepository extends Mock implements TranslationRepository {}

// ---------------------------------------------------------------------------
// 定数・ヘルパー
// ---------------------------------------------------------------------------
final Uri _endpoint = Uri.parse('https://example.com/translate');

// API のレスポンスを組み立てる（日本語を含むので UTF-8 の bytes で返す）
http.Response _jsonResponse(Object body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(body is String ? body : jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

// fetchTranslationsBatch が返す TokenCore を組み立てる
TokenCore _makeEntry({
  int id = 1,
  required String word,
  bool isShow = true,
  String translation = '',
}) {
  return TokenCore(
    vocabId: id,
    showWord: word,
    isShow: isShow,
    translation: translation,
  );
}

// partTranslation の nowTokens 用の TokenData を組み立てる
TokenData _makeToken({
  int id = -1,
  int vocabId = -1,
  required String showWord,
  bool nowShow = false,
  String translation = '',
}) {
  return TokenData(
    id: id,
    vocabId: vocabId,
    showWord: showWord,
    nowShow: nowShow,
    translation: translation,
  );
}

// トークンの全フィールドを検証する
void _expectToken(
  TokenData actual, {
  required int id,
  required int vocabId,
  required String showWord,
  required bool nowShow,
  required String translation,
}) {
  expect(actual.id, id, reason: 'id');
  expect(actual.vocabId, vocabId, reason: 'vocabId');
  expect(actual.showWord, showWord, reason: 'showWord');
  expect(actual.nowShow, nowShow, reason: 'nowShow');
  expect(actual.translation, translation, reason: 'translation');
}

// ---------------------------------------------------------------------------
// テスト
// ---------------------------------------------------------------------------
void main() {
  late MockTranslationRepository mockDb;
  late List<http.Request> requests;

  // MockClient を差し込んだ RemoteTextProcessor を作る
  RemoteTextProcessor buildProcessor(
    Future<http.Response> Function(http.Request request) handler, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    final client = MockClient((request) async {
      requests.add(request);
      return handler(request);
    });
    return RemoteTextProcessor(
      local: LocalTextProcessor(mockDb),
      endpoint: _endpoint,
      client: client,
      timeout: timeout,
    );
  }

  setUp(() {
    mockDb = MockTranslationRepository();
    requests = [];

    // デフォルトは「単語帳に何も登録されていない」
    when(
      () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
    ).thenAnswer((_) async => []);
  });

  // =========================================================================
  // fullTranslation
  // =========================================================================
  group('fullTranslation', () {
    group('正常系 - リクエスト', () {
      test('endpoint に POST され、Content-Type と body が正しく送られること', () async {
        final processor = buildProcessor((_) async => _jsonResponse([]));

        await processor.fullTranslation(text: 'I like apples.');

        expect(requests.length, 1);
        final request = requests.single;
        expect(request.method, 'POST');
        expect(request.url, _endpoint);
        expect(
          request.headers['Content-Type'],
          'application/json; charset=utf-8',
        );
        expect(jsonDecode(request.body), {'text': 'I like apples.'});
      });
    });

    group('正常系 - レスポンスの変換', () {
      test('レスポンスの順序どおりにトークンが返り、id が 0 始まりの連番になること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'I', 'translation': '私は'},
            {'showWord': 'like', 'translation': '好む'},
            {'showWord': 'apples', 'translation': 'りんご'},
            {'showWord': '.', 'translation': ''},
          ]),
        );

        final result = await processor.fullTranslation(text: 'I like apples.');

        expect(result.map((t) => t.showWord).toList(), [
          'I',
          'like',
          'apples',
          '.',
        ]);
        expect(result.map((t) => t.id).toList(), [0, 1, 2, 3]);
      });

      test(
        '訳語のある単語が vocabId: -2 / nowShow: true / translation 付きになること',
        () async {
          final processor = buildProcessor(
            (_) async => _jsonResponse([
              {'showWord': 'apples', 'translation': 'りんご'},
            ]),
          );

          final result = await processor.fullTranslation(text: 'apples');

          expect(result.length, 1);
          _expectToken(
            result.first,
            id: 0,
            vocabId: TokenData.remoteVocabId,
            showWord: 'apples',
            nowShow: true,
            translation: 'りんご',
          );
          expect(result.first.isRemote, isTrue);
        },
      );

      test('訳語が空文字の単語が未登録トークンになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'apples', 'translation': ''},
          ]),
        );

        final result = await processor.fullTranslation(text: 'apples');

        _expectToken(
          result.first,
          id: 0,
          vocabId: TokenData.noVocabId,
          showWord: 'apples',
          nowShow: false,
          translation: '',
        );
      });

      test('訳語が空白のみの単語が未登録トークンになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'apples', 'translation': '   '},
          ]),
        );

        final result = await processor.fullTranslation(text: 'apples');

        expect(result.first.vocabId, TokenData.noVocabId);
        expect(result.first.nowShow, isFalse);
        expect(result.first.translation, '');
      });

      test('translation キーが省略された単語が未登録トークンになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'apples'},
          ]),
        );

        final result = await processor.fullTranslation(text: 'apples');

        _expectToken(
          result.first,
          id: 0,
          vocabId: TokenData.noVocabId,
          showWord: 'apples',
          nowShow: false,
          translation: '',
        );
      });

      test('translation が null の単語が未登録トークンになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'apples', 'translation': null},
          ]),
        );

        final result = await processor.fullTranslation(text: 'apples');

        expect(result.first.vocabId, TokenData.noVocabId);
        expect(result.first.translation, '');
      });

      test('句読点は訳語があっても未登録トークンのままになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': '.', 'translation': '。'},
          ]),
        );

        final result = await processor.fullTranslation(text: '.');

        _expectToken(
          result.first,
          id: 0,
          vocabId: TokenData.noVocabId,
          showWord: '.',
          nowShow: false,
          translation: '',
        );
      });

      test('showWord が空・空白のみのトークンが除外され、id が詰めて振り直されること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'hello', 'translation': 'こんにちは'},
            {'showWord': '', 'translation': 'x'},
            {'showWord': '   ', 'translation': 'y'},
            {'showWord': 'world', 'translation': '世界'},
          ]),
        );

        final result = await processor.fullTranslation(text: 'hello world');

        expect(result.map((t) => t.showWord).toList(), ['hello', 'world']);
        expect(result.map((t) => t.id).toList(), [0, 1]);
      });

      test('UTF-8 の日本語訳が文字化けせずに取得できること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'sushi', 'translation': 'お寿司🍣'},
          ]),
        );

        final result = await processor.fullTranslation(text: 'sushi');

        expect(result.first.translation, 'お寿司🍣');
      });

      test('同じ単語が複数回出てきても、それぞれ remote トークンになること', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'go', 'translation': '行く'},
            {'showWord': 'go', 'translation': '行く'},
          ]),
        );

        final result = await processor.fullTranslation(text: 'go go');

        expect(result.length, 2);
        expect(result.every((t) => t.isRemote), isTrue);
        expect(result.map((t) => t.id).toList(), [0, 1]);
      });

      test('空配列のレスポンスは空リストを返し、ローカルにフォールバックしないこと', () async {
        final processor = buildProcessor((_) async => _jsonResponse([]));

        final result = await processor.fullTranslation(text: '');

        expect(result, isEmpty);
        verifyNever(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        );
      });

      test('成功時は単語帳(DB)を参照しないこと', () async {
        final processor = buildProcessor(
          (_) async => _jsonResponse([
            {'showWord': 'hello', 'translation': 'こんにちは'},
          ]),
        );

        await processor.fullTranslation(text: 'hello');

        verifyNever(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        );
      });
    });

    group('異常系 - ローカル処理へのフォールバック', () {
      // フォールバックしたことを確かめるため、DB に hello を登録しておく
      void stubDbWithHello() {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer(
          (_) async => [_makeEntry(id: 7, word: 'hello', translation: '登録訳')],
        );
      }

      void expectFellBackToLocal(List<TokenData> result) {
        expect(result.length, 1);
        _expectToken(
          result.first,
          id: 0,
          vocabId: 7,
          showWord: 'hello',
          nowShow: true,
          translation: '登録訳',
        );
        verify(() => mockDb.fetchTranslationsBatch(keys: {'hello'})).called(1);
      }

      for (final status in [500, 404, 429]) {
        test('HTTP ステータスが $status のとき、ローカル処理の結果が返ること', () async {
          stubDbWithHello();
          final processor = buildProcessor(
            (_) async => _jsonResponse([
              {'showWord': 'hello', 'translation': 'こんにちは'},
            ], status: status),
          );

          final result = await processor.fullTranslation(text: 'hello');

          expectFellBackToLocal(result);
        });
      }

      final invalidResponses = <String, http.Response>{
        'JSON として不正な文字列': _jsonResponse('not json'),
        '空のボディ': _jsonResponse(''),
        '配列ではなくオブジェクト': _jsonResponse({'showWord': 'hello'}),
        '要素が Map ではない': _jsonResponse(['hello', 'world']),
        'showWord キーが欠落': _jsonResponse([
          {'translation': 'こんにちは'},
        ]),
        'showWord が null': _jsonResponse([
          {'showWord': null, 'translation': 'こんにちは'},
        ]),
        'showWord が文字列でない': _jsonResponse([
          {'showWord': 1, 'translation': 'こんにちは'},
        ]),
        'translation が文字列でない': _jsonResponse([
          {'showWord': 'hello', 'translation': 1},
        ]),
      };

      invalidResponses.forEach((name, response) {
        test('不正なレスポンス（$name）のとき、ローカル処理の結果が返ること', () async {
          stubDbWithHello();
          final processor = buildProcessor((_) async => response);

          final result = await processor.fullTranslation(text: 'hello');

          expectFellBackToLocal(result);
        });
      });

      test('通信例外のとき、ローカル処理の結果が返ること', () async {
        stubDbWithHello();
        final processor = buildProcessor(
          (_) async => throw http.ClientException('network down'),
        );

        final result = await processor.fullTranslation(text: 'hello');

        expectFellBackToLocal(result);
      });

      test('想定外の例外のとき、ローカル処理の結果が返ること', () async {
        stubDbWithHello();
        final processor = buildProcessor(
          (_) async => throw Exception('unexpected'),
        );

        final result = await processor.fullTranslation(text: 'hello');

        expectFellBackToLocal(result);
      });

      test('タイムアウトのとき、ローカル処理の結果が返ること', () async {
        stubDbWithHello();
        final processor = buildProcessor((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return _jsonResponse([
            {'showWord': 'hello', 'translation': 'こんにちは'},
          ]);
        }, timeout: const Duration(milliseconds: 20));

        final result = await processor.fullTranslation(text: 'hello');

        expectFellBackToLocal(result);
      });

      test('フォールバック先(DB)が Exception を throw したとき、そのまま投げること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => throw Exception('db error'));
        final processor = buildProcessor(
          (_) async => _jsonResponse([], status: 500),
        );

        expect(
          () => processor.fullTranslation(text: 'hello'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  // =========================================================================
  // partTranslation
  // =========================================================================
  group('partTranslation', () {
    group('正常系', () {
      test('通信せずローカル処理に委譲されること', () async {
        final processor = buildProcessor((_) async => _jsonResponse([]));
        final nowTokens = [_makeToken(id: 0, showWord: 'hello')];

        await processor.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        expect(requests, isEmpty);
      });

      test('追加された単語にだけ DB の翻訳が反映されること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer(
          (_) async => [_makeEntry(id: 5, word: 'world', translation: '世界')],
        );
        final processor = buildProcessor((_) async => _jsonResponse([]));
        final nowTokens = [_makeToken(id: 0, showWord: 'hello')];

        final result = await processor.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        expect(result.length, 2);
        _expectToken(
          result[0],
          id: 0,
          vocabId: -1,
          showWord: 'hello',
          nowShow: false,
          translation: '',
        );
        _expectToken(
          result[1],
          id: 1,
          vocabId: 5,
          showWord: 'world',
          nowShow: true,
          translation: '世界',
        );
        verify(() => mockDb.fetchTranslationsBatch(keys: {'world'})).called(1);
      });

      test(
        '変更のない remote トークンの vocabId / translation / nowShow が保持されること',
        () async {
          final processor = buildProcessor((_) async => _jsonResponse([]));
          final nowTokens = [
            _makeToken(
              id: 0,
              vocabId: TokenData.remoteVocabId,
              showWord: 'hello',
              nowShow: true,
              translation: 'こんにちは',
            ),
          ];

          final result = await processor.partTranslation(
            nowTokens: nowTokens,
            newText: 'hello world',
          );

          _expectToken(
            result[0],
            id: 0,
            vocabId: TokenData.remoteVocabId,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          );
        },
      );

      test('変更された単語は DB で引き直され、remote の訳は引き継がれないこと', () async {
        final processor = buildProcessor((_) async => _jsonResponse([]));
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: TokenData.remoteVocabId,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
        ];

        // DB は空 → 未登録として引き直される
        final result = await processor.partTranslation(
          nowTokens: nowTokens,
          newText: 'goodbye',
        );

        expect(result.length, 1);
        _expectToken(
          result.first,
          id: 0,
          vocabId: TokenData.noVocabId,
          showWord: 'goodbye',
          nowShow: false,
          translation: '',
        );
      });
    });

    group('異常系', () {
      test('DB が Exception を throw したとき、そのまま投げること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => throw Exception('db error'));
        final processor = buildProcessor((_) async => _jsonResponse([]));

        expect(
          () => processor.partTranslation(nowTokens: [], newText: 'hello'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
