import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_record_service.dart';
import 'package:household_accounts/v2/data/models/income_record_model.dart' as data_model;
import 'package:household_accounts/v2/domain/models/vo/income.dart';

import '../../../domain/models/income_record.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';

class FirestorePersonalIncomeRepository implements IncomeRepository {
  const FirestorePersonalIncomeRepository(
    this._personalIncomeRecordService,
    this._uid,
  );

  final PersonalIncomeRecordService _personalIncomeRecordService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    final result = await _personalIncomeRecordService.fetchPersonalIncomes(
      _uid,
      date.year,
      date.month,
    );
    final createIncomeVo =
        (data_model.IncomeRecordModel record) => IncomeVo(record.amount);
    final convertToIncomeVoList = (List<data_model.IncomeRecordModel> incomeList) =>
        incomeList.map(createIncomeVo).toList(growable: false);
    return result.map(convertToIncomeVoList);
  }

  @override
  Future<Either<Exception, Unit>> add(IncomeRecordModel record) async {
    final model = data_model.IncomeRecordModel(
      id: record.id.value,
      date: record.recordDate.value,
      amount: record.amount.value,
      note: record.note.value,
      hasCheckedOut: record.hasCheckedOut,
      createdAt: DateTime.now(),
      property: {'ref': '/personalNotes/${_uid.value}/properties/${record.property.id.value}'},
      category: {'ref': '/personalNotes/${_uid.value}/incomeCategories/${record.category.id.value}'},
    );
    return _personalIncomeRecordService.addPersonalIncome(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    return _personalIncomeRecordService.deletePersonalIncome(_uid, id.value);
  }
}
