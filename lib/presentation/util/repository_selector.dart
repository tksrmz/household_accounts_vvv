import 'package:flutter/foundation.dart';

import '../../entity/category.dart';
import '../../entity/record.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/repository.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';

Repository<IncomeCategory> selectIncomeCategoryRepository(SelectedNote value) {
  debugPrint('selectIncomeCategoryRepository($value)');
  final Repository<IncomeCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint(
        'selectIncomeCategoryRepository: Select personal income cateogy.',
      );
      repository = sl<PersonalIncomeCategoryRepository>();
      break;

    case SelectedNote.shared:
      debugPrint(
        'selectIncomeCategoryRepository: Select shared income cateogy.',
      );
      repository = sl<SharedIncomeCategoryRepository>();
      break;
  }

  return repository;
}

Repository<ExpenseCategory> selectExpenseCategoryRepository(
  SelectedNote value,
) {
  debugPrint('selectExpenseCategoryRepository($value)');
  final Repository<ExpenseCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint(
        'selectExpenseCategoryRepository: Select personal expense cateogy.',
      );
      repository = sl<PersonalExpenseCategoryRepository>();
      break;

    case SelectedNote.shared:
      debugPrint(
        'selectExpenseCategoryRepository: Select shared expense cateogy.',
      );
      repository = sl<SharedExpenseCategoryRepository>();
      break;
  }

  return repository;
}

RecordRepository<ExpenseRecord> selectExpenseRecordRepository(
  SelectedNote value,
) {
  debugPrint('selectExpenseRecordRepository($value)');
  final RecordRepository<ExpenseRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint(
        'selectExpenseRecordRepository: Select personal expense record.',
      );
      repository = sl<PersonalExpenseRecordRepository>();
      break;

    case SelectedNote.shared:
      debugPrint(
        'selectExpenseRecordRepository: Select shared  expense record.',
      );
      repository = sl<SharedExpenseRecordRepository>();
      break;
  }

  return repository;
}
