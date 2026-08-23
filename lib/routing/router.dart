import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../presentation/budget_viewer/budget_viewer_page.dart';
import '../presentation/category_viewer/category_viewer_page.dart';
import '../presentation/monthly_record_viewer/monthly_record_viewer_page.dart';
import '../presentation/property_viewer/property_viewer_page.dart';
import '../presentation/record_register/record_register_page.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/settings/settings_view_model.dart';
import '../ui/shell/shell_screen_host.dart';
import '../v2/domain/models/user_auth.dart';
import '../v2/presentation/pages/dashboard/page.dart';
import '../v2/presentation/pages/dashboard/view_model.dart';
import '../v2/presentation/pages/state_managements/selected_note_state.dart';
import 'routes.dart';

/// StreamをGoRouterのrefreshListenableへ橋渡しする。
///
/// go_router側のGoRouterRefreshStreamはAPI存続が不明瞭なため自前で持つ
/// (約10行・版非依存)。
class StreamRefreshListenable extends ChangeNotifier {
  StreamRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// アプリのルーターを生成する。
GoRouter createRouter({
  required AuthRepository authRepository,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: refreshListenable,
    // ProviderではなくAuthRepositoryを直接読む: redirectはProviderツリーの
    // 構築タイミングに左右されずに評価される必要があるため。
    redirect: (context, state) {
      final isSignedIn = authRepository.getCurrentUser() != UserAuth.notSignIn;
      final isAtSignIn = state.matchedLocation == Routes.signIn;

      if (!isSignedIn) {
        return isAtSignIn ? null : Routes.signIn;
      }
      if (isAtSignIn) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) =>
            ui.SignInScreen(providers: [ui.EmailAuthProvider()]),
      ),
      // ボトムナビを覆う従来挙動に合わせ、シェルの外(ルートレベル)へ置く
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => SettingsScreen(
          viewModel: SettingsViewModel(
            profileRepository: context.read(),
            authRepository: context.read(),
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreenHost(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => Builder(
                  builder: (context) {
                    // ノート切替時にDashboardViewModelを作り直す
                    // ProxyProvider2が上流で新Repositoryへ差し替わった後に
                    // このwatchで再buildされる。
                    context.watch<SelectedNoteState>();

                    final now = DateTime.now();
                    final userAuth = context.read<UserAuth>();
                    return DashboardPage(
                      viewModel: DashboardViewModel(
                        incomeRepository: context.read(),
                        expenseRepository: context.read(),
                        publicProfileRepository: context.read(),
                        date: now,
                        userId: userAuth.uid,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.entry,
                builder: (context, state) => const RecordInputPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.calendar,
                builder: (context, state) => const CalendarRecordViewPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.properties,
                builder: (context, state) => const PropertyListBody(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.categories,
                builder: (context, state) => const CategoryListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.budget,
                builder: (context, state) => const BudgetViewerPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
