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
      // orderByは付けない: 旧実装もクエリの既定順(ドキュメントID順)のまま
      // 扱っており、挙動変更を増やさないため踏襲する。
      _collection('incomeCategories').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => IncomeCategoryDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() =>
      _collection('expenseCategories').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ExpenseCategoryDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _db.collection('${notebookPath(_notebook)}/$name');
}
