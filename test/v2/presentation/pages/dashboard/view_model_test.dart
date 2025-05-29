import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/expense_repository.dart';
import 'package:household_accounts/v2/domain/repositories/income_repository.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
  MockSpec<PublicProfileRepository>(),
])
import 'view_model_test.mocks.dart';

void main() {
  late MockIncomeRepository mockIncomeRepository;
  late MockExpenseRepository mockExpenseRepository;
  late MockPublicProfileRepository mockPublicProfileRepository;
  final date = DateTime(2025, 1);
  const userId = UserIdVo('testUserId');

  setUp(() {
    mockIncomeRepository = MockIncomeRepository();
    mockExpenseRepository = MockExpenseRepository();
    mockPublicProfileRepository = MockPublicProfileRepository();
  });

  tearDown(() {
    // モックのクリーンアップ
    reset(mockIncomeRepository);
    reset(mockExpenseRepository);
    reset(mockPublicProfileRepository);
  });

  test('初期化前はModelが初期値であり、エラー状態ではない', () {
    final sut = DashboardViewModel(
      incomeRepository: mockIncomeRepository,
      expenseRepository: mockExpenseRepository,
      publicProfileRepository: mockPublicProfileRepository,
    );

    verifyNoMoreInteractions(mockIncomeRepository);
    verifyNoMoreInteractions(mockExpenseRepository);
    verifyNoMoreInteractions(mockPublicProfileRepository);
    expect(sut.value.isUninitialized, isTrue);
    expect(sut.value.model.income, IncomeVo.empty);
    expect(sut.value.model.expense, ExpenseVo.empty);
    expect(sut.value.model.userName, UserNameVo.empty);
    expect(sut.value.isFailed, isFalse);
  });

  group('初期化に成功したとき', () {
    group('データ集約のテスト', () {
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
        (
          description: '複数のincomeとexpenseが正しく合計されること',
          incomeAnswer: [
            IncomeVo(60),
            IncomeVo(40),
          ],
          expenseAnswer: [
            ExpenseVo(30),
            ExpenseVo(40),
          ],
          userNameAnswer: UserNameVo('testUserId'),
          expectedIncome: 100,
          expectedExpense: 70,
          expectedUserName: 'testUserId',
        ),
      ].forEach((testData) {
        test(testData.description, () async {
          when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
            (_) async => Right(testData.incomeAnswer),
          );
          when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
            (_) async => Right(testData.expenseAnswer),
          );
          when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
            (_) async => testData.userNameAnswer,
          );

          final sut = DashboardViewModel(
            incomeRepository: mockIncomeRepository,
            expenseRepository: mockExpenseRepository,
            publicProfileRepository: mockPublicProfileRepository,
          );
          await sut.init(date, userId);

          verify(mockIncomeRepository.fetchMonthly(date)).called(1);
          verify(mockExpenseRepository.fetchMonthly(date)).called(1);
          verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
          expect(sut.value.isUninitialized, isFalse);
          expect(sut.value.model.income.value, testData.expectedIncome);
          expect(sut.value.model.expense.value, testData.expectedExpense);
          expect(sut.value.model.userName.value, testData.expectedUserName);
          expect(sut.value.isFailed, isFalse);
        });
      });
    });

    test('notifyListeners()を呼び出しており、エラー状態ではない', () async {
      when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Right([IncomeVo(60), IncomeVo(40)]),
      );
      when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Right([ExpenseVo(30), ExpenseVo(40)]),
      );
      when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
        (_) async => UserNameVo("testUserId"),
      );

      final sut = DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date, userId);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isFalse);
    });

  });

  group('初期化に失敗したとき', () {
    setUp(() {
      // 基本的なモックセットアップ（個別テストで例外を発生させる）
      when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
        (_) async => Right(<IncomeVo>[]),
      );
      when(mockExpenseRepository.fetchMonthly(any)).thenAnswer(
        (_) async => Right(<ExpenseVo>[]),
      );
      when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
        (_) async => UserNameVo('TestUserName'),
      );
    });

    test('IncomeRepositoryで例外が発生したとき、エラー状態になり、Modelは初期値である', () async {
      when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Left(Exception('テストエラー')),
      );

      final sut = DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      );
      await sut.init(date, userId);

      verify(mockIncomeRepository.fetchMonthly(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.model.income, IncomeVo.empty);
      expect(sut.value.model.expense, ExpenseVo.empty);
      expect(sut.value.model.userName, UserNameVo.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('ExpenseRepositoryで例外が発生したとき、エラー状態になり、Modelは初期値である', () async {
      when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Left(Exception('テストエラー')),
      );

      final sut = DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      );
      await sut.init(date, userId);

      verify(mockIncomeRepository.fetchMonthly(date)).called(1);
      verify(mockExpenseRepository.fetchMonthly(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.model.income, IncomeVo.empty);
      expect(sut.value.model.expense, ExpenseVo.empty);
      expect(sut.value.model.userName, UserNameVo.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('PublicProfileRepositoryで例外が発生したとき、エラー状態になり、Modelは初期値である', () async {
      when(mockPublicProfileRepository.fetchUserName(userId)).thenThrow(
        Exception('テストエラー'),
      );

      final sut = DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      );
      await sut.init(date, userId);

      verify(mockIncomeRepository.fetchMonthly(date)).called(1);
      verify(mockExpenseRepository.fetchMonthly(date)).called(1);
      verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.model.income, IncomeVo.empty);
      expect(sut.value.model.expense, ExpenseVo.empty);
      expect(sut.value.model.userName, UserNameVo.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('notifyListeners()を呼び出している', () async {
      when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
        (_) async => Left(Exception('テスト：エラーが発生しました')),
      );

      final sut = DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date, userId);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isTrue);
    });

  });
}