import 'package:household_accounts/v2/data/repositories/firestore/personal_income_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
])
import 'personal_income_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    group('1件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => [
              {'amount': 100}
            ]);

        final target = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await target.fetchMonthly(date);

        verify(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(incomeList, hasLength(1));
        expect(incomeList[0], IncomeVo(100));
      });
    });

    group('2件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => [
              {'amount': 100},
              {'amount': 200},
            ]);

        final target = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await target.fetchMonthly(date);

        verify(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(incomeList, hasLength(2));
        expect(incomeList[0], IncomeVo(100));
        expect(incomeList[1], IncomeVo(200));
      });
    });

    group('0件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => []);

        final target = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await target.fetchMonthly(date);

        verify(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(incomeList, hasLength(0));
      });
    });

    <({String description, dynamic value})>[
      (
        description: 'amountが数値以外のとき、TypeErrorが発生する',
        value: '100',
      ),
      (
        description: 'amountがnullのとき、TypeErrorが発生する',
        value: null,
      ),
    ].forEach((element) {
      final (:description, :value) = element;
      test(description, () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => [
              {'amount': value}
            ]);

        final target = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        expect(
          () async => await target.fetchMonthly(date),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
