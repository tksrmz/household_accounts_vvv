import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';

import '../../../util/golden_helper.dart';

void main() {
  testGoldens(
    'SummaryPanel displays income, expense and positive balance',
    goldenFileName: 'summary_panel_positive_balance',
    builder: () => SummaryPanel(
      Income(100),
      Expense(70),
    ),
  );

  testGoldens(
    'SummaryPanel displays income, expense and negative balance',
    goldenFileName: 'summary_panel_negative_balance',
    builder: () => SummaryPanel(
      Income(20),
      Expense(30),
    ),
  );

  testGoldens(
    'SummaryPanel displays income, expense and zero balance',
    goldenFileName: 'summary_panel_zero_balance',
    builder: () => SummaryPanel(
      Income(1),
      Expense(1),
    ),
  );
}
