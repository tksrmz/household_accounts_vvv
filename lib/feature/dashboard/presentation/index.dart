import 'package:flutter/material.dart';

import '../../../common/logic/formatter.dart';
import '../../../presentation/util/future_builder_helper.dart';
import '../domain/use_case.dart';
import 'widget/spaced_list_view.dart';
import 'widget/summary_panel.dart';

class Dashboard extends StatelessWidget {
  final DashboardUseCase _useCase;

  const Dashboard(this._useCase, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Formatter.date(DateTime.now())),
        leading: const Icon(Icons.menu),
      ),
      body: _Body(_useCase),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('取引履歴'),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body(this._useCase, {super.key});

  final DashboardUseCase _useCase;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// A future that resolves when all the data is fetched.
  late final Future<List<dynamic>> _futures;

  @override
  void initState() {
    super.initState();
    _futures = Future.wait(
      [
        widget._useCase.getSummary(),
        widget._useCase.getTopThreeBudgetsWithOthers(),
        widget._useCase.getTopThreeFundsWithOthers(),
        widget._useCase.getRecentTenTransactions(),
      ],
      eagerError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futures,
      builder: (_, snapshot) => FutureBuilderHelper<List<dynamic>>(
        snapshot: snapshot,
        onSuccess: (context, data) => _BodyOnSuccess(
          summary: data[0] as Summary,
          budgets: data[1] as List<Budget>,
          funds: data[2] as List<Fund>,
          transactions: data[3] as List<Transaction>,
        ),
        // TODO add onError and onLoading
      ),
    );
  }
}

class _BodyOnSuccess extends StatelessWidget {
  const _BodyOnSuccess({
    super.key,
    required Summary summary,
    required List<Budget> budgets,
    required List<Fund> funds,
    required List<Transaction> transactions,
  })  : _summary = summary,
        _budgets = budgets,
        _funds = funds,
        _transactions = transactions;

  final Summary _summary;
  final List<Budget> _budgets;
  final List<Fund> _funds;
  final List<Transaction> _transactions;

  @override
  Widget build(BuildContext context) {
    const spaceBetweenChildren = 16.0;
    const horizontalEdgeInset = 16.0;

    return SpacedListView(
      spaceHeight: spaceBetweenChildren,
      // Add a enough space between the last item and the bottom of the screen.
      padding: const EdgeInsets.only(top: 4.0, bottom: 80.0 /* FAB height */),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalEdgeInset,
          ),
          child: SummaryPanel(_summary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalEdgeInset,
          ),
          child: Placeholder(
            fallbackHeight: 100,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalEdgeInset,
          ),
          child: Placeholder(
            fallbackHeight: 100,
          ),
        ),
      ],
    );
  }
}
