import 'dart:collection';

import 'package:flutter/material.dart';

import '../../entity/category.dart';
import '../../feature/category_retrieve/retrieve_expense_category_use_case.dart';
import '../../feature/category_retrieve/retrieve_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class IncomeCategoryListState with ChangeNotifier {
  // States
  List<IncomeCategory> _categories = [];
  bool _isLoading = false;
  Exception? _failure;

  UnmodifiableListView<IncomeCategory> get categories =>
      UnmodifiableListView(_categories);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Exception? get failure => _failure;

  Future<void> fetch({
    required SelectedNote singleOrPair,
    required UserInfo userInfo,
  }) async {
    debugPrint(
      '$IncomeCategoryListState#$fetch(${singleOrPair.name}, $userInfo)',
    );
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final retrieve = sl<RetrieveIncomeCategoryUseCase>();
    final failureOrCategories = await retrieve(
      RetrieveIncomeCategoryInput(
        uid: userInfo.repoId(singleOrPair),
        repository: selectIncomeCategoryRepository(singleOrPair),
      ),
    );
    failureOrCategories.fold(
      (failure) {
        debugPrint(
          '$IncomeCategoryListState#$fetch: retrieve use case failed. $_failure',
        );
        _failure = failure;
        _categories = [];
      },
      (categories) {
        debugPrint(
          '$IncomeCategoryListState#$fetch: retrieve use case succeeded.',
        );
        _categories = categories;
      },
    );
    _isLoading = false;
    notifyListeners();
  }
}

class ExpenseCategoryListState with ChangeNotifier {
  // States
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  Exception? _failure;

  UnmodifiableListView<ExpenseCategory> get categories =>
      UnmodifiableListView(_categories);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Exception? get failure => _failure;

  Future<void> fetch({
    required SelectedNote singleOrPair,
    required UserInfo userInfo,
  }) async {
    debugPrint(
      '$ExpenseCategoryListState#$fetch(${singleOrPair.name}, $userInfo)',
    );
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final retrieve = sl<RetrieveExpenseCategoryUseCase>();
    final failureOrCategories = await retrieve(
      RetrieveExpenseCategoryInput(
        uid: userInfo.repoId(singleOrPair),
        repository: selectExpenseCategoryRepository(singleOrPair),
      ),
    );
    failureOrCategories.fold(
      (failure) {
        debugPrint(
          '$ExpenseCategoryListState#$fetch: retrieve use case failed. $_failure',
        );
        _failure = failure;
        _categories = [];
      },
      (categories) {
        debugPrint(
          '$ExpenseCategoryListState#$fetch: retrieve use case succeeded.',
        );
        _categories = categories;
      },
    );
    _isLoading = false;
    notifyListeners();
  }
}
