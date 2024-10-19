import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/common/domain/amount.dart';
import 'package:household_accounts/feature/dashboard/domain/use_case.dart';
import 'package:household_accounts/feature/dashboard/presentation/widget/summary_panel.dart';

void main() async {
  group('SummaryPanel', () {
    // FIXME: import fonts
    goldenTest(
      'renders correctly',
      fileName: 'summary_panel',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints.tightFor(width: 360),
        children: [
          GoldenTestScenario(
            name: 'default',
            child: SummaryPanel(
              Summary(
                income: const Amount(20000),
                expense: const Amount(15001),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
