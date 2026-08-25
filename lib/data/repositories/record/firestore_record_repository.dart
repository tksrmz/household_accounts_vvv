import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/notebook.dart';
import '../../../domain/models/period.dart';
import '../../../domain/models/record.dart';
import '../../../utils/combine_latest.dart';
import '../firestore_shared/notebook_paths.dart';
import 'record_dto.dart';
import 'record_repository.dart';

// このRepositoryの単体テストは書かない。パス解決は notebook_paths_test.dart、
// ドキュメント変換は record_dto_test.dart でそれぞれ担保しており、
// 3コレクションの結合はcombine_latest_test.dartで担保済みの combineLatest3 を
// そのまま使っているだけである。期間フィルタ(where句)の実効性はFirestoreの
// クエリ実行そのものが対象であり、フェイクでは検証にならないため、
// integrationテストで担保する。

class FirestoreRecordRepository implements RecordRepository {
  FirestoreRecordRepository(this._db, this._notebook);

  final FirebaseFirestore _db;
  final Notebook _notebook;

  @override
  Stream<List<Record>> watchPeriod(Period period) => combineLatest3(
    _watchIncomes(period),
    _watchExpenses(period),
    _watchTransfers(period),
    (incomes, expenses, transfers) =>
        [...incomes, ...expenses, ...transfers]
          ..sort((a, b) => a.date.value.compareTo(b.date.value)),
  );

  Stream<List<Record>> _watchIncomes(Period period) =>
      _rangeQuery('incomes', period).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => IncomeRecordDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  Stream<List<Record>> _watchExpenses(Period period) =>
      _rangeQuery('expenses', period).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ExpenseRecordDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  Stream<List<Record>> _watchTransfers(Period period) =>
      _rangeQuery('transfers', period).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => TransferRecordDto.fromSnapshot(doc).toDomain())
            .toList(),
      );

  Query<Map<String, dynamic>> _rangeQuery(String collection, Period period) {
    return _db
        .collection('${notebookPath(_notebook)}/$collection')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(period.start))
        .where('date', isLessThan: Timestamp.fromDate(period.end));
  }
}
