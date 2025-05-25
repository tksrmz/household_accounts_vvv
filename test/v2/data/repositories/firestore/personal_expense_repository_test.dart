import 'package:household_accounts/v2/data/repositories/firestore/personal_expense_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
])
import 'personal_expense_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    group('1件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => [
              {'amount': 100}
            ]);

        final target = FirestorePersonalExpenseRepository(
          mockFirestoreService,
          userId,
        );
        final expenseList = await target.fetchMonthly(date);

        verify(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(expenseList, hasLength(1));
        expect(expenseList[0], ExpenseVo(100));
      });
    });

    group('0件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => []);

        final target = FirestorePersonalExpenseRepository(
          mockFirestoreService,
          userId,
        );
        final expenseList = await target.fetchMonthly(date);

        // クエリの正しさは別のテストで確認しているので、取得した結果だけ確認
        expect(expenseList, hasLength(0));
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
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => [
              {'amount': value}
            ]);

        final target = FirestorePersonalExpenseRepository(
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
