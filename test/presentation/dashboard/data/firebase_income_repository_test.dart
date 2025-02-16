import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/data/firebase_income_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference>(),
  MockSpec<DocumentReference>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<Query>(),
])
import 'firebase_income_repository_test.mocks.dart';

void main() {
  test('fetchMonthlyで指定された月の収入一覧を取得できる', () async {
    final mockFirebaseFirestore = MockFirebaseFirestore();

    final sut = FirebaseIncomeRepository(mockFirebaseFirestore);
    final incomeList = await sut.fetchMonthly(DateTime(2025, 1));

    expect(incomeList, hasLength(1));
    expect(incomeList[0], Income(100));
  });

  // Firebaseのモックをどう使えばいいかのメモ
  group('Firestore Mock Tests', () {
    MockFirebaseFirestore mockFirestore;
    MockCollectionReference<Map<String, dynamic>> mockCollection;
    MockDocumentReference<Map<String, dynamic>> mockDocument;
    MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    test('Test Firestore get document', () async {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocument = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();

      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

      final documentSnapshot =
          await mockFirestore.collection('users').doc('123').get();

      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollection.doc('123')).called(1);
      expect(documentSnapshot, isA<DocumentSnapshot>());
    });
  });
}
