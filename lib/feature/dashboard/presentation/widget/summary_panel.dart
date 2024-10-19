import 'package:flutter/material.dart';

import '../../../../common/logic/formatter.dart';
import '../../domain/use_case.dart';
import 'm3_container.dart';
import 'spaced_row.dart';

/// A panel that displays the given [summary].
class SummaryPanel extends StatelessWidget {
  const SummaryPanel(this._summary, {super.key});

  final Summary _summary;

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
                summary: _summary,
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
  final Summary summary;

  const _Values({required this.summary});

  @override
  Widget build(BuildContext context) {
    final List<String> strings = [
      Formatter.simpleCurrency(summary.income.value),
      Formatter.simpleCurrency(summary.expense.value),
      Formatter.simpleCurrency(summary.balance.value),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: strings.map((text) => Text(text)).toList(),
    );
  }
}
