import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_record_service.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart'
    as data_model;

import '../../../domain/models/expense_record.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';

class FirestorePersonalExpenseRepository implements ExpenseRepository {
  const FirestorePersonalExpenseRepository(
    this._personalExpenseRecordService,
    this._uid,
  );

  final PersonalExpenseRecordService _personalExpenseRecordService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date) async {
    final result = await _personalExpenseRecordService.fetchByDate(
      _uid,
      date.year,
      date.month,
    );
    ExpenseVo createExpenseVo(data_model.ExpenseRecordModel record) =>
        ExpenseVo(record.amount);
    List<ExpenseVo> convertToExpenseVoList(
            List<data_model.ExpenseRecordModel> expenseList) =>
        expenseList.map(createExpenseVo).toList(growable: false);
    return result.map(convertToExpenseVoList);
  }

  @override
  Future<Either<Exception, Unit>> add(ExpenseRecordModel record) async {
    final model = data_model.ExpenseRecordModel(
      id: record.id.value,
      date: record.recordDate.value,
      amount: record.amount.value,
      note: record.note.value,
      hasCheckedOut: record.hasCheckedOut,
      createdAt: DateTime.now(),
      property: {
        'ref':
            '/personalNotes/${_uid.value}/properties/${record.property.id.value}'
      },
      category: {
        'ref':
            '/personalNotes/${_uid.value}/expenseCategories/${record.category.id.value}'
      },
    );
    return _personalExpenseRecordService.add(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    return _personalExpenseRecordService.delete(_uid, id.value);
  }
}
