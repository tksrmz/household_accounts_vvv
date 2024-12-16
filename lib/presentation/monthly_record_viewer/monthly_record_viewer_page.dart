import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entity/record.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/single_or_pair.dart';
import '../daily_record_viewer/daily_record_viewer_page.dart';
import '../util/date.dart';
import '../util/future_builder_helper.dart';
import '../util/model/user_info.dart';
import '../util/use_case_wrapper/fetch_records.dart';

class CalendarRecordViewPage extends StatefulWidget {
  const CalendarRecordViewPage({Key? key}) : super(key: key);

  @override
  State<CalendarRecordViewPage> createState() => _CalendarRecordViewPageState();
}

class _CalendarRecordViewPageState extends State<CalendarRecordViewPage> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final increment = () => _updateMonthBy(1);
    final decrement = () => _updateMonthBy(-1);

    return ListView(
      children: [
        _DateLabelWidget(
          year: _year,
          month: _month,
          onLeftArrowPressed: decrement,
          onRightArrowPressed: increment,
          disableRightArrow: isCurrentMonth(_year, _month),
        ),
        _CalendarRecordView(
          year: _year,
          month: _month,
          singleOrPair: context.watch<SingleOrPair>(),
        ),
      ],
    );
  }

  void _updateMonthBy(int delta) {
    final newDate = addMonths(_year, _month, delta);
    final update = () {
      _year = newDate.year;
      _month = newDate.month;
    };
    setState(update);
  }
}

class _DateLabelWidget extends StatelessWidget {
  const _DateLabelWidget({
    required int year,
    required int month,
    required VoidCallback onLeftArrowPressed,
    required VoidCallback onRightArrowPressed,
    bool disableLeftArrow = false,
    bool disableRightArrow = false,
    Key? key,
  })  : _year = year,
        _month = month,
        _onLeftArrowPressed = onLeftArrowPressed,
        _onRightArrowPressed = onRightArrowPressed,
        _disableLeftArrow = disableLeftArrow,
        _disableRightArrow = disableRightArrow,
        super(key: key);

  final int _year;
  final int _month;
  final VoidCallback _onLeftArrowPressed;
  final VoidCallback _onRightArrowPressed;
  final bool _disableLeftArrow;
  final bool _disableRightArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: _disableLeftArrow ? null : _onLeftArrowPressed,
        ),
        Text('$_year/$_month'),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: _disableRightArrow ? null : _onRightArrowPressed,
        ),
      ],
    );
  }
}

class _CalendarRecordView extends StatefulWidget {
  const _CalendarRecordView({
    required int year,
    required int month,
    required SingleOrPair singleOrPair,
    Key? key,
  })  : _year = year,
        _month = month,
        _singleOrPair = singleOrPair,
        super(key: key);

  final int _year;
  final int _month;
  final SingleOrPair _singleOrPair;

  @override
  State<_CalendarRecordView> createState() => _CalendarRecordViewState();
}

typedef _DailyRecordSummary = Map<String, List<int>>;

class _CalendarRecordViewState extends State<_CalendarRecordView> {
  late Future<_DailyRecordSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _setSummaryFutureState();
  }

  @override
  void didUpdateWidget(_CalendarRecordView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setSummaryFutureState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DailyRecordSummary>(
      future: _summaryFuture,
      builder: (_, snapshot) => FutureBuilderHelper<_DailyRecordSummary>(
        snapshot: snapshot,
        onSuccess: (_, summary) => buildCalendar(summary),
      ),
    );
  }

  _Calendar buildCalendar(_DailyRecordSummary summary) {
    return _Calendar(
      year: widget._year,
      month: widget._month,
      dayWidgetBuilder: (y, m, d) => buildCalendarDay(y, m, d, summary),
    );
  }

  _CalendarDay buildCalendarDay(
    int year,
    int month,
    int day,
    _DailyRecordSummary summary,
  ) {
    final onTap = () async {
      final sop = context.read<SingleOrPair>();
      final repoId = context.read<UserInfo>().repoId(sop);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyRecordMinute(
            year: year,
            month: month,
            day: day,
            sop: sop,
            repoId: repoId,
          ),
        ),
      );
      setState(() {
        _setSummaryFutureState();
      });
    };
    return _CalendarDay(
      day: day,
      income: summary["income"]![day - 1],
      expense: summary["expense"]![day - 1],
      transfer: summary["transfer"]![day - 1],
      onTap: onTap,
    );
  }

  void _setSummaryFutureState() {
    final year = widget._year;
    final month = widget._month;
    final sop = widget._singleOrPair;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final List<int> Function(ExceptionOr<List<RecordBase>>) action =
        (result) => result.fold<List<int>>(
              (_) => List.filled(daysInMonth, 0),
              (records) => _summarize(daysInMonth, records),
            );
    final repoId = context.read<UserInfo>().repoId(sop);
    _summaryFuture = Future.wait<List<int>>(
      [
        fetchIncomeRecords(
          year: year,
          month: month,
          sop: sop,
          repoId: repoId,
        ).then(action),
        fetchExpenseRecords(
          year: year,
          month: month,
          sop: sop,
          repoId: repoId,
        ).then(action),
        fetchTransferRecords(
          year: year,
          month: month,
          sop: sop,
          repoId: repoId,
        ).then(action),
      ],
    ).then(
      (lists) => <String, List<int>>{
        "income": lists[0],
        "expense": lists[1],
        "transfer": lists[2],
      },
    );
  }

  List<int> _summarize(int length, List<RecordBase> records) => List.generate(
        length,
        (index) => records
            .where((e) => e.recordDate.day == index + 1)
            .fold<int>(0, (prev, e) => prev + e.amount),
      );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required int day,
    required int income,
    required int expense,
    required int transfer,
    required VoidCallback onTap,
    Key? key,
  })  : _day = day,
        _income = income,
        _expense = expense,
        _transfer = transfer,
        _onTap = onTap,
        super(key: key);

  final int _day;
  final int _income;
  final int _expense;
  final int _transfer;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: _onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(child: Text('$_day')),
            Text(
              '$_income',
              style: TextStyle(color: Colors.green),
            ),
            Text(
              '$_expense',
              style: TextStyle(color: Colors.orange),
            ),
            Text(
              '$_transfer',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required int year,
    required int month,
    required Widget Function(int, int, int) dayWidgetBuilder,
    Key? key,
  })  : _year = year,
        _month = month,
        _dayWidgetBuilder = dayWidgetBuilder,
        super(key: key);

  final int _year;
  final int _month;
  final Widget Function(int, int, int) _dayWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    final TableRow Function(List<int>) weekWidgetBuilder = (week) => TableRow(
          children: week
              .map<Widget>(
                (day) => day == 0
                    ? Container()
                    : _dayWidgetBuilder(_year, _month, day),
              )
              .toList(growable: false),
        );
    final date = _createCalendar(_year, _month)
        .map<TableRow>(weekWidgetBuilder)
        .toList(growable: false);
    final weekday = TableRow(
      children: const [
        Text("Mon"),
        Text("Tue"),
        Text("Wed"),
        Text("Thu"),
        Text("Fri"),
        Text("Sat"),
        Text("Sun"),
      ],
    );

    return Table(
      children: [
        weekday,
        ...date,
      ],
    );
  }

  List<List<int>> _createCalendar(int year, int month) {
    final calendar = [List<int>.filled(DateTime.daysPerWeek, 0)];
    final fillCalendar = (int day) {
      var weekday = DateTime(year, month, day).weekday;
      // DateTime.weekday is 1-origin, so subtracting one is needed to use it as an index of a list.
      calendar.last[weekday - 1] = day;
      if (weekday == DateTime.sunday) {
        calendar.add(List<int>.filled(DateTime.daysPerWeek, 0));
      }
    };

    final days = List.generate(
      DateUtils.getDaysInMonth(year, month),
      (i) => i + 1,
      growable: false,
    );
    days.forEach(fillCalendar);

    return calendar;
  }
}
