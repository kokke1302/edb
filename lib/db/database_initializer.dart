import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:edb/db/app_database.dart';

const String dbFileName = 'db.sqlite';

// データベースの初期化と初回データ投入を行うクラス
class DatabaseInitializer {
  final AppDatabase db;
  DatabaseInitializer(this.db);

  // 単語帳データ投入関数
  Future<void> insertManualVocabularies() async {
    // print('INFO: 単語帳初期データ投入を開始...');

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
          isHidden: true,
          memo: '',
        ),
        VocabulariesCompanion.insert(
          englishWord: 'sentence',
          japaneseTranslation: '文章',
          isHidden: false,
          memo: '',
        ),
        VocabulariesCompanion.insert(
          englishWord: 'hello',
          japaneseTranslation: 'こんにちは',
          isHidden: false,
          memo: '挨拶',
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

      // print('INFO: 単語帳初期データ ${initialData.length} 件の投入が完了しました。');
    } else {
      // print('INFO: 行数が0以上です。単語帳初期データ投入をスキップします。');
    }
  }

  // ネイティブ環境での初回起動時のみ、アセットの辞書ファイルをDBパスにコピー
  static Future<void> ensureDictionaryCopied() async {
    // Web環境ではこの処理は不要
    if (kIsWeb) {
      // print('INFO: Web環境です。ファイルコピー処理をスキップします。');
      return;
    }

    // 1. データベース格納ディレクトリとファイルパスを取得
    final dbFolder = await getApplicationSupportDirectory();
    final dbFilePath = p.join(dbFolder.path, dbFileName);
    final file = File(dbFilePath);

    // 2. データベースファイルが既に存在する場合、コピーはスキップ
    if (await file.exists()) {
      // print('INFO: データベースファイル（$dbFilePath）は既に存在します。コピーをスキップします。');
      return;
    }

    // 3. データベースファイルが存在しない場合のみ、アセットからコピーを開始
    // print('INFO: データベースファイルが存在しません。アセットからのコピーを開始します。');

    const String assetPath = 'assets/output.sqlite3';
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // ファイルを直接書き込み
      await file.writeAsBytes(bytes, flush: true);
      // print('INFO: 内部辞書ファイル（$assetPath）のコピーが完了しました。');
    } catch (e) {
      // print('ERROR: プリパッケージドデータベースのコピー中にエラーが発生しました: $e');
      rethrow;
    }
  }
}
