import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/v2/data/repositories/firestore/public_profile_repository.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
])
import 'public_profile_repository_test.mocks.dart';

void main() {
  group('fetchUserName', () {
    final mockDb = MockFirebaseFirestore();
    final mockDocumentReference = MockDocumentReference();
    final mockDocumentSnapshot = MockDocumentSnapshot();

    setUp(() {
      when(mockDb.doc('/publicProfiles/XxXSampleUserIdXxX'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
    });

    tearDown(() {
      reset(mockDb);
      reset(mockDocumentReference);
      reset(mockDocumentSnapshot);
    });

    test('ユーザー名を取得できる', () async {
      when(mockDocumentSnapshot.data()).thenReturn({
        'name': 'XxXSampleNameXxX',
      });

      final sut = FirestorePublicProfileRepository(mockDb);
      final userName = await sut.fetchUserName(UserIdVo('XxXSampleUserIdXxX'));

      verify(mockDb.doc('/publicProfiles/XxXSampleUserIdXxX')).called(1);
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentSnapshot.data()).called(1);

      expect(userName, UserNameVo('XxXSampleNameXxX'));
    });
  });
}
