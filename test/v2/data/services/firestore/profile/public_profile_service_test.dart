import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/public_profile_service.dart';
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
import 'public_profile_service_test.mocks.dart';

void main() {
  group('PublicProfileService', () {
    group('fetchPublicProfileOf', () {
      final mockDb = MockFirebaseFirestore();
      final mockDocumentReference = MockDocumentReference();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(
          mockDb.doc('/publicProfiles/${userId.value}'),
        ).thenReturn(mockDocumentReference);
        when(
          mockDocumentReference.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(
          mockDocumentSnapshot.data(),
        ).thenReturn({'name': 'Test User', 'updatedAt': DateTime(2025, 5, 25)});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockDocumentReference);
        reset(mockDocumentSnapshot);
      });

      test('ユーザーの公開プロファイルを取得できる', () async {
        // Arrange
        final target = PublicProfileService(mockDb);

        // Act
        final result = await target.fetchPublicProfileOf(userId);

        // Assert
        verify(mockDb.doc('/publicProfiles/${userId.value}')).called(1);
        verify(mockDocumentReference.get()).called(1);
        verify(mockDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final profileData = result.getOrElse(Map.new);
        expect(profileData['name'], 'Test User');
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.get()).thenThrow(Exception('test error'));
        final target = PublicProfileService(mockDb);

        // Act
        final result = await target.fetchPublicProfileOf(userId);

        // Assert
        verify(mockDocumentReference.get()).called(1);
        expect(result.isLeft(), isTrue);
      });
    });

    group('updatePublicProfileNameOf', () {
      final mockDb = MockFirebaseFirestore();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final userName = UserNameVo('New User Name');

      setUp(() {
        when(
          mockDb.doc('/publicProfiles/${userId.value}'),
        ).thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockDocumentReference);
      });

      test('ユーザー名を更新できる', () async {
        // Arrange
        final target = PublicProfileService(mockDb);

        // Act
        final result = await target.updatePublicProfileNameOf(userId, userName);

        // Assert
        verify(mockDb.doc('/publicProfiles/${userId.value}')).called(1);

        // Using a more flexible verification approach since we can't directly match FieldValue.serverTimestamp()
        final verification = verify(mockDocumentReference.update(captureAny));
        verification.called(1);

        // Use a safer approach to handle the captured argument
        final capturedArg = verification.captured.first;
        expect(capturedArg, isMap);
        expect((capturedArg as Map)['name'], equals(userName.value));
        expect(capturedArg.containsKey('updatedAt'), isTrue);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(
          mockDocumentReference.update(any),
        ).thenThrow(Exception('test error'));
        final target = PublicProfileService(mockDb);

        // Act
        final result = await target.updatePublicProfileNameOf(userId, userName);

        // Assert
        verify(mockDocumentReference.update(any)).called(1);
        expect(result.isLeft(), isTrue);
      });
    });
  });
}
