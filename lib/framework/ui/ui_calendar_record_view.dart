import 'package:flutter/material.dart';

class CalendarRecordViewPage extends StatefulWidget {
  const CalendarRecordViewPage({Key? key}) : super(key: key);
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
        _MonthlyRecordView(_selectedDate),
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

class _MonthlyRecordView extends StatelessWidget {
  final DateTime _selectedMonth;

  int get _year => _selectedMonth.year;
  int get _month => _selectedMonth.month;

  _MonthlyRecordView(this._selectedMonth) : super();

  @override
  Widget build(BuildContext context) {
    final Widget Function(int) dayWidgetBuilder = (day) {
      final void Function() onPressedCallback = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _DailyRecordMinute(
              DateTime(_year, _month, day),
            ),
          ),
        );
      };

      final childWidget = Column(
        children: [
          Text('$day'),
        ],
      );

      return TextButton(
        onPressed: onPressedCallback,
        child: childWidget,
      );
    };

    return _Calendar(_selectedMonth, dayWidgetBuilder);
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
  int get _year => _displayDate.year;
  int get _month => _displayDate.month;
  int get _day => _displayDate.day;

  const _DailyRecordMinute(this._displayDate, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minute'),
      ),
      body: ListView(
        children: [
          Text('$_year/$_month/$_day - 1'),
          Text('$_year/$_month/$_day - 2'),
          Text('$_year/$_month/$_day - 3'),
        ],
      ),
    );
  }
}
