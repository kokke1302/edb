import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/share/data/vocab_entry.dart';
import 'package:edb/share/data/card_data.dart';

// VocabularyRepositoryのインスタンスを提供する
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyRepository(db);
});

class VocabularyRepository {
  final AppDatabase db;
  VocabularyRepository(this.db);

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

  Future<bool> addVocabulary({required CardData card}) async {
    if (card.vocab.based == Based.vocabularies) updateVocabulary(card: card);

    // 排他制御
    if (card.vocab.isShow) _setAllOthersHidden(word: card.vocab.word);

    // VocabularyCompanion: 仮で行を作る
    final companion = VocabulariesCompanion.insert(
      englishWord: card.vocab.word,
      japaneseTranslation: card.vocab.translation,
      isHidden: !card.vocab.isShow,
      memo: card.vocab.memo,
    );

    // 仮の行を実際に挿入し、挿入された場所のIDを受け取る
    final id = await db.into(db.vocabularies).insert(companion);
    return !id.isNaN;
  }

  // ===============================================
  // U: Update (単語の更新)
  // ===============================================

  // 更新された行の数を返す
  Future<int> updateVocabulary({required CardData card}) {
    if (card.vocab.based != Based.vocabularies) addVocabulary(card: card);

    // 排他制御
    if (card.vocab.isShow) _setAllOthersHidden(word: card.vocab.word);

    // 更新したい行のidを探す
    final query = db.update(db.vocabularies)
      ..where((v) => v.id.equals(card.id));

    // どう変更するか
    final companion = VocabulariesCompanion(
      englishWord: Value(card.vocab.word),
      japaneseTranslation: Value(card.vocab.translation),
      isHidden: Value(!card.vocab.isShow),
      memo: Value(card.vocab.memo),
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
