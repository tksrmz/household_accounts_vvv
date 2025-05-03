import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/expense_repository.dart';
import 'package:household_accounts/v2/domain/repositories/income_repository.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/domain/usecases/dashboard.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
  MockSpec<PublicProfileRepository>(),
])
import 'summary_test.mocks.dart';

void main() {
  final date = DateTime(2025, 1);
  const userId = UserIdVo('testUserId');

  final mockIncomeRepository = MockIncomeRepository();
  final mockExpenseRepository = MockExpenseRepository();
  final mockPublicProfileRepository = MockPublicProfileRepository();

  tearDown(() {
    // モックのクリーンアップ
    reset(mockIncomeRepository);
    reset(mockExpenseRepository);
    reset(mockPublicProfileRepository);
  });

  group("fetch", () {
    final executeFetch = () => DashboardUseCase(
          incomeRepository: mockIncomeRepository,
          expenseRepository: mockExpenseRepository,
          publicProfileRepository: mockPublicProfileRepository,
        ).fetch(date, userId);

    group("正常に取得できるとき", () {
      [
        (
          description: 'incomeとexpenseがともに0円のとき',
          incomeAnswer: <IncomeVo>[],
          expenseAnswer: <ExpenseVo>[],
          userNameAnswer: UserNameVo('TestUserName'),
          expectedIncome: 0,
          expectedExpense: 0,
          expectedUserName: 'TestUserName',
        ),
        (
          description: 'incomeとexpenseがともに0円ではないとき',
          incomeAnswer: [
            IncomeVo(100),
            IncomeVo(200),
          ],
          expenseAnswer: [
            ExpenseVo(50),
            ExpenseVo(100),
          ],
          userNameAnswer: UserNameVo('PiyoPiyo'),
          expectedIncome: 300,
          expectedExpense: 150,
          expectedUserName: 'PiyoPiyo',
        ),
      ].forEach((testData) {
        test(testData.description, () async {
          when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
            (_) async => testData.incomeAnswer,
          );
          when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
            (_) async => testData.expenseAnswer,
          );
          when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
            (_) async => testData.userNameAnswer,
          );

          final result = await executeFetch();

          verify(mockIncomeRepository.fetchMonthly(date)).called(1);
          verify(mockExpenseRepository.fetchMonthly(date)).called(1);
          verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
          expect(result.income.value, testData.expectedIncome);
          expect(result.expense.value, testData.expectedExpense);
          expect(result.userName.value, testData.expectedUserName);
        });
      });
    });

    group("例外が発生するとき", () {
      setUp(() {
        // モックのセットアップ
        // 例外を発生させるメソッドは、個別のテストで上書きする
        when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
          (_) async => <IncomeVo>[],
        );
        when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
          (_) async => <ExpenseVo>[],
        );
        when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
          (_) async => UserNameVo('TestUserName'),
        );
      });

      test('IncomeRepositoryで例外が発生したとき', () async {
        when(mockIncomeRepository.fetchMonthly(date)).thenThrow(
          Exception('テストエラー'),
        );

        await expectLater(
          executeFetch,
          throwsA(isA<DashboardUseCaseException>()),
        );
      });

      test('ExpenseRepositoryで例外が発生したとき', () async {
        when(mockExpenseRepository.fetchMonthly(date)).thenThrow(
          Exception('テストエラー'),
        );

        await expectLater(
          executeFetch,
          throwsA(isA<DashboardUseCaseException>()),
        );
      });

      test('PublicProfileRepositoryで例外が発生したとき', () async {
        when(mockPublicProfileRepository.fetchUserName(userId)).thenThrow(
          Exception('テストエラー'),
        );

        await expectLater(
          executeFetch,
          throwsA(isA<DashboardUseCaseException>()),
        );
      });
    });
  });
}
