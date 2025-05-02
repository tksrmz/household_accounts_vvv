import 'package:flutter/material.dart';

import '../../../../../../common/logic/formatter.dart';
import '../../../../../entity/balance.dart';
import '../../../../domain/models/vo/expense.dart';
import '../../../../domain/models/vo/income.dart';
import 'm3_container.dart';
import 'spaced_row.dart';

/// A panel that displays the given [summary].
class SummaryPanel extends StatelessWidget {
  SummaryPanel(
    this.income,
    this.expense, {
    super.key,
  }) : balance = Balance(income, expense);

  final Income income;
  final Expense expense;
  final Balance balance;

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 8;
    const double borderRadius = 4;
    const double spaceBetweenLabelAndAmount = 20;

    return M3Container.primary(
      padding: const EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      colorScheme: Theme.of(context).colorScheme,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: SpacedRow(
            spaceWidth: spaceBetweenLabelAndAmount,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Labels(),
              _Values(
                income,
                expense,
                balance,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Labels extends StatelessWidget {
  const _Labels();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('収入'),
        Text('支出'),
        Text('残高'),
      ],
    );
  }
}

class _Values extends StatelessWidget {
  const _Values(
    this.income,
    this.expense,
    this.balance,
  );

  final Income income;
  final Expense expense;
  final Balance balance;

  @override
  Widget build(BuildContext context) {
    final List<String> strings = [
      Formatter.simpleCurrency(income.value),
      Formatter.simpleCurrency(expense.value),
      Formatter.simpleCurrency(balance.value),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: strings.map((text) => Text(text)).toList(),
    );
  }
}
