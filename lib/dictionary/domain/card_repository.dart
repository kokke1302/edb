import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/dictionary/data/card_state.dart';
import 'package:edb/db/vocaburary_repository.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CardRepository(db);
});

class CardRepository extends VocabularyRepository {
  CardRepository(super.db);

  // ===============================================
  // R: Read (特定の単語に対する単語帳エントリ)
  // ===============================================

  // 単語帳（Vocabularies）から特定の英単語に対応する訳語を取得し、CardEntryのリストとして返す
  Future<List<CardEntry>>? fetchVocabularyEntries(String englishWord) async {
    final query = db.select(db.vocabularies)
      ..where((v) => v.englishWord.equals(englishWord.toLowerCase()));

    final vocabularies = await query.get();

    // 取得したDBデータをCardEntryに変換
    return vocabularies.map((v) {
      // isShowは、VocabulariesテーブルのisHidden（非表示ならtrue）の逆
      final isShow = !v.isHidden;

      // CardEntryに変換
      return CardEntry(
        id: v.id,
        translation: v.japaneseTranslation,
        isShow: isShow,
        nowShow: isShow,
        memo: v.memo ?? '',
        based: Based.vocabularies,
      );
    }).toList();
  }

  // ===============================================
  // R: Read (特定の単語に対する内部辞書エントリ)
  // ===============================================

  // 内部辞書（InternalDictionaries）から特定の単語に対応する訳語を取得し、CardEntryのリストとして返す
  Future<List<CardEntry>>? fetchDictionaryEntries(String wordKey) async {
    final query = db.select(db.internalDictionaries)
      ..where((d) => d.key.equals(wordKey.toLowerCase()));

    final dictionaries = await query.get();

    // 取得したDBデータをCardEntryに変換
    return dictionaries.map((d) {
      return CardEntry(
        id: d.id,
        translation: d.mean,
        isShow: false, // 内部辞書のエントリでは使わない
        nowShow: false, // 内部辞書のエントリでは使わない
        memo: d.memo ?? '',
        based: Based.dictionary,
      );
    }).toList();
  }
}
