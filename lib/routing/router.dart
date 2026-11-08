import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../domain/models/category.dart';
import '../domain/models/notebook.dart';
import '../domain/models/property.dart';
import '../domain/models/user_auth.dart';
import '../ui/budget/budget_screen_host.dart';
import '../ui/calendar/calendar_screen_host.dart';
import '../ui/calendar/daily_records_screen_host.dart';
import '../ui/categories/categories_screen_host.dart';
import '../ui/categories/category_editor_screen_host.dart';
import '../ui/dashboard/dashboard_screen_host.dart';
import '../ui/properties/properties_screen_host.dart';
import '../ui/properties/property_editor_screen_host.dart';
import '../ui/record_entry/record_entry_screen_host.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/settings/settings_view_model.dart';
import '../ui/shell/shell_screen_host.dart';
import '../ui/core/selected_notebook.dart';
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
      // 日次明細もボトムナビを覆う(旧実装のrootNavigatorへのpushに合わせる)
      GoRoute(
        path: Routes.calendarDay,
        builder: (context, state) {
          // 遷移経路はカレンダーの日セルだけであり、パラメータはアプリが
          // 組み立てる([Routes.calendarDayOf])。解釈できない値が来るのは
          // 実装の不具合であるため、FormatExceptionでfail fastさせる。
          final date = DateTime.parse(state.pathParameters['date']!);
          return _notebookScoped(
            (notebook) => DailyRecordsScreenHost(
              key: ValueKey(notebook),
              year: date.year,
              month: date.month,
              day: date.day,
            ),
          );
        },
      ),
      // 資産エディタもボトムナビを覆う(旧実装のrootNavigatorへのpushに合わせる)。
      // シェル内の資産一覧(/properties)とパスの先頭を共有するが、一覧のルートは
      // 子ルートを持たないため /properties/new 等には一致せず、衝突しない
      GoRoute(
        path: Routes.propertyNew,
        builder: (context, state) => _notebookScoped(
          (notebook) => PropertyEditorScreenHost(key: ValueKey(notebook)),
        ),
      ),
      GoRoute(
        path: Routes.propertyEdit,
        builder: (context, state) {
          // 遷移経路は資産一覧の編集ボタンだけであり、編集対象はアプリが
          // extraへ渡す。Propertyでない値が来るのは実装の不具合であるため、
          // ArgumentErrorでfail fastさせる。
          final property = state.extra;
          if (property is! Property) {
            throw ArgumentError.value(
              property,
              'extra',
              '資産の編集画面には編集対象のPropertyを渡す必要があります',
            );
          }
          return _notebookScoped(
            (notebook) => PropertyEditorScreenHost(
              key: ValueKey(notebook),
              property: property,
            ),
          );
        },
      ),
      // カテゴリエディタも資産エディタと同じくボトムナビを覆う。一覧のルート
      // (/categories)は子ルートを持たないため、/categories/new 等とは衝突しない
      GoRoute(
        path: Routes.categoryNew,
        builder: (context, state) => _notebookScoped(
          (notebook) => CategoryEditorScreenHost.add(key: ValueKey(notebook)),
        ),
      ),
      GoRoute(
        path: Routes.categoryEdit,
        builder: (context, state) {
          // 遷移経路はカテゴリ一覧の編集ボタンだけであり、編集対象はアプリが
          // extraへ渡す。収入カテゴリと支出カテゴリには共通の上位型がないため
          // ここで型を見て分け、どちらでもない値が来たら実装の不具合として
          // ArgumentErrorでfail fastさせる。
          final category = state.extra;
          return switch (category) {
            IncomeCategory() => _notebookScoped(
              (notebook) => CategoryEditorScreenHost.editIncome(
                key: ValueKey(notebook),
                category: category,
              ),
            ),
            ExpenseCategory() => _notebookScoped(
              (notebook) => CategoryEditorScreenHost.editExpense(
                key: ValueKey(notebook),
                category: category,
              ),
            ),
            _ => throw ArgumentError.value(
              category,
              'extra',
              'カテゴリの編集画面には編集対象のIncomeCategoryかExpenseCategoryを渡す必要があります',
            ),
          };
        },
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
                builder: (context, state) => _notebookScoped(
                  (notebook) => PropertiesScreenHost(key: ValueKey(notebook)),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.categories,
                builder: (context, state) => _notebookScoped(
                  (notebook) => CategoriesScreenHost(key: ValueKey(notebook)),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.budget,
                builder: (context, state) => _notebookScoped(
                  (notebook) => BudgetScreenHost(key: ValueKey(notebook)),
                ),
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
/// ノート切替時にViewModelを作り直すため、SelectedNotebookの変化で
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
      final notebook = context.watch<SelectedNotebook>().resolve(userAuth.uid);
      return builder(notebook);
    },
  );
}
