import 'package:household_accounts/domain/models/record_summary.dart';
import 'package:household_accounts/ui/dashboard/widgets/summary_panel.dart';

import '../../../test-util/golden_helper.dart';

void main() {
  testGoldens(
    '収入が支出を上回るとき、残高が正の値で表示されること',
    goldenFileName: 'summary_panel/positive_balance',
    builder: () =>
        const SummaryPanel(summary: RecordSummary(income: 100, expense: 70)),
  );

  testGoldens(
    '支出が収入を上回るとき、残高が負の値で表示されること',
    goldenFileName: 'summary_panel/negative_balance',
    builder: () =>
        const SummaryPanel(summary: RecordSummary(income: 20, expense: 30)),
  );

  testGoldens(
    '収入と支出が同額のとき、残高が0で表示されること',
    goldenFileName: 'summary_panel/zero_balance',
    builder: () =>
        const SummaryPanel(summary: RecordSummary(income: 1, expense: 1)),
  );
}
