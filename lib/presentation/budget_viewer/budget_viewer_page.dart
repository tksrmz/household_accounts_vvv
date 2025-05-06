import 'dart:math';

import 'package:flutter/material.dart';
import 'package:household_accounts/util/extension/date_time.dart';
import 'package:provider/provider.dart';

import '../../feature/budget_analyzer/budget_analyzer_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../common_widget/loading.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class BudgetViewerPage extends StatelessWidget {
  const BudgetViewerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      singleOrPair: context.watch<SelectedNoteState>().value,
    );
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({
    required SelectedNote singleOrPair,
    Key? key,
  })  : _singleOrPair = singleOrPair,
        super(key: key);

  final SelectedNote _singleOrPair;

  @override
  State<_PageContents> createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
  late Future<ExceptionOr<RetrieveBudgetStateOutput>> _budgetFuture;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setFuture();
  }

  @override
  void didUpdateWidget(_PageContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setFuture();
  }

  void _setFuture() {
    final begin = DateTime(_date.year, _date.month);
    final end = begin.nextMonth();
    final sop = widget._singleOrPair;
    final repoId = context.read<UserInfo>().repoId(sop);
    _budgetFuture = sl<RetrieveBudgetStateUseCase>()(
      RetrieveBudgetStateInput(
        uid: repoId,
        begin: begin,
        end: end,
        recordRepository: selectExpenseRecordRepository(sop),
        categoryRepository: selectExpenseCategoryRepository(sop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExceptionOr<RetrieveBudgetStateOutput>>(
      future: _budgetFuture,
      builder: (context, snapshot) {
        final hasConnected = snapshot.connectionState == ConnectionState.done;
        if (hasConnected && snapshot.hasError) {
          return const Center(
            child: Text('エラーが発生しました'),
          );
        }

        if (hasConnected && snapshot.hasData) {
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
            Text('${_budgetState.spentAmount} / ${_budgetState.totalAmount}円'),
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
