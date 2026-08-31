import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../presentation/budget_viewer/budget_viewer_page.dart';
import '../presentation/category_viewer/category_viewer_page.dart';
import '../presentation/property_viewer/property_viewer_page.dart';
import '../domain/models/notebook.dart';
import '../domain/models/user_auth.dart';
import '../ui/calendar/calendar_screen_host.dart';
import '../ui/dashboard/dashboard_screen_host.dart';
import '../ui/record_entry/record_entry_screen_host.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/settings/settings_view_model.dart';
import '../ui/shell/shell_screen_host.dart';
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
      final isSignedIn = authRepository.getCurrentUser() is UserAuthSignedIn;
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
                builder: (context, state) => _notebookScoped(
                  (notebook) => DashboardScreenHost(
                    key: ValueKey(notebook),
                    notebook: notebook,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.entry,
                builder: (context, state) => _notebookScoped(
                  (notebook) => RecordEntryScreenHost(key: ValueKey(notebook)),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.calendar,
                builder: (context, state) => _notebookScoped(
                  (notebook) => CalendarScreenHost(key: ValueKey(notebook)),
                ),
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

/// サインイン済みユーザーの選択中ノートを解決し、[builder] へ渡す。
///
/// ノート切替時にViewModelを作り直すため、SelectedNoteStateの変化で
/// 再buildされ、ValueKeyの変化によりHostのStateごと再生成される(旧ViewModelの
/// disposeで購読解除、新ViewModelが新しいRepositoryを購読する)。[builder] 側で
/// `ValueKey(notebook)` を付与すること。
Widget _notebookScoped(Widget Function(Notebook notebook) builder) {
  return Builder(
    builder: (context) {
      final userAuth = context.watch<UserAuth>();
      // サインアウト直後、redirectがサインイン画面へ遷移するまでの
      // 一瞬だけ未サインイン状態で再buildされうる。その間は何も
      // 描画しない(無効なuidで購読を開始しないため)
      if (userAuth is! UserAuthSignedIn) {
        return const SizedBox.shrink();
      }
      final notebook = context.watch<SelectedNoteState>().resolve(userAuth.uid);
      return builder(notebook);
    },
  );
}
