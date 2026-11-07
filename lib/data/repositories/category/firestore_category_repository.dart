import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/category_id.dart';
import '../../../domain/models/category_name.dart';
import '../../../domain/models/notebook.dart';
import '../../../utils/result.dart';
import '../firestore_shared/notebook_paths.dart';
import 'category_dto.dart';
import 'category_repository.dart';

// このRepositoryの単体テストは書かない。ドキュメント変換・書き込みJSONは
// category_dto_test.dartで担保しており、Firestoreの購読・書き込みそのものは
// フェイクでは検証にならないためintegrationテストで担保する。

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository(this._db, this._notebook);

  final FirebaseFirestore _db;
  final Notebook _notebook;

  @override
  Stream<List<IncomeCategory>> watchIncomeCategories() =>
      // 名前順は旧実装(retrieveAllのorderBy('name'))の踏襲。ドキュメントID順に
      // すると選択肢の並びが実質ランダムになってしまう
      _incomeCategories
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => IncomeCategoryDto.fromSnapshot(doc).toDomain())
                .toList(),
          );

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() => _expenseCategories
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ExpenseCategoryDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  @override
  Future<Result<void>> addIncomeCategory(CategoryName name) => Result.guard(
    () => _incomeCategories.add(incomeCategoryCreateJson(name: name)),
  );

  @override
  Future<Result<void>> addExpenseCategory({
    required CategoryName name,
    required Budget budget,
  }) => Result.guard(
    () => _expenseCategories.add(
      expenseCategoryCreateJson(name: name, budget: budget),
    ),
  );

  @override
  Future<Result<void>> updateIncomeCategory(
    CategoryId id, {
    required CategoryName name,
  }) => Result.guard(
    () => _incomeCategories
        .doc(id.value)
        .update(incomeCategoryUpdateJson(name: name)),
  );

  @override
  Future<Result<void>> updateExpenseCategory(
    CategoryId id, {
    CategoryName? name,
    Budget? budget,
  }) => Result.guard(
    () => _updateExpenseCategory(id, name: name, budget: budget),
  );

  // ArgumentErrorはExceptionではないためResult.guardに捕捉されず、
  // 呼び出し側の不具合としてそのまま伝播する(fail fast)。
  Future<void> _updateExpenseCategory(
    CategoryId id, {
    CategoryName? name,
    Budget? budget,
  }) {
    if (name == null && budget == null) {
      throw ArgumentError('nameとbudgetの少なくとも一方を指定してください');
    }
    return _expenseCategories
        .doc(id.value)
        .update(expenseCategoryUpdateJson(name: name, budget: budget));
  }

  @override
  Future<Result<void>> deleteIncomeCategory(CategoryId id) =>
      Result.guard(() => _incomeCategories.doc(id.value).delete());

  @override
  Future<Result<void>> deleteExpenseCategory(CategoryId id) =>
      Result.guard(() => _expenseCategories.doc(id.value).delete());

  CollectionReference<Map<String, dynamic>> get _incomeCategories =>
      _collection('incomeCategories');

  CollectionReference<Map<String, dynamic>> get _expenseCategories =>
      _collection('expenseCategories');

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _db.collection('${notebookPath(_notebook)}/$name');
}
