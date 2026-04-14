import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/domain/entity/value/base_status.dart';
import 'package:edb/presentation/view_models/register_notifier.dart';
import 'package:edb/presentation/pages/register/regi_english_card.dart';
import 'package:edb/presentation/pages/register/regi_footer_bar.dart';
import 'package:edb/presentation/pages/register/regi_memo_card.dart';
import 'package:edb/presentation/pages/register/regi_translation_card.dart';
import 'package:edb/presentation/pages/register/regi_visual_card.dart';

// オリジナル訳語の登録・編集画面
class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRegiData = ref.watch(registerProvider);
    // 中身の CardData だけを取り出す（初期化が終わっていれば取得できる）
    final regiData = asyncRegiData.value;

    // 初期ロード中かつデータがまだない場合だけ全画面ローディング
    if (regiData == null && asyncRegiData.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // データが取れなかった場合のエラー表示
    if (regiData == null) {
      return const Scaffold(body: Center(child: Text('データの読み込みに失敗しました')));
    }

    final appBarTitle = regiData.vocab.based == Based.vocabularies
        ? const Text('カードを編集')
        : const Text('カードを作成');

    return Scaffold(
      appBar: AppBar(title: appBarTitle),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 英単語入力フィールド
                const EnglishCard(),
                const SizedBox(height: 16),

                // 2. 訳語入力フィールド
                const TranslationCard(),
                const SizedBox(height: 16),

                // 3. メモ入力フィールド
                const MemoCard(),
                const SizedBox(height: 16),

                // 4. 訳の表示可否スイッチ
                const VisibilitySwitchCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // 5. フッター（保存・キャンセル・削除ボタン）
          const FooterBar(),
        ],
      ),
    );
  }
}
