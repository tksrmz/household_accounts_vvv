import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/auth_repository.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<PublicProfileRepository>(),
  MockSpec<AuthRepository>(),
])
import 'view_model_test.mocks.dart';

void main() {
  final mockPublicProfileRepository = MockPublicProfileRepository();
  final mockAuthRepository = MockAuthRepository();
  const userId = UserIdVo('testUserId');
  const userName = UserNameVo('TestUser');
  final build = () async {
    final vm = SettingsViewModel(
      publicProfileRepository: mockPublicProfileRepository,
      authRepository: mockAuthRepository,
    );
    // 初期化完了を待つ
    await Future.delayed(Duration(milliseconds: 100));
    return vm;
  };

  setUp(() {
    when(mockAuthRepository.getCurrentUser()).thenReturn(UserAuth(uid: userId));
    when(mockPublicProfileRepository.fetchUserName(userId))
        .thenAnswer((_) async => userName);
  });

  tearDown(() {
    // モックのクリーンアップ
    reset(mockPublicProfileRepository);
    reset(mockAuthRepository);
  });

  group('SettingsViewModel', () {
    group('画面全体の状態', () {
      group('初期化実行中', () {
        setUp(() {
          when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
            (_) => Completer<UserNameVo>().future,
          );
        });

        test('初期化中はそのことが分かること', () async {
          final target = await build();

          verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
          expect(target.init.isExecuting, isTrue);
        });

        test('初期化実行中にもう一度初期化を要求されても何もしないこと', () async {
          final target = await build();
          target.init(userId);
          await Future.delayed(Duration(milliseconds: 100));

          verify(mockPublicProfileRepository.fetchUserName(userId)).called(1);
        });
      });

      test('初期化成功後はエラー状態ではないこと', () async {
        when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
          (_) async => UserNameVo('上田 技術'),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isFalse);
      });

      test('初期化失敗時はエラー状態であること', () async {
        when(mockPublicProfileRepository.fetchUserName(any)).thenThrow(
          Exception('fetchUserNameエラー'),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isTrue);
      });
    });

    group('ユーザー名編集', () {
      const userName = UserNameVo('上田 技術');

      setUp(() {
        when(mockPublicProfileRepository.fetchUserName(userId))
            .thenAnswer((_) async => userName);
      });

      test('ユーザー名を編集状態に変更できる', () async {
        final target = await build();

        target.startEditing();

        expect(target.userName, userName.value);
        expect(target.hasValidationError, isFalse);
      });

      test('ユーザー名が0文字になると検証エラーになる', () async {
        final target = await build();
        target.startEditing();

        target.validateUserName('');

        expect(target.hasValidationError, isTrue);
      });

      test('ユーザー名が20文字を超えると検証エラーになる', () async {
        final target = await build();
        target.startEditing();

        target.validateUserName("a" * 21);

        expect(target.hasValidationError, isTrue);
      });

      test('有効なユーザー名に戻すと検証エラーが解消される', () async {
        final target = await build();
        target.startEditing();
        target.validateUserName("a" * 21);

        target.validateUserName("validUsername");

        expect(target.hasValidationError, isFalse);
      });
    });

    group('ユーザー名保存', () {
      const currentUserName = UserNameVo('上田 技術');
      const newUserName = UserNameVo("newUserName");

      setUp(() {
        when(mockPublicProfileRepository.fetchUserName(userId))
            .thenAnswer((_) async => currentUserName);
      });

      test('保存に成功すると編集状態が終了し、新しい名前が表示される', () async {
        final target = await build();
        target.startEditing();

        target.validateUserName(newUserName.value);

        // モックの設定
        when(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .thenAnswer((_) async => {});

        await target.save(newUserName.value);

        verify(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .called(1);
        expect(target.userName, newUserName.value);
        expect(target.isEditing, isFalse);
      });

      test('保存に失敗するとエラー状態になり、編集前の名前が表示される', () async {
        final target = await build();

        target.startEditing();
        target.validateUserName(newUserName.value);

        // モックの設定
        when(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .thenThrow(Exception('保存に失敗しました'));

        await target.save(newUserName.value);

        verify(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .called(1);
        expect(target.save.canExecute, isTrue);
        expect(target.userName, currentUserName.value);
        expect(target.save.hasError, isTrue);
      });

      test('保存に失敗後にエラーをクリアすると、編集前の名前が表示される', () async {
        final target = await build();

        target.startEditing();
        target.validateUserName(newUserName.value);

        // モックの設定
        when(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .thenThrow(Exception('保存に失敗しました'));

        await target.save(newUserName.value);
        target.save.resetError();

        verify(mockPublicProfileRepository.updateUserName(userId, newUserName))
            .called(1);
        expect(target.save.canExecute, isTrue);
        expect(target.userName, currentUserName.value);
        expect(target.save.hasError, isFalse);
      });
    });
  });
}
