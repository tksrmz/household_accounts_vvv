import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
])
import 'how_to_use_firestore_mock_test.mocks.dart';

void main() {
  final mockFirestore = MockFirebaseFirestore();
  final mockCollection = MockCollectionReference();
  final mockDocument = MockDocumentReference();
  final mockDocumentSnapshot = MockDocumentSnapshot();

  tearDown(() {
    reset(mockFirestore);
    reset(mockCollection);
    reset(mockDocument);
    reset(mockDocumentSnapshot);
  });

  test('Test Firestore get document', () async {
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
    when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

    final documentSnapshot =
        await mockFirestore.collection('users').doc('123').get();

    verify(mockFirestore.collection('users')).called(1);
    verify(mockCollection.doc('123')).called(1);
    expect(documentSnapshot, isA<DocumentSnapshot>());
  });
}
