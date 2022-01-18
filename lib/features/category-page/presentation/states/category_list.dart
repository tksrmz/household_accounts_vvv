import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class CategoryListState with ChangeNotifier {
  // States
  List<Category> _categories = [];
  bool _isLoading = false;
  Failure? _failure;

  // Use cases
  final RetrieveCategoriesUseCase _retrieveCategoriesUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final AddCategoryUseCase _addCategoryUseCase;

  CategoryListState(
    this._retrieveCategoriesUseCase,
    this._deleteCategoryUseCase,
    this._addCategoryUseCase,
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

  Future<void> addCategory(String name, CategoryType type) async {
    _failure = null;

    final failureOrProperty =
        await _addCategoryUseCase.handle(AddCategoryInput(name, type));
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
}
