import 'package:flutter/foundation.dart';

import '../../entity/category.dart';
import '../../entity/property.dart';
import '../../entity/record.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/property_repository.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/repository.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';

Repository<Property> selectPropertyRepository(SelectedNote value) {
  debugPrint('$selectPropertyRepository($value)');
  final Repository<Property> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint('$selectPropertyRepository: Select personal repository.');
      repository = sl<PersonalPropertyRepository>();
      break;

    case SelectedNote.shared:
      debugPrint('$selectPropertyRepository: Select shared repository.');
      repository = sl<SharedPropertyRepository>();
      break;
  }

  return repository;
}

Repository<IncomeCategory> selectIncomeCategoryRepository(SelectedNote value) {
  debugPrint('$selectPropertyRepository($value)');
  final Repository<IncomeCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint('$selectPropertyRepository: Select personal income cateogy.');
      repository = sl<PersonalIncomeCategoryRepository>();
      break;

    case SelectedNote.shared:
      debugPrint('$selectPropertyRepository: Select shared income cateogy.');
      repository = sl<SharedIncomeCategoryRepository>();
      break;
  }

  return repository;
}

Repository<ExpenseCategory> selectExpenseCategoryRepository(
  SelectedNote value,
) {
  debugPrint('$selectPropertyRepository($value)');
  final Repository<ExpenseCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint('$selectPropertyRepository: Select personal expense cateogy.');
      repository = sl<PersonalExpenseCategoryRepository>();
      break;

    case SelectedNote.shared:
      debugPrint('$selectPropertyRepository: Select shared expense cateogy.');
      repository = sl<SharedExpenseCategoryRepository>();
      break;
  }

  return repository;
}

RecordRepository<IncomeRecord> selectIncomeRecordRepository(
  SelectedNote value,
) {
  debugPrint('selectIncomeRecordRepository($value)');
  final RecordRepository<IncomeRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint(
        'selectIncomeRecordRepository: Select personal income record.',
      );
      repository = sl<PersonalIncomeRecordRepository>();
      break;

    case SelectedNote.shared:
      debugPrint('selectIncomeRecordRepository: Select shared  income record.');
      repository = sl<SharedIncomeRecordRepository>();
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

RecordRepository<TransferRecord> selectTransferRecordRepository(
  SelectedNote value,
) {
  debugPrint('selectTransferRecordRepository($value)');
  final RecordRepository<TransferRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      debugPrint(
        'selectTransferRecordRepository: Select personal transfer record.',
      );
      repository = sl<PersonalTransferRecordRepository>();
      break;

    case SelectedNote.shared:
      debugPrint(
        'selectTransferRecordRepository: Select shared  transfer record.',
      );
      repository = sl<SharedTransferRecordRepository>();
      break;
  }

  return repository;
}
