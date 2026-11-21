import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/notebook.dart';
import '../../../domain/models/period.dart';
import '../../../domain/models/record.dart';
import '../../../domain/models/record_content.dart';
import '../../../utils/combine_latest.dart';
import '../../../utils/result.dart';
import '../firestore_shared/notebook_paths.dart';
import 'record_dto.dart';
import 'record_repository.dart';

// watchPeriodの単体テストは書かない。パス解決は notebook_paths_test.dart、
// ドキュメント変換は record_dto_test.dart でそれぞれ担保しており、
// 3コレクションの結合はcombine_latest_test.dartで担保済みの combineLatest3 を
// そのまま使っているだけである。期間フィルタ(where句)の実効性はFirestoreの
// クエリ実行そのものが対象であり、フェイクでは検証にならないため、
// integrationテストで担保する。addの書き込みJSONの組み立てはrecord_dto_test.dartで
// 担保しており、書き込みの実効性(Rules適合・残高増減)もintegrationテストで担保する。
// deleteも同様に、打ち消し量の算出は record_test.dart(RecordContent.balanceEffects)、
// 再読ドキュメントの変換は record_dto_test.dart で担保し、トランザクションの
// 実効性(原子性・資産消失時のスキップ)はintegrationテストで担保する。

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

  @override
  Future<Result<void>> add(RecordContent record) =>
      Result.guard(() => _add(record));

  @override
  Future<Result<void>> delete(Record record) =>
      Result.guard(() => _delete(record));

  // WriteBatchを使う理由: addは読み取りを伴わないため、原子性の面では
  // トランザクションと同等である。その上でバッチはオフライン時もローカルへ
  // 即時適用され、オンライン復帰時にサーバーへ同期される(トランザクションは
  // オフラインでは即座に失敗する)。存在しない資産へのupdateはバッチ全体を
  // 失敗させるため、参照整合性(資産が存在すること)もこの原子性の中で保たれる。
  Future<void> _add(RecordContent record) async {
    final batch = _db.batch();
    final (collectionName, json) = switch (record) {
      IncomeRecordContent() => (
        'incomes',
        incomeRecordJson(
          record: record,
          categoryRef: _collection(
            'incomeCategories',
          ).doc(record.categoryId.value),
          propertyRef: _collection('properties').doc(record.propertyId.value),
        ),
      ),
      ExpenseRecordContent() => (
        'expenses',
        expenseRecordJson(
          record: record,
          categoryRef: _collection(
            'expenseCategories',
          ).doc(record.categoryId.value),
          propertyRef: _collection('properties').doc(record.propertyId.value),
        ),
      ),
      TransferRecordContent() => (
        'transfers',
        transferRecordJson(
          record: record,
          fromPropertyRef: _collection(
            'properties',
          ).doc(record.fromPropertyId.value),
          toPropertyRef: _collection(
            'properties',
          ).doc(record.toPropertyId.value),
        ),
      ),
    };
    batch.set(_collection(collectionName).doc(), json);
    for (final effect in record.balanceEffects) {
      batch.update(_collection('properties').doc(effect.propertyId.value), {
        'amount': FieldValue.increment(effect.delta),
      });
    }
    await batch.commit();
  }

  // runTransactionを使う理由: 打ち消す残高は保存されているレコードの再読値を
  // 正とするため、読み取りと書き込みを一体で行う必要がある(読み取りを伴わない
  // addはWriteBatch)。読み取ったドキュメントが確定までの間に変更された場合、
  // トランザクションは自動で再試行される。
  Future<void> _delete(Record record) async {
    final (collectionName, toDomain) = switch (record) {
      IncomeRecord() => (
        'incomes',
        (String id, Map<String, dynamic> data) =>
            IncomeRecordDto.fromData(id, data).toDomain(),
      ),
      ExpenseRecord() => (
        'expenses',
        (String id, Map<String, dynamic> data) =>
            ExpenseRecordDto.fromData(id, data).toDomain(),
      ),
      TransferRecord() => (
        'transfers',
        (String id, Map<String, dynamic> data) =>
            TransferRecordDto.fromData(id, data).toDomain(),
      ),
    };
    final recordRef = _collection(collectionName).doc(record.id.value);

    await _db.runTransaction((transaction) async {
      final data = (await transaction.get(recordRef)).data();
      if (data == null) {
        return;
      }

      // 打ち消し量は引数のrecordではなく再読したドキュメントから求める。
      // 引数が古い内容を保持していても残高がずれないようにするため。
      // 打ち消しは無条件に行う。記録は作成と同時に残高へ反映されるため。
      // 旧フィールドhasCheckedOutがfalse(残高へ未反映)の記録は本番に1件も
      // 無いことを確かめたうえで、このフィールドを廃止した。
      final effects = toDomain(recordRef.id, data).content.balanceEffects;

      // 資産の存在確認は読み取りであり、Firestoreのトランザクションは
      // すべての読み取りを書き込みより前に行う必要があるため、打ち消しの
      // updateとレコードのdeleteより先にまとめて済ませる。
      final increments =
          <({DocumentReference<Map<String, dynamic>> ref, int delta})>[];
      for (final effect in effects) {
        final propertyRef = _collection(
          'properties',
        ).doc(effect.propertyId.value);
        // 参照先の資産が既に削除されている場合、その打ち消しは行えない。
        // レコードだけが消せずに残り続けるほうが害が大きいためスキップする。
        if ((await transaction.get(propertyRef)).exists) {
          increments.add((ref: propertyRef, delta: -effect.delta));
        }
      }

      for (final increment in increments) {
        transaction.update(increment.ref, {
          'amount': FieldValue.increment(increment.delta),
        });
      }
      transaction.delete(recordRef);
    });
  }

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
    return _collection(collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(period.start))
        .where('date', isLessThan: Timestamp.fromDate(period.end));
  }

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _db.collection('${notebookPath(_notebook)}/$name');
}
