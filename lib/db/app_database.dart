import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// 単語帳テーブルの定義
class Vocabularies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class EnglishSentence extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalText => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

QueryExecutor _openConnection() {
  return driftDatabase(
    // データベース名
    name: 'db.sqlite',

    // Web環境の設定を渡す
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),

    // ネイティブ環境の設定
    // デフォルトのパスを使用する場合はオプション全体を省略可
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}

// データベース本体
@DriftDatabase(tables: [Vocabularies, EnglishSentence])
class AppDatabase extends _$AppDatabase {
  // シングルトンインスタンス
  static final AppDatabase _instance = AppDatabase._internal();
  AppDatabase._internal() : super(_openConnection());
  factory AppDatabase() {
    return _instance;
  }

  // データベース構造のバージョン
  @override
  int get schemaVersion => 1;

  // バージョン管理
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // 全テーブルを作成
        await m.createAll();
        // 初期データ投入
        await _populateInitialData();
      },
      // onUpgrade: (Migrator m, int from, int to) async {
      //   // スキーマバージョンが将来上がった時の処理
      //   // 今回はバージョン1なので不要
      // },
    );
  }

  // 初期データ投入関数
  Future<void> _populateInitialData() async {
    print('データベースの初期データ投入を開始...');

    final countStatement = countAll();
    final currentCount =
        await (selectOnly(vocabularies)..addColumns([countStatement]))
            .map((row) => row.read(countStatement))
            .getSingle();

    // 行数が0の場合のみ初期データを投入
    if (currentCount == 0) {
      print('INFO: データベースに初期データ投入を開始します...');

      // バッチ処理で投入
      await batch((batch) {
        for (int i = 1; i <= 60; i++) {
          final companion = VocabulariesCompanion.insert(
            title: '初期単語 $i',
            memo: Value('これは無限スクロールテスト用の単語 $i の説明です。'),
          );
          batch.insert(vocabularies, companion);
        }
      });

      print('INFO: データベースに初期データ60件の投入が完了しました。');
    } else {
      print('INFO: 行数が0以上です。');
    }
  }
}
