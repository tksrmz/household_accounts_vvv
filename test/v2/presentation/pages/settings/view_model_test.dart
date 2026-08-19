import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../test-util/fake_auth_repository.dart';
@GenerateNiceMocks([MockSpec<PublicProfileRepository>()])
import 'view_model_test.mocks.dart';

void main() {
  final mockPublicProfileRepository = MockPublicProfileRepository();
  final fakeAuthRepository = FakeAuthRepository();
  const userId = UserIdVo('testUserId');
  const userName = UserNameVo('TestUser');
  Future<SettingsViewModel> build() async {
    final vm = SettingsViewModel(
      publicProfileRepository: mockPublicProfileRepository,
      authRepository: fakeAuthRepository,
    );
    // 初期化完了を待つ
    await Future.delayed(Duration(milliseconds: 100));
    return vm;
  }

  setUp(() {
    fakeAuthRepository.currentUser = UserAuth(uid: userId);
    when(
      mockPublicProfileRepository.fetchUserName(userId),
    ).thenAnswer((_) async => Right<Exception, UserNameVo>(userName));
  });

  tearDown(() {
    // モックのクリーンアップ
    reset(mockPublicProfileRepository);
  });

  group('SettingsViewModel', () {
    group('画面全体の状態', () {
      group('初期化実行中', () {
        setUp(() {
          when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
            (_) => Completer<Either<Exception, UserNameVo>>().future,
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
          (_) async => Right<Exception, UserNameVo>(UserNameVo('上田 技術')),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isFalse);
      });

      test('初期化失敗時はエラー状態であること', () async {
        when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
          (_) async =>
              Left<Exception, UserNameVo>(Exception('fetchUserNameエラー')),
        );

        final target = await build();
        await Future.delayed(Duration(milliseconds: 100));

        expect(target.init.isExecuting, isFalse);
        expect(target.init.hasError, isTrue);
      });
    });

    group('ユーザー名保存', () {
      const currentUserName = UserNameVo('上田 技術');
      const newUserName = UserNameVo("newUserName");

      setUp(() {
        when(mockPublicProfileRepository.fetchUserName(userId)).thenAnswer(
          (_) async => Right<Exception, UserNameVo>(currentUserName),
        );
        when(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).thenAnswer((_) async => Right<Exception, Unit>(unit));
      });

      test('初期化後はサーバから取得したユーザー名が表示される', () async {
        final target = await build();

        expect(target.userName, currentUserName.value);
      });

      test('ユーザー名を編集状態に変更できる', () async {
        final target = await build();

        target.startEditing();

        expect(target.isEditing, isTrue);
      });

      test('保存に成功すると編集状態が終了し、新しい名前が表示される', () async {
        final target = await build();
        target.startEditing();

        await target.save(newUserName.value);

        verify(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).called(1);
        expect(target.userName, newUserName.value);
        expect(target.isEditing, isFalse);
      });

      test('保存に失敗するとエラー状態になり、編集前の名前が表示される', () async {
        final target = await build();

        target.startEditing();

        // モックの設定
        when(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).thenAnswer(
          (_) async => Left<Exception, Unit>(Exception('保存に失敗しました')),
        );

        await target.save(newUserName.value);

        verify(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).called(1);
        expect(target.save.canExecute, isTrue);
        expect(target.userName, currentUserName.value);
        expect(target.save.hasError, isTrue);
      });

      test('保存に失敗後にエラーをクリアすると、編集前の名前が表示される', () async {
        final target = await build();

        target.startEditing();

        // モックの設定
        when(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).thenAnswer(
          (_) async => Left<Exception, Unit>(Exception('保存に失敗しました')),
        );

        await target.save(newUserName.value);
        target.save.resetError();

        verify(
          mockPublicProfileRepository.updateUserName(userId, newUserName),
        ).called(1);
        expect(target.save.canExecute, isTrue);
        expect(target.userName, currentUserName.value);
        expect(target.save.hasError, isFalse);
      });

      test('0文字のユーザー名を保存しようとすると検証エラーになる', () async {
        final target = await build();
        target.startEditing();

        await target.save('');

        expect(target.hasValidationError, isTrue);
      });

      test('20文字を超えるユーザー名を保存しようとすると検証エラーになる', () async {
        final target = await build();
        target.startEditing();

        await target.save("a" * 21);

        expect(target.hasValidationError, isTrue);
      });

      test('検証エラーになったあと、有効なユーザー名を保存できる', () async {
        final validUserNameVo = UserNameVo("validUsername");
        when(
          mockPublicProfileRepository.updateUserName(userId, validUserNameVo),
        ).thenAnswer((_) async => Right<Exception, Unit>(unit));

        final target = await build();
        target.startEditing();
        await target.save("a" * 21);
        expect(target.hasValidationError, isTrue);

        await target.save("validUsername");
        expect(target.hasValidationError, isFalse);
      });
    });
  });
}
