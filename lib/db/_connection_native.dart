import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:edb/db/database_initializer.dart';

/// ネイティブ環境用の QueryExecutor を返す関数
QueryExecutor constructDb() {
  print('INFO: ネイティブ環境の接続ロジックを読み込みました。');
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final dbFilePath = p.join(dbFolder.path, dbFileName);
    final file = File(dbFilePath);

    return NativeDatabase(file);
  });
}
