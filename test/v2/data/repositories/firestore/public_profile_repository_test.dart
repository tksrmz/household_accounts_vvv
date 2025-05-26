
import 'package:household_accounts/v2/data/repositories/firestore/public_profile_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
])
import 'public_profile_repository_test.mocks.dart';

void main() {
  group('fetchUserName', () {
    final mockFirestoreService = MockFirestoreService();
    final userId = UserIdVo('XxXSampleUserIdXxX');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('ユーザー名を取得できる', () async {
      when(mockFirestoreService.fetchPublicProfileOf(userId))
          .thenAnswer((_) async => {
                'name': 'XxXSampleNameXxX',
              });

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      final userName = await sut.fetchUserName(userId);

      verify(mockFirestoreService.fetchPublicProfileOf(userId)).called(1);

      expect(userName, UserNameVo('XxXSampleNameXxX'));
    });
  });

  group('updateUserName', () {
    final mockFirestoreService = MockFirestoreService();
    final userId = UserIdVo('XxXSampleUserIdXxX');
    final userName = UserNameVo('NewUserName');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('ユーザー名を更新できる', () async {
      when(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .thenAnswer((_) async => {});

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      await sut.updateUserName(userId, userName);

      verify(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .called(1);
    });

    test('更新に失敗したら例外が発生する', () async {
      when(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .thenThrow(Exception('更新に失敗しました'));

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      expect(
        () => sut.updateUserName(userId, userName),
        throwsException,
      );
    });
  });
}
