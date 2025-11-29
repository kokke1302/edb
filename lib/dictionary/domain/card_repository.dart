import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/db/app_database.dart';
import 'package:edb/dictionary/data/card_state.dart';

// すべてのビジネスロジック（CRUD, ページング）を担当する
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CardRepository(db);
});

class CardRepository {
  final AppDatabase db;
  CardRepository(this.db);

  // ===============================================
  // R: Read (特定の単語に対する単語帳エントリ)
  // ===============================================

  // 単語帳（Vocabularies）から特定の英単語に対応する訳語を取得し、CardEntryのリストとして返す
  Future<List<CardEntry>>? fetchVocabularyEntries(String englishWord) async {
    final query = db.select(db.vocabularies)
      ..where((v) => v.englishWord.lower().equals(englishWord.toLowerCase()));

    final vocabularies = await query.get();

    // 取得したDBデータをCardEntryに変換
    return vocabularies.map((v) {
      // CardEntryに変換
      return CardEntry(
        id: v.id,
        word: englishWord,
        translation: v.japaneseTranslation,
        isShow: !v.isHidden,
        nowShow: !v.isHidden,
        memo: v.memo,
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
      ..where((d) => d.key.lower().equals(wordKey.toLowerCase()));

    final dictionaries = await query.get();

    // 取得したDBデータをCardEntryに変換
    return dictionaries.map((d) {
      return CardEntry(
        id: d.id,
        word: wordKey,
        translation: d.mean,
        isShow: false,
        nowShow: false,
        memo: d.memo ?? '',
        based: Based.dictionary,
      );
    }).toList();
  }
}
