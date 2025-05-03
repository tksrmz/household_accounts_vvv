import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/dashboard_info.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/page.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/state.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../util/golden_helper.dart';
@GenerateNiceMocks([MockSpec<DashboardViewModel>()])
import 'page_test.mocks.dart';

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
  final mockViewModel = MockDashboardViewModel();
  final targetBuilder = () => DashboardPage(
        date: DateTime(2025, 1),
        userId: UserIdVo("testUserId"),
        viewModel: mockViewModel,
      );

  tearDown(() {
    // モックのクリーンアップ
    reset(mockViewModel);
  });

  testGoldens(
    '初期化完了前はローディング画面が表示される',
    goldenFileName: 'dashboard_page_loading',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        DashboardState.uninitialized(),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(
        DateTime(2025, 1),
        UserIdVo("testUserId"),
      )).called(1);
    },
  );

  testGoldens(
    '初期化が正常に完了するとダッシュボードコンテンツが表示される',
    goldenFileName: 'dashboard_page_complete',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        DashboardState.uninitialized().success(
          DashboardInfoModel(
            IncomeVo(99),
            ExpenseVo(200),
            UserNameVo('testUserName'),
          ),
        ),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(
        DateTime(2025, 1),
        UserIdVo("testUserId"),
      )).called(1);
    },
  );

  testGoldens(
    '初期化に失敗するとエラーメッセージが表示される',
    goldenFileName: 'dashboard_page_error',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        DashboardState.uninitialized().fail(),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(
        DateTime(2025, 1),
        UserIdVo("testUserId"),
      )).called(1);
    },
  );
}
