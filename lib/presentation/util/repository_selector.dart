import '../../entity/category.dart';
import '../../entity/property.dart';
import '../../entity/record.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/property_repository.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/repository.dart';
import '../../util/type/single_or_pair.dart';

Repository<Property> selectPropertyRepository(SingleOrPair value) {
  print('$selectPropertyRepository($value)');
  final Repository<Property> repository;

  switch (value) {
    case SingleOrPair.single:
      print('$selectPropertyRepository: Select personal repository.');
      repository = sl<PersonalPropertyRepository>();
      break;

    case SingleOrPair.pair:
      print('$selectPropertyRepository: Select shared repository.');
      repository = sl<SharedPropertyRepository>();
      break;
  }

  return repository;
}

Repository<IncomeCategory> selectIncomeCategoryRepository(SingleOrPair value) {
  print('$selectPropertyRepository($value)');
  final Repository<IncomeCategory> repository;

  switch (value) {
    case SingleOrPair.single:
      print('$selectPropertyRepository: Select personal income cateogy.');
      repository = sl<PersonalIncomeCategoryRepository>();
      break;

    case SingleOrPair.pair:
      print('$selectPropertyRepository: Select shared income cateogy.');
      repository = sl<SharedIncomeCategoryRepository>();
      break;
  }

  return repository;
}

Repository<ExpenseCategory> selectExpenseCategoryRepository(
  SingleOrPair value,
) {
  print('$selectPropertyRepository($value)');
  final Repository<ExpenseCategory> repository;

  switch (value) {
    case SingleOrPair.single:
      print('$selectPropertyRepository: Select personal expense cateogy.');
      repository = sl<PersonalExpenseCategoryRepository>();
      break;

    case SingleOrPair.pair:
      print('$selectPropertyRepository: Select shared expense cateogy.');
      repository = sl<SharedExpenseCategoryRepository>();
      break;
  }

  return repository;
}

RecordRepository<IncomeRecord> selectIncomeRecordRepository(
  SingleOrPair value,
) {
  print('selectIncomeRecordRepository($value)');
  final RecordRepository<IncomeRecord> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectIncomeRecordRepository: Select personal income record.');
      repository = sl<PersonalIncomeRecordRepository>();
      break;

    case SingleOrPair.pair:
      print('selectIncomeRecordRepository: Select shared  income record.');
      repository = sl<SharedIncomeRecordRepository>();
      break;
  }

  return repository;
}

RecordRepository<ExpenseRecord> selectExpenseRecordRepository(
  SingleOrPair value,
) {
  print('selectExpenseRecordRepository($value)');
  final RecordRepository<ExpenseRecord> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectExpenseRecordRepository: Select personal expense record.');
      repository = sl<PersonalExpenseRecordRepository>();
      break;

    case SingleOrPair.pair:
      print('selectExpenseRecordRepository: Select shared  expense record.');
      repository = sl<SharedExpenseRecordRepository>();
      break;
  }

  return repository;
}

RecordRepository<TransferRecord> selectTransferRecordRepository(
  SingleOrPair value,
) {
  print('selectTransferRecordRepository($value)');
  final RecordRepository<TransferRecord> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectTransferRecordRepository: Select personal transfer record.');
      repository = sl<PersonalTransferRecordRepository>();
      break;

    case SingleOrPair.pair:
      print('selectTransferRecordRepository: Select shared  transfer record.');
      repository = sl<SharedTransferRecordRepository>();
      break;
  }

  return repository;
}
