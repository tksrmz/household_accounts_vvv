import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/record_use_case.dart';
import 'package:household_accounts/use_case/retrieve_daily_records.dart';

class DailyRecordModel with ChangeNotifier {
  // States
  /// Records
  List<Record> _records;

  /// Whether loading [_records] from a repository.
  bool _isLoading;

  // Use cases
  late final RetrieveDailyRecordsUseCase _retrieve;
  late final RecordDeleteUseCase _delete;

  DailyRecordModel(this._retrieve, this._delete)
      : _records = List.empty(),
        _isLoading = false;

  bool get isLoading => _isLoading;

  UnmodifiableListView get incomes => UnmodifiableListView(
      _records.where((element) => element.recordType == RecordType.income));

  UnmodifiableListView get expenses => UnmodifiableListView(
      _records.where((element) => element.recordType == RecordType.expense));

  void loadRecords(int year, int month, int day) {
    _isLoading = true;
    notifyListeners();

    _retrieve.handle(RetrieveDailyRecordsInput(year, month, day)).then(
      (records) {
        _records = records;
        _isLoading = false;
        notifyListeners();
      },
    ).onError(
      (error, stackTrace) {
        _isLoading = false;
        notifyListeners();
        print(error);
      },
    );
  }

  void deleteById(String id) {
    _records.removeWhere((element) => element.id == id);
    notifyListeners();
    _delete.deleteById(id);
  }
}
