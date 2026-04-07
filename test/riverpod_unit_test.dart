// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:edb/transelation/domain/text_processor.dart';
// import 'package:edb/register/domain/registration_notifier.dart';
// import 'package:edb/share/data/registration_state.dart';
// import 'package:edb/register/domain/vocaburary_repository.dart';
// import 'package:edb/wordbook/domain/sort_notifier.dart';
// import 'package:edb/transelation/domain/batch_repository.dart';
// import 'package:edb/db/app_database.dart';

// class MockVocabularyRepository extends Mock implements VocabularyRepository {}

// class MockBatchRepository extends Mock implements BatchRepository {}

// class RegistrationStateFake extends Fake implements RegistrationState {}

// void main() {
//   setUpAll(() {
//     // mocktail が RegistrationState 型を認識できるように登録
//     registerFallbackValue(RegistrationStateFake());
//   });
//   group('TextProcessor (解析ロジック) のテスト', () {
//     late ProviderContainer container;
//     late MockBatchRepository mockBatchRepository;

//     setUp(() {
//       mockBatchRepository = MockBatchRepository();
//       container = ProviderContainer(
//         overrides: [
//           batchRepositoryProvider.overrideWithValue(mockBatchRepository),
//         ],
//       );
//     });

//     tearDown(() => container.dispose());

//     test('tokenizeText: 英文が単語と記号に正しく分割されること', () {
//       final processor = container.read(textProcessorProvider);

//       // Mockの戻り値を設定（空リスト）
//       when(
//         () => mockBatchRepository.fetchTranslationsBatch(any()),
//       ).thenAnswer((_) async => []);

//       expect(() async {
//         final tokens = await processor.fullTranslation(text: "Apple, pen.");
//         // [Apple], [,], [ ], [pen], [.] のような分割を想定
//         // isWord が Apple と pen に対して true になっているか
//         final wordTokens = tokens.where((t) => t.isWord).toList();
//         return wordTokens.length;
//       }(), completion(equals(2)));
//     });

//     test('fullTranslation が呼ばれた際、BatchRepositoryからデータを取得すること', () async {
//       when(
//         () => mockBatchRepository.fetchTranslationsBatch(any()),
//       ).thenAnswer((_) async => <Vocabulary>[]);

//       final processor = container.read(textProcessorProvider);

//       await processor.fullTranslation(text: "Hello world");

//       verify(() => mockBatchRepository.fetchTranslationsBatch(any())).called(1);
//     });
//   });

//   group('RegistrationNotifier (排他制御と保存) のテスト', () {
//     late ProviderContainer container;
//     late MockVocabularyRepository mockVocabRepository;

//     setUp(() {
//       mockVocabRepository = MockVocabularyRepository();
//       container = ProviderContainer(
//         overrides: [
//           vocabularyRepositoryProvider.overrideWithValue(mockVocabRepository),
//         ],
//       );
//     });

//     tearDown(() => container.dispose());

//     test('save: 保存時に処理中フラグが isProcessing になり、完了後に解除されること', () async {
//       // Mockの挙動: 100ms待機してから成功を返す
//       when(
//         () => mockVocabRepository.addVocabulary(state: any(named: 'state')),
//       ).thenAnswer((_) async {
//         await Future.delayed(const Duration(milliseconds: 100));
//         return true;
//       });

//       final notifier = container.read(registrationProvider.notifier);

//       // 保存を有効にするためのデータ入力
//       notifier.updateEnglish('Apple');
//       notifier.updateTranslation('リンゴ');

//       // 初期状態は false
//       expect(container.read(registrationProvider).isProcessing, false);

//       // 非同期実行
//       final future = notifier.save();

//       await Future.microtask(() {});

//       // 実行直後は true
//       expect(container.read(registrationProvider).isProcessing, true);

//       await future;

//       // 完了後は false
//       expect(container.read(registrationProvider).isProcessing, false);
//     });

//     test('isHidden が false の時、Repositoryの保存処理が呼ばれること', () async {
//       when(
//         () => mockVocabRepository.addVocabulary(state: any(named: 'state')),
//       ).thenAnswer((_) async => true);

//       final notifier = container.read(registrationProvider.notifier);

//       // 文字列が入っていないと saveEnabled が false になるので更新
//       notifier.updateEnglish('test');
//       notifier.updateTranslation('テスト');
//       notifier.toggleIsShowing(false); // isHidden = false (表示)

//       await notifier.save();

//       // 引数の検証
//       verify(
//         () => mockVocabRepository.addVocabulary(
//           state: any(
//             named: 'state',
//             that: isA<RegistrationState>().having(
//               (s) => s.isHidden,
//               'isHidden',
//               false,
//             ),
//           ),
//         ),
//       ).called(1);
//     });
//   });

//   group('SortSettingNotifier のテスト', () {
//     test('初期値とリセットの動作', () {
//       final container = ProviderContainer();
//       final notifier = container.read(sortSettingProvider.notifier);

//       // 検索ワードを入力
//       notifier.setSearchWord('test');
//       expect(container.read(sortSettingProvider).searchWord, 'test');

//       // リセット
//       notifier.reset();
//       expect(container.read(sortSettingProvider).searchWord, '');
//     });
//   });
// }
