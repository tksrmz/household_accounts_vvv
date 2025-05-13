import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/page.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../test-util/golden_helper.dart';
@GenerateNiceMocks([MockSpec<PublicProfileRepository>()])
import 'page_test.mocks.dart';

void main() {
  const userId = UserIdVo('testUserId');
  final mockRepository = MockPublicProfileRepository();
  final buildTarget = (WidgetTester tester) async {
    // golden file size is 320 * 600
    final newSize = Size(320, 600) * tester.view.devicePixelRatio;
    tester.view.physicalSize = newSize;
    final widget = Provider<UserAuth>(
      create: (_) => UserAuth(uid: UserIdVo('testUserId')),
      child: GoldenPageWrapper(
        child: SettingsPage(
          viewModel: SettingsViewModel(
            publicProfileRepository: mockRepository,
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    return widget;
  };

  tearDown(() {
    // モックのクリーンアップ
    reset(mockRepository);
  });

  group('SettingsPage', () {
    group('画面全体', () {
      final getFileName =
          (WidgetTester tester) => 'goldens/${tester.testDescription}.png';
      testWidgets(
        '画面を開くとローディング画面が表示されること',
        (tester) async {
          when(mockRepository.fetchUserName(any)).thenAnswer(
            (_) => Completer<UserNameVo>().future,
          );

          await buildTarget(tester);

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        'ローディングに成功するとコンテンツが表示されること',
        (tester) async {
          when(mockRepository.fetchUserName(any)).thenAnswer(
            (_) async => UserNameVo('うえだぎじゅつ'),
          );

          await buildTarget(tester);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        'ローディングに失敗するとエラーメッセージが表示されること',
        (tester) async {
          when(mockRepository.fetchUserName(any)).thenThrow(
            Exception('fetchUserNameエラー'),
          );

          final widget = await buildTarget(tester);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );
    });

    group('ユーザー名編集', () {
      const userName = UserNameVo('testUserName');
      final getFileName = (WidgetTester tester) =>
          'goldens/name-editing/${tester.testDescription}.png';

      setUp(() {
        when(mockRepository.fetchUserName(userId))
            .thenAnswer((_) async => userName);
      });

      // 初期化後の状態は画面全体のテストで確認できるためスキップする
      // testWidgets('初期化後はユーザー名が編集状態ではない', (tester) async {
      // }, tags: ['golden']);

      testWidgets(
        'ユーザー名を選択すると編集状態になること',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        'ユーザー名を0文字にするとエラーメッセージが表示されること',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '');
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        'ユーザー名を21文字にするとエラーメッセージが表示されること',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'a' * 21);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        '有効なユーザー名に戻すと検証エラーが解消される',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '');
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        '保存に成功すると、新しい名前が表示される',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
          await tester.pumpAndSettle();

          // モックの設定
          when(mockRepository.updateUserName(any, any))
              .thenAnswer((_) async => {});

          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        '保存に失敗するとスナックバーが表示され、編集前の名前が表示される',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
          await tester.pumpAndSettle();

          // モックの設定
          when(mockRepository.updateUserName(any, any))
              .thenThrow(Exception('保存に失敗しました'));

          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );
    });
  });
}
