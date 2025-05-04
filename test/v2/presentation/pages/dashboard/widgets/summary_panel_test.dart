import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/widgets/summary_panel.dart';

import '../../../../../test-util/golden_helper.dart';

void main() {
  testGoldens(
    'SummaryPanel displays income, expense and positive balance',
    goldenFileName: 'summary_panel/positive_balance',
    builder: () => SummaryPanel(
      IncomeVo(100),
      ExpenseVo(70),
    ),
  );

  testGoldens(
    'SummaryPanel displays income, expense and negative balance',
    goldenFileName: 'summary_panel/negative_balance',
    builder: () => SummaryPanel(
      IncomeVo(20),
      ExpenseVo(30),
    ),
  );

  testGoldens(
    'SummaryPanel displays income, expense and zero balance',
    goldenFileName: 'summary_panel/zero_balance',
    builder: () => SummaryPanel(
      IncomeVo(1),
      ExpenseVo(1),
    ),
  );
}
