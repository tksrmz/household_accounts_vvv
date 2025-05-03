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
      final date = DateTime(2025, 1);
      final userId = UserIdVo('testUserId');

      final mockIncomeRepository = MockIncomeRepository();
      when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
        (_) async => testData.incomeAnswer,
      );
      final mockExpenseRepository = MockExpenseRepository();
      when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
        (_) async => testData.expenseAnswer,
      );
      final mockPublicProfileRepository = MockPublicProfileRepository();
      when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
        (_) async => testData.userNameAnswer,
      );

      final result = await DashboardUseCase(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      ).fetch(date, userId);

      verify(mockIncomeRepository.fetchMonthly(date)).called(1);
      verify(mockExpenseRepository.fetchMonthly(date)).called(1);
      verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
      expect(result.income.value, testData.expectedIncome);
      expect(result.expense.value, testData.expectedExpense);
      expect(result.userName.value, testData.expectedUserName);
    });
  });

  test('IncomeRepositoryで例外が発生したとき', () async {
    final date = DateTime(2025, 1);
    final userId = UserIdVo('testUserId');

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenThrow(
      Exception('IncomeRepositoryでエラーが発生しました'),
    );
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <ExpenseVo>[],
    );
    final mockPublicProfileRepository = MockPublicProfileRepository();
    when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
      (_) async => UserNameVo('TestUserName'),
    );

    expect(
      () async => await DashboardUseCase(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      ).fetch(date, userId),
      throwsA(isA<DashboardUseCaseException>()),
    );
  });

  test('ExpenseRepositoryで例外が発生したとき', () async {
    final date = DateTime(2025, 1);
    final userId = UserIdVo('testUserId');

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <IncomeVo>[],
    );
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenThrow(
      Exception('ExpenseRepositoryでエラーが発生しました'),
    );
    final mockPublicProfileRepository = MockPublicProfileRepository();
    when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
      (_) async => UserNameVo('TestUserName'),
    );

    expect(
      () async => await DashboardUseCase(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      ).fetch(date, userId),
      throwsA(isA<DashboardUseCaseException>()),
    );
  });

  test('PublicProfileRepositoryで例外が発生したとき', () async {
    final date = DateTime(2025, 1);
    final userId = UserIdVo('testUserId');

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <IncomeVo>[],
    );
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <ExpenseVo>[],
    );
    final mockPublicProfileRepository = MockPublicProfileRepository();
    when(mockPublicProfileRepository.fetchUserName(userId)).thenThrow(
      Exception('PublicProfileRepositoryでエラーが発生しました'),
    );

    expect(
      () async => await DashboardUseCase(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      ).fetch(date, userId),
      throwsA(isA<DashboardUseCaseException>()),
    );
  });
}
