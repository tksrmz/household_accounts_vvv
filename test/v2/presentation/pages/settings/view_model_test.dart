import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<PublicProfileRepository>()])
import 'view_model_test.mocks.dart';

void main() {
  final mockRepository = MockPublicProfileRepository();
  const userId = UserIdVo('testUserId');
  const userName = UserNameVo('testUserName');
  late SettingsViewModel target;

  setUp(() {
    // テスト対象の初期化
    target = SettingsViewModel(
      publicProfileRepository: mockRepository,
    );
  });

  tearDown(() {
    // モックのクリーンアップ
    reset(mockRepository);
  });

  group('SettingsViewModel', () {
    group('画面全体の状態', () {
      test('初期化前は初期化実行中ではないこと', () {
        verifyNoMoreInteractions(mockRepository);
        expect(target.initIsRunning, isFalse);
      });

      group('初期化実行中', () {
        setUp(() {
          when(mockRepository.fetchUserName(any)).thenAnswer(
            (_) => Completer<UserNameVo>().future,
          );
        });

        test('初期化中はそのことが分かること', () async {
          target.initialize(userId);
          await Future.delayed(Duration(milliseconds: 100));

          verify(mockRepository.fetchUserName(userId)).called(1);
          expect(target.initIsRunning, isTrue);
        });

        test('初期化実行中にもう一度初期化を要求されても何もしないこと', () async {
          target.initialize(userId);
          target.initialize(userId);
          await Future.delayed(Duration(milliseconds: 100));

          verify(mockRepository.fetchUserName(userId)).called(1);
        });
      });

      test('初期化成功後はデータを取得可能で、エラーがない状態であること', () async {
        when(mockRepository.fetchUserName(any)).thenAnswer(
          (_) async => UserNameVo('上田 技術'),
        );

        await target.initialize(userId);

        expect(target.userName, '上田 技術');
        expect(target.initIsRunning, isFalse);
        expect(target.initHasError, isFalse);
      });

      test('初期化失敗時はデータを取得できず、エラーがあること', () async {
        when(mockRepository.fetchUserName(any)).thenThrow(
          Exception('fetchUserNameエラー'),
        );

        await target.initialize(userId);

        expect(target.userName, isNull);
        expect(target.initIsRunning, isFalse);
        expect(target.initHasError, isTrue);
      });
    });

    group('ユーザー名編集', () {
      setUp(() {
        when(mockRepository.fetchUserName(userId))
            .thenAnswer((_) async => userName);
      });

      test('初期化後、ユーザー名が表示される', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);

        expect(sut.userName, userName.value);
        expect(sut.isEditing, isFalse);
      });

      test('ユーザー名を編集状態に変更できる', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);

        sut.startEditing();

        expect(sut.isEditing, isTrue);
        expect(sut.userName, userName.value);
        expect(sut.hasValidationError, isFalse);
      });

      test('ユーザー名が0文字になると検証エラーになる', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        sut.startEditing();

        sut.updateUserName('');

        expect(sut.hasValidationError, isTrue);
        expect(sut.isEditing, isFalse);
      });

      test('ユーザー名が20文字を超えると検証エラーになる', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        sut.startEditing();

        sut.updateUserName("a" * 21);

        expect(sut.hasValidationError, isTrue);
        expect(sut.isEditing, isFalse);
      });

      test('有効なユーザー名に戻すと検証エラーが解消される', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        sut.startEditing();
        sut.updateUserName("a" * 21);

        sut.updateUserName("validUsername");

        expect(sut.hasValidationError, isFalse);
        expect(sut.isEditing, isTrue);
      });

      test('保存に成功すると編集状態が終了し、新しい名前が表示される', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        sut.startEditing();

        const newUserName = "newUserName";
        sut.updateUserName(newUserName);

        // モックの設定
        when(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .thenAnswer((_) async => {});

        await sut.save();

        verify(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .called(1);
        expect(sut.isEditing, isFalse);
        expect(sut.userName, newUserName);
      });

      test('保存に失敗するとエラー状態になり、編集前の名前が表示される', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        const newUserName = "newUserName";

        sut.startEditing();
        sut.updateUserName(newUserName);

        // モックの設定
        when(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .thenThrow(Exception('保存に失敗しました'));

        await sut.save();

        verify(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .called(1);
        expect(sut.isEditing, isFalse);
        expect(sut.userName, userName.value);
        expect(sut.hasSaveError, isTrue);
      });

      test('保存に失敗後にエラーをクリアすると、編集前の名前が表示される', () async {
        final sut = SettingsViewModel(
          publicProfileRepository: mockRepository,
        );
        await sut.init(userId);
        const newUserName = "newUserName";

        sut.startEditing();
        sut.updateUserName(newUserName);

        // モックの設定
        when(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .thenThrow(Exception('保存に失敗しました'));

        await sut.save();
        sut.clearSaveError();

        verify(mockRepository.updateUserName(userId, UserNameVo(newUserName)))
            .called(1);
        expect(sut.isEditing, isFalse);
        expect(sut.userName, "testUserName");
        expect(sut.hasSaveError, isFalse);
      });
    });
  });
}
