import 'package:drift/drift.dart';

import 'package:edb/data/db/app_database.dart';
import 'package:edb/data/mapper/vocab_mapper.dart';
import 'package:edb/domain/entity/carry/vocab_entry.dart';
import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/domain/repository_abstract/register_repository.dart';

class LocalRegisterRepository implements RegisterRepository {
  final AppDatabase db;
  LocalRegisterRepository(this.db);

  // 同じ英単語に紐づく全てのエントリのisHiddenをtrueに更新
  Future<int> _setAllOthersHidden({required String word}) {
    final query = db.update(db.vocabularies)
      ..where((v) => v.englishWord.lower().equals(word.toLowerCase()));

    final companion = const VocabulariesCompanion(
      isHidden: Value(true), // isHiddenを強制的に true にする
      id: Value.absent(),
    );

    return query.write(companion);
  }

  // ===============================================
  // C: Create (単語の挿入)
  // ===============================================
  @override
  Future<VocabEntry> addVocabulary({required VocabEntry vocab}) async {
    if (vocab.based == Based.vocabularies) updateVocabulary(vocab: vocab);

    // 排他制御
    if (vocab.isShow) _setAllOthersHidden(word: vocab.word);

    // VocabularyCompanion: 仮で行を作る
    final companion = VocabulariesCompanion.insert(
      englishWord: vocab.word,
      japaneseTranslation: vocab.translation,
      isHidden: !vocab.isShow,
      memo: vocab.memo,
    );

    final vocabulary = await db
        .into(db.vocabularies)
        .insertReturning(companion);

    return VocabMapper.fromVocabularies(vocabulary: vocabulary);
  }

  // ===============================================
  // U: Update (単語の更新)
  // ===============================================

  // 更新された行のidを返す
  @override
  Future<VocabEntry> updateVocabulary({required VocabEntry vocab}) async {
    if (vocab.based != Based.vocabularies) addVocabulary(vocab: vocab);

    // 排他制御
    if (vocab.isShow) await _setAllOthersHidden(word: vocab.word);

    // 更新内容を定義
    final companion = VocabulariesCompanion(
      englishWord: Value(vocab.word),
      japaneseTranslation: Value(vocab.translation),
      isHidden: Value(!vocab.isShow),
      memo: Value(vocab.memo),
    );

    // companion を getReturning に渡して更新を実行
    final results =
        await (db.update(db.vocabularies)..where((v) => v.id.equals(vocab.id)))
            .writeReturning(companion); // ここで companion を適用

    return VocabMapper.fromVocabularies(vocabulary: results.first);
  }

  // ===============================================
  // D: Delete (単語の削除)
  // ===============================================

  @override
  Future<void> deleteVocabulary({required int id}) async {
    // 削除したい行のidを探す
    final query = db.delete(db.vocabularies)..where((v) => v.id.equals(id));
    // 実行
    await query.go();
  }
}
