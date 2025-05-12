import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:household_accounts/v2/domain/repositories/public_profile_repository.dart';
import 'package:household_accounts/v2/presentation/pages/settings/page.dart';
import 'package:household_accounts/v2/presentation/pages/settings/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../test-util/golden_helper.dart';
@GenerateNiceMocks([MockSpec<PublicProfileRepository>()])
import 'page_test.mocks.dart';

void main() {
  const userId = UserIdVo('testUserId');
  final mockRepository = MockPublicProfileRepository();
  final buildTarget = () => GoldenWrapper(
        child: SettingsPage(
          userId: userId,
          viewModel: SettingsViewModel(
            publicProfileRepository: mockRepository,
          ),
        ),
      );

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

          await tester.pumpWidget(buildTarget());

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

          await tester.pumpWidget(buildTarget());

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

          await tester.pumpWidget(buildTarget());

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
