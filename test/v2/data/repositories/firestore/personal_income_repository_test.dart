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
    final mockFirestoreService = MockFirestoreService();
    final userId = UserIdVo('samplePersonalNoteId');

    group('1件取得', () {
      <({String description, DateTime date})>[
        (
          description: '指定された月の収入一覧を取得できる',
          date: DateTime(2025, 1),
        ),
        (
          description: '初日の0時以外の日付を指定されたとき、月初の0時に整形してからデータを取得する',
          date: DateTime(2025, 1, 2, 3, 4, 5),
        ),
      ].forEach((element) {
        final (:description, :date) = element;
        test(description, () async {
          when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
            userId,
            date,
          )).thenAnswer((_) async => [
                {'amount': 100}
              ]);

          final sut = FirestorePersonalIncomeRepository(
            mockFirestoreService,
            userId,
          );
          final incomeList = await sut.fetchMonthly(date);

          verify(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
            userId,
            date,
          )).called(1);

          expect(incomeList, hasLength(1));
          expect(incomeList[0], IncomeVo(100));
        });
      });
    });

    group('0件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          any,
        )).thenAnswer((_) async => []);

        final sut = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await sut.fetchMonthly(DateTime(2025, 1));

        expect(incomeList, hasLength(0));
      });
    });

    group('2件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          any,
        )).thenAnswer((_) async => [
              {'amount': 100},
              {'amount': 100},
            ]);

        final sut = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await sut.fetchMonthly(DateTime(2025, 1));

        expect(incomeList, hasLength(2));
        expect(incomeList[0], IncomeVo(100));
        expect(incomeList[1], IncomeVo(100));
      });
    });

    group('複数件取得', () {
      test('異なる金額の収入を取得できる', () async {
        when(mockFirestoreService.fetchMonthlyPersonalIncomesOf(
          userId,
          any,
        )).thenAnswer((_) async => [
              {'amount': 100},
              {'amount': 200},
            ]);

        final sut = FirestorePersonalIncomeRepository(
          mockFirestoreService,
          userId,
        );
        final incomeList = await sut.fetchMonthly(DateTime(2025, 1));

        expect(incomeList, hasLength(2));
        expect(incomeList[0], IncomeVo(100));
        expect(incomeList[1], IncomeVo(200));
      });
    });
  });
}
