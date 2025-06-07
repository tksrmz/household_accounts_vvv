import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';

import '../../../domain/models/expense_record.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';

class FirestorePersonalExpenseRepository implements ExpenseRepository {
  const FirestorePersonalExpenseRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date) async {
    final result = await _firestoreService.fetchAllPersonalExpensesOf(
      _uid,
      date.year,
      date.month,
    );
    final createExpenseVo =
        (Map<String, dynamic> doc) => ExpenseVo(doc['amount']!);
    final convertToExpenseVoList = (List<Map<String, dynamic>> expenseList) =>
        expenseList.map(createExpenseVo).toList(growable: false);
    return result.map(convertToExpenseVoList);
  }

  @override
  Future<Either<Exception, Unit>> add(ExpenseRecordVo record) async {
    final model = ExpenseRecordModel(
      id: record.id.value,
      date: record.recordDate.value,
      amount: record.amount.value,
      note: record.note.value,
      hasCheckedOut: record.hasCheckedOut,
      createdAt: DateTime.now(),
      property: {'ref': '/personalNotes/${_uid.value}/properties/${record.property.id.value}'},
      category: {'ref': '/personalNotes/${_uid.value}/expenseCategories/${record.category.id.value}'},
    );
    return _firestoreService.addPersonalExpense(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    return _firestoreService.deletePersonalExpense(_uid, id.value);
  }
}
