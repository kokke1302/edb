// -----------------------------------------------------------------------------
// - 正常系（showCard → vocabularyCards: 表示中カードを非表示にする）:
//   - targetCard が showCard と同じ id のとき、新しい showCard が null になること
//   - そのとき targetCard が nowShow: false で vocabularyCards に追加されること
//   - そのとき newToken の nowShow が false になること
//   - そのとき vocabularyCards の件数が元より1件増えること
//
// - 正常系（vocabularyCards → showCard: showCard なしの状態でリストから選択）:
//   - currentData.showCard が null のとき、targetCard が nowShow: true で新しい showCard に設定されること
//   - そのとき targetCard が vocabularyCards から取り除かれること
//   - そのとき newToken の nowShow が true になり、vocabId と translation が targetCard の内容に更新されること
//   - そのとき vocabularyCards の件数が元より1件減ること
//
// - 正常系（vocabularyCards → showCard: showCard ありの状態でリストから選択）:
//   - currentData.showCard が存在するとき、既存の showCard が nowShow: false で vocabularyCards に追加されること
//   - そのとき targetCard が nowShow: true で新しい showCard に設定されること
//   - そのとき targetCard が vocabularyCards から取り除かれること
//   - そのとき newToken の nowShow が true になり、vocabId と translation が targetCard の内容に更新されること
//   - そのとき vocabularyCards の件数が変わらないこと（1件削除・1件追加）
//
// - 異常系（対象カードが見つからない）:
//   - targetCard の id が vocabularyCards にも showCard にも存在しないとき、currentData と currentToken がそのまま返ること
// -----------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';

import 'package:edb/domain/usecase/toggle_card_visibility_usecase.dart';
import 'package:edb/domain/entity/model/card_data.dart';
import 'package:edb/domain/entity/model/token_data.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/model/dictionary_data.dart';
import 'package:edb/domain/entity/value/base_status.dart';

void main() {
  late ToggleCardVisibilityUseCase useCase;

  // テスト共通で使用するベースのDateTime
  final now = DateTime.now();

  // テスト用のダミーVocabEntryデータ
  final vocabApple = VocabEntry(
    id: 1,
    word: 'apple',
    translation: 'りんご',
    isShow: true,
    memo: '',
    createdAt: now,
    updatedAt: now,
    based: Based.vocabularies,
  );
  final vocabBanana = VocabEntry(
    id: 2,
    word: 'banana',
    translation: 'バナナ',
    isShow: true,
    memo: '',
    createdAt: now,
    updatedAt: now,
    based: Based.vocabularies,
  );

  setUp(() {
    useCase = ToggleCardVisibilityUseCase();
  });

  group('ToggleCardVisibilityUseCase', () {
    group('正常系（showCard → vocabularyCards: 表示中カードを非表示にする）', () {
      test(
        'targetCard が showCard と同じ id のとき、カードが非表示（null）になり、vocabularyCards と Token の状態が正しく更新されること',
        () {
          // Arrange (準備)
          final showCard = CardData(nowShow: true, vocab: vocabApple);
          final currentData = DictionaryData(
            showCard: showCard,
            vocabularyCards: [], // 元は空
          );
          final currentToken = TokenData(
            id: 10,
            vocabId: 1,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );

          // Act (実行): showCard（apple）自身をターゲットにして実行
          final (newData, newToken) = useCase.execute(
            currentData: currentData,
            targetCard: showCard,
            currentToken: currentToken,
          );

          // Assert (検証)
          // 1. 新しい showCard が null になること
          expect(newData.showCard, isNull);

          // 2. targetCard が nowShow: false で vocabularyCards に追加されること
          expect(newData.vocabularyCards.length, 1);
          expect(newData.vocabularyCards[0].vocab.id, vocabApple.id);
          expect(newData.vocabularyCards[0].nowShow, isFalse);

          // 3. newToken の nowShow が false になること
          expect(newToken.nowShow, isFalse);
        },
      );
    });

    group('正常系（vocabularyCards → showCard: showCard なしの状態でリストから選択）', () {
      test(
        'currentData.showCard が null のとき、targetCard が showCard に昇格し、vocabularyCards から削除されること',
        () {
          // Arrange (準備)
          final targetCard = CardData(nowShow: false, vocab: vocabApple);
          final currentData = DictionaryData(
            showCard: null,
            vocabularyCards: [targetCard], // リストに入っている
          );
          final currentToken = TokenData(
            id: 10,
            vocabId: 1,
            showWord: 'Apple',
            nowShow: false,
            translation: 'りんご',
          );

          // Act (実行)
          final (newData, newToken) = useCase.execute(
            currentData: currentData,
            targetCard: targetCard,
            currentToken: currentToken,
          );

          // Assert (検証)
          // 1. targetCard が nowShow: true で新しい showCard に設定されること
          expect(newData.showCard, isNotNull);
          expect(newData.showCard!.vocab.id, vocabApple.id);
          expect(newData.showCard!.nowShow, isTrue);

          // 2. targetCard が vocabularyCards から取り除かれる（件数が1→0になる）こと
          expect(newData.vocabularyCards, isEmpty);

          // 3. newToken の nowShow が true になること
          expect(newToken.nowShow, isTrue);
          expect(newToken.vocabId, vocabApple.id);
          expect(newToken.translation, vocabApple.translation);
        },
      );
    });

    group('正常系（vocabularyCards → showCard: showCard ありの状態でリストから選択）', () {
      test(
        'currentData.showCard が存在するとき、既存のカードがリストに降格し、選択されたカードが新しく showCard になること',
        () {
          // Arrange (準備)
          final oldShowCard = CardData(nowShow: true, vocab: vocabApple);
          final targetCard = CardData(nowShow: false, vocab: vocabBanana);

          final currentData = DictionaryData(
            showCard: oldShowCard,
            vocabularyCards: [targetCard],
          );

          final currentToken = TokenData(
            id: 10,
            vocabId: 1,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );

          // Act (実行): 表示中の apple がある状態で、リストの banana を選択
          final (newData, newToken) = useCase.execute(
            currentData: currentData,
            targetCard: targetCard,
            currentToken: currentToken,
          );

          // Assert (検証)
          // 1. targetCard(banana) が nowShow: true で新しい showCard に設定されること
          expect(newData.showCard, isNotNull);
          expect(newData.showCard!.vocab.id, vocabBanana.id);
          expect(newData.showCard!.nowShow, isTrue);

          // 2. 既存の showCard(apple) が nowShow: false で vocabularyCards に追加されていること
          final containsOldCard = newData.vocabularyCards.any(
            (c) => c.vocab.id == vocabApple.id && c.nowShow == false,
          );
          expect(containsOldCard, isTrue);

          // 3. targetCard(banana) が vocabularyCards から取り除かれていること
          final containsTargetCard = newData.vocabularyCards.any(
            (c) => c.vocab.id == vocabBanana.id,
          );
          expect(containsTargetCard, isFalse);

          // 4. vocabularyCards の総件数が変わらないこと（1件削除、1件追加のため元と同じ1件）
          expect(newData.vocabularyCards.length, 1);

          // 5. newToken の nowShow が true になること
          expect(newToken.nowShow, isTrue);
          expect(newToken.vocabId, vocabBanana.id);
          expect(newToken.translation, vocabBanana.translation);
        },
      );
    });

    group('正常系（TokenData の vocabId と translation が正しく同期することの検証）', () {
      test(
        'リストからカードを選択した際、currentToken の vocabId と translation が、選択された targetCard の内容で上書きされること',
        () {
          // Arrange
          final targetCard = CardData(nowShow: false, vocab: vocabBanana);
          final currentData = DictionaryData(
            showCard: null,
            vocabularyCards: [targetCard],
          );
          // トークンは初期状態、あるいは別の古い情報を持っていると仮定
          final currentToken = TokenData(
            id: 99,
            vocabId: -1, // 未紐付け状態を模倣
            showWord: 'Banana',
            nowShow: false,
            translation: '未設定の翻訳',
          );

          // Act
          final (_, newToken) = useCase.execute(
            currentData: currentData,
            targetCard: targetCard,
            currentToken: currentToken,
          );

          // Assert
          expect(newToken.vocabId, equals(vocabBanana.id));
          expect(newToken.translation, equals(vocabBanana.translation));
        },
      );
    });

    group('異常系（対象カードが見つからない）', () {
      test(
        'targetCard の id が vocabularyCards にも showCard にも存在しないとき、データが変更されずそのまま返ること',
        () {
          // Arrange (準備)
          final showCard = CardData(nowShow: true, vocab: vocabApple);
          final currentData = DictionaryData(
            showCard: showCard,
            vocabularyCards: [],
          );
          final currentToken = TokenData(
            id: 10,
            vocabId: 1,
            showWord: 'Apple',
            nowShow: true,
            translation: 'りんご',
          );

          // リストにもshowCardにもいない、存在しない banana カードをターゲットにする
          final nonExistentCard = CardData(nowShow: false, vocab: vocabBanana);

          // Act (実行)
          final (newData, newToken) = useCase.execute(
            currentData: currentData,
            targetCard: nonExistentCard,
            currentToken: currentToken,
          );

          // Assert (検証): 変更が加わらず、元のデータ構造と同一であること
          expect(newData.showCard, equals(currentData.showCard));
          expect(newData.vocabularyCards, equals(currentData.vocabularyCards));
          expect(newToken, equals(currentToken));
        },
      );
    });
  });
}
