import 'package:flutter/material.dart';
import 'package:household_accounts/adapter/controller/record_controller.dart';
import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/framework/db/db_record_repository.dart';
import 'package:household_accounts/use_case/record_use_case.dart';
import 'package:household_accounts/use_case/uc_repository.dart';
import 'package:provider/provider.dart';

class CalendarRecordViewPage extends StatefulWidget {
  final RecordRepositoryInterface _rrif;

  const CalendarRecordViewPage(this._rrif, {Key? key}) : super(key: key);

  @override
  _CalendarRecordViewPageState createState() => _CalendarRecordViewPageState();
}

class _CalendarRecordViewPageState extends State<CalendarRecordViewPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _decrementMonth() {
    setState(() =>
        _selectedDate = DateUtils.addMonthsToMonthDate(_selectedDate, -1));
  }

  void _incrementMonth() {
    setState(
        () => _selectedDate = DateUtils.addMonthsToMonthDate(_selectedDate, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DateLabelWidget(
          _selectedDate,
          _decrementMonth,
          _incrementMonth,
        ),
        const _WeekdayWidget(),
        _MonthlyRecordView(_selectedDate, widget._rrif),
      ],
    );
  }
}

class _DateLabelWidget extends StatelessWidget {
  final DateTime _selectedMonth;
  final VoidCallback _arrowLeftCallback;
  final VoidCallback _arrowRightCallback;

  const _DateLabelWidget(
    this._selectedMonth,
    this._arrowLeftCallback,
    this._arrowRightCallback, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: _arrowLeftCallback,
        ),
        Text('${_selectedMonth.year}/${_selectedMonth.month}'),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: (DateUtils.isSameMonth(_selectedMonth, DateTime.now()))
              ? null
              : _arrowRightCallback,
        ),
      ],
    );
  }
}

class _WeekdayWidget extends StatelessWidget {
  const _WeekdayWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
  }
}

extension DateTimeUtil on DateTime {
  DateTime nextMonth() {
    final days = DateUtils.getDaysInMonth(this.year, this.month);
    return DateUtils.addDaysToDate(this, days);
  }
}

class _MonthlyRecordView extends StatelessWidget {
  final DateTime _selectedMonth;
  final RecordRepositoryInterface _rrif;

  int get _year => _selectedMonth.year;

  int get _month => _selectedMonth.month;

  _MonthlyRecordView(this._selectedMonth, this._rrif) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _rrif.retrieveRecordsOf(
        DateTime(_year, _month),
        DateTime(_year, _month).nextMonth(),
      ),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.hasError) {
          return Center(
            child: Text('Error occurred'),
          );
        }

        if (dataSnapshot.connectionState == ConnectionState.done) {
          List<Record> records = dataSnapshot.data as List<Record>;

          // final Widget Function(int) dayWidgetBuilder = (day) {
          final Widget Function(int) dayWidgetBuilder = (day) {
            final todayRecord = List.of(
                records.where((element) => element.dateOfRecord.day == day));

            final void Function() onPressedCallback = () {
              List<Record> incomes = List.of(todayRecord
                  .where((element) => element.recordType == RecordType.income));
              List<Record> expenses = List.of(todayRecord.where(
                  (element) => element.recordType == RecordType.expense));

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _DailyRecordMinute(
                    DateTime(_year, _month, day),
                    incomes,
                    expenses,
                  ),
                ),
              );
            };

            final int income = todayRecord
                .where((element) => element.recordType == RecordType.income)
                .fold(0,
                    (previousValue, element) => previousValue + element.amount);
            final int expense = todayRecord
                .where((element) => element.recordType == RecordType.expense)
                .fold(0,
                    (previousValue, element) => previousValue + element.amount);

            final childWidget = Column(
              children: [
                Text('$day'),
                Text('$income'),
                Text('$expense'),
              ],
            );

            return TextButton(
              onPressed: onPressedCallback,
              child: childWidget,
            );
          };

          return _Calendar(_selectedMonth, dayWidgetBuilder);
        }

        return Center(
          child: Text('loading'),
        );
      },
    );
  }
}

class _Calendar extends StatelessWidget {
  final DateTime _dateTime;
  final Widget Function(int) _dayWidgetBuilder;

  int get year => _dateTime.year;
  int get month => _dateTime.month;

  const _Calendar(this._dateTime, this._dayWidgetBuilder, {Key? key})
      : super(key: key);
  _Calendar.column(DateTime dateTime)
      : this(dateTime, (day) => Column(children: [Text('$day')]));

  List<List<int>> _createCalendar() {
    final calendar = [List<int>.filled(DateTime.daysPerWeek, 0)];

    for (var day = 1; day <= DateUtils.getDaysInMonth(year, month); day++) {
      var weekday = DateTime(year, month, day).weekday;
      // DateTime.weekday is 1-origin, so subtracting one is needed to use it as an index of a list.
      calendar.last[weekday - 1] = day;
      if (weekday == DateTime.sunday) {
        calendar.add(List<int>.filled(DateTime.daysPerWeek, 0));
      }
    }

    return calendar;
  }

  @override
  Widget build(BuildContext context) {
    final calendar = _createCalendar();

    final TableRow Function(List<int>) weekWidgetBuilder = (week) => TableRow(
          children: List<Widget>.of(
            week.map(
              (day) => day == 0 ? Container() : _dayWidgetBuilder(day),
            ),
          ),
        );

    return Table(
      children: List<TableRow>.of(
        calendar.map(weekWidgetBuilder),
      ),
    );
  }
}

class _DailyRecordMinute extends StatelessWidget {
  final DateTime _displayDate;
  final List<Record> _incomeRecords;
  final List<Record> _expenseRecords;

  int get _year => _displayDate.year;

  int get _month => _displayDate.month;

  int get _day => _displayDate.day;

  const _DailyRecordMinute(
      this._displayDate, this._incomeRecords, this._expenseRecords,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (_incomeRecords.isNotEmpty) {
      children.add(Text('Incomes'));
      children.addAll(_incomeRecords.map((e) => _MinuteItem(e)));
    }
    if (_expenseRecords.isNotEmpty) {
      children.add(Text('Expenses'));
      children.addAll(_expenseRecords.map((e) => _MinuteItem(e)));
    }

    if (children.isEmpty) children.add(Text('No items to display'));

    return Scaffold(
      appBar: AppBar(
        title: Text('$_year/$_month/$_day'),
      ),
      body: Provider(
        create: (ctx) => RecordDeleteController(
            RecordDeleteInteractor(FirestoreRecordRepository())),
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}

class _MinuteItem extends StatelessWidget {
  final Record _record;

  const _MinuteItem(this._record, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('${_record.note}@${_record.category}'),
        ),
        Text('${_record.amount} yen'),
        OutlinedButton(
          onPressed: () =>
              context.read<RecordDeleteController>().deleteById(_record.id),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
