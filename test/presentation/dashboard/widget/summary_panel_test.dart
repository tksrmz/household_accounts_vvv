import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';

void main() {
  testWidgets(
    'SummaryPanel displays income, expense and balance',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryPanel(
              Income(100),
              Expense(70),
            ),
          ),
        ),
      );

      final incomeLabelFinder = find.text('収入');
      final expenseLabelFinder = find.text('支出');
      final balanceLabelFinder = find.text('残高');
      final incomeValueFinder = find.text('¥100');
      final expenseValueFinder = find.text('¥70');
      final balanceValueFinder = find.text('¥30');

      expect(incomeLabelFinder, findsOneWidget);
      expect(expenseLabelFinder, findsOneWidget);
      expect(balanceLabelFinder, findsOneWidget);
      expect(incomeValueFinder, findsOneWidget);
      expect(expenseValueFinder, findsOneWidget);
      expect(balanceValueFinder, findsOneWidget);
    },
  );

  testWidgets(
    'SummaryPanel displays income, expense and balance (golden file)',
    (tester) async {
      final Future<ByteData> font = rootBundle.load('fonts/NotoSansJP.ttf');

      final FontLoader fontLoader = FontLoader('NotoSansJP')..addFont(font);
      await fontLoader.load();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansJP',
          ),
          home: Scaffold(
            body: RepaintBoundary(
              child: SummaryPanel(
                Income(100),
                Expense(70),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(SummaryPanel),
        matchesGoldenFile('golden/summary_panel.png'),
      );
    },
    tags: ['golden'],
  );
}
