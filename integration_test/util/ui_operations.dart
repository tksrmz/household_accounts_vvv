import 'dart:async';

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

/// [condition]が満たされるまで、フレームを進めながら待つ。
///
/// Firestoreの購読や書き込みの完了を待って画面が変わる操作(削除した行が
/// 消える、保存の完了を待ってエディタが閉じる等)は、操作直後の
/// [WidgetTester.pumpAndSettle]では反映前の状態を見てしまう(完了を待つ間は
/// アニメーションが無く、待つべきフレームも無いため即座に戻る)。
Future<void> waitUntil(
  WidgetTester tester,
  FutureOr<bool> Function() condition, {
  required String description,
}) async {
  const timeout = Duration(seconds: 30);
  const interval = Duration(milliseconds: 200);

  final deadline = DateTime.now().add(timeout);
  while (true) {
    if (await condition()) {
      return;
    }
    if (DateTime.now().isAfter(deadline)) {
      fail('$description が${timeout.inSeconds}秒以内に満たされませんでした');
    }
    await tester.pump(interval);
  }
}
