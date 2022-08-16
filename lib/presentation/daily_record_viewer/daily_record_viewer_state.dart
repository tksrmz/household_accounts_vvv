import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_use_case.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_daily_records_use_case.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/type/use_case.dart';

class DailyRecordModel with ChangeNotifier {
  // States
  /// Records
  List<Record> _records;

  /// Categories
  List<IncomeCategory> _incomeCategories;
  List<ExpenseCategory> _expenseCategories;

  /// Whether loading [_records] from a repository.
  bool _isLoading;

  /// Failure that will happen when connect to DB.
  Failure? _failure;

  // Use cases
  late final RetrieveDailyRecordsUseCase _retrieve;
  late final DeleteRecordUseCaseNew _delete;
  late final RetrieveIncomeCategoriesUseCase _retrieveIncomeCategoriesUseCase;
  late final RetrieveExpenseCategoriesUseCase _retrieveExpenseCategoriesUseCase;

  DailyRecordModel(
    this._retrieve,
    this._delete,
    this._retrieveIncomeCategoriesUseCase,
    this._retrieveExpenseCategoriesUseCase,
  )   : _records = List.empty(),
        _incomeCategories = List.empty(),
        _expenseCategories = List.empty(),
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

    final failureOrIncomeCategories =
        await _retrieveIncomeCategoriesUseCase.handle(noparam);
    failureOrIncomeCategories.fold(
      (failure) => _failure = failure,
      (categories) => _incomeCategories = categories,
    );
    final failureOrExpenseCategories =
        await _retrieveExpenseCategoriesUseCase.handle(noparam);
    failureOrExpenseCategories.fold(
      (failure) => _failure = failure,
      (categories) => _expenseCategories = categories,
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
      final index = _incomeCategories.indexWhere(
        (category) => category.id == record.categoryId,
      );
      return index >= 0
          ? _incomeCategories[index].name
          : categoryNameWhenFailed;
    }
    if (record is ExpenseRecord) {
      final index = _expenseCategories.indexWhere(
        (category) => category.id == record.categoryId,
      );
      return index >= 0
          ? _expenseCategories[index].name
          : categoryNameWhenFailed;
    }
    if (record is TransferRecord) {
      return 'Transfer';
    }
    return categoryNameWhenFailed;
  }
}
