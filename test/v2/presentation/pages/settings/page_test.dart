import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/presentation/pages/settings/page.dart';
import 'package:household_accounts/v2/presentation/pages/settings/state.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../test-util/golden_helper.dart';
@GenerateNiceMocks([MockSpec<SettingsViewModel>()])
import 'page_test.mocks.dart';

void main() {
  final mockViewModel = MockSettingsViewModel();
  final targetBuilder = () => SettingsPage(
        userId: UserIdVo("testUserId"),
        viewModel: mockViewModel,
      );

  tearDown(() {
    // モックのクリーンアップ
    reset(mockViewModel);
  });

  testGoldens(
    '初期化完了前はローディング画面が表示される',
    goldenFileName: 'settings_page_loading',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        SettingsState.uninitialized(UserNameVo.empty),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(UserIdVo("testUserId"))).called(1);
    },
  );

  testGoldens(
    '初期化が正常に完了すると設定画面コンテンツが表示される',
    goldenFileName: 'settings_page_complete',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        SettingsState.uninitialized(UserNameVo.empty).success(
          UserNameVo('testUserName'),
        ),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(UserIdVo("testUserId"))).called(1);
    },
  );

  testGoldens(
    '初期化に失敗するとエラーメッセージが表示される',
    goldenFileName: 'settings_page_error',
    mockFn: () {
      when(mockViewModel.value).thenReturn(
        SettingsState.uninitialized(UserNameVo.empty).fail(UserNameVo.empty),
      );
    },
    builder: targetBuilder,
    expectFn: () {
      verify(mockViewModel.init(UserIdVo("testUserId"))).called(1);
    },
  );
}
