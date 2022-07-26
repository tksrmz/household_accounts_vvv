import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/update_category.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class CategoryPageState with ChangeNotifier {
  // States
  List<Category> _categories = [];
  bool _isLoading = false;
  Failure? _failure;

  // Use cases
  final RetrieveCategoriesUseCase _retrieveCategoriesUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;

  CategoryPageState(
    this._retrieveCategoriesUseCase,
    this._deleteCategoryUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
  );

  UnmodifiableListView<Category> get incomeCategories => UnmodifiableListView(
        _categories.where((element) => element.type == CategoryType.income),
      );

  UnmodifiableListView<Category> get expenseCategories => UnmodifiableListView(
        _categories.where((element) => element.type == CategoryType.expense),
      );

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Failure? get failure => _failure;

  Future<void> loadCategories() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrCategories =
        await _retrieveCategoriesUseCase.handle(NoParam());
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
    _failure = null;

    final failureOrUnit =
        await _deleteCategoryUseCase.handle(DeleteCategoryInput(id));
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _categories = [];
      },
      (_) {
        print('Delete property whose id is $id');
        _categories.removeWhere((element) => element.id == id);
      },
    );
    notifyListeners();
  }

  Future<void> addCategory(
    String name,
    CategoryType type,
    // String budgetString,
  ) async {
    _failure = null;

    // Add this code as TextField to input budget string is removed.
    // budgetString = '0';

    // FIXME: Validate [budgetString] before parsing it into int.
    // final budget = int.parse(budgetString);

    final failureOrProperty = await _addCategoryUseCase
        .handle(AddCategoryInput(name, type /*, budget*/));
    failureOrProperty.fold(
      (failure) {
        _failure = failure;
        _categories.clear();
      },
      (category) {
        print('Add ${category.toString()}');
        _categories.add(category);
      },
    );
    notifyListeners();
  }

  Future<void> updateCategory(
    String id,
    String newCategoryName,
    // String newBudgetString,
  ) async {
    _failure = null;

    final failureOrCategory = await _updateCategoryUseCase.handle(
      UpdateCategoryInput(
        id: id,
        newCategoryName: newCategoryName.isNotEmpty ? newCategoryName : null,
        // FIXME: Validate [budgetString] before parsing it into int.

        // Should budgetString validator returns null if it is empty?
        // Or return a Failure?
        // Returning a failure seems good, as Failure class is a general representation of errors in this application.
        // Let's consider passing empty string to the validator as an error.
        // newBudget:
        //     newBudgetString.isNotEmpty ? int.parse(newBudgetString) : null,
      ),
    );
    failureOrCategory.fold((failure) {
      _failure = failure;
      _categories.clear();
    }, (category) {
      print('Update ${category.toString()}');
      final index = _categories.indexWhere((element) => element.id == id);
      assert(index >= 0, '$id is not in the properties');
      _categories[index] = category;
    });
    notifyListeners();
  }
}

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
