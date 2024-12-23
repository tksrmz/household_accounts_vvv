import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';

import '../../../util/golden_wrapper.dart';

void main() {
  testWidgets(
    'SummaryPanel displays income, expense and balance',
    (tester) async {
      await tester.pumpWidget(
        GoldenWrapper(
          child: SummaryPanel(
            Income(100),
            Expense(70),
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
