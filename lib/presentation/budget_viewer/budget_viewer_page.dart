import 'package:flutter/widgets.dart';
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
            (output) => ListView(
              children: List.of(
                output.states.map(
                  (e) => _BudgetListItem(budgetState: e),
                ),
              ),
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_budgetState.name),
        Spacer(),
        Text('${_budgetState.spentAmount} / ${_budgetState.totalAmount}'),
      ],
    );
  }
}
