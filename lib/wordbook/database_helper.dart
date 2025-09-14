import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'word_list_notifier.dart';

class DatabaseHelper {
  // データベースのバージョン管理
  static const _databaseVersion = 1;
  static const _databaseName = 'word_entry_database.db';
  static const _tableName = 'word_entries_table';

  // シングルトンインスタンスの作成
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // 接続されているデータベースインスタンスを保持
  static Database? _database;

  // データベースを取得するgetter
  Future<Database> get database async {
    // 既にデータベースが開かれている場合はそれを返す
    if (_database != null) return _database!;

    // 初めてアクセスされた場合はデータベースを開く
    _database = await _initDatabase();
    return _database!;
  }

  // データベースの初期化（オープンとテーブル作成）
  Future<Database> _initDatabase() async {
    // データベースファイルのパスを取得
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

    // データベースを開く
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // テーブルを作成するメソッド（初回実行時のみ）
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        memo TEXT NOT NULL
      )
    ''');

    // 🔥 初期データ投入 🔥
    // 無限スクロールのテストのため、初期データを多めに投入しておきます
    await _insertInitialData(db);
  }

  // 初期データ投入ヘルパー（テスト用）
  Future<void> _insertInitialData(Database db) async {
    final batch = db.batch();
    for (int i = 1; i <= 60; i++) {
      // 合計60件のデータ
      batch.insert(_tableName, {
        'title': '初期データ単語 $i',
        'memo': 'これは初期データ単語 $i の詳細です。',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
    print('INFO: データベースに初期データ60件を投入しました。');
  }

  // 無限スクロールのコアとなるデータ取得メソッド
  // WordListNotifier の _fetchData から呼び出されることを想定
  Future<List<WordEntry>> fetchWordEntries({
    required int offset,
    required int limit,
  }) async {
    final db = await database; // データベース接続を取得

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['id', 'title', 'memo'],
      limit: limit, // 取得する件数
      offset: offset, // 開始位置
      orderBy: 'id ASC',
    );

    // Map のリストを WordEntry のリストに変換
    return List.generate(maps.length, (i) {
      return WordEntry(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        memo: maps[i]['memo'] as String,
      );
    });
  }
}
