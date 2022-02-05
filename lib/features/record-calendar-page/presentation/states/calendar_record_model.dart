import 'package:flutter/material.dart';
import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_monthly_records.dart';

class CalendarRecordModel with ChangeNotifier {
  // States
  /// Current year.
  int _year;

  /// One of DateTime.january, ..., DateTime.december.
  int _month;

  /// Records in [_year]/[_month]
  List<Record> _records;

  /// Whether loading [_records] from a repository.
  bool _isLoading;

  // Use cases
  late final RetrieveMonthlyRecordsUseCase _useCase;

  CalendarRecordModel(this._useCase)
      : _year = DateTime.now().year,
        _month = DateTime.now().month,
        _records = List.empty(),
        _isLoading = false;

  int get year => _year;

  int get month => _month;

  bool get isLoading => _isLoading;

  void loadRecords() {
    _isLoading = true;
    notifyListeners();

    _useCase.handle(RetrieveMonthlyRecordsInput(_year, _month)).then((records) {
      _records = records;
      _isLoading = false;
      notifyListeners();
    }).onError((error, stackTrace) {
      _isLoading = false;
      notifyListeners();
      print(error);
    });
  }

  void incrementMonth() {
    final next = DateUtils.addMonthsToMonthDate(
      DateTime(_year, _month),
      1,
    );
    _year = next.year;
    _month = next.month;
    notifyListeners();
    loadRecords();
  }

  void decrementMonth() {
    final previous = DateUtils.addMonthsToMonthDate(
      DateTime(_year, _month),
      -1,
    );
    _year = previous.year;
    _month = previous.month;
    notifyListeners();
    loadRecords();
  }

  DailyRecordSummary recordAt(int day) {
    final int income = _records
        .where((element) =>
            element.recordType == RecordType.income &&
            element.dateOfRecord.day == day)
        .fold<int>(
            0, (previousValue, element) => previousValue + element.amount);
    final int expense = _records
        .where((element) =>
            element.recordType == RecordType.expense &&
            element.dateOfRecord.day == day)
        .fold<int>(
            0, (previousValue, element) => previousValue + element.amount);

    return DailyRecordSummary(_year, _month, day, income, expense);
  }
}

class DailyRecordSummary {
  final int _year;
  final int _month;
  final int _day;
  final int _totalIncome;
  final int _totalExpense;

  DailyRecordSummary(this._year, this._month, this._day, this._totalIncome,
      this._totalExpense);

  int get year => _year;

  int get month => _month;

  int get day => _day;

  int get totalIncome => _totalIncome;

  int get totalExpense => _totalExpense;
}
