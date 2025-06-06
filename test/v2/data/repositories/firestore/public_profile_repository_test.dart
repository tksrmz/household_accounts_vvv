
import 'package:dartz/dartz.dart';
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
          .thenAnswer((_) async => Right<Exception, Map<String, dynamic>>({
                'name': 'XxXSampleNameXxX',
              }));

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      final result = await sut.fetchUserName(userId);

      verify(mockFirestoreService.fetchPublicProfileOf(userId)).called(1);

      expect(result, isA<Either<Exception, UserNameVo>>());
      expect(result.isRight(), isTrue);
      final userName = result.getOrElse(() => UserNameVo(''));
      expect(userName, UserNameVo('XxXSampleNameXxX'));
    });

    test('取得に失敗した場合、Leftを返す', () async {
      when(mockFirestoreService.fetchPublicProfileOf(userId))
          .thenAnswer((_) async => Left<Exception, Map<String, dynamic>>(Exception('取得に失敗しました')));

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      final result = await sut.fetchUserName(userId);

      verify(mockFirestoreService.fetchPublicProfileOf(userId)).called(1);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => r), isA<Exception>());
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
          .thenAnswer((_) async => Right<Exception, Unit>(unit));

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      final result = await sut.updateUserName(userId, userName);

      verify(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .called(1);

      expect(result, isA<Either<Exception, Unit>>());
      expect(result.isRight(), isTrue);
    });

    test('更新に失敗した場合、Leftを返す', () async {
      when(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .thenAnswer((_) async => Left<Exception, Unit>(Exception('更新に失敗しました')));

      final sut = FirestorePublicProfileRepository(mockFirestoreService);
      final result = await sut.updateUserName(userId, userName);

      verify(mockFirestoreService.updatePublicProfileNameOf(userId, userName))
          .called(1);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => r), isA<Exception>());
    });
  });
}
