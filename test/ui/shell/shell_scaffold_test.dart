import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/pair_status.dart';
import 'package:household_accounts/ui/shell/shell_scaffold.dart';
import 'package:household_accounts/ui/shell/shell_view_model.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/presentation/pages/state_managements/selected_note_state.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/golden_helper.dart';

// なぜtestGoldensのexpectFnで直接ドロワーをtapしてよいか:
// golden_helper.dartのtestGoldensは`await expectFn?.call(tester)`を
// `matchesGoldenFile`の直前・pumpWidgetの直後に呼ぶだけであり、tester操作に
// 制約はない。ShellScaffold自身がAppBar+Drawerを持つ1つのScaffoldであるため、
// ハンバーガーアイコンはそのScaffold自身のドロワーを開閉する
// (`_GoldenWrapper`の外側Scaffoldにはdrawerを渡していないため衝突しない)。
void main() {
  group('golden', () {
    testGoldens(
      'ペアがいない状態でタブ0(プレースホルダbody)を表示する',
      goldenFileName: 'shell_scaffold_personal',
      builder: () => ShellScaffold(
        currentIndex: 0,
        onSelectTab: (_) {},
        onOpenSettings: () {},
        viewModel: _buildFixture(pairId: null).viewModel,
        body: const SizedBox.expand(),
      ),
      expectFn: (tester) async {
        // pairIdストリームの発行(null)を反映させる
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      'ペアがいる状態(personalモード)でドロワーを開く',
      goldenFileName: 'shell_scaffold_drawer_with_pair',
      builder: () => ShellScaffold(
        currentIndex: 0,
        onSelectTab: (_) {},
        onOpenSettings: () {},
        viewModel: _buildFixture().viewModel,
        body: const SizedBox.expand(),
      ),
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      'ペアがいる状態(sharedモード)でドロワーを開く',
      goldenFileName: 'shell_scaffold_drawer_shared',
      builder: () => ShellScaffold(
        currentIndex: 0,
        onSelectTab: (_) {},
        onOpenSettings: () {},
        viewModel: _buildFixture(initialNote: SelectedNote.shared).viewModel,
        body: const SizedBox.expand(),
      ),
      expectFn: (tester) async {
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
      },
    );
  });

  group('操作', () {
    testWidgets('タブをタップしたとき、onSelectTabへそのインデックスが渡ること', (tester) async {
      int? selectedIndex;
      await _pumpScaffold(
        tester,
        onSelectTab: (index) => selectedIndex = index,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('予算'),
        ),
      );
      await tester.pump();

      expect(selectedIndex, 5);
    });

    testWidgets('ペアがないとき、ノート切替タイルが表示されないこと', (tester) async {
      await _pumpScaffold(tester, pairId: null);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('ふたりの家計簿を見る'), findsNothing);
    });

    testWidgets('ノート切替タイルをタップしたとき、SelectedNoteStateが切り替わりドロワーが閉じること', (
      tester,
    ) async {
      final fixture = await _pumpScaffold(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isTrue,
      );

      await tester.tap(find.text('ふたりの家計簿を見る'));
      await tester.pumpAndSettle();

      expect(fixture.selectedNoteState.value, SelectedNote.shared);
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
    });

    testWidgets('ログアウトアイコンを押したとき、AuthRepositoryのsignOutが実行されること', (
      tester,
    ) async {
      final fixture = await _pumpScaffold(tester);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(fixture.authRepository.signOutCallCount, 1);
    });

    testWidgets('設定タイルをタップしたとき、onOpenSettingsが呼ばれること', (tester) async {
      var settingsOpened = false;
      await _pumpScaffold(tester, onOpenSettings: () => settingsOpened = true);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('設定'));
      await tester.pumpAndSettle();

      expect(settingsOpened, isTrue);
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.authRepository,
    required this.selectedNoteState,
  });

  final ShellViewModel viewModel;
  final FakeAuthRepository authRepository;
  final SelectedNoteState selectedNoteState;
}

_Fixture _buildFixture({
  String? pairId = 'pair-id',
  SelectedNote initialNote = SelectedNote.personal,
}) {
  final pairStatusController = StreamController<PairStatus>();
  final authRepository = FakeAuthRepository(
    currentUser: const UserAuth(uid: UserIdVo('test-uid')),
  );
  final selectedNoteState = SelectedNoteState();
  if (initialNote == SelectedNote.shared) {
    selectedNoteState.select(SelectedNote.shared);
  }
  final viewModel = ShellViewModel(
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
    watchPairStatus: (_) => pairStatusController.stream,
  );
  // シングルサブスクリプションストリームはlisten後のaddで問題なく配送される。
  pairStatusController.add(
    pairId == null
        ? const PairStatus.notPaired()
        : PairStatus.paired(PairId(pairId)),
  );

  return _Fixture(
    viewModel: viewModel,
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
  );
}

Future<_Fixture> _pumpScaffold(
  WidgetTester tester, {
  String? pairId = 'pair-id',
  SelectedNote initialNote = SelectedNote.personal,
  void Function(int)? onSelectTab,
  VoidCallback? onOpenSettings,
}) async {
  final fixture = _buildFixture(pairId: pairId, initialNote: initialNote);

  await tester.pumpWidget(
    MaterialApp(
      home: ShellScaffold(
        currentIndex: 0,
        onSelectTab: onSelectTab ?? (_) {},
        onOpenSettings: onOpenSettings ?? () {},
        viewModel: fixture.viewModel,
        body: const SizedBox.expand(),
      ),
    ),
  );
  // pairIdストリームの発行を反映させる
  await tester.pump();

  return fixture;
}
