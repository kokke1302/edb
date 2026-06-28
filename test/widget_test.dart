// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// あるべき表示を定義する（状態や処理も）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edb/presentation/root/rooting.dart';
import 'package:edb/presentation/pages/translation/text_field.dart';
import 'package:edb/presentation/pages/translation/translate_fab.dart';
import 'package:edb/presentation/pages/translation/bookmark_fab.dart';

void main() {
  testWidgets('翻訳画面の初期表示テスト', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(const ProviderScope(child: EnglishLearningApp()));
    // GoRouterの遷移が終わるまで待機
    await tester.pumpAndSettle();

    // 「あるべき表示」を検証

    // 入力フィールド(MyTextField)が存在するか？
    expect(find.byType(MyTextField), findsOneWidget);
    expect(find.byType(MyTranslateFab), findsOneWidget);
    expect(find.byType(MyBookmarkFab), findsOneWidget);
  });

  testWidgets('翻訳ボタンをタップすると入力が反映される', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishLearningApp()));
    await tester.pumpAndSettle();

    // 1. 文字を入力する
    final textField = find.byType(TextField); // MyTextFieldの中にあるTextFieldを探す
    await tester.enterText(textField, 'Hello world');

    // 2. 翻訳ボタンをタップする
    final fab = find.byType(MyTranslateFab);
    await tester.tap(fab);

    // 3. 画面の変化を待つ
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // 4. 読み込み中のインジケーターが出ているか確認
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
