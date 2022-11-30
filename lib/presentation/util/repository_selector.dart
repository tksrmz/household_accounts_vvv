import '../../entity/category_entity.dart';
import '../../entity/property_entity.dart';
import '../../entity/record_entity.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/property_repository.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/repository.dart';
import '../../util/type/single_or_pair.dart';

Repository2<Property> selectPropertyRepository(SingleOrPair value) {
  print('$selectPropertyRepository($value)');
  final Repository2<Property> repository;

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

Repository2<IncomeCategory> selectIncomeCategoryRepository(SingleOrPair value) {
  print('$selectPropertyRepository($value)');
  final Repository2<IncomeCategory> repository;

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

Repository2<ExpenseCategory> selectExpenseCategoryRepository(
  SingleOrPair value,
) {
  print('$selectPropertyRepository($value)');
  final Repository2<ExpenseCategory> repository;

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

RecordRepository2<IncomeRecord2> selectIncomeRecordRepository(
  SingleOrPair value,
) {
  print('selectIncomeRecordRepository($value)');
  final RecordRepository2<IncomeRecord2> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectIncomeRecordRepository: Select personal income record.');
      repository = sl<PersonalIncomeRecordRepository2>();
      break;

    case SingleOrPair.pair:
      print('selectIncomeRecordRepository: Select shared  income record.');
      repository = sl<SharedIncomeRecordRepository2>();
      break;
  }

  return repository;
}

RecordRepository2<ExpenseRecord2> selectExpenseRecordRepository(
  SingleOrPair value,
) {
  print('selectExpenseRecordRepository($value)');
  final RecordRepository2<ExpenseRecord2> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectExpenseRecordRepository: Select personal expense record.');
      repository = sl<PersonalExpenseRecordRepository2>();
      break;

    case SingleOrPair.pair:
      print('selectExpenseRecordRepository: Select shared  expense record.');
      repository = sl<SharedExpenseRecordRepository2>();
      break;
  }

  return repository;
}

RecordRepository2<TransferRecord2> selectTransferRecordRepository(
  SingleOrPair value,
) {
  print('selectTransferRecordRepository($value)');
  final RecordRepository2<TransferRecord2> repository;

  switch (value) {
    case SingleOrPair.single:
      print('selectTransferRecordRepository: Select personal transfer record.');
      repository = sl<PersonalTransferRecordRepository2>();
      break;

    case SingleOrPair.pair:
      print('selectTransferRecordRepository: Select shared  transfer record.');
      repository = sl<SharedTransferRecordRepository2>();
      break;
  }

  return repository;
}
