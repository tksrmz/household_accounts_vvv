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
void main() {
  const uid = 'test-uid';
  const currentUserName = UserName('上田 技術');
  const newUserName = UserName('Gijutsu Ueda');

  group('読み込み', () {
    test('読み込みが完了していないとき、loadコマンドが実行中であること', () async {
      final target = await _buildFixture(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      );

      expect(target.profileRepository.fetchUserNameCallCount, 1);
      expect(target.profileRepository.lastFetchUserNameUid, const UserId(uid));
      expect(target.viewModel.load.running, isTrue);
    });

    test('読み込み中にもう一度読み込みを要求したとき、fetchUserNameが再実行されないこと', () async {
      final target = await _buildFixture(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      );

      await target.viewModel.load.execute();
      await pumpEventQueue();

      expect(target.profileRepository.fetchUserNameCallCount, 1);
    });

    test('読み込みに成功したとき、loadコマンドがエラー状態でないこと', () async {
      final target = await _buildFixture();

      expect(target.viewModel.load.running, isFalse);
      expect(target.viewModel.load.error, isFalse);
      expect(target.viewModel.load.completed, isTrue);
    });

    test('読み込みに成功したとき、サーバから取得したユーザー名が表示されること', () async {
      final target = await _buildFixture();

      expect(target.viewModel.userName, currentUserName.value);
    });

    test('読み込みに失敗したとき、loadコマンドがエラー状態であること', () async {
      final target = await _buildFixture(
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      );

      expect(target.viewModel.load.running, isFalse);
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
      expect(target.profileRepository.lastUpdateUserNameUid, const UserId(uid));
      expect(target.profileRepository.lastUpdatedUserName, newUserName);
      expect(target.viewModel.userName, newUserName.value);
      expect(target.viewModel.isEditing, isFalse);
      expect(target.viewModel.saveUserName.completed, isTrue);
    });

    test('保存に失敗したとき、saveコマンドがエラー状態になり編集状態が終了すること', () async {
      final target = await _buildFixture();
      target.profileRepository.updateUserNameResult = Result.error(
        Exception('保存に失敗しました'),
      );
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);

      expect(target.profileRepository.updateUserNameCallCount, 1);
      expect(target.viewModel.saveUserName.error, isTrue);
      expect(target.viewModel.canSave, isTrue);
      expect(target.viewModel.isEditing, isFalse);
    });

    test('保存に失敗したとき、userNameが編集前の値のままであること', () async {
      final target = await _buildFixture();
      target.profileRepository.updateUserNameResult = Result.error(
        Exception('保存に失敗しました'),
      );
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);

      expect(target.viewModel.userName, currentUserName.value);
    });

    test('保存に失敗したあとclearResultしたとき、エラー状態が解消され編集前の名前が表示されること', () async {
      final target = await _buildFixture();
      target.profileRepository.updateUserNameResult = Result.error(
        Exception('保存に失敗しました'),
      );
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);
      target.viewModel.saveUserName.clearResult();

      expect(target.viewModel.saveUserName.error, isFalse);
      expect(target.viewModel.canSave, isTrue);
      expect(target.viewModel.userName, currentUserName.value);
    });

    test('連続で保存に失敗したとき、2回目もsaveコマンドのエラーが検知できること', () async {
      final target = await _buildFixture();
      target.profileRepository.updateUserNameResult = Result.error(
        Exception('保存に失敗しました'),
      );
      target.viewModel.startEditing();

      await target.viewModel.save(newUserName.value);
      expect(target.viewModel.saveUserName.error, isTrue);
      // 画面がスナックバーを表示したあとの状態を再現する
      target.viewModel.saveUserName.clearResult();

      target.viewModel.startEditing();
      await target.viewModel.save(newUserName.value);

      expect(target.profileRepository.updateUserNameCallCount, 2);
      expect(target.viewModel.saveUserName.error, isTrue);
    });
  });

  group('入力の検証', () {
    test('0文字のユーザー名を保存しようとしたとき、検証エラーメッセージが表示されること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('');

      expect(target.viewModel.validationErrorMessage, '1文字以上20文字以下にしてください');
    });

    test('20文字を超えるユーザー名を保存しようとしたとき、検証エラーメッセージが表示されること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('a' * 21);

      expect(target.viewModel.validationErrorMessage, '1文字以上20文字以下にしてください');
    });

    test('検証エラーになったとき、updateUserNameが呼ばれないこと', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('');

      expect(target.profileRepository.updateUserNameCallCount, 0);
      expect(target.viewModel.saveUserName.result, isNull);
    });

    test('検証エラーになったとき、編集状態が継続すること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('');

      expect(target.viewModel.isEditing, isTrue);
    });

    test('検証エラーのあとに有効なユーザー名を保存したとき、検証エラーが解消されること', () async {
      final target = await _buildFixture();
      target.viewModel.startEditing();

      await target.viewModel.save('a' * 21);
      expect(target.viewModel.validationErrorMessage, isNotNull);

      await target.viewModel.save(newUserName.value);

      expect(target.viewModel.validationErrorMessage, isNull);
      expect(target.viewModel.userName, newUserName.value);
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
    ..fetchUserNameResult =
        fetchUserNameResult ?? Result.ok(const UserName('上田 技術'))
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
