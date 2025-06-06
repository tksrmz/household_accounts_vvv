import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/auth_repository.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/page.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../test-util/golden_helper.dart';
@GenerateNiceMocks([
  MockSpec<PublicProfileRepository>(),
  MockSpec<AuthRepository>(),
])
import 'page_test.mocks.dart';

void main() {
  const userId = UserIdVo('testUserId');
  final mockPublicProfileRepository = MockPublicProfileRepository();
  final mockAuthRepository = MockAuthRepository();
  final buildTarget = (WidgetTester tester) async {
    // golden file size is 320 * 600
    final newSize = Size(320, 600) * tester.view.devicePixelRatio;
    tester.view.physicalSize = newSize;
    await tester.pumpWidget(
      Provider<UserAuth>(
        create: (_) => UserAuth(uid: UserIdVo('testUserId')),
        child: GoldenPageWrapper(
          child: SettingsPage(
            viewModel: SettingsViewModel(
              publicProfileRepository: mockPublicProfileRepository,
              authRepository: mockAuthRepository,
            ),
          ),
        ),
      ),
    );
  };

  tearDown(() {
    // モックのクリーンアップ
    reset(mockPublicProfileRepository);
    reset(mockAuthRepository);
  });

  group('SettingsPage', () {
    setUp(() {
      when(mockAuthRepository.getCurrentUser())
          .thenReturn(UserAuth(uid: userId));
    });

    group('画面全体', () {
      final getFileName =
          (WidgetTester tester) => 'goldens/${tester.testDescription}.png';

      testWidgets(
        '画面を開くとローディング画面が表示されること',
        (tester) async {
          when(mockPublicProfileRepository.fetchUserName(any)).thenAnswer(
              (_) => Completer<Either<Exception, UserNameVo>>().future);

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
          when(mockPublicProfileRepository.fetchUserName(any))
              .thenAnswer((_) async => Right(UserNameVo('うえだぎじゅつ')));

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
          when(mockPublicProfileRepository.fetchUserName(any))
              .thenAnswer((_) async => Left(Exception('fetchUserNameエラー')));

          await buildTarget(tester);
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
        when(mockPublicProfileRepository.fetchUserName(userId))
            .thenAnswer((_) async => Right(userName));
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
        'テキストフィールドにフォーカスが当たると編集状態になること',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          // フォーカスを当てる
          await tester.showKeyboard(find.byType(TextField));
          await tester.pumpAndSettle();

          // 編集状態になっていることを確認（保存ボタンが表示される）
          expect(find.text('保存'), findsOneWidget);

          await expectLater(
            find.byType(SettingsPage),
            matchesGoldenFile(getFileName(tester)),
          );
        },
        tags: ['golden'],
      );

      testWidgets(
        '0文字のユーザー名はバリデーションエラーで保存に失敗すること',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '');
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
        '有効なユーザー名に戻すと検証エラーが解消される',
        (tester) async {
          when(mockPublicProfileRepository.updateUserName(
                  userId, UserNameVo('Gijutsu Ueda')))
              .thenAnswer((_) async => Right<Exception, Unit>(unit));

          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '');
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
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
        '保存に成功すると、新しい名前が表示される',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
          await tester.pumpAndSettle();

          // モックの設定
          when(mockPublicProfileRepository.updateUserName(any, any))
              .thenAnswer((_) async => Right(unit));

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
          when(mockPublicProfileRepository.updateUserName(any, any))
              .thenAnswer((_) async => Left(Exception('保存に失敗しました')));

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
        '失敗したあとに再度編集して保存できる',
        (tester) async {
          await buildTarget(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.text(userName.value));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'Gijutsu Ueda');
          await tester.pumpAndSettle();

          // モックの設定
          when(mockPublicProfileRepository.updateUserName(any, any))
              .thenAnswer((_) async => Left(Exception('保存に失敗しました')));

          await tester.tap(find.text('保存'));
          // スナックバー表示確認
          await tester.pumpAndSettle();
          expect(find.text('ユーザー名の保存に失敗しました'), findsOneWidget);

          // 再度編集
          await tester.enterText(find.byType(TextField), 'ソフト テス太');
          await tester.pumpAndSettle();

          // モックの設定
          when(mockPublicProfileRepository.updateUserName(any, any))
              .thenAnswer((_) async => Right(unit));

          // 保存
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          // メモ：スナックバーが表示されてから消えるのに十分な時間が立っていないため、
          // ゴールデンファイルにスナックバーの表示が残っている
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
