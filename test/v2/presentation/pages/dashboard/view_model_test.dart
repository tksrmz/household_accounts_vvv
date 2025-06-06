import 'dart:async';

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
  final mockIncomeRepository = MockIncomeRepository();
  final mockExpenseRepository = MockExpenseRepository();
  final mockPublicProfileRepository = MockPublicProfileRepository();
  final date = DateTime(2025, 1);
  const userId = UserIdVo('testUserId');
  const userName = UserNameVo('TestUser');

  final build = () async {
    final vm = DashboardViewModel(
      incomeRepository: mockIncomeRepository,
      expenseRepository: mockExpenseRepository,
      publicProfileRepository: mockPublicProfileRepository,
      date: date,
      userId: userId,
    );
    // 初期化完了を待つ
    await Future.delayed(Duration(milliseconds: 100));
    return vm;
  };

  setUp(() {
    when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Right<Exception, List<IncomeVo>>(<IncomeVo>[]));
    when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
        (_) async => Right<Exception, List<ExpenseVo>>(<ExpenseVo>[]));
    when(mockPublicProfileRepository.fetchUserName(userId))
        .thenAnswer((_) async => Right<Exception, UserNameVo>(userName));
  });

  tearDown(() {
    // モックのクリーンアップ
    reset(mockIncomeRepository);
    reset(mockExpenseRepository);
    reset(mockPublicProfileRepository);
  });

  group('DashboardViewModel', () {
    group('画面全体の状態', () {
      group('初期化実行中', () {
        setUp(() {
          when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
            (_) => Completer<Either<Exception, List<IncomeVo>>>().future,
          );
        });

        test('初期化中はそのことが分かること', () async {
          final target = await build();

          verify(mockIncomeRepository.fetchMonthly(date)).called(1);
          expect(target.init.isExecuting, isTrue);
        });
      });

      test('初期化成功後はエラー状態ではないこと', () async {
        when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
          (_) async => Right<Exception, List<IncomeVo>>([IncomeVo(100)]),
        );
        when(mockExpenseRepository.fetchMonthly(any)).thenAnswer(
          (_) async => Right<Exception, List<ExpenseVo>>([ExpenseVo(50)]),
        );
        when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
          (_) async => Right<Exception, UserNameVo>(UserNameVo('テストユーザー')),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isFalse);
      });

      test('初期化失敗時はエラー状態であること', () async {
        when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
          (_) async =>
              Left<Exception, List<IncomeVo>>(Exception('fetchIncomeエラー')),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isTrue);
      });
    });

    group('データ集約', () {
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
          incomeAnswer: [IncomeVo(100), IncomeVo(200)],
          expenseAnswer: [ExpenseVo(50), ExpenseVo(100)],
          userNameAnswer: UserNameVo('PiyoPiyo'),
          expectedIncome: 300,
          expectedExpense: 150,
          expectedUserName: 'PiyoPiyo',
        ),
        (
          description: '複数のincomeとexpenseが正しく合計されること',
          incomeAnswer: [IncomeVo(60), IncomeVo(40)],
          expenseAnswer: [ExpenseVo(30), ExpenseVo(40)],
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
            (_) async => Right(testData.userNameAnswer),
          );

          final target = await build();

          verify(mockIncomeRepository.fetchMonthly(date)).called(1);
          verify(mockExpenseRepository.fetchMonthly(date)).called(1);
          verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
          expect(target.value.income.value, testData.expectedIncome);
          expect(target.value.expense.value, testData.expectedExpense);
          expect(target.value.userName.value, testData.expectedUserName);
        });
      });
    });

    group('エラーハンドリング', () {
      test('IncomeRepositoryでエラーが発生したとき、エラー状態になりModelは初期値である', () async {
        when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
          (_) async => Left(Exception('IncomeRepositoryエラー')),
        );

        final target = await build();

        verify(mockIncomeRepository.fetchMonthly(date)).called(1);
        expect(target.value.income, IncomeVo.empty);
        expect(target.value.expense, ExpenseVo.empty);
        expect(target.value.userName, UserNameVo.empty);
      });

      test('ExpenseRepositoryでエラーが発生したとき、エラー状態になりModelは初期値である', () async {
        when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
          (_) async => Left(Exception('ExpenseRepositoryエラー')),
        );

        final target = await build();

        verify(mockIncomeRepository.fetchMonthly(date)).called(1);
        verify(mockExpenseRepository.fetchMonthly(date)).called(1);
        expect(target.value.income, IncomeVo.empty);
        expect(target.value.expense, ExpenseVo.empty);
        expect(target.value.userName, UserNameVo.empty);
      });

      test('PublicProfileRepositoryでエラーが発生したとき、エラー状態になりModelは初期値である', () async {
        when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
          (_) async => Left(Exception('PublicProfileRepositoryエラー')),
        );

        final target = await build();

        verify(mockIncomeRepository.fetchMonthly(date)).called(1);
        verify(mockExpenseRepository.fetchMonthly(date)).called(1);
        verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
        expect(target.value.income, IncomeVo.empty);
        expect(target.value.expense, ExpenseVo.empty);
        expect(target.value.userName, UserNameVo.empty);
      });
    });
  });
}
