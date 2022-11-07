import 'package:flutter/material.dart';

import '../../entity/record_entity.dart';
import '../../util/type/single_or_pair.dart';
import '../common_widget/delete_icon_button.dart';
import '../util/future_builder_helper.dart';
import '../util/use_case_wrapper/fetch_records.dart';

class DailyRecordMinute extends StatelessWidget {
  const DailyRecordMinute({
    required int year,
    required int month,
    required int day,
    required SingleOrPair sop,
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
  final SingleOrPair _sop;
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
    required SingleOrPair sop,
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
  final SingleOrPair _sop;
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
        onSuccess: (_, itemList) => ListView(
          children: itemList
              .map(
                (item) => Row(
                  children: [
                    Expanded(
                      child: Text(item.leading),
                    ),
                    Text('${item.amount} yen'),
                    DeleteIconButton(
                      onPressed: () {},
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
            (incomes) => incomes
                .map((record) => _ViewModelItem.ofIncome(record))
                .toList(),
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
                .map((record) => _ViewModelItem.ofExpense(record))
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
                .map((record) => _ViewModelItem.ofTransfer(record))
                .toList(),
          ),
        ),
      ],
    ).then(
      (nestedList) => nestedList.expand((list) => list).toList(),
    );
  }
}

class _ViewModelItem {
  _ViewModelItem.ofIncome(IncomeRecord entity)
      : leading = '${entity.category.name}@${entity.note}',
        amount = '+${entity.amount}';

  _ViewModelItem.ofExpense(ExpenseRecord entity)
      : leading = '${entity.category.name}@${entity.note}',
        amount = '-${entity.amount}';

  _ViewModelItem.ofTransfer(TransferRecord entity)
      : leading = '${entity.source.name}→${entity.destination.name}',
        amount = '${entity.amount}';

  final String leading;
  final String amount;
}