import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/ui/properties/properties_screen.dart';
import 'package:household_accounts/ui/properties/properties_view_model.dart';
import 'package:household_accounts/ui/properties/widgets/delete_property_dialog.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_property_repository.dart';
import '../../test-util/golden_helper.dart';

final _wallet = Property(
  id: PropertyId('wallet'),
  name: PropertyName('財布'),
  balance: 12000,
);
final _bank = Property(
  id: PropertyId('bank'),
  name: PropertyName('銀行'),
  balance: -5000,
);
// 名前の上限ちょうどの資産。長い名前でも編集・削除アイコンが押し出されないことを見る
final _longName = Property(
  id: PropertyId('long'),
  name: PropertyName('あ' * PropertyName.maxLength),
  balance: 1234567,
);

const _dialogMessage = '本当に『財布』を削除しますか？';

// なぜ確認ダイアログを一覧のgoldenに含めないか:
// ダイアログはルートのNavigatorのオーバーレイに開くため、3幅ヘルパーが撮影する
// 画面の範囲(幅を絞ったSizedBox)の外に描かれる。ダイアログの中身は
// [DeletePropertyDialog]単体のgoldenで幅ごとに固定する。
//
// なぜスナックバーをgoldenで確認しないか:
// 3幅ヘルパーの外側のScaffoldに出るため撮影範囲の外になる。文言は下の
// 通常のtestWidgetsで固定する。
void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      '資産の一覧が未着のとき、ローディングが表示されること',
      goldenFileName: 'properties_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      '資産の購読が失敗したとき、エラーメッセージが表示されること',
      goldenFileName: 'properties_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.propertiesController.addError(
          Exception('watchAllエラー'),
        );
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '資産が1件も無いとき、追加ボタンだけが表示されること',
      goldenFileName: 'properties_empty',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.propertiesController.add([]);
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '負の残高や上限文字数の名前を含む資産が届いたとき、各行に名前と残高が表示されること',
      goldenFileName: 'properties_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.propertiesController.add([
          _longName,
          _wallet,
          _bank,
        ]);
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '削除の確認ダイアログを開いたとき、資産名を含む確認文と2つのボタンが表示されること',
      goldenFileName: 'properties_delete_dialog',
      builder: () => DeletePropertyDialog(propertyName: _longName.name.value),
    );
  });

  group('削除', () {
    testWidgets('削除アイコンを押したとき、資産名を含む確認ダイアログが開き、まだ削除されないこと', (tester) async {
      final fixture = await _pumpLoaded(tester);

      await _tapDeleteOf(tester, _wallet);

      expect(find.text(_dialogMessage), findsOneWidget);
      expect(fixture.repository.deleteCalls, isEmpty);
    });

    testWidgets('確認ダイアログで削除しないを選んだとき、ダイアログが閉じ削除されないこと', (tester) async {
      final fixture = await _pumpLoaded(tester);
      await _tapDeleteOf(tester, _wallet);

      await tester.tap(find.text('削除しない'));
      await tester.pumpAndSettle();

      expect(find.text(_dialogMessage), findsNothing);
      expect(fixture.repository.deleteCalls, isEmpty);
    });

    testWidgets('確認ダイアログで削除するを選んだとき、ダイアログが閉じその資産が削除されること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      await _tapDeleteOf(tester, _wallet);

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(find.text(_dialogMessage), findsNothing);
      expect(fixture.repository.deleteCalls, [_wallet.id]);
    });

    testWidgets('削除に失敗したとき、スナックバーで失敗が伝えられること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      fixture.repository.deleteResult = Result.error(Exception('deleteエラー'));
      await _tapDeleteOf(tester, _wallet);

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(find.text('資産の削除に失敗しました'), findsOneWidget);
    });
  });
}

class _Fixture {
  _Fixture({required this.screen, required this.repository});

  final PropertiesScreen screen;
  final FakePropertyRepository repository;
}

_Fixture _buildFixture() {
  final repository = FakePropertyRepository();
  return _Fixture(
    screen: PropertiesScreen(
      viewModel: PropertiesViewModel(propertyRepository: repository),
    ),
    repository: repository,
  );
}

/// 資産2件が届いた一覧を表示する。
///
/// 一覧はシェルの本体として表示されScaffoldを持たないため、スナックバーの
/// 表示先となるScaffoldで包む(シェルのScaffoldの代わり)。
Future<_Fixture> _pumpLoaded(WidgetTester tester) async {
  final fixture = _buildFixture();
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: fixture.screen)));
  fixture.repository.propertiesController.add([_wallet, _bank]);
  await tester.pumpAndSettle();
  return fixture;
}

/// [property]の行の削除アイコンを押し、確認ダイアログが開くまで待つ。
Future<void> _tapDeleteOf(WidgetTester tester, Property property) async {
  final row = find.ancestor(
    of: find.text(property.name.value),
    matching: find.byType(Row),
  );
  await tester.tap(
    find.descendant(of: row.first, matching: find.byIcon(Icons.delete)),
  );
  await tester.pumpAndSettle();
}
