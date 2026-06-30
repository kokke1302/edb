import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/domain/entity/model/tiles_data.dart';
import 'package:edb/domain/usecase/fetch_tiles_all_usecase.dart';
import 'package:edb/domain/usecase/save_tile_usecase.dart';
import 'package:edb/domain/usecase/delete_tile_usecase.dart';
import 'package:edb/domain/usecase/fetch_tile_detail_usecase.dart';
import 'package:edb/presentation/view_models/translation_notifier.dart';

final tilesProvider = AsyncNotifierProvider<TilesNotifier, TilesData>(
  () => TilesNotifier(),
);

// 訳語リストを管理
class TilesNotifier extends AsyncNotifier<TilesData> {
  @override
  Future<TilesData> build() async {
    final list = await ref.read(fetchAllTilesUseCaseProvider).execute();
    return TilesData(list: list);
  }

  // 英文を保存する
  Future<void> addTile() async {
    // バリデーション
    final translationAsync = ref.read(translationProvider);
    if (!translationAsync.hasValue ||
        translationAsync.isLoading ||
        state.isLoading) {
      return;
    }

    state = await AsyncValue.guard(() async {
      final nowTranslation = translationAsync.requireValue;

      final newTile = await ref
          .read(saveTileUseCaseProvider)
          .execute(
            originalText: nowTranslation.originalText,
            tokens: nowTranslation.tokens,
          );
      final previousState = state.value ?? TilesData(list: []);

      return previousState.copyWith(list: [...previousState.list, newTile]);
    });
  }

  // 保存した英文を消去する
  Future<void> deleteTile({required int id}) async {
    if (state.isLoading) return;

    state = await AsyncValue.guard(() async {
      // DBから削除
      await ref.read(deleteTileUseCaseProvider).execute(id: id);

      final previousState = state.value ?? TilesData(list: []);
      return previousState.copyWith(
        // 現在のリストから対象IDを除外
        list: previousState.list.where((t) => t.id != id).toList(),
      );
    });
  }

  Future<void> makeTokenChain({required int id}) async {
    try {
      // 対象タイルの取得
      final tileDtail = await ref
          .read(fetchTileDetailUseCaseProvider)
          .execute(id: id);

      // TokenCainに反映
      ref
          .read(translationProvider.notifier)
          .restore(text: tileDtail.title, chain: tileDtail.chain);
    } catch (e) {
      throw '復元中にエラーが発生しました: $e';
    }
  }
}
