import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/register/data/registration_state.dart';

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

  Future<bool> addVocabulary({required RegistrationState state}) async {
    if (state.existingVocId == -1) return false;

    // VocabularyCompanion: 仮で行を作る
    final companion = VocabulariesCompanion.insert(
      englishWord: state.englishWord,
      japaneseTranslation: state.japaneseTranslation,
      isHidden: state.isHidden,
      memo: state.memo,
    );

    // 仮の行を実際に挿入し、挿入された場所のIDを受け取る
    final id = await db.into(db.vocabularies).insert(companion);
    return !id.isNaN;
  }

  // ===============================================
  // U: Update (単語の更新)
  // ===============================================

  // 更新された行の数を返す
  Future<int> updateVocabulary({required RegistrationState state}) {
    if (state.existingVocId == -1) return Future.value(0);

    // 更新したい行のidを探す
    final query = db.update(db.vocabularies)
      ..where((v) => v.id.equals(state.existingVocId));

    // 排他制御
    if (!state.isHidden) _setAllOthersHidden(word: state.englishWord);

    // どう変更するか
    final companion = VocabulariesCompanion(
      englishWord: Value(state.englishWord),
      japaneseTranslation: Value(state.japaneseTranslation),
      isHidden: Value(state.isHidden),
      memo: Value(state.memo),
    );

    // 上書き
    return query.write(companion);
  }

  // 同じ英単語に紐づく全てのエントリのisHiddenをtrueに更新
  Future<int> _setAllOthersHidden({required String word}) {
    final query = db.update(db.vocabularies)
      ..where((v) => v.englishWord.equals(word));

    final companion = const VocabulariesCompanion(
      isHidden: Value(true), // isHiddenを強制的に true にする
      id: Value.absent(),
    );

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
