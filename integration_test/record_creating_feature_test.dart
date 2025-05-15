import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/sign_in.dart';
import 'util/sign_up.dart';

Future<void> recordCreatingFeature() async {
  testWidgets('ユーザーは自分の家計簿で収入レコードを作成できるので、収入を正確に記録できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // カテゴリ画面に移動してカテゴリを作成
    await tester.tap(find.text('カテゴリ'));
    await tester.pumpAndSettle();

    // 収入カテゴリ作成
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '給料');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 資産画面に移動して資産を作成
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '普通預金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '100000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 金額入力
    await tester.enterText(find.widgetWithText(TextField, '金額'), '250000');

    // カテゴリ選択
    await tester.tap(find.text('カテゴリを選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('給料'));
    await tester.pumpAndSettle();

    // 資産選択
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('普通預金'));
    await tester.pumpAndSettle();

    // メモ入力
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), '6月分給料');

    // 登録
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });

  testWidgets('ユーザーは自分の家計簿で支出レコードを作成できるので、支出を正確に記録できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // カテゴリ画面に移動してカテゴリを作成
    await tester.tap(find.text('カテゴリ'));
    await tester.pumpAndSettle();

    // 支出カテゴリ作成
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('支出'));
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '食費');
    await tester.enterText(find.widgetWithText(TextField, '予算'), '50000');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 資産画面に移動して資産を作成
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '現金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '50000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 支出タブを選択
    await tester.tap(find.text('支出'));
    await tester.pumpAndSettle();

    // 金額入力
    await tester.enterText(find.widgetWithText(TextField, '金額'), '1200');

    // カテゴリ選択
    await tester.tap(find.text('カテゴリを選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('食費'));
    await tester.pumpAndSettle();

    // 資産選択
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('現金'));
    await tester.pumpAndSettle();

    // メモ入力
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), 'コンビニ昼食');

    // 登録
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });

  testWidgets('ユーザーは自分の家計簿で振替レコードを作成できるので、資産間の移動を正確に記録できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // 資産画面に移動して振替元資産を作成
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '普通預金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '200000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 振替先資産を作成
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '現金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '30000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 振替タブを選択
    await tester.tap(find.text('振替'));
    await tester.pumpAndSettle();

    // 金額入力
    await tester.enterText(find.widgetWithText(TextField, '金額'), '50000');

    // 振替元資産選択
    // このタイミングでは「資産を選択」が2つ表示されるので、最初のものを選択する
    await tester.tap(find.text('資産を選択').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('普通預金'));
    await tester.pumpAndSettle();

    // 振替先資産選択
    // 振替元資産を選択したため、この「資産を選択」が1つしか表示されない。
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('現金'));
    await tester.pumpAndSettle();

    // メモ入力
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), '現金引き出し');

    // 登録
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で収入レコードを作成できるので、共有収入を正確に記録できる',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、`pair_user_a@example.com`を使用
    // await singUpApp(
    //   tester,
    //   "pair_user_can_create_income_record@example.com",
    // );
    await signInApp(tester, pairUser);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Open the navigation menu to switch to shared account
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Switch to shared household account
    await tester.tap(find.text('ふたりの家計簿を見る'));
    await tester.pumpAndSettle();

    // カテゴリ画面に移動してカテゴリを作成
    await tester.tap(find.text('カテゴリ'));
    await tester.pumpAndSettle();

    // 収入カテゴリ作成
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '共同収入');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 資産画面に移動して資産を作成
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '共同口座');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '300000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 収入レコード作成
    await tester.enterText(find.widgetWithText(TextField, '金額'), '100000');
    await tester.tap(find.text('カテゴリを選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共同収入'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共同口座'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), '家賃収入');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で支出レコードを作成できるので、共有支出を正確に記録できる',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、`pair_user_a@example.com`を使用
    // await singUpApp(
    //   tester,
    //   "pair_user_can_create_expense_record@example.com",
    // );
    await signInApp(tester, pairUser);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Open the navigation menu to switch to shared account
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Switch to shared household account
    await tester.tap(find.text('ふたりの家計簿を見る'));
    await tester.pumpAndSettle();

    // カテゴリ画面に移動してカテゴリを作成
    await tester.tap(find.text('カテゴリ'));
    await tester.pumpAndSettle();

    // 支出カテゴリ作成
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('支出'));
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '光熱費');
    await tester.enterText(find.widgetWithText(TextField, '予算'), '30000');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // FIXME: `pair_user_a@example.com`使用中は、以下の操作は不要
    // 資産画面に移動して資産を作成
    // await tester.tap(find.text('資産'));
    // await tester.pumpAndSettle();
    // await tester.tap(find.text('資産の追加'));
    // await tester.pumpAndSettle();
    // await tester.enterText(find.widgetWithText(TextField, '資産名'), '共同口座');
    // await tester.enterText(find.widgetWithText(TextField, '資産額'), '300000');
    // await tester.tap(find.text('保存'));
    // await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 支出タブを選択
    await tester.tap(find.text('支出'));
    await tester.pumpAndSettle();

    // 支出レコード作成
    await tester.enterText(find.widgetWithText(TextField, '金額'), '25000');
    await tester.tap(find.text('カテゴリを選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('光熱費'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共同口座'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), '5月分電気代');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で振替レコードを作成できるので、共有資産間の移動を正確に記録できる',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、`pair_user_a@example.com`を使用
    // await singUpApp(
    //   tester,
    //   "pair_user_can_create_transfer_record@example.com",
    // );
    await signInApp(tester, pairUser);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Open the navigation menu to switch to shared account
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Switch to shared household account
    await tester.tap(find.text('ふたりの家計簿を見る'));
    await tester.pumpAndSettle();

    // 資産画面に移動して資産を作成
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();

    // 振替元資産を作成
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '共同口座A');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '300000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 振替先資産を作成
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '共同口座B');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '200000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 入力画面に移動
    await tester.tap(find.text('入力'));
    await tester.pumpAndSettle();

    // 振替タブを選択
    await tester.tap(find.text('振替'));
    await tester.pumpAndSettle();

    // 振替レコード作成
    await tester.enterText(find.widgetWithText(TextField, '金額'), '150000');
    // このタイミングでは「資産を選択」が2つ表示されるので、最初のものを選択する
    await tester.tap(find.text('資産を選択').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共同口座A'));
    await tester.pumpAndSettle();
    // 振替元資産を選択したため、この「資産を選択」が1つしか表示されない。
    await tester.tap(find.text('資産を選択'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共同口座B'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'ノート'), '積立');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // 登録完了の確認
    expect(find.text('レコードを登録しました'), findsOneWidget);
  });
}
