// -----------------------------------------------------------------------------
// - 正常系（データ取得）:
//   - fetchVocabularies が token.word を引数に1回呼ばれること
//   - fetchDictionaries が token.word を引数に1回呼ばれること
//
// - 正常系（振り分けロジック: 単語帳の行から showCard が設定されるケース）:
//   - token.nowShow が true かつ vocabId と一致する VocabCore が vocabularies に存在するとき、showCard にその CardData が設定されること
//   - そのとき showCard の nowShow が true になること
//   - そのとき該当カード以外の vocabularyCards の nowShow がすべて false になること
//
// - 正常系（振り分けロジック: showCard が設定されないケース）:
//   - token.nowShow が false のとき、showCard が null になること
//   - そのとき vocabularyCards の nowShow がすべて false になり、件数が増えないこと
//
// - 正常系（振り分けロジック: トークン自身の値から showCard が作られるケース）:
//   - token.nowShow が true かつ vocabId と一致する VocabCore が vocabularies に存在しないとき、トークンの値（vocabId / word / translation）から showCard が作られること
//   - そのとき showCard の nowShow が true、based が Based.init になること
//   - そのとき vocabularyCards の nowShow がすべて false で、件数が増えないこと
//   - remote トークン（vocabId: -2）が nowShow: true のとき、based が Based.remote の showCard が作られること
//   - そのとき remote の訳が vocabularyCards に重複して追加されないこと
//
// - 正常系（外部APIの訳を非表示にしたケース）:
//   - remote トークンが nowShow: false のとき、showCard が null になること
//   - そのとき remote の訳が nowShow: false の CardData として vocabularyCards の末尾に追加されること
//
// - 正常系（dictionaryCards）:
//   - dictionaryCards が fetchDictionaries の返り値（VocabCore）と一致すること
//
// - 正常系（空データ）:
//   - fetchVocabularies が空リストを返したとき、showCard が null で vocabularyCards が空リストになること（token.nowShow が false の場合）
//   - fetchVocabularies が空リストでも token.nowShow が true のとき、トークンの値から showCard が作られ vocabularyCards は空になること
//   - fetchDictionaries が空リストを返したとき、dictionaryCards が空リストになること
//
// - 異常系:
//   - fetchVocabularies が Exception をthrowしたとき、usecase もそのまま投げること
//   - fetchDictionaries が Exception をthrowしたとき、usecase もそのまま投げること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:edb/domain/usecase/fetch_dictionarydata_usecase.dart';
import 'package:edb/domain/repository_abstract/dictionary_repository.dart';
import 'package:edb/domain/model/value_object/token_data.dart';
import 'package:edb/domain/model/value_object/vocab_core.dart';
import 'package:edb/domain/model/enum/base_status.dart';

// DictionaryRepositoryのモッククラスを作成
class MockDictionaryRepository extends Mock implements DictionaryRepository {}

void main() {
  late MockDictionaryRepository mockRepository;
  late FetchDictionaryDataUseCase useCase;

  setUp(() {
    mockRepository = MockDictionaryRepository();
    useCase = FetchDictionaryDataUseCase(mockRepository);
  });

  group('FetchDictionaryDataUseCase', () {
    // 共通で使用するベースのDateTime
    final now = DateTime.now();

    // テスト用の共通VocabCoreデータ
    final vocab1Show = VocabCore(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'memo42',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab1Hidden = VocabCore(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'memo42',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab2Show = VocabCore(
      id: 99,
      word: 'apple',
      translation: '（別の意味の）りんご',
      isShow: false,
      memo: 'memo99',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab2Hidden = VocabCore(
      id: 99,
      word: 'apple',
      translation: '（別の意味の）りんご',
      isShow: false,
      memo: 'memo99',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final dictVocab = VocabCore(
      id: 100,
      word: 'apple',
      translation: '辞書のデータ',
      isShow: false,
      memo: 'dict memo',
      createdAt: now,
      updatedAt: now,
      based: Based.dictionary,
    );

    group('正常系（データ取得・基本検証）', () {
      test(
        'fetchVocabularies と fetchDictionaries が token.word を引数に1回ずつ呼ばれること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Show, vocab2Hidden]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => [dictVocab]);

          // Act
          await useCase.execute(token);

          // Assert
          verify(
            () => mockRepository.fetchVocabularies(word: token.word),
          ).called(1);
          verify(
            () => mockRepository.fetchDictionaries(word: token.word),
          ).called(1);
        },
      );
    });

    group('正常系（振り分けロジック: showCard が設定されるケース）', () {
      test(
        'token.nowShow が true かつ vocabId と一致する VocabCore が存在するとき、showCard が設定され nowShow が true、その他は false になること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          // isShowの値は関係ない
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Hidden, vocab2Show]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => [dictVocab]);

          // Act
          final result = await useCase.execute(token);

          // Assert
          // 1. showCard が設定され、その id が token.vocabId と一致し、nowShow が true であること
          expect(result.showCard, isNotNull);
          expect(result.showCard!.vocab.id, token.vocabId);
          expect(result.showCard!.nowShow, isTrue);

          // 2. 該当以外のカード(otherVocab)が vocabularyCards に回り、nowShow が false になっていること
          expect(result.vocabularyCards.length, 1);
          expect(result.vocabularyCards[0].vocab.id, 99);
          expect(result.vocabularyCards[0].nowShow, isFalse);
        },
      );
    });

    group('正常系（振り分けロジック: showCard が設定されないケース）', () {
      test(
        'token.nowShow が false のとき、showCard が null になり、vocabularyCards の nowShow がすべて false になること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: false,
            translation: 'りんご',
          );
          // isShowの値は関係ない
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Show, vocab2Hidden]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => [dictVocab]);

          // Act
          final result = await useCase.execute(token);

          // Assert
          expect(result.showCard, isNull);
          expect(result.vocabularyCards.length, 2);
          expect(result.vocabularyCards[0].nowShow, isFalse);
          expect(result.vocabularyCards[1].nowShow, isFalse);
        },
      );

      test(
        'token.nowShow が true で vocabId と一致する VocabCore が存在しないとき、トークン自身の値から showCard が作られること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 10,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );

          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Show, vocab2Hidden]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => [dictVocab]);

          final result = await useCase.execute(token);

          expect(result.showCard, isNotNull);
          expect(result.showCard!.nowShow, isTrue);
          expect(result.showCard!.vocab.id, 10);
          expect(result.showCard!.vocab.word, 'apple');
          expect(result.showCard!.vocab.translation, 'りんご');
          expect(result.showCard!.vocab.based, Based.init);
          expect(result.vocabularyCards.length, 2);
          expect(result.vocabularyCards.every((c) => !c.nowShow), isTrue);
        },
      );
    });

    group('正常系（dictionaryCards）', () {
      test(
        'dictionaryCards が fetchDictionaries の返り値を CardData に変換したリストと一致すること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => []);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => [dictVocab]);

          // Act
          final result = await useCase.execute(token);

          // Assert
          expect(result.dictionaryCards.length, 1);
          expect(result.dictionaryCards[0], dictVocab);
        },
      );

      test(
        'remote トークンが nowShow: true のとき、Based.remote の showCard が作られること',
        () async {
          final token = TokenData(
            id: 1,
            vocabId: TokenData.remoteVocabId,
            showWord: 'Apple',
            nowShow: true,
            translation: 'API訳',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Show]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => []);

          final result = await useCase.execute(token);

          expect(result.showCard!.vocab.based, Based.remote);
          expect(result.showCard!.vocab.id, TokenData.remoteVocabId);
          expect(result.showCard!.vocab.translation, 'API訳');
          expect(result.vocabularyCards.length, 1); // remote カードは候補に重複しない
        },
      );

      test(
        'remote トークンが nowShow: false のとき、showCard は null で remote カードが候補の末尾に残ること',
        () async {
          final token = TokenData(
            id: 1,
            vocabId: TokenData.remoteVocabId,
            showWord: 'Apple',
            nowShow: false,
            translation: 'API訳',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => [vocab1Show]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => []);

          final result = await useCase.execute(token);

          expect(result.showCard, isNull);
          expect(result.vocabularyCards.length, 2);
          expect(result.vocabularyCards.last.vocab.based, Based.remote);
          expect(result.vocabularyCards.last.nowShow, isFalse);
        },
      );
    });

    group('正常系（空データ）', () {
      test(
        'fetchVocabularies が空リストを返したとき、showCard が null で vocabularyCards が空リストになること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: false,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => <VocabCore>[]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => []);

          // Act
          final result = await useCase.execute(token);

          // Assert
          expect(result.showCard, isNull);
          expect(result.vocabularyCards, isEmpty);
        },
      );

      test(
        'fetchVocabularies が空リストでも token.nowShow が true のとき、トークンの値から showCard が作られ vocabularyCards は空になること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => <VocabCore>[]);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => []);

          // Act
          final result = await useCase.execute(token);

          // Assert
          expect(result.showCard, isNotNull);
          expect(result.showCard!.nowShow, isTrue);
          expect(result.showCard!.vocab.id, 42);
          expect(result.showCard!.vocab.translation, 'りんご');
          expect(result.vocabularyCards, isEmpty);
        },
      );

      test(
        'fetchDictionaries が空リストを返したとき、dictionaryCards が空リストになること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => []);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => <VocabCore>[]);

          // Act
          final result = await useCase.execute(token);

          // Assert
          expect(result.dictionaryCards, isEmpty);
        },
      );
    });

    group('異常系', () {
      test(
        'fetchVocabularies が Exception を throw したとき、ユースケースもそのまま例外を投げること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          final exception = Exception('単語帳データの取得に失敗');
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenThrow(exception);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenAnswer((_) async => []);

          // Act & Assert
          expect(() => useCase.execute(token), throwsA(equals(exception)));
        },
      );

      test(
        'fetchDictionaries が Exception を throw したとき、ユースケースもそのまま例外を投げること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 42,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          final exception = Exception('辞書データの取得に失敗');
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => []);
          when(
            () => mockRepository.fetchDictionaries(word: any(named: 'word')),
          ).thenThrow(exception);

          // Act & Assert
          expect(() => useCase.execute(token), throwsA(equals(exception)));
        },
      );
    });
  });
}
