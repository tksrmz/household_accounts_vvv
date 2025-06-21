import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/v2/data/services/firestore/transaction/firestore_transaction_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
])
import 'firestore_transaction_service_test.mocks.dart';

void main() {
  group('FirestoreTransactionService', () {
    test('トランザクションの実行が正常に動作することを確認', () async {
      // Arrange
      final mockDb = MockFirebaseFirestore();
      when(mockDb.runTransaction(any)).thenAnswer((_) async => null);

      final target = FirestoreTransactionService(mockDb);
      Future<void> transactionHandler(Transaction transaction) async {
        // Mock transaction handler
      }

      // Act
      final result = await target.executeTransaction(transactionHandler);

      // Assert
      verify(mockDb.runTransaction(any)).called(1);
      expect(result.isRight(), isTrue);
    });

    test('例外が発生した場合、Leftを返す', () async {
      // Arrange
      final mockDb = MockFirebaseFirestore();
      when(mockDb.runTransaction(any)).thenThrow(Exception('test error'));

      final target = FirestoreTransactionService(mockDb);
      Future<void> transactionHandler(Transaction transaction) async {
        // Mock transaction handler
      }

      // Act
      final result = await target.executeTransaction(transactionHandler);

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });
}