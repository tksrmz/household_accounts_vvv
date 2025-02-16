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
  MockSpec<QuerySnapshot>(),
  MockSpec<QueryDocumentSnapshot>(),
])
import 'firebase_income_repository_test.mocks.dart';

void main() {
  test('fetchMonthlyで指定された月の収入一覧を取得できる', () async {
    final mockDb = MockFirebaseFirestore();
    final mockCollectionReference =
        MockCollectionReference<Map<String, dynamic>>();
    final mockQuery = MockQuery<Map<String, dynamic>>();
    final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    final mockQueryDocumentSnapshot =
        MockQueryDocumentSnapshot<Map<String, dynamic>>();

    when(mockDb.collection('hoge')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.where(
      'date',
      isGreaterThanOrEqualTo: DateTime(2025, 1),
    )).thenReturn(mockQuery);
    when(mockQuery.where(
      'date',
      isLessThan: DateTime(2025, 2),
    )).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
    when(mockQueryDocumentSnapshot.data()).thenReturn({'amount': 100});

    final sut = FirebaseIncomeRepository(mockDb);
    final incomeList = await sut.fetchMonthly(DateTime(2025, 1));

    verify(mockDb.collection('hoge')).called(1);
    // 日付の下限
    verify(mockCollectionReference.where(
      'date',
      isGreaterThanOrEqualTo: DateTime(2025, 1),
    )).called(1);
    // 日付の上限
    verify(mockQuery.where(
      'date',
      isLessThan: DateTime(2025, 2),
    )).called(1);
    verify(mockQuery.get()).called(1);
    verify(mockQuerySnapshot.docs).called(1);
    verify(mockQueryDocumentSnapshot.data()).called(1);

    expect(incomeList, hasLength(1));
    expect(incomeList[0], Income(100));
  });

  group('DateTimeが期待通りの動きをすること', () {
    test('DateTime(2024, 13)とDateTime(2025, 1)が等しいこと', () {
      // DateTime(other.year, other.month + 1)がotherの1ヶ月後になることの確認
      expect(DateTime(2024, 13), DateTime(2025, 1));
    });
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
