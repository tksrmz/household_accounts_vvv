import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/category.dart';
import '../../../domain/models/notebook.dart';
import '../firestore_shared/notebook_paths.dart';
import 'category_dto.dart';
import 'category_repository.dart';

// このRepositoryの単体テストは書かない。ドキュメント変換はcategory_dto_test.dartで
// 担保しており、Firestoreの購読そのものはフェイクでは検証にならないため
// integrationテストで担保する。

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository(this._db, this._notebook);

  final FirebaseFirestore _db;
  final Notebook _notebook;

  @override
  Stream<List<IncomeCategory>> watchIncomeCategories() =>
      // 名前順は旧実装(retrieveAllのorderBy('name'))の踏襲。ドキュメントID順に
      // すると選択肢の並びが実質ランダムになってしまう
      _collection('incomeCategories')
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => IncomeCategoryDto.fromSnapshot(doc).toDomain())
                .toList(),
          );

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() =>
      _collection('expenseCategories')
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ExpenseCategoryDto.fromSnapshot(doc).toDomain())
                .toList(),
          );

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _db.collection('${notebookPath(_notebook)}/$name');
}
