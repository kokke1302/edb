import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:edb/data/db/database_initializer.dart'; // dbFileName を使用するため

/// Web環境用の QueryExecutor を返す関数
QueryExecutor constructDb() {
  // print('INFO: Web環境の接続ロジックを読み込みました。');
  return driftDatabase(
    // データベース名
    name: dbFileName,

    // Web環境の設定を渡す
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
