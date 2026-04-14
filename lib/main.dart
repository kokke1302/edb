import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/db/database_initializer.dart';
import 'package:edb/presentation/root/rooting.dart';

// -----------------------------------------------------------------------------
// アプリケーションのエントリーポイント
// -----------------------------------------------------------------------------

void main() async {
  // ウィジェットバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();

  // 辞書DBコピー処理
  await DatabaseInitializer.ensureDictionaryCopied();
  // AppDatabaseのインスタンスを取得
  final appDb = AppDatabase();
  // 単語帳初期データ投入を実行
  await DatabaseInitializer(appDb).insertManualVocabularies();

  runApp(const ProviderScope(child: EnglishLearningApp()));
}
