import 'dart:math';

import 'package:flutter/material.dart';
import 'package:household_accounts/feature/budget_analyzer/budget_analyzer_use_case.dart';
import 'package:household_accounts/util/service_locator/service_locator.dart';
import 'package:household_accounts/util/type/failure_or.dart';
import 'package:household_accounts/presentation/common_widget/loading.dart';
import 'package:household_accounts/util/extension/date-time.dart';

class BudgetViewerPage extends StatelessWidget {
  const BudgetViewerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PageContents();
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  State<_PageContents> createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
  late Future<FailureOr<RetrieveBudgetStateOutput>> _budgetFuture;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final begin = DateTime(_date.year, _date.month);
    final end = begin.nextMonth();
    _budgetFuture = sl<RetrieveBudgetStateUseCase>().handle(
      RetrieveBudgetStateInput(
        begin: begin,
        end: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FailureOr<RetrieveBudgetStateOutput>>(
      future: _budgetFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!.fold(
                (failure) => Center(
              child: Text(failure.toString()),
            ),
            (output) {
              return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: output.states.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _BudgetListItem(budgetState: output.states[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.black,
                    );
                  });
            },
          );
        }

        return const Center(
          child: LoadingWidget(),
        );
      },
    );
  }
}

class _BudgetListItem extends StatelessWidget {
  const _BudgetListItem({
    Key? key,
    required BudgetState budgetState,
  })  : _budgetState = budgetState,
        super(key: key);

  final BudgetState _budgetState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(_budgetState.name),
            Spacer(),
            Text('${_budgetState.spentAmount} / ${_budgetState.totalAmount}'),
          ],
        ),
        SizedBox(
          height: 20,
          width: double.infinity,
          child: Container(
            color: Colors.grey,
            child: Transform.scale(
              alignment: Alignment.centerLeft,
              scaleX: min(
                1.0, // avoiding scaleX from being larger than 1.0
                _budgetState.spentAmount / _budgetState.totalAmount,
              ),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
