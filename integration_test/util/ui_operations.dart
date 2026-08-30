import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// integrationテスト共通のUI操作ヘルパー。
///
/// シェル(タブ・ドロワー)への操作は画面をまたいで同じ手順になるため、
/// 各featureテストに同じ実装が増殖しないようここへ集約する。

/// ボトムナビゲーションで[label]のタブへ移動する。
///
/// AppBarのタイトルとタブのラベルは同じ文字列なので(例: 入力タブでは
/// どちらも'入力')、ボトムナビゲーション配下に絞って一意に特定する。
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

/// ドロワーを開き、ふたりの家計簿へ切り替える。
Future<void> switchToSharedNote(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ふたりの家計簿を見る'));
  await tester.pumpAndSettle();
}
