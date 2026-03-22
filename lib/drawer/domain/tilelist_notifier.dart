import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edb/drawer/data/sentence.dart';
import 'package:edb/drawer/data/sentence_list.dart';
import 'package:edb/drawer/domain/tile_repository.dart';
import 'package:edb/translation/domain/translation_notifier.dart';

// Riverpod Providerの定義
final tileListProvider = AsyncNotifierProvider<TileListNotifier, TileState>(
  () => TileListNotifier(),
);

// 訳語リストを管理するNotifier
class TileListNotifier extends AsyncNotifier<TileState> {
  @override
  Future<TileState> build() async {
    final allTiles =
        await ref.read(tileRepositoryProvider).fetchAllTiles() ?? const [];

    return TileState(list: allTiles, isProcessing: false);
  }

  // 英文を保存する
  Future<void> addTile() async {
    // 現在の翻訳状態を確認
    final nowTranslation = ref.read(translationProvider);
    if (nowTranslation.isProcessing == true) return;

    // AsyncDataであることを確認
    state.whenData((currentState) async {
      try {
        // 処理中フラグを立てる (UIを更新)
        state = AsyncValue.data(currentState.copyWith(isProcessing: true));

        // 新しいTileを保存、IDを取得
        final tileId = await ref
            .read(tileRepositoryProvider)
            .createTile(
              text: nowTranslation.originalText,
              chain: nowTranslation.tokens,
            );

        // 新しいTileオブジェクト
        final newTile = Tile(
          id: tileId,
          text: nowTranslation.originalText,
          chain: nowTranslation.tokens,
        );

        // Stateを更新
        final updatedList = [...currentState.list, newTile];
        state = AsyncValue.data(
          currentState.copyWith(list: updatedList, isProcessing: false),
        );
      } catch (e, stack) {
        // エラー処理: エラーをログに出力し、ステートをAsyncErrorにする
        // print('Error adding tile: $e\n$stack');
        // AsyncValue.dataから AsyncError にステートを変更
        state = AsyncValue.error('英文履歴の追加に失敗しました: $e', stack);
      }
    });
  }

  // 保存した英文を消去する
  Future<void> deleteTile(int id) async {
    state.whenData((currentState) async {
      try {
        // 処理中フラグを立てる (UIを更新)
        state = AsyncValue.data(currentState.copyWith(isProcessing: true));

        // DBから削除
        await ref.read(tileRepositoryProvider).deleteTile(id);

        // メモリ上のリストから削除し、Stateを更新
        final updatedList = currentState.list
            .where((tile) => tile.id != id) // 削除対象ID以外のTileのみを残す
            .toList();

        state = AsyncValue.data(
          currentState.copyWith(list: updatedList, isProcessing: false),
        );
      } catch (e, stack) {
        // print('Error deleting tile with ID $id: $e\n$stack');
        // エラーが発生した場合、処理中フラグをfalseに戻すか、エラー状態として保持する
        state = AsyncValue.error('英文履歴の削除に失敗しました: $e', stack);
      }
    });
  }
}
