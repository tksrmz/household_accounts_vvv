import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/sign_in.dart';

Future<void> shellFeature() async {
  testWidgets('ユーザーはタブとドロワーで各画面を行き来できるので、家計簿のすべての機能へ素早くアクセスできる', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await signInApp(tester, singleUser);
    await tester.pumpAndSettle();

    // ダッシュボードタブが初期表示であること
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('ダッシュボード')),
      findsOneWidget,
    );

    // ボトムナビゲーションから各タブを巡回し、AppBarタイトルが追従することを確認する
    for (final label in ['入力', 'カレンダー', '資産', 'カテゴリ', '予算']) {
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
    }

    // ダッシュボードタブへ戻れること
    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('ダッシュボード'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('ダッシュボード')),
      findsOneWidget,
    );

    // ドロワーを開くと、自分の家計簿ヘッダーと設定への導線が表示されること
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('自分の家計簿'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);

    // 設定画面を開けること
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('設定')),
      findsOneWidget,
    );

    // 戻ると、開いたままだったドロワーとともにシェルへ戻ること
    // (設定はルートNavigatorへのpushで開くため、下に残るシェルのDrawer開閉状態は
    // pushでは破棄されない。押す前に開いていたドロワーがそのまま見える)
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('自分の家計簿'), findsOneWidget);
  });
}
