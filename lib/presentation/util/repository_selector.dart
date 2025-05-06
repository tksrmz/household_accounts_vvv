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
  print('$selectPropertyRepository($value)');
  final Repository<Property> repository;

  switch (value) {
    case SelectedNote.personal:
      print('$selectPropertyRepository: Select personal repository.');
      repository = sl<PersonalPropertyRepository>();
      break;

    case SelectedNote.shared:
      print('$selectPropertyRepository: Select shared repository.');
      repository = sl<SharedPropertyRepository>();
      break;
  }

  return repository;
}

Repository<IncomeCategory> selectIncomeCategoryRepository(SelectedNote value) {
  print('$selectPropertyRepository($value)');
  final Repository<IncomeCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      print('$selectPropertyRepository: Select personal income cateogy.');
      repository = sl<PersonalIncomeCategoryRepository>();
      break;

    case SelectedNote.shared:
      print('$selectPropertyRepository: Select shared income cateogy.');
      repository = sl<SharedIncomeCategoryRepository>();
      break;
  }

  return repository;
}

Repository<ExpenseCategory> selectExpenseCategoryRepository(
  SelectedNote value,
) {
  print('$selectPropertyRepository($value)');
  final Repository<ExpenseCategory> repository;

  switch (value) {
    case SelectedNote.personal:
      print('$selectPropertyRepository: Select personal expense cateogy.');
      repository = sl<PersonalExpenseCategoryRepository>();
      break;

    case SelectedNote.shared:
      print('$selectPropertyRepository: Select shared expense cateogy.');
      repository = sl<SharedExpenseCategoryRepository>();
      break;
  }

  return repository;
}

RecordRepository<IncomeRecord> selectIncomeRecordRepository(
  SelectedNote value,
) {
  print('selectIncomeRecordRepository($value)');
  final RecordRepository<IncomeRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      print('selectIncomeRecordRepository: Select personal income record.');
      repository = sl<PersonalIncomeRecordRepository>();
      break;

    case SelectedNote.shared:
      print('selectIncomeRecordRepository: Select shared  income record.');
      repository = sl<SharedIncomeRecordRepository>();
      break;
  }

  return repository;
}

RecordRepository<ExpenseRecord> selectExpenseRecordRepository(
  SelectedNote value,
) {
  print('selectExpenseRecordRepository($value)');
  final RecordRepository<ExpenseRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      print('selectExpenseRecordRepository: Select personal expense record.');
      repository = sl<PersonalExpenseRecordRepository>();
      break;

    case SelectedNote.shared:
      print('selectExpenseRecordRepository: Select shared  expense record.');
      repository = sl<SharedExpenseRecordRepository>();
      break;
  }

  return repository;
}

RecordRepository<TransferRecord> selectTransferRecordRepository(
  SelectedNote value,
) {
  print('selectTransferRecordRepository($value)');
  final RecordRepository<TransferRecord> repository;

  switch (value) {
    case SelectedNote.personal:
      print('selectTransferRecordRepository: Select personal transfer record.');
      repository = sl<PersonalTransferRecordRepository>();
      break;

    case SelectedNote.shared:
      print('selectTransferRecordRepository: Select shared  transfer record.');
      repository = sl<SharedTransferRecordRepository>();
      break;
  }

  return repository;
}
