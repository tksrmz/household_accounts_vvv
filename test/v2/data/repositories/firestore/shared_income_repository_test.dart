import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/private_profile.dart';
import 'package:household_accounts/v2/data/repositories/firestore/shared_income_repository.dart';
import 'package:household_accounts/v2/data/services/firestore/shared/shared_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/private_profile_service.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<SharedRecordService>(),
  MockSpec<PrivateProfileService>(),
  MockSpec<DocumentSnapshot<PrivateProfile>>(as: #MockDocumentSnapshot),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
  MockSpec<PrivateProfile>(as: #MockPrivateProfile),
])
import 'shared_income_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final mockSharedRecordService = MockSharedRecordService();
    final mockPrivateProfileService = MockPrivateProfileService();
    final mockPrivateProfileDocSnapshot = MockDocumentSnapshot();
    final mockSharedNoteDocRef = MockDocumentReference();
    final mockPrivateProfile = MockPrivateProfile();
    final userId = UserIdVo('sampleUserId');

    setUp(() {
      reset(mockSharedRecordService);
      reset(mockPrivateProfileService);
      reset(mockPrivateProfileDocSnapshot);
      reset(mockSharedNoteDocRef);
      reset(mockPrivateProfile);
    });

    group('共有ノートが存在する場合', () {
      test('指定された月の収入一覧を取得できる', () async {
        // Arrange
        final date = DateTime(2025, 1);
        final sharedNote = {'ref': mockSharedNoteDocRef};

        when(
          mockPrivateProfileService.fetch(userId),
        ).thenAnswer((_) async => Right(mockPrivateProfileDocSnapshot));
        when(mockPrivateProfileDocSnapshot.exists).thenReturn(true);
        when(
          mockPrivateProfileDocSnapshot.data(),
        ).thenReturn(mockPrivateProfile);
        when(mockPrivateProfile.sharedNote).thenReturn(sharedNote);
        when(
          mockSharedRecordService.fetchIncomesByDate(
            mockSharedNoteDocRef,
            date.year,
            date.month,
          ),
        ).thenAnswer(
          (_) async => Right([
            {'amount': 100},
            {'amount': 200},
          ]),
        );

        final target = FirestoreSharedIncomeRepository(
          mockSharedRecordService,
          mockPrivateProfileService,
          userId,
        );

        // Act
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        // Assert
        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(2));
        expect(incomeList[0], IncomeVo(100));
        expect(incomeList[1], IncomeVo(200));
      });
    });

    group('共有ノートが存在しない場合', () {
      test('プライベートプロファイルが存在しない場合、空のリストを返す', () async {
        // Arrange
        final date = DateTime(2025, 1);

        when(
          mockPrivateProfileService.fetch(userId),
        ).thenAnswer((_) async => Right(mockPrivateProfileDocSnapshot));
        when(mockPrivateProfileDocSnapshot.exists).thenReturn(false);

        final target = FirestoreSharedIncomeRepository(
          mockSharedRecordService,
          mockPrivateProfileService,
          userId,
        );

        // Act
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        // Assert
        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(0));
      });

      test('プライベートプロファイルのデータがnullの場合、空のリストを返す', () async {
        // Arrange
        final date = DateTime(2025, 1);

        when(
          mockPrivateProfileService.fetch(userId),
        ).thenAnswer((_) async => Right(mockPrivateProfileDocSnapshot));
        when(mockPrivateProfileDocSnapshot.exists).thenReturn(true);
        when(mockPrivateProfileDocSnapshot.data()).thenReturn(null);

        final target = FirestoreSharedIncomeRepository(
          mockSharedRecordService,
          mockPrivateProfileService,
          userId,
        );

        // Act
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        // Assert
        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(0));
      });

      test('共有ノートがnullの場合、空のリストを返す', () async {
        // Arrange
        final date = DateTime(2025, 1);

        when(
          mockPrivateProfileService.fetch(userId),
        ).thenAnswer((_) async => Right(mockPrivateProfileDocSnapshot));
        when(mockPrivateProfileDocSnapshot.exists).thenReturn(true);
        when(
          mockPrivateProfileDocSnapshot.data(),
        ).thenReturn(mockPrivateProfile);
        when(mockPrivateProfile.sharedNote).thenReturn(null);

        final target = FirestoreSharedIncomeRepository(
          mockSharedRecordService,
          mockPrivateProfileService,
          userId,
        );

        // Act
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        // Assert
        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(0));
      });

      test('共有ノートにrefが含まれていない場合、空のリストを返す', () async {
        // Arrange
        final date = DateTime(2025, 1);
        final sharedNote = <String, dynamic>{};

        when(
          mockPrivateProfileService.fetch(userId),
        ).thenAnswer((_) async => Right(mockPrivateProfileDocSnapshot));
        when(mockPrivateProfileDocSnapshot.exists).thenReturn(true);
        when(
          mockPrivateProfileDocSnapshot.data(),
        ).thenReturn(mockPrivateProfile);
        when(mockPrivateProfile.sharedNote).thenReturn(sharedNote);

        final target = FirestoreSharedIncomeRepository(
          mockSharedRecordService,
          mockPrivateProfileService,
          userId,
        );

        // Act
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        // Assert
        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(0));
      });
    });
  });
}
