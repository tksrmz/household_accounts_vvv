import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

/// Firestoreトランザクション操作を提供するサービス
class FirestoreTransactionService {
  final FirebaseFirestore _db;

  const FirestoreTransactionService(this._db);

  /// Firestoreトランザクションを実行する
  ///
  /// 複数のFirestore操作を原子的に実行する必要がある場合に使用する。
  /// 資産残高の更新と収入/支出/振替レコードの作成を同時に行う場合など。
  Future<Either<Exception, Unit>> executeTransaction(
    Future<void> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      await _db.runTransaction(transactionHandler);
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
