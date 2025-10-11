import 'package:drift/drift.dart';

import 'app_database.dart';

const String dbFileName = 'db.sqlite';

// データベースの初期化と初回データ投入を行うクラス
class DatabaseInitializer {
  final AppDatabase db;
  DatabaseInitializer(this.db);

  // 単語帳データ投入関数
  Future<void> insertManualVocabularies() async {
    print('INFO: 手動初期データ投入を開始...');

    final countStatement = countAll();
    final currentCount =
        await (db.selectOnly(db.vocabularies)..addColumns([countStatement]))
            .map((row) => row.read(countStatement))
            .getSingle();

    // 行数が0の場合のみ初期データを投入
    if (currentCount == 0) {
      // 投入したい具体的な単語リスト
      final List<VocabulariesCompanion> initialData = [
        VocabulariesCompanion.insert(
          englishWord: 'this',
          japaneseTranslation: 'これ',
          isHidden: const Value(false),
          memo: const Value('あああ'),
        ),
        VocabulariesCompanion.insert(
          englishWord: 'is',
          japaneseTranslation: 'です',
          isHidden: const Value(false),
          memo: const Value(''),
        ),
        VocabulariesCompanion.insert(
          englishWord: 'test',
          japaneseTranslation: 'テスト',
          isHidden: const Value(false),
          memo: const Value(''),
        ),
        VocabulariesCompanion.insert(
          englishWord: 'sentence',
          japaneseTranslation: '文章',
          isHidden: const Value(true),
          memo: const Value(''),
        ),
        VocabulariesCompanion.insert(
          englishWord: 'hello',
          japaneseTranslation: 'こんにちは',
          isHidden: const Value(false),
          memo: const Value('挨拶'),
        ),
      ];

      // バッチ処理
      await db.batch((batch) {
        batch.insertAll(
          db.vocabularies,
          initialData,
          mode: InsertMode.insertOrIgnore,
        );
      });

      print('INFO: 手動初期データ ${initialData.length} 件の投入が完了しました。');
    } else {
      print('INFO: 行数が0以上です。手動初期データ投入をスキップします。');
    }
  }
}
