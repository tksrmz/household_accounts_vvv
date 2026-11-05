import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/ui/properties/property_editor_screen.dart';
import 'package:household_accounts/ui/properties/property_editor_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_property_repository.dart';
import '../../test-util/golden_helper.dart';

final _bank = Property(
  id: PropertyId('bank'),
  name: PropertyName('銀行'),
  balance: -5000,
);

final _nameField = find.widgetWithText(TextField, '資産名');
final _balanceField = find.widgetWithText(TextField, '資産額');
final _saveButton = find.widgetWithText(ElevatedButton, '保存');

// なぜスナックバーをgoldenで確認しないか:
// ScaffoldMessengerは入れ子のScaffoldのうち最も外側にだけスナックバーを出す。
// 3幅ヘルパーはPropertyEditorScreenのScaffoldを別のScaffoldで包むため、
// スナックバーは撮影範囲の外に出る。文言は下の通常のtestWidgetsで固定する。
void main() {
  group('golden', () {
    testGoldens(
      '追加で開いたとき、空欄の入力欄と押せない保存ボタンが表示されること',
      goldenFileName: 'property_editor_add',
      builder: () => _buildFixture().screen,
      // 資産名へのautofocusが効いた状態で撮る
      expectFn: (tester) => tester.pumpAndSettle(),
    );

    testGoldens(
      '編集で開いたとき、編集対象の名前と負の残高が入力済みで表示されること',
      goldenFileName: 'property_editor_edit',
      builder: () => _buildFixture(property: _bank).screen,
      expectFn: (tester) => tester.pumpAndSettle(),
    );

    testGoldens(
      '資産名を空にしたとき、資産名のエラーが表示され保存ボタンが押せないこと',
      goldenFileName: 'property_editor_name_error',
      builder: () => _buildFixture(property: _bank).screen,
      expectFn: (tester) async {
        await tester.enterText(_nameField, '');
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '資産額を整数でない値にしたとき、資産額のエラーが表示され保存ボタンが押せないこと',
      goldenFileName: 'property_editor_balance_error',
      builder: () => _buildFixture(property: _bank).screen,
      expectFn: (tester) async {
        await tester.enterText(_balanceField, '-');
        await tester.pumpAndSettle();
      },
    );
  });

  group('保存ボタン', () {
    testWidgets('追加で開いた直後のとき、押下できないこと', (tester) async {
      await _pumpScreen(tester, _buildFixture());

      expect(tester.widget<ElevatedButton>(_saveButton).onPressed, isNull);
    });

    testWidgets('資産名と資産額を入力したとき、押下できるようになること', (tester) async {
      await _pumpScreen(tester, _buildFixture());

      await tester.enterText(_nameField, '財布');
      await tester.enterText(_balanceField, '-300');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(_saveButton).onPressed, isNotNull);
    });
  });

  group('資産額の入力', () {
    testWidgets('マイナス記号と数字以外を入力したとき、入力欄に残らないこと', (tester) async {
      await _pumpScreen(tester, _buildFixture());

      await tester.enterText(_balanceField, '-12a3');
      await tester.pump();

      expect(find.text('-12'), findsOneWidget);
    });
  });

  group('保存', () {
    testWidgets('保存に成功したとき、エディタが閉じること', (tester) async {
      final fixture = _buildFixture(property: _bank);
      await _pumpScreen(tester, fixture);

      await tester.enterText(_balanceField, '8000');
      await tester.tap(_saveButton);
      await tester.pumpAndSettle();

      expect(find.byType(PropertyEditorScreen), findsNothing);
      expect(fixture.repository.updateCalls, hasLength(1));
    });

    testWidgets('保存に失敗したとき、スナックバーで失敗が伝えられ、エディタに留まること', (tester) async {
      final fixture = _buildFixture(property: _bank);
      fixture.repository.updateResult = Result.error(Exception('updateエラー'));
      await _pumpScreen(tester, fixture);

      await tester.enterText(_balanceField, '8000');
      await tester.tap(_saveButton);
      await tester.pumpAndSettle();

      expect(find.text('資産の保存に失敗しました'), findsOneWidget);
      expect(find.byType(PropertyEditorScreen), findsOneWidget);
      expect(find.text('8000'), findsOneWidget);
    });
  });
}

class _Fixture {
  _Fixture({required this.screen, required this.repository});

  final PropertyEditorScreen screen;
  final FakePropertyRepository repository;
}

_Fixture _buildFixture({Property? property}) {
  final repository = FakePropertyRepository();
  return _Fixture(
    screen: PropertyEditorScreen(
      viewModel: PropertyEditorViewModel(
        propertyRepository: repository,
        property: property,
      ),
    ),
    repository: repository,
  );
}

/// 一覧から開いたときと同じく、別の画面の上へエディタを積んで表示する
/// (保存の成功で画面が閉じることを確かめるため)。
Future<void> _pumpScreen(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => fixture.screen)),
            child: const Text('開く'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('開く'));
  await tester.pumpAndSettle();
}
