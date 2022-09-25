import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/category_deletion/delete_category_use_case.dart';
import 'package:household_accounts/feature/category_editing/update_category_use_case.dart';
import 'package:household_accounts/feature/category_register/category_register_use_case.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';

class IncomeCategoryListState with ChangeNotifier {
  // States
  List<IncomeCategory> _categories = [];
  bool _isLoading = false;
  Exception? _failure;

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

  Exception? get failure => _failure;

  Future<void> loadState() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrCategories = await _retrieveCategoriesUseCase(unit);
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
        await _deleteCategoryUseCase(DeleteIncomeCategoryInput(id));
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
    final failureOrUnit = await _addCategoryUseCase(
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
    final failureOrCategory = await _updateCategoryUseCase(
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
  Exception? _failure;

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

  Exception? get failure => _failure;

  Future<void> loadState() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrCategories = await _retrieveCategoriesUseCase(unit);
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
        await _deleteCategoryUseCase(DeleteExpenseCategoryInput(id));
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
    final failureOrUnit = await _addCategoryUseCase(
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
    final failureOrCategory = await _updateCategoryUseCase(
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
