import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'package:edb/db/app_database.dart';
import 'package:edb/drawer/data/sentence.dart';
import 'package:edb/translation/data/token.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final tileRepositoryProvider = Provider<TileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TileRepository(db);
});

class TileRepository {
  final AppDatabase db;
  TileRepository(this.db);

  // ===============================================
  // C: Create (書き込み)
  // ===============================================

  /// 新しい英文データ（Tile）をデータベースに追加します。
  Future<int> createTile({
    required String text,
    required List<Token> chain,
  }) async {
    // List<Token> から List<Map<String, dynamic>> へ
    final tokenListJson = chain.map((token) => token.toJson()).toList();
    // List<Map<String, dynamic>> を JSON文字列へ変換
    final jsonToString = json.encode(tokenListJson);

    final companion = EnglishTextsCompanion.insert(
      originalText: text,
      parsedWordsJson: jsonToString,
    );

    return db.into(db.englishTexts).insert(companion);
  }

  // ===============================================
  // R: Read (読み込み)
  // ===============================================
  Future<List<Tile>>? fetchAllTiles() async {
    final query = db.select(db.englishTexts);
    final tiles = await query.get();

    return tiles.map((t) {
      final parsedWords = json.decode(t.parsedWordsJson) as List<dynamic>;

      final List<Token> chain = parsedWords
          // List<dynamic> から Map<String, dynamic> へ
          .map((jsonMap) => Token.fromJson(jsonMap as Map<String, dynamic>))
          .toList();

      return Tile(id: t.id, text: t.originalText, chain: chain);
    }).toList();
  }

  // ===============================================
  // D: Delete
  // ===============================================

  /// 指定されたIDの英文データ（Tile）をデータベースから削除します。
  Future<int> deleteTile(int id) async {
    return (db.delete(db.englishTexts)..where((t) => t.id.equals(id))).go();
  }
}
