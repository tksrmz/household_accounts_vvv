import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';

import '../../use_case.dart';

class CategoryListState with ChangeNotifier {
  // States
  List<Category> _categories = [];
  bool _isLoading = false;
  Failure? _failure;

  // Use cases
  final RetrieveCategoriesUseCase _useCase;

  CategoryListState(this._useCase);

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

    final failureOrCategories = await _useCase.handle(NoParam());
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
}
