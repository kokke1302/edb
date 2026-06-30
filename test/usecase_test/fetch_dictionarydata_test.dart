// -----------------------------------------------------------------------------
// - 正常系（データ取得）:
//   - fetchVocabularies が token.word を引数に1回呼ばれること
//   - fetchDictionaries が token.word を引数に1回呼ばれること
//
// - 正常系（振り分けロジック: showCard が設定されるケース）:
//   - token.nowShow が true かつ vocabId と一致する VocabEntry が vocabularies に存在するとき、showCard にその CardData が設定されること
//   - そのとき showCard の nowShow が true になること
//   - そのとき該当カード以外の vocabularyCards の nowShow がすべて false になること
//
// - 正常系（振り分けロジック: showCard が設定されないケース）:
//   - token.nowShow が false のとき、showCard が null になること
//   - token.nowShow が true かつ vocabId と一致する VocabEntry が vocabularies に存在しないとき、showCard が null になること
//   - いずれのケースでも vocabularyCards の nowShow がすべて false になること
//
// - 正常系（dictionaryCards）:
//   - dictionaryCards が fetchDictionaries の返り値を CardData に変換したリストと一致すること
//
// - 正常系（空データ）:
//   - fetchVocabularies が空リストを返したとき、showCard が null で vocabularyCards が空リストになること
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
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';

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

    // テスト用の共通VocabEntryデータ
    final vocab1Show = VocabEntry(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'memo42',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab1Hidden = VocabEntry(
      id: 42,
      word: 'apple',
      translation: 'りんご',
      isShow: true,
      memo: 'memo42',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab2Show = VocabEntry(
      id: 99,
      word: 'apple',
      translation: '（別の意味の）りんご',
      isShow: false,
      memo: 'memo99',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final vocab2Hidden = VocabEntry(
      id: 99,
      word: 'apple',
      translation: '（別の意味の）りんご',
      isShow: false,
      memo: 'memo99',
      createdAt: now,
      updatedAt: now,
      based: Based.vocabularies,
    );

    final dictVocab = VocabEntry(
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
        'token.nowShow が true かつ vocabId と一致する VocabEntry が存在するとき、showCard が設定され nowShow が true、その他は false になること',
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
        'token.nowShow が true でも vocabId と一致する VocabEntry が存在しないとき、showCard が null になり、vocabularyCards の nowShow がすべて false になること',
        () async {
          // Arrange
          final token = TokenData(
            id: 1,
            vocabId: 10,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );
          // vocabId: 10 かつ nowShow: true は、英文保存時に単語帳登録済みで、現在は登録解除している場合に起こる。
          // そのとき内部辞書に showCard は存在しないから、全て false。
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
          expect(result.dictionaryCards[0].vocab, dictVocab);
          expect(
            result.dictionaryCards[0].nowShow,
            false,
          ); // fromVocabEntryのデフォルト挙動
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
            nowShow: true,
            translation: 'りんご',
          );
          when(
            () => mockRepository.fetchVocabularies(word: any(named: 'word')),
          ).thenAnswer((_) async => <VocabEntry>[]);
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
          ).thenAnswer((_) async => <VocabEntry>[]);

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
