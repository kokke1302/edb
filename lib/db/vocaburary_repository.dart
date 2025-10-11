import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';

// VocabularyRepositoryのインスタンスを提供する
// すべてのビジネスロジック（CRUD, ページング）を担当する
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyRepository(db);
});

class VocabularyRepository {
  // 💡 コンストラクタでAppDatabaseを受け取る
  final AppDatabase db;
  VocabularyRepository(this.db);

  // ===============================================
  // C: Create (単語の挿入)
  // ===============================================

  // 新しく挿入された単語データを返す
  Future<Vocabulary> addVocabulary({
    required String englishWord,
    required String japaneseTranslation,
    String? memo,
  }) async {
    // VocabularyCompanion: 仮で行を作る
    final companion = VocabulariesCompanion.insert(
      englishWord: englishWord,
      japaneseTranslation: japaneseTranslation,
      memo: Value(memo), // Value(): null対策
      // createdAt: デフォルト値 currentDayAndTime を使用するため、指定不要
    );

    // 仮の行を実際に挿入し、挿入された場所のIDを受け取る
    final id = await db.into(db.vocabularies).insert(companion);

    // そのIDを使って、挿入後の完全なデータを取得し返す
    final query = db.select(db.vocabularies)..where((v) => v.id.equals(id));
    return query.getSingle();
  }

  // ===============================================
  // U: Update (単語の更新)
  // ===============================================

  // 更新された行の数を返す
  Future<int> updateVocabulary({
    required int id,
    String? englishWord,
    String? japaneseTranslation,
    String? memo,
  }) {
    // 更新したい行のidを探す
    final query = db.update(db.vocabularies)..where((v) => v.id.equals(id));

    // どう変更するか
    final companion = VocabulariesCompanion(
      id: Value.absent(),
      englishWord: englishWord != null
          ? Value(englishWord) // Value(): 値をカッコ内の文字列に変更
          : const Value.absent(), // absent(): 値はそのまま
      japaneseTranslation: japaneseTranslation != null
          ? Value(japaneseTranslation)
          : const Value.absent(),
      memo: memo != null ? Value(memo) : const Value.absent(),
    );

    // 上書き
    return query.write(companion);
  }

  // ===============================================
  // D: Delete (単語の削除)
  // ===============================================

  // 消去された行の数を返す
  Future<int> deleteVocabulary(int id) {
    // 削除したい行のidを探す
    final query = db.delete(db.vocabularies)..where((v) => v.id.equals(id));
    // 実行
    return query.go();
  }
}
