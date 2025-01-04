import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';

import '../../../util/golden_helper.dart';

void main() {
  testGoldens(
    'SummaryPanel displays income, expense and balance',
    goldenFileName: 'summary_panel',
    builder: () => SummaryPanel(
      Income(100),
      Expense(70),
    ),
  );
}
