import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/domain/models/user_name.dart';
import 'package:household_accounts/ui/settings/settings_view_model.dart';
import 'package:household_accounts/utils/result.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/fake_profile_repository.dart';

// なぜtestWidgetsではなくtestを使うか:
// SettingsViewModelは純粋なDartのChangeNotifierでありWidgetツリーを必要としない。
// コマンドの完了は`pumpEventQueue()`で待つ。
//
// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/error/clearResultの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  const uid = 'test-uid';
  final currentUserName = UserName('上田 技術');
  final newUserName = UserName('Gijutsu Ueda');

  group('読み込み', () {
    test('読み込みが完了していないとき、loadコマンドが実行中であること', () async {
      final target = await _buildFixture(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      );

      expect(target.profileRepository.fetchUserNameCallCount, 1);
      expect(target.profileRepository.lastFetchUserNameUid, UserId(uid));
      expect(target.viewModel.load.running, isTrue);
    });

    test('読み込みに成功したとき、サーバから取得したユーザー名が表示されること', () async {
      final target = await _buildFixture();

      expect(target.viewModel.load.completed, isTrue);
      expect(target.viewModel.userName, currentUserName.value);
    });

    test('読み込みに失敗したとき、loadコマンドがエラー状態であること', () async {
      final target = await _buildFixture(
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      );

      expect(target.viewModel.load.error, isTrue);
    });
  });

  group('ユーザー名保存', () {
    test('startEditingしたとき、編集状態になること', () async {
      final target = await _buildFixture();

      target.viewModel.startEditing();

      expect(target.viewModel.isEditing, isTrue);
    });

    test('保存に成功したとき、編集状態が終了し新しい名前が表示されること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);

      expect(target.profileRepository.updateUserNameCallCount, 1);
      expect(target.profileRepository.lastUpdateUserNameUid, UserId(uid));
      expect(target.profileRepository.lastUpdatedUserName, newUserName);
      expect(target.viewModel.userName, newUserName.value);
      expect(target.viewModel.isEditing, isFalse);
      expect(target.viewModel.saveUserName.completed, isTrue);
    });

    test('保存に失敗したとき、編集状態が終了し編集前の名前が表示されたままであること', () async {
      final target = await _buildFixture();
      target.profileRepository.updateUserNameResult = Result.error(
        Exception('保存に失敗しました'),
      );
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);

      expect(target.profileRepository.updateUserNameCallCount, 1);
      expect(target.viewModel.saveUserName.error, isTrue);
      expect(target.viewModel.userName, currentUserName.value);
      expect(target.viewModel.isEditing, isFalse);
    });
  });

  group('入力の検証', () {
    test('0文字のユーザー名を保存しようとしたとき、検証エラーになり保存されず編集状態が続くこと', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('');

      expect(target.viewModel.hasValidationError, isTrue);
      expect(target.profileRepository.updateUserNameCallCount, 0);
      expect(target.viewModel.saveUserName.result, isNull);
      expect(target.viewModel.isEditing, isTrue);
    });

    test('20文字を超えるユーザー名を保存しようとしたとき、検証エラーになり保存されないこと', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('a' * 21);

      expect(target.viewModel.hasValidationError, isTrue);
      expect(target.profileRepository.updateUserNameCallCount, 0);
    });

    test('検証エラーのあとに有効なユーザー名を保存したとき、検証エラーが解消されること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('a' * 21);
      expect(target.viewModel.hasValidationError, isTrue);

      await target.viewModel.save(newUserName.value);

      expect(target.viewModel.hasValidationError, isFalse);
      expect(target.viewModel.userName, newUserName.value);
    });

    test('入力中に0文字にしたとき、検証エラーになり保存できなくなること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      target.viewModel.onUserNameChanged('');

      expect(target.viewModel.hasValidationError, isTrue);
      expect(target.viewModel.canSave, isFalse);
    });

    test('入力中の検証エラーのあとに有効な入力へ戻したとき、検証エラーが解消され保存できるようになること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();
      target.viewModel.onUserNameChanged('');

      target.viewModel.onUserNameChanged(newUserName.value);

      expect(target.viewModel.hasValidationError, isFalse);
      expect(target.viewModel.canSave, isTrue);
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.profileRepository});

  final SettingsViewModel viewModel;
  final FakeProfileRepository profileRepository;
}

Future<_Fixture> _buildFixture({
  Result<UserName>? fetchUserNameResult,
  Completer<Result<UserName>>? fetchUserNameCompleter,
}) async {
  final profileRepository = FakeProfileRepository()
    ..fetchUserNameResult = fetchUserNameResult ?? Result.ok(UserName('上田 技術'))
    ..fetchUserNameCompleter = fetchUserNameCompleter;
  final authRepository = FakeAuthRepository(
    currentUser: const UserAuth(uid: UserIdVo('test-uid')),
  );

  final viewModel = SettingsViewModel(
    profileRepository: profileRepository,
    authRepository: authRepository,
  );
  // コンストラクタで始まる読み込みの完了を待つ
  await pumpEventQueue();

  return _Fixture(viewModel: viewModel, profileRepository: profileRepository);
}
