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

  group('updateUserName', () {
    final mockDb = MockFirebaseFirestore();
    final mockDocumentReference = MockDocumentReference();

    setUp(() {
      when(mockDb.doc('/publicProfiles/XxXSampleUserIdXxX'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
    });

    tearDown(() {
      reset(mockDb);
      reset(mockDocumentReference);
    });

    test('ユーザー名を更新できる', () async {
      final sut = FirestorePublicProfileRepository(mockDb);
      await sut.updateUserName(
        UserIdVo('XxXSampleUserIdXxX'),
        UserNameVo('NewUserName'),
      );

      verify(mockDb.doc('/publicProfiles/XxXSampleUserIdXxX')).called(1);

      final verification = verify(mockDocumentReference.update(captureAny));
      verification.called(1);
      final capturedArg = verification.captured.single as Map<Object?, Object?>;
      expect(capturedArg['name'], equals('NewUserName'));
      expect(capturedArg['updatedAt'], isA<FieldValue>());
    });

    test('更新に失敗したら例外が発生する', () async {
      when(mockDocumentReference.update(any)).thenThrow(Exception('更新に失敗しました'));

      final sut = FirestorePublicProfileRepository(mockDb);
      expect(
        () => sut.updateUserName(
          UserIdVo('XxXSampleUserIdXxX'),
          UserNameVo('NewUserName'),
        ),
        throwsException,
      );
    });
  });
}
