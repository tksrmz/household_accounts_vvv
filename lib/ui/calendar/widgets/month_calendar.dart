import 'package:flutter/material.dart';

import '../../../common/logic/formatter.dart';
import '../../../domain/models/daily_summary.dart';

/// 1か月分の日を週ごとに並べ、日ごとの収入/支出/振替の合計を表示するカレンダー。
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.dailySummaries,
    required this.onDaySelected,
  });

  /// 表示する年。
  final int year;

  /// 表示する月(1〜12)。
  final int month;

  /// 日(1〜31)ごとの集計。レコードのない日はキーを持たない。
  final Map<int, DailySummary> dailySummaries;

  /// 日セルが選択されたときに、その日を渡して呼ばれる。
  final void Function(int day) onDaySelected;

  // レコードのない日も金額0の3行を表示する(日ごとの高さが揃い、
  // 「その日は何もなかった」ことが空白ではなく金額として読み取れる)。
  // 集計側は存在しない日にキーを持たないため、ゼロ埋めは表示側で行う。
  static const _empty = DailySummary(income: 0, expense: 0, transfer: 0);

  @override
  Widget build(BuildContext context) {
    final weeks = _createCalendar(year, month)
        .map<TableRow>(
          (week) => TableRow(
            children: week
                .map<Widget>(
                  (day) => day == 0
                      ? Container()
                      : _CalendarDay(
                          day: day,
                          summary: dailySummaries[day] ?? _empty,
                          onTap: () => onDaySelected(day),
                        ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
    const weekday = TableRow(
      children: [
        Text('月'),
        Text('火'),
        Text('水'),
        Text('木'),
        Text('金'),
        Text('土'),
        Text('日'),
      ],
    );

    return Table(children: [weekday, ...weeks]);
  }

  /// 月の日を週(月曜始まりの7要素)の配列へ並べる。日の入らない位置は0で表す。
  List<List<int>> _createCalendar(int year, int month) {
    final calendar = [List<int>.filled(DateTime.daysPerWeek, 0)];
    void fillCalendar(int day) {
      final weekday = DateTime(year, month, day).weekday;
      // DateTime.weekdayは1起点なので、配列の添字にするには1を引く
      calendar.last[weekday - 1] = day;
      if (weekday == DateTime.sunday) {
        calendar.add(List<int>.filled(DateTime.daysPerWeek, 0));
      }
    }

    final days = List.generate(
      DateUtils.getDaysInMonth(year, month),
      (index) => index + 1,
      growable: false,
    );
    days.forEach(fillCalendar);

    return calendar;
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.summary,
    required this.onTap,
  });

  final int day;
  final DailySummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(child: Text('$day')),
            Text(
              Formatter.simpleCurrency(summary.income),
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              Formatter.simpleCurrency(summary.expense),
              style: const TextStyle(color: Colors.orange),
            ),
            Text(
              Formatter.simpleCurrency(summary.transfer),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
