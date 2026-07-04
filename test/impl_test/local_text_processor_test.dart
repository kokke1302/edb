// -----------------------------------------------------------------------------
// - 正常系（fullTranslation: トークン化）:
//   - 通常の英単語がトークンに分割されること
//   - ハイフン単語（例: "well-known"）が 1 トークンになること
//   - アポストロフィ単語（例: "it's"）が 1 トークンになること
//   - 句読点が独立したトークンになること
//   - 空白のみのトークンが無視されること
//
// - 正常系（fullTranslation: 翻訳マッピング）:
//   - DB に登録済みの単語に vocabId / translation / nowShow が反映されること
//   - DB に未登録の単語の vocabId / translation が初期値のままになること
//   - 句読点トークンの vocabId / translation が初期値のままになること
//   - 各トークンの id が 0 始まりの連番になること
//
// - 境界値（fullTranslation）:
//   - 同じ word の大文字・小文字が混在するテキストでも DB のエントリが反映されること
//   - lookupKeys に重複する単語があっても fetchTokenChain に渡されるキーが重複しないこと
//
// - 正常系（partTranslation: 差分なし）:
//   - newText が nowTokens と同じ内容のとき、既存トークンがそのまま返ること
//   - fetchTokenChain が空 Set で呼ばれること
//
// - 正常系（partTranslation: 追加）:
//   - 末尾に単語が追加されたとき、新しいトークンが末尾に挿入されること
//   - 追加されたトークンに DB の翻訳が反映されること
//   - 既存トークンの vocabId / translation / nowShow が変わらないこと
//
// - 正常系（partTranslation: 削除）:
//   - 末尾の単語が削除されたとき、該当トークンが取り除かれること
//   - affectedIndices が空のとき fetchTokenChain が空 Set で呼ばれること
//
// - 正常系（partTranslation: 変更）:
//   - 既存トークンの単語が別の単語に変わったとき、新しい翻訳が反映されること
//   - 変更されていないトークンの vocabId / translation / nowShow が変わらないこと
//
// - 正常系（partTranslation: ID 整合性）:
//   - 差分適用後の全トークンの id が 0 始まりの連番になること
//
// - 異常系:
//   - fetchTokenChain が Exception を throw したとき、そのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/data/repository_impl/local_text_processor.dart';
import 'package:edb/domain/entity/carry/token_entry.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/repository_abstract/translation_repository.dart';

// ---------------------------------------------------------------------------
// モック
// ---------------------------------------------------------------------------
class MockTokenChainRepository extends Mock implements TranslationRepository {}

// ---------------------------------------------------------------------------
// ヘルパー: fetchTranslationsBatch が返す TokenEntry を組み立てる
// ---------------------------------------------------------------------------
TokenEntry _makeEntry({
  int id = 1,
  required String word,
  bool isShow = true,
  String translation = '',
}) {
  return TokenEntry(
    vocabId: id,
    showWord: word,
    isShow: isShow,
    translation: translation,
  );
}

// ---------------------------------------------------------------------------
// ヘルパー: 翻訳済み TokenData を組み立てる（partTranslation の nowTokens 用）
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// テスト
// ---------------------------------------------------------------------------
void main() {
  late MockTokenChainRepository mockDb;
  late LocalTextProcessor repository;

  setUp(() {
    mockDb = MockTokenChainRepository();
    repository = LocalTextProcessor(mockDb);
  });

  // =========================================================================
  // fullTranslation
  // =========================================================================
  group('fullTranslation', () {
    group('正常系 - トークン化', () {
      test('通常の英単語がトークンに分割されること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'hello world');

        final words = result.map((t) => t.showWord).toList();
        expect(words, containsAll(['hello', 'world']));
        expect(result.any((t) => t.showWord.trim().isEmpty), isFalse);
      });

      test('ハイフン単語が 1 トークンになること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'well-known');

        expect(result.length, 1);
        expect(result.first.showWord, 'well-known');
      });

      test("アポストロフィ単語が 1 トークンになること", () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: "it's");

        expect(result.length, 1);
        expect(result.first.showWord, "it's");
      });

      test('句読点が独立したトークンになること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'Hello,world.');

        final words = result.map((t) => t.showWord).toList();
        expect(words, contains('Hello'));
        expect(words, contains(','));
        expect(words, contains('world'));
        expect(words, contains('.'));
      });

      test('空白のみのトークンが無視されること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'a   b');

        // 空白トークンが含まれないこと
        expect(result.every((t) => t.showWord.trim().isNotEmpty), isTrue);
        expect(result.map((t) => t.showWord).toList(), ['a', 'b']);
      });
    });

    group('正常系 - 翻訳マッピング', () {
      test('DB に登録済みの単語に vocabId / translation / nowShow が反映されること', () async {
        final entry = _makeEntry(
          id: 42,
          word: 'apple',
          isShow: true,
          translation: 'りんご',
        );
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => [entry]);

        final result = await repository.fullTranslation(text: 'apple');

        expect(result.length, 1);
        expect(result.first.vocabId, 42);
        expect(result.first.nowShow, isTrue);
        expect(result.first.translation, 'りんご');
      });

      test('DB に未登録の単語の vocabId / translation が初期値のままになること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'unknown');

        expect(result.length, 1);
        expect(result.first.vocabId, -1);
        expect(result.first.translation, '');
        expect(result.first.nowShow, isFalse);
      });

      test('句読点トークンの vocabId / translation が初期値のままになること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'Hello.');

        final period = result.firstWhere((t) => t.showWord == '.');
        expect(period.vocabId, -1);
        expect(period.translation, '');
      });

      test('各トークンの id が 0 始まりの連番になること', () async {
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.fullTranslation(text: 'one two three');

        for (int i = 0; i < result.length; i++) {
          expect(result[i].id, i);
        }
      });
    });
    group('境界値', () {
      test('大文字・小文字が混在するテキストでも DB のエントリが反映されること', () async {
        // DB は小文字キーで保持
        final entry = _makeEntry(
          id: 7,
          word: 'apple',
          isShow: true,
          translation: 'りんご',
        );
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => [entry]);

        // テキストは大文字
        final result = await repository.fullTranslation(text: 'Apple');

        expect(result.first.vocabId, 7);
        expect(result.first.translation, 'りんご');
      });

      test('重複する単語があっても fetchTokenChain に渡されるキーが重複しないこと', () async {
        Set<String>? capturedKeys;
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((invocation) async {
          capturedKeys = invocation.namedArguments[#keys] as Set<String>;
          return [];
        });

        // "apple" が 3 回登場
        await repository.fullTranslation(text: 'apple apple apple');

        expect(capturedKeys, isNotNull);
        // Set なので要素数は 1 のはず
        expect(capturedKeys!.length, 1);
        expect(capturedKeys, contains('apple'));
      });
    });
  });

  // =========================================================================
  // partTranslation
  // =========================================================================
  group('partTranslation', () {
    group('正常系 - 差分なし', () {
      test('newText が nowTokens と同じ内容のとき、既存トークンがそのまま返ること', () async {
        // 既存トークン: 翻訳済み状態を再現
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
          _makeToken(
            id: 1,
            vocabId: 2,
            showWord: 'world',
            nowShow: true,
            translation: '世界',
          ),
        ];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        // 既存トークンの翻訳情報がそのまま保持されていること
        expect(result.length, 2);
        expect(result[0].translation, 'こんにちは');
        expect(result[1].translation, '世界');
      });

      test('差分なしのとき fetchTokenChain が空 Set で呼ばれること', () async {
        final nowTokens = [_makeToken(id: 0, showWord: 'hello')];

        Set<String>? capturedKeys;
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((invocation) async {
          capturedKeys = invocation.namedArguments[#keys] as Set<String>;
          return [];
        });

        await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello',
        );

        expect(capturedKeys, isEmpty);
      });
    });

    group('正常系 - 追加', () {
      test('末尾に単語が追加されたとき、新しいトークンが末尾に挿入されること', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
        ];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        expect(result.length, 2);
        expect(result.last.showWord, 'world');
      });

      test('追加されたトークンに DB の翻訳が反映されること', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
        ];

        final entry = _makeEntry(
          id: 99,
          word: 'world',
          isShow: true,
          translation: '世界',
        );
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => [entry]);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        final worldToken = result.firstWhere((t) => t.showWord == 'world');
        expect(worldToken.vocabId, 99);
        expect(worldToken.nowShow, isTrue);
        expect(worldToken.translation, '世界');
      });

      test('追加時に既存トークンの vocabId / translation / nowShow が変わらないこと', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
        ];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello world',
        );

        final helloToken = result.firstWhere((t) => t.showWord == 'hello');
        expect(helloToken.vocabId, 1);
        expect(helloToken.translation, 'こんにちは');
        expect(helloToken.nowShow, isTrue);
      });
    });

    group('正常系 - 削除', () {
      test('末尾の単語が削除されたとき、該当トークンが取り除かれること', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
          _makeToken(
            id: 1,
            vocabId: 2,
            showWord: 'world',
            nowShow: true,
            translation: '世界',
          ),
        ];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello',
        );

        expect(result.length, 1);
        expect(result.first.showWord, 'hello');
      });

      test(
        '削除のみで affectedIndices が空のとき fetchTokenChain が空 Set で呼ばれること',
        () async {
          final nowTokens = [
            _makeToken(id: 0, showWord: 'hello'),
            _makeToken(id: 1, showWord: 'world'),
          ];

          Set<String>? capturedKeys;
          when(
            () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
          ).thenAnswer((invocation) async {
            capturedKeys = invocation.namedArguments[#keys] as Set<String>;
            return [];
          });

          await repository.partTranslation(
            nowTokens: nowTokens,
            newText: 'hello',
          );

          expect(capturedKeys, isEmpty);
        },
      );
    });

    group('正常系 - 変更', () {
      test('既存トークンの単語が別の単語に変わったとき、新しい翻訳が反映されること', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
        ];

        final entry = _makeEntry(
          id: 55,
          word: 'bye',
          isShow: true,
          translation: 'さようなら',
        );
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => [entry]);

        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'bye',
        );

        expect(result.length, 1);
        expect(result.first.showWord, 'bye');
        expect(result.first.vocabId, 55);
        expect(result.first.translation, 'さようなら');
      });

      test('変更されていないトークンの vocabId / translation / nowShow が変わらないこと', () async {
        final nowTokens = [
          _makeToken(
            id: 0,
            vocabId: 1,
            showWord: 'hello',
            nowShow: true,
            translation: 'こんにちは',
          ),
          _makeToken(
            id: 1,
            vocabId: 2,
            showWord: 'world',
            nowShow: true,
            translation: '世界',
          ),
        ];

        final entry = _makeEntry(
          id: 55,
          word: 'bye',
          isShow: true,
          translation: 'さようなら',
        );
        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => [entry]);

        // world → bye に変更（hello は変わらず）
        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'hello bye',
        );

        final helloToken = result.firstWhere((t) => t.showWord == 'hello');
        expect(helloToken.vocabId, 1);
        expect(helloToken.translation, 'こんにちは');
        expect(helloToken.nowShow, isTrue);
      });
    });

    group('正常系 - ID 整合性', () {
      test('差分適用後の全トークンの id が 0 始まりの連番になること', () async {
        final nowTokens = [
          _makeToken(id: 0, showWord: 'one'),
          _makeToken(id: 1, showWord: 'two'),
        ];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenAnswer((_) async => []);

        // 先頭に挿入して id がずれるケース
        final result = await repository.partTranslation(
          nowTokens: nowTokens,
          newText: 'zero one two',
        );

        for (int i = 0; i < result.length; i++) {
          expect(result[i].id, i);
        }
      });
    });

    group('異常系', () {
      test('fetchTokenChain が Exception を throw したとき、そのまま投げること', () async {
        final nowTokens = [_makeToken(id: 0, showWord: 'hello')];

        when(
          () => mockDb.fetchTranslationsBatch(keys: any(named: 'keys')),
        ).thenThrow(Exception('DB error'));

        // 追加が発生するテキストを渡して fetchTokenChain を実行させる
        expect(
          () => repository.partTranslation(
            nowTokens: nowTokens,
            newText: 'hello world',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
