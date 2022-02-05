import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_daily_records.dart';
import 'package:household_accounts/util/failures/failure.dart';

class DailyRecordModel with ChangeNotifier {
  // States
  /// Records
  List<Record> _records;

  /// Whether loading [_records] from a repository.
  bool _isLoading;

  /// Failure that will happen when connect to DB.
  Failure? _failure;

  // Use cases
  late final RetrieveDailyRecordsUseCase _retrieve;
  late final DeleteRecordUseCase _delete;

  DailyRecordModel(this._retrieve, this._delete)
      : _records = List.empty(),
        _isLoading = false;

  bool get isLoading => _isLoading;

  UnmodifiableListView get incomes => UnmodifiableListView(
      _records.where((element) => element.type == RecordType.income));

  UnmodifiableListView get expenses => UnmodifiableListView(
      _records.where((element) => element.type == RecordType.expense));

  bool get hasFailure => _failure != null;

  Failure? get failure => _failure;

  Future<void> loadRecords(int year, int month, int day) async {
    _failure = null;
    _isLoading = true;
    notifyListeners();

    final failureOrRecords =
        await _retrieve.handle(RetrieveDailyRecordsInput(year, month, day));
    failureOrRecords.fold(
        (failure) => _failure = failure, (records) => _records = records);
    _isLoading = false;
    notifyListeners();
  }

  void deleteById(String id) {
    _records.removeWhere((element) => element.id == id);
    notifyListeners();
    _delete.handle(DeleteRecordInput(id));
  }
}
