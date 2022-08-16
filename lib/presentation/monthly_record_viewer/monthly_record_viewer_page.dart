import 'package:flutter/material.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_use_case.dart';
import 'package:household_accounts/presentation/monthly_record_viewer/monthly_record_viewer_state.dart';
import 'package:household_accounts/presentation/daily_record_viewer/daily_record_viewer_state.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_daily_records_use_case.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_monthly_records_use_case.dart';
import 'package:household_accounts/util/service_locator/service_locator.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';
import 'package:provider/provider.dart';

class CalendarRecordViewPage2 extends StatelessWidget {
  CalendarRecordViewPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CalendarRecordModel(sl<RetrieveMonthlyRecordsUseCase>())
        ..loadRecords(),
      child: _Page(),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoading =
        context.select<CalendarRecordModel, bool>((model) => model.isLoading);

    return ListView(
      children: [
        _DateLabelWidget2(),
        const _WeekdayWidget(),
        isLoading ? const Text('loading') : _CalenderView()
      ],
    );
  }
}

class _CalenderView extends StatelessWidget {
  const _CalenderView({Key? key}) : super(key: key);

  // Widget _buildDayWidget

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalendarRecordModel>();

    return _Calendar(
      model.year,
      model.month,
      (int year, int month, int day) {
        final summary = model.recordAt(day);

        return TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (newContext) => _DailyRecordMinute(year, month, day),
              ),
            );
          },
          child: Column(
            children: [
              Text('$day'),
              Text('+${summary.totalIncome}'),
              Text('-${summary.totalExpense}'),
              Text('=${summary.totalTransfer}'),
            ],
          ),
        );
      },
    );
  }
}

class _DateLabelWidget2 extends StatelessWidget {
  const _DateLabelWidget2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final year =
        context.select<CalendarRecordModel, int>((model) => model.year);
    final month =
        context.select<CalendarRecordModel, int>((model) => model.month);
    final isCurrentMonth = DateUtils.isSameMonth(
      DateTime(year, month),
      DateTime.now(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: context.read<CalendarRecordModel>().decrementMonth,
        ),
        Text('$year/$month'),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: isCurrentMonth
              ? null
              : context.read<CalendarRecordModel>().incrementMonth,
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

class _Calendar extends StatelessWidget {
  final int _year;
  final int _month;
  final Widget Function(int, int, int) _dayWidgetBuilder;

  const _Calendar(this._year, this._month, this._dayWidgetBuilder, {Key? key})
      : super(key: key);

  List<List<int>> _createCalendar() {
    final calendar = [List<int>.filled(DateTime.daysPerWeek, 0)];

    for (var day = 1; day <= DateUtils.getDaysInMonth(_year, _month); day++) {
      var weekday = DateTime(_year, _month, day).weekday;
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
              (day) => day == 0
                  ? Container()
                  : _dayWidgetBuilder(_year, _month, day),
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
  final int _year;
  final int _month;
  final int _day;

  const _DailyRecordMinute(this._year, this._month, this._day, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$_year/$_month/$_day'),
        ),
        body: ChangeNotifierProvider(
          create: (ctx) => DailyRecordModel(
            sl<RetrieveDailyRecordsUseCase>(),
            sl<DeleteRecordUseCaseNew>(),
            sl<RetrieveIncomeCategoriesUseCase>(),
            sl<RetrieveExpenseCategoriesUseCase>(),
          )
            ..loadRecords(_year, _month, _day)
            ..loadCategories(),
          child: _MinuteList(),
        ));
  }
}

class _MinuteList extends StatelessWidget {
  const _MinuteList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DailyRecordModel>();

    if (model.isLoading) {
      return const Text('loading');
    }

    final forEachAction =
        (List<Widget> children, Record record) => children.add(
              _MinuteItem(
                record: record,
                categoryName: model.categoryNameOf(record),
              ),
            );

    final minutes = <Widget>[];
    if (model.incomes.isNotEmpty) {
      minutes.add(const Text('INCOMES'));
      model.incomes.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    if (model.expenses.isNotEmpty) {
      minutes.add(const Text('EXPENSES'));
      model.expenses.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    if (model.transfer.isNotEmpty) {
      minutes.add(const Text('TRANSFER'));
      model.transfer.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    return minutes.isEmpty
        ? Center(child: Text('No record'))
        : Column(children: minutes);
  }
}

class _MinuteItem extends StatelessWidget {
  final Record _record;
  final String _categoryName;

  const _MinuteItem({
    Key? key,
    required Record record,
    required String categoryName,
  })  : _record = record,
        _categoryName = categoryName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('${_record.note}@$_categoryName'),
        ),
        Text('${_record.amount} yen'),
        OutlinedButton(
          onPressed: () => context.read<DailyRecordModel>().deleteById(
                _record.id,
                _record.type,
              ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
