import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/input-page/domain/use-cases/add_record.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/presentation/states/category_list.dart';
import 'package:household_accounts/util/string-parser.dart';

class InputPageState with ChangeNotifier {
  // States
  late CategoryListState _categoryListState;
  DateTime _dateOfRecord = DateTime.now();
  String _amount = '';
  String _note = '';
  String _categoryId = '';
  Failure? _failure;

  // Use cases
  final AddRecordUseCase _useCase;

  InputPageState(this._useCase);

  UnmodifiableListView<Category> get incomeCategories =>
      _categoryListState.incomeCategories;

  UnmodifiableListView<Category> get expenseCategories =>
      _categoryListState.expenseCategories;

  bool get isLoading => _categoryListState.isLoading;

  bool get hasFailure => _failure != null || _categoryListState.hasFailure;

  Failure? get failure => _failure ?? _categoryListState.failure;

  void _setFailureAndNotifyListeners(Failure? value) {
    _failure = value;
    notifyListeners();
  }

  set updateState(CategoryListState state) {
    _categoryListState = state;
    notifyListeners();
  }

  DateTime get dateOfRecord => _dateOfRecord;

  set dateOfRecord(DateTime value) {
    _dateOfRecord = value;
    notifyListeners();
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
    notifyListeners();
  }

  String get note => _note;

  set note(String value) {
    _note = value;
    notifyListeners();
  }

  String get categoryId => _categoryId;

  set categoryId(String value) {
    _categoryId = value;
    notifyListeners();
  }

  Future<void> submit() async {
    _amount.tryToInt().fold<void>(
      (failure) => _setFailureAndNotifyListeners(failure),
      (amount) async {
        final failureOrRecord = await _useCase.handle(AddRecordInput(
          _dateOfRecord,
          amount,
          _note,
          _categoryId,
        ));
        failureOrRecord.fold(
          (failure) => _setFailureAndNotifyListeners(failure),
          (_) => _deleteInputValues(),
        );
      },
    );
  }

  /// Delete user input values (amount, note).
  void _deleteInputValues() {
    _amount = '';
    _note = '';
    notifyListeners();
  }
}
