import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Web環境用の QueryExecutor を返す関数
QueryExecutor constructDb() {
  return DatabaseConnection.delayed(
    Future(() async {
      // WasmDatabase の open を使用
      final db = await WasmDatabase.open(
        databaseName: 'local_dict', // IndexedDB上のデータベース名
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),

        initializeDatabase: () async {
          final data = await rootBundle.load('assets/local_dict.sqlite3');
          return data.buffer.asUint8List(); // ブラウザのメモリ/ストレージへ展開
        },
      );

      return db.resolvedExecutor;
    }),
  );
}
