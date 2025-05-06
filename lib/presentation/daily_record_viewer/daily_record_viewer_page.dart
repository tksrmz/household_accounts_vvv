import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';

import '../../common/logic/formatter.dart';
import '../../entity/record.dart';
import '../../feature/record_deletion/use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../common_widget/delete_icon_button.dart';
import '../util/future_builder_helper.dart';
import '../util/repository_selector.dart';
import '../util/use_case_wrapper/fetch_records.dart';

class DailyRecordMinute extends StatelessWidget {
  const DailyRecordMinute({
    required int year,
    required int month,
    required int day,
    required SelectedNote sop,
    required String repoId,
    Key? key,
  })  : _year = year,
        _month = month,
        _day = day,
        _sop = sop,
        _repoId = repoId,
        super(key: key);

  final int _year;
  final int _month;
  final int _day;
  final SelectedNote _sop;
  final String _repoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_year/$_month/$_day'),
      ),
      body: _DailyRecordMinuteBody(
        year: _year,
        month: _month,
        day: _day,
        sop: _sop,
        repoId: _repoId,
      ),
    );
  }
}

class _DailyRecordMinuteBody extends StatefulWidget {
  const _DailyRecordMinuteBody({
    required int year,
    required int month,
    required int day,
    required SelectedNote sop,
    required String repoId,
    Key? key,
  })  : _year = year,
        _month = month,
        _day = day,
        _sop = sop,
        _repoId = repoId,
        super(key: key);

  final int _year;
  final int _month;
  final int _day;
  final SelectedNote _sop;
  final String _repoId;

  @override
  State<_DailyRecordMinuteBody> createState() => _DailyRecordMinuteBodyState();
}

class _DailyRecordMinuteBodyState extends State<_DailyRecordMinuteBody> {
  late Future<List<_ViewModelItem>> _recordListFuture;

  @override
  void initState() {
    super.initState();
    _setRecordListState();
  }

  @override
  void didUpdateWidget(_DailyRecordMinuteBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setRecordListState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ViewModelItem>>(
      future: _recordListFuture,
      builder: (_, snapshot) => FutureBuilderHelper<List<_ViewModelItem>>(
        snapshot: snapshot,
        onSuccess: (context, itemList) => ListView(
          children: itemList
              .map(
                (item) => Row(
                  children: [
                    Expanded(
                      child: Text(item.leadingText),
                    ),
                    Text('${item.amountText}'),
                    DeleteIconButton(
                      onPressed: () async {
                        await item.delete(
                          uid: widget._repoId,
                          sop: widget._sop,
                        );
                        setState(() {
                          _setRecordListState();
                        });
                      },
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _setRecordListState() {
    final year = widget._year;
    final month = widget._month;
    final day = widget._day;
    final sop = widget._sop;
    final repoId = widget._repoId;
    _recordListFuture = Future.wait(
      [
        fetchIncomeRecords(
          year: year,
          month: month,
          day: day,
          sop: sop,
          repoId: repoId,
        ).then(
          (failureOrIncomes) => failureOrIncomes.fold(
            (_) => <_ViewModelItem>[],
            (incomes) =>
                incomes.map((record) => _ViewModelItemIncome(record)).toList(),
          ),
        ),
        fetchExpenseRecords(
          year: year,
          month: month,
          day: day,
          sop: sop,
          repoId: repoId,
        ).then(
          (failureOrExpenses) => failureOrExpenses.fold(
            (_) => <_ViewModelItem>[],
            (expenses) => expenses
                .map((record) => _ViewModelItemExpense(record))
                .toList(),
          ),
        ),
        fetchTransferRecords(
          year: year,
          month: month,
          day: day,
          sop: sop,
          repoId: repoId,
        ).then(
          (failureOrTransfers) => failureOrTransfers.fold(
            (_) => <_ViewModelItem>[],
            (transfers) => transfers
                .map((record) => _ViewModelItemTransfer(record))
                .toList(),
          ),
        ),
      ],
    ).then(
      (nestedList) => nestedList.expand((list) => list).toList(),
    );
  }
}

abstract class _ViewModelItem {
  String get leadingText;

  String get amountText;

  RecordType get type;

  Future<ExceptionOr<dartz.Unit>> delete({
    required String uid,
    required SelectedNote sop,
  });
}

class _ViewModelItemIncome extends _ViewModelItem {
  _ViewModelItemIncome(this.entity);

  final IncomeRecord entity;

  @override
  String get amountText => '+${Formatter.simpleCurrency(entity.amount)}';

  @override
  String get leadingText => '${entity.category.name}@${entity.note}';

  @override
  RecordType get type => entity.type;

  @override
  Future<ExceptionOr<dartz.Unit>> delete({
    required String uid,
    required SelectedNote sop,
  }) =>
      sl<DeleteRecordUseCase<IncomeRecord>>()(
        DeleteRecordInput(
          uid: uid,
          record: entity,
          repository: selectIncomeRecordRepository(sop),
        ),
      );
}

class _ViewModelItemExpense extends _ViewModelItem {
  _ViewModelItemExpense(this.entity);

  final ExpenseRecord entity;

  @override
  String get amountText => '${Formatter.simpleCurrency(entity.amount)}';

  @override
  String get leadingText => '${entity.category.name}@${entity.note}';

  @override
  RecordType get type => entity.type;

  @override
  Future<ExceptionOr<dartz.Unit>> delete({
    required String uid,
    required SelectedNote sop,
  }) =>
      sl<DeleteRecordUseCase<ExpenseRecord>>()(
        DeleteRecordInput(
          uid: uid,
          record: entity,
          repository: selectExpenseRecordRepository(sop),
        ),
      );
}

class _ViewModelItemTransfer extends _ViewModelItem {
  _ViewModelItemTransfer(this.entity);

  final TransferRecord entity;

  @override
  String get amountText => '${Formatter.simpleCurrency(entity.amount)}';

  @override
  String get leadingText => '${entity.source.name}→${entity.destination.name}';

  @override
  RecordType get type => entity.type;

  @override
  Future<ExceptionOr<dartz.Unit>> delete({
    required String uid,
    required SelectedNote sop,
  }) =>
      sl<DeleteRecordUseCase<TransferRecord>>()(
        DeleteRecordInput(
          uid: uid,
          record: entity,
          repository: selectTransferRecordRepository(sop),
        ),
      );
}
