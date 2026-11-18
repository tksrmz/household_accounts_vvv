import 'package:flutter/material.dart';

import '../../core/formatter.dart';
import '../../../domain/models/record_summary.dart';
import 'm3_container.dart';
import 'spaced_row.dart';

/// A panel that displays the given [summary].
class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key, required this.summary});

  final RecordSummary summary;

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
            children: [const _Labels(), _Values(summary)],
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
      children: [Text('収入'), Text('支出'), Text('残高')],
    );
  }
}

class _Values extends StatelessWidget {
  const _Values(this.summary);

  final RecordSummary summary;

  @override
  Widget build(BuildContext context) {
    final List<String> strings = [
      Formatter.simpleCurrency(summary.income),
      Formatter.simpleCurrency(summary.expense),
      Formatter.simpleCurrency(summary.balance),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: strings.map((text) => Text(text)).toList(),
    );
  }
}
