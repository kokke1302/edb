import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '_connection_web.dart' if (dart.library.io) '_connection_native.dart';

part 'app_database.g.dart';

// 単語帳テーブル（Vocabulary）
class Vocabularies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get englishWord => text()();
  TextColumn get japaneseTranslation => text()();
  BoolColumn get isHidden => boolean()();
  TextColumn get memo => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 内部辞書テーブル（InternalDictionary）
class InternalDictionaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text()();
  TextColumn get word => text()();
  TextColumn get mean => text()();
  TextColumn get memo => text().nullable()();
}

// 英文データテーブル（EnglishTextData）
class EnglishTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalText => text()();
  TextColumn get parsedWordsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// AppDatabaseのインスタンスを提供する
// シングルトンのような振る舞いをする
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// データベース本体
@DriftDatabase(tables: [Vocabularies, EnglishTexts, InternalDictionaries])
class AppDatabase extends _$AppDatabase {
  // シングルトンインスタンス
  static final AppDatabase _instance = AppDatabase._internal();
  AppDatabase._internal() : super(constructDb());
  factory AppDatabase() {
    return _instance;
  }

  AppDatabase.forTesting(super.e);

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
      },
      // onUpgrade: (Migrator m, int from, int to) async {
      //   // スキーマバージョンが将来上がった時の処理
      // },
    );
  }
}
