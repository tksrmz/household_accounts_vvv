import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_daily_records.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class DailyRecordModel with ChangeNotifier {
  // States
  /// Records
  List<Record> _records;

  /// Categories
  List<Category> _categories;

  /// Whether loading [_records] from a repository.
  bool _isLoading;

  /// Failure that will happen when connect to DB.
  Failure? _failure;

  // Use cases
  late final RetrieveDailyRecordsUseCase _retrieve;
  late final DeleteRecordUseCaseNew _delete;
  late final RetrieveCategoriesUseCase _retrieveCategoriesUseCase;

  DailyRecordModel(
    this._retrieve,
    this._delete,
    this._retrieveCategoriesUseCase,
  )   : _records = List.empty(),
        _categories = List.empty(),
        _isLoading = false;

  bool get isLoading => _isLoading;

  UnmodifiableListView get incomes => UnmodifiableListView(
      _records.where((element) => element.type == RecordType.income));

  UnmodifiableListView get expenses => UnmodifiableListView(
      _records.where((element) => element.type == RecordType.expense));

  UnmodifiableListView get transfer => UnmodifiableListView(
      _records.where((element) => element.type == RecordType.transfer));

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

  Future<void> loadCategories() async {
    _failure = null;
    _isLoading = true;
    notifyListeners();

    final failureOrCategories =
        await _retrieveCategoriesUseCase.handle(const NoParam());
    failureOrCategories.fold(
      (failure) => _failure = failure,
      (categories) => _categories = categories,
    );
    _isLoading = false;
    notifyListeners();
  }

  void deleteById(String id, RecordType type) {
    _records.removeWhere((element) => element.id == id);
    notifyListeners();
    _delete.handle(DeleteRecordInputNew(id, type));
  }

  String categoryNameOf(Record record) {
    const categoryNameWhenFailed = 'Not found';
    if (record is IncomeRecord) {
      final index = _categories.indexWhere(
        (category) => category.id == record.categoryId,
      );
      return index >= 0 ? _categories[index].name : categoryNameWhenFailed;
    }
    if (record is ExpenseRecord) {
      final index = _categories.indexWhere(
        (category) => category.id == record.categoryId,
      );
      return index >= 0 ? _categories[index].name : categoryNameWhenFailed;
    }
    if (record is TransferRecord) {
      return 'Transfer';
    }
    return categoryNameWhenFailed;
  }
}
