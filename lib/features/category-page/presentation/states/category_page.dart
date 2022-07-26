import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/update_category.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class IncomeCategoryListState with ChangeNotifier {
  // States
  List<IncomeCategory> _categories = [];
  bool _isLoading = false;
  Failure? _failure;

  // Use cases
  final RetrieveIncomeCategoriesUseCase _retrieveCategoriesUseCase;
  final DeleteIncomeCategoryUseCase _deleteCategoryUseCase;
  final AddCategoryUseCase2 _addCategoryUseCase;
  final UpdateIncomeCategoryUseCase _updateCategoryUseCase;

  IncomeCategoryListState(
    this._retrieveCategoriesUseCase,
    this._deleteCategoryUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
  );

  UnmodifiableListView<IncomeCategory> get categories =>
      UnmodifiableListView(_categories);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Failure? get failure => _failure;

  Future<void> loadState() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrCategories =
        await _retrieveCategoriesUseCase.handle(noparam);
    failureOrCategories.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
      },
      (categories) {
        _categories = categories;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final failureOrUnit =
        await _deleteCategoryUseCase.handle(DeleteIncomeCategoryInput(id));
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
        notifyListeners();
      },
      (_) {
        print('Delete property whose id is $id');
        _failure = null;
        loadState();
      },
    );
  }

  Future<void> addCategory(String name) async {
    final failureOrUnit = await _addCategoryUseCase.handle(
      AddCategoryInput2(
        name: name,
        type: CategoryType.income,
      ),
    );
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
        notifyListeners();
      },
      (_) {
        _failure = null;
        loadState();
      },
    );
  }

  Future<void> updateCategory(
      IncomeCategory original, String? newCategoryName) async {
    final failureOrCategory = await _updateCategoryUseCase.handle(
      UpdateIncomeCategoryInput(
        original: original,
        newName: newCategoryName,
      ),
    );
    failureOrCategory.fold((failure) {
      _failure = failure;
      _categories.clear();
      notifyListeners();
    }, (category) {
      _failure = null;
      loadState();
    });
  }
}

class ExpenseCategoryListState with ChangeNotifier {
  // States
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  Failure? _failure;

  // Use cases
  final RetrieveExpenseCategoriesUseCase _retrieveCategoriesUseCase;
  final DeleteExpenseCategoryUseCase _deleteCategoryUseCase;
  final AddCategoryUseCase2 _addCategoryUseCase;
  final UpdateExpenseCategoryUseCase _updateCategoryUseCase;

  ExpenseCategoryListState(
    this._retrieveCategoriesUseCase,
    this._deleteCategoryUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
  );

  UnmodifiableListView<ExpenseCategory> get categories =>
      UnmodifiableListView(_categories);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Failure? get failure => _failure;

  Future<void> loadState() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrCategories =
        await _retrieveCategoriesUseCase.handle(noparam);
    failureOrCategories.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
      },
      (categories) {
        _categories = categories;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final failureOrUnit =
        await _deleteCategoryUseCase.handle(DeleteExpenseCategoryInput(id));
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
        notifyListeners();
      },
      (_) {
        print('Delete property whose id is $id');
        _failure = null;
        loadState();
      },
    );
  }

  Future<void> addCategory(String name, int budgetAmount) async {
    final failureOrUnit = await _addCategoryUseCase.handle(
      AddCategoryInput2(
        name: name,
        type: CategoryType.expense,
        budgetAmount: budgetAmount,
      ),
    );
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
        notifyListeners();
      },
      (_) {
        _failure = null;
        loadState();
      },
    );
  }

  Future<void> updateCategory(
    ExpenseCategory original,
    String? newCategoryName,
    int? newBudget,
  ) async {
    final failureOrCategory = await _updateCategoryUseCase.handle(
      UpdateExpenseCategoryInput(
        original: original,
        newName: newCategoryName,
        newBudgetAmount: newBudget,
      ),
    );
    failureOrCategory.fold((failure) {
      _failure = failure;
      _categories.clear();
      notifyListeners();
    }, (category) {
      _failure = null;
      loadState();
    });
  }
}
