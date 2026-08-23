import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/user_name.dart';
import 'package:household_accounts/ui/settings/settings_screen.dart';
import 'package:household_accounts/ui/settings/settings_view_model.dart';
import 'package:household_accounts/utils/result.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/fake_profile_repository.dart';
import '../../test-util/golden_helper.dart';

final _loadedUserName = UserName('うえだぎじゅつ');
final _editableUserName = UserName('testUserName');
final _newUserName = UserName('Gijutsu Ueda');
const _saveErrorMessage = 'ユーザー名の保存に失敗しました';

// なぜスナックバーをgoldenで確認しないか:
// ScaffoldMessengerは入れ子のScaffoldのうち最も外側にだけスナックバーを出す。
// 3幅ヘルパーはSettingsScreenのScaffoldを別のScaffoldで包むため、
// スナックバーは撮影範囲の外に出る。文言と再表示は下の通常のtestWidgetsで固定する。
void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      '画面を開くとローディングが表示されること',
      goldenFileName: 'settings_loading',
      builder: () => (fixture = _buildFixture(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      )).screen,
    );

    testGoldens(
      '読み込みに成功するとコンテンツが表示されること',
      goldenFileName: 'settings_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '読み込みに失敗するとエラーメッセージが表示されること',
      goldenFileName: 'settings_load_failed',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      'ユーザー名を選択すると編集状態になること',
      goldenFileName: 'settings_editing_by_tap',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await tester.tap(find.text(_editableUserName.value));
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      'テキストフィールドにフォーカスが当たると編集状態になること',
      goldenFileName: 'settings_editing_by_focus',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await tester.showKeyboard(find.byType(TextField));
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '0文字のユーザー名を保存しようとすると検証エラーが表示されること',
      goldenFileName: 'settings_validation_error',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await _startEditing(tester);
        await _saveWith(tester, '');
      },
    );

    testGoldens(
      '有効なユーザー名に戻すと検証エラーが解消されること',
      goldenFileName: 'settings_validation_error_recovered',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await _startEditing(tester);
        await _saveWith(tester, '');
        await _saveWith(tester, _newUserName.value);
      },
    );

    testGoldens(
      '保存に成功すると新しい名前が表示されること',
      goldenFileName: 'settings_save_succeeded',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await _startEditing(tester);
        await _saveWith(tester, _newUserName.value);
      },
    );

    testGoldens(
      '保存に失敗すると編集前の名前へ戻ること',
      goldenFileName: 'settings_save_failed',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
        updateUserNameResult: Result.error(Exception('保存に失敗しました')),
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await _startEditing(tester);
        await _saveWith(tester, _newUserName.value);
      },
    );

    testGoldens(
      '保存に失敗したあとに再度編集して保存できること',
      goldenFileName: 'settings_save_succeeded_after_failure',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: _editableResult,
        updateUserNameResult: Result.error(Exception('保存に失敗しました')),
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await _startEditing(tester);
        await _saveWith(tester, _newUserName.value);

        fixture.profileRepository.updateUserNameResult = const Result.ok(null);
        await _saveWith(tester, 'ソフト テス太');
      },
    );
  });

  group('画面全体', () {
    testWidgets('画面を開いたとき、AppBarに設定と表示されること', (tester) async {
      await _pumpScreen(tester);

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('設定')),
        findsOneWidget,
      );
    });

    testWidgets('読み込みに失敗したとき、エラーメッセージが表示されコンテンツが表示されないこと', (tester) async {
      await _pumpScreen(
        tester,
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      );

      expect(find.text('エラーが発生しました。'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('ユーザー名編集', () {
    testWidgets('テキストフィールドにフォーカスが当たるまで、保存ボタンが表示されないこと', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('保存'), findsNothing);

      await _startEditing(tester);

      expect(find.text('保存'), findsOneWidget);
    });

    testWidgets('保存に成功したとき、編集後の名前が表示され保存ボタンが消えること', (tester) async {
      final fixture = await _pumpScreen(tester);

      await _startEditing(tester);
      await _saveWith(tester, _newUserName.value);

      expect(fixture.profileRepository.lastUpdatedUserName, _newUserName);
      expect(find.text(_newUserName.value), findsOneWidget);
      expect(find.text('保存'), findsNothing);
    });

    testWidgets('検証エラーになったとき、エラーメッセージが表示され編集状態が続くこと', (tester) async {
      final fixture = await _pumpScreen(tester);

      await _startEditing(tester);
      await _saveWith(tester, '');

      expect(find.text('1文字以上20文字以下にしてください'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
      expect(fixture.profileRepository.updateUserNameCallCount, 0);
    });

    testWidgets('保存に失敗したとき、スナックバーが表示され入力が編集前の名前へ戻ること', (tester) async {
      await _pumpScreen(
        tester,
        updateUserNameResult: Result.error(Exception('保存に失敗しました')),
      );

      await _startEditing(tester);
      await _saveWith(tester, _newUserName.value);

      expect(find.text(_saveErrorMessage), findsOneWidget);
      expect(find.text(_loadedUserName.value), findsOneWidget);
      expect(find.text(_newUserName.value), findsNothing);
    });

    testWidgets('連続で保存に失敗したとき、2回目もスナックバーが表示されること', (tester) async {
      await _pumpScreen(
        tester,
        updateUserNameResult: Result.error(Exception('保存に失敗しました')),
      );

      await _startEditing(tester);
      await _saveWith(tester, _newUserName.value);
      expect(find.text(_saveErrorMessage), findsOneWidget);

      // 1回目のスナックバーが自動的に消えるまで待ち、2回目の表示と区別する
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text(_saveErrorMessage), findsNothing);

      await _saveWith(tester, _newUserName.value);

      expect(find.text(_saveErrorMessage), findsOneWidget);
    });
  });
}

final _editableResult = Result.ok(_editableUserName);

class _Fixture {
  _Fixture({required this.screen, required this.profileRepository});

  final SettingsScreen screen;
  final FakeProfileRepository profileRepository;
}

_Fixture _buildFixture({
  Result<UserName>? fetchUserNameResult,
  Completer<Result<UserName>>? fetchUserNameCompleter,
  Result<void>? updateUserNameResult,
}) {
  final profileRepository = FakeProfileRepository()
    ..fetchUserNameResult = fetchUserNameResult ?? Result.ok(_loadedUserName)
    ..fetchUserNameCompleter = fetchUserNameCompleter
    ..updateUserNameResult = updateUserNameResult ?? const Result.ok(null);
  final authRepository = FakeAuthRepository(
    currentUser: const UserAuth(uid: UserIdVo('test-uid')),
  );

  return _Fixture(
    screen: SettingsScreen(
      viewModel: SettingsViewModel(
        profileRepository: profileRepository,
        authRepository: authRepository,
      ),
    ),
    profileRepository: profileRepository,
  );
}

Future<_Fixture> _pumpScreen(
  WidgetTester tester, {
  Result<UserName>? fetchUserNameResult,
  Result<void>? updateUserNameResult,
}) async {
  final fixture = _buildFixture(
    fetchUserNameResult: fetchUserNameResult,
    updateUserNameResult: updateUserNameResult,
  );

  await tester.pumpWidget(GoldenPageWrapper(child: fixture.screen));
  await tester.pumpAndSettle();

  return fixture;
}

Future<void> _startEditing(WidgetTester tester) async {
  await tester.showKeyboard(find.byType(TextField));
  await tester.pumpAndSettle();
}

Future<void> _saveWith(WidgetTester tester, String userName) async {
  await tester.enterText(find.byType(TextField), userName);
  await tester.pumpAndSettle();
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}
