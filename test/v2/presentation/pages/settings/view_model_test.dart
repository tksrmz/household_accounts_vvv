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

  tearDown(() {
    // モックのクリーンアップ
    reset(mockRepository);
  });

  test('初期化前はModelが初期値であり、エラー状態ではない', () {
    final sut = SettingsViewModel(
      publicProfileRepository: mockRepository,
    );

    verifyNoMoreInteractions(mockRepository);
    expect(sut.value.isUninitialized, isTrue);
    expect(sut.value.userName, UserNameVo.empty);
    expect(sut.value.isFailed, isFalse);
  });

  group('初期化に成功したとき', () {
    setUp(() {
      // mock
      when(mockRepository.fetchUserName(userId)).thenAnswer(
        (_) async => UserNameVo("testUserName"),
      );
    });

    test('Modelを取得でき、エラー状態ではない', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      await sut.init(userId);

      verify(mockRepository.fetchUserName(userId)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.userName, UserNameVo("testUserName"));
      expect(sut.value.isFailed, isFalse);
    });

    test('notifyListeners()を呼び出している', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(userId);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isFalse);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      var counter = 0;
      sut.addListener(() {
        counter = counter + 1;
      });

      expect(counter, 0);
      await sut.init(userId);
      expect(counter, 1);
      await sut.init(userId);
      expect(counter, 1);
    });
  });

  group('初期化に失敗したとき', () {
    setUp(() {
      when(mockRepository.fetchUserName(any)).thenThrow(
        Exception('テスト：エラーが発生しました'),
      );
    });

    test('エラー状態になり、Modelは初期値である', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      await sut.init(userId);

      verify(mockRepository.fetchUserName(userId)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.userName, UserNameVo.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('notifyListeners()を呼び出している', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(userId);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isTrue);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SettingsViewModel(
        publicProfileRepository: mockRepository,
      );
      var counter = 0;
      sut.addListener(() {
        counter = counter + 1;
      });

      expect(counter, 0);
      await sut.init(userId);
      expect(counter, 1);
      await sut.init(userId);
      expect(counter, 1);
    });
  });
}
