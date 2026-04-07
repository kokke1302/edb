import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/drawer/data/tile_data.dart';
import 'package:edb/drawer/data/tile_list.dart';
import 'package:edb/drawer/domain/tile_message_resiver.dart';
import 'package:edb/drawer/domain/tile_repository.dart';
import 'package:edb/translation/data/token_data.dart';
import 'package:edb/translation/domain/translation_notifier.dart';

// Riverpod Providerの定義
final tileListProvider = AsyncNotifierProvider<TileListNotifier, TileState>(
  () => TileListNotifier(),
);

// 訳語リストを管理するNotifier
class TileListNotifier extends AsyncNotifier<TileState> {
  @override
  Future<TileState> build() async {
    final repository = ref.read(tileRepositoryProvider);
    final rows = await repository.fetchAllTile();

    final list = rows.map((row) {
      return TileData(id: row['id'] as int, text: row['text'] as String);
    }).toList();

    return TileState(list: list);
  }

  // 英文を保存する
  Future<void> addTile() async {
    // ガード句
    final translationAsync = ref.read(translationProvider);
    final bool exist =
        (!translationAsync.hasValue ||
        translationAsync.isLoading ||
        state.isLoading);
    if (exist) return;

    // 安全
    final nowTranslation = translationAsync.value!;

    // 処理中フラグ
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final List<Map<String, dynamic>> tokenMaps = nowTranslation.tokens
          .map((t) => t.toJson())
          .toList();

      final jsonString = json.encode(tokenMaps);

      // DBへ保存
      final tileId = await ref
          .read(tileRepositoryProvider)
          .createTile(text: nowTranslation.originalText, chain: jsonString);

      // 以前のデータ（list）を取得して新しい要素を追加
      final previousState = state.value ?? TileState(list: []);
      final newTile = TileData(id: tileId, text: nowTranslation.originalText);

      return previousState.copyWith(list: [...previousState.list, newTile]);
    });
  }

  // 保存した英文を消去する
  Future<void> deleteTile({required int id}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // DBから削除
      await ref.read(tileRepositoryProvider).deleteTile(id);

      // 現在のリストから対象IDを除外
      final previousState = state.value ?? TileState(list: []);
      final updatedList = previousState.list.where((t) => t.id != id).toList();

      return previousState.copyWith(list: updatedList);
    });
  }

  Future<void> makeTokenChain({required int id}) async {
    try {
      final repository = ref.read(tileRepositoryProvider);
      final row = await repository.fetchTileDetail(id);

      // JSON文字列をパースして List<TokenData> に変換
      final List<dynamic> decodedList =
          json.decode(row.parsedWordsJson) as List<dynamic>;
      final List<TokenData> tokenChain = decodedList
          .map((item) => TokenData.fromJson(item as Map<String, dynamic>))
          .toList();

      ref
          .read(translationProvider.notifier)
          .restore(text: row.originalText, chain: tokenChain);
    } catch (e) {
      ref
          .read(tileMessageProvider.notifier)
          .setString(text: '復元中にエラーが発生しました: $e');
    }
  }
}
