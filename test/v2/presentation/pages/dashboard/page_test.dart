import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/expense_repository.dart';
import 'package:household_accounts/v2/domain/repositories/income_repository.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/page.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/view_model.dart';
import 'package:household_accounts/v2/presentation/pages/state_managements/selected_note_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../test-util/golden_helper.dart';
@GenerateNiceMocks([
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
  MockSpec<PublicProfileRepository>(),
])
import 'page_test.mocks.dart';

// FIXME testGoldensの代わりにGoldenWrapperを使うようにする
void main() {
  /**
   * TODO
   *
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - 発生したエラーに応じてエラーメッセージの内容を変える？
   * - ViewModelのincomeとexpenseを一つのプロパティ（summaryとか）にまとめる？
   * - BudgetGraphModel.fetchでBudgetGraphDataListを取得できる
   * - dateをX月1日00:00:00に整形するロジックをモデルに移す
   */
  const userId = UserIdVo('testUserId');
  final mockIncomeRepository = MockIncomeRepository();
  final mockExpenseRepository = MockExpenseRepository();
  final mockPublicProfileRepository = MockPublicProfileRepository();

  MultiProvider targetBuilder() => MultiProvider(
    providers: [
      ChangeNotifierProvider<SelectedNoteState>(
        create: (_) => SelectedNoteState(),
      ),
      Provider<UserAuth>(create: (_) => UserAuth(uid: userId)),
    ],
    child: DashboardPage(
      viewModel: DashboardViewModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
        publicProfileRepository: mockPublicProfileRepository,
        date: DateTime(2025, 1),
        userId: userId,
      ),
    ),
  );

  tearDown(() {
    // モックのクリーンアップ
    reset(mockIncomeRepository);
    reset(mockExpenseRepository);
    reset(mockPublicProfileRepository);
  });

  testGoldens(
    '初期化完了前はローディング画面が表示される',
    goldenFileName: 'dashboard_page_loading',
    mockFn: () {
      // 初期化が完了しないようにFutureを返す
      when(mockIncomeRepository.fetchMonthly(any)).thenAnswer(
        (_) => Completer<Either<Exception, List<IncomeVo>>>().future,
      );
      when(mockExpenseRepository.fetchMonthly(any)).thenAnswer(
        (_) => Completer<Either<Exception, List<ExpenseVo>>>().future,
      );
      when(
        mockPublicProfileRepository.fetchUserName(any),
      ).thenAnswer((_) => Completer<Either<Exception, UserNameVo>>().future);
    },
    builder: targetBuilder,
  );

  testGoldens(
    '初期化が正常に完了するとダッシュボードコンテンツが表示される',
    goldenFileName: 'dashboard_page_complete',
    mockFn: () {
      when(
        mockIncomeRepository.fetchMonthly(any),
      ).thenAnswer((_) async => Right([IncomeVo(99)]));
      when(
        mockExpenseRepository.fetchMonthly(any),
      ).thenAnswer((_) async => Right([ExpenseVo(200)]));
      when(
        mockPublicProfileRepository.fetchUserName(any),
      ).thenAnswer((_) async => Right(UserNameVo('testUserName')));
    },
    builder: targetBuilder,
    expectFn: (tester) async {
      await tester.pumpAndSettle();

      verify(mockIncomeRepository.fetchMonthly(DateTime(2025, 1))).called(1);
      verify(mockExpenseRepository.fetchMonthly(DateTime(2025, 1))).called(1);
      verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
    },
  );

  testGoldens(
    '初期化に失敗するとエラーメッセージが表示される',
    goldenFileName: 'dashboard_page_error',
    mockFn: () {
      when(
        mockIncomeRepository.fetchMonthly(any),
      ).thenAnswer((_) async => Left(Exception('fetchMonthlyエラー')));
    },
    builder: targetBuilder,
    expectFn: (tester) async {
      await tester.pumpAndSettle();
      verify(mockIncomeRepository.fetchMonthly(DateTime(2025, 1))).called(1);
    },
  );
}
