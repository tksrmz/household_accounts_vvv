# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app for household expense tracking (income / expense / transfer records, assets, categories with budgets, calendar and budget views) using Firebase as the backend. A personal notebook and a notebook shared with a paired user have the same structure and features. The app follows the MVVM architecture of the official Flutter [App architecture](https://docs.flutter.dev/app-architecture) guide: a UI layer and a data layer, plus domain models used by both (no UseCase layer).

For detailed information, refer to the following documentation:

- @docs/architecture.md - Architecture overview, data flow, error handling, DI, routing and data-layer policies
- @docs/style_guide.md - Development conventions, coding standards, test policy and libraries
- @docs/firestore_schema.md - Database schema and data structure definitions
- @docs/firestore_constraints.md - Database constraints and business rules

## Monorepo Structure

This repository contains both the app and its backend:

- Repository root: the Flutter app
- `firebase/`: the Firebase backend (TypeScript Cloud Functions in `firebase/functions/`, `firebase/firestore.rules`, Hosting content in `firebase/public/`)

Notes:

- Firebase CLI commands (`firebase deploy`, `firebase emulators:start`) are run from `firebase/`
- Windowsでは、miseで入れた `firebase`(単体バイナリ)で `firebase deploy` や、Functionsエミュレータを含む `firebase emulators:*` を実行しないこと。単体バイナリは中にNode 20.18.2を持っていて、`deploy` はpredeployの `npm run lint` がそのnpmで動いて失敗し、`emulators:exec` はFunctionsエミュレータが起動できずテストが始まらないまま止まる(どちらも15.37.0で確認)。代わりに `mise.toml` の `firebase` と同じバージョンをnpmから取り、miseのNode 22で動かす: `npx firebase-tools@<mise.tomlのfirebaseのバージョン> deploy --only functions --project production`(エミュレータも同様に `npx firebase-tools@<バージョン> emulators:exec ...`)
- Cloud Functionsの本番デプロイはCIが行う: `firebase/functions/**` などを変えたPRがmasterに入ると `.github/workflows/functions-deploy.yml` が動き、`production-functions` エンバイロメントの承認の後にデプロイし、本番がADR-001(Node.js 22・1st gen)に沿っていることを確かめる。手でのデプロイはCIが使えないときだけにする。手順と前提の設定は `docs/functions_deploy.md`(2026-11-23時点で前提の設定は未了で、CIからのデプロイはまだ成功していない)
- ADRのコンプライアンスのうちファイルで確かめられるものは `docs/adr/checks/NNN-*.test.mjs` にあり、全PRで `adr-compliance.yml` が走らせる。ローカルでは `node --test "docs/adr/checks/*.test.mjs"`
- Backend tests run online against the dev project: `npm --prefix firebase/functions test`
- Emulator ports are defined in `firebase/firebase.json` (Firestore: 8081, Auth: 9099) and must stay in sync with `lib/main.dart`

## Development Commands

### 環境の前提(mise)

flutter / dart / firebase / node はmiseで管理されており、シェルの初期PATHからは見えない。**コマンド実行のたびにshimsをPATHへ前置すること**(シェル状態は持続しない):

```powershell
$env:Path = "$env:LOCALAPPDATA\mise\shims;$env:Path"
```

```bash
export PATH="$HOME/AppData/Local/mise/shims:$PATH"
```

ツールのバージョンはリポジトリ直下の `mise.toml`(+ `mise.lock`)が**唯一の正**。CIの全ワークフローも `jdx/mise-action` で同じファイルを読むため、ローカルとCIで同じバージョンになる:

- ワークフローやcomposite actionにバージョンを直書きしない(`subosito/flutter-action`・`setup-java`・`setup-node` は使わない)。ジョブで使うツールは `MISE_ENABLE_TOOLS` で絞る
- バージョンを上げるときは `mise.toml` を書き換えてから `mise lock --platform linux-x64,windows-x64` を実行し、`mise.lock` も一緒にコミットする(Dependabotは `mise.toml` を更新できないため手動)
- 個人的な上書きは `mise.local.toml`(gitignore済み)で行う

### Build & Run

```bash
flutter run                           # Run on connected device/emulator
flutter build apk                     # Build Android APK
flutter build ipa                     # Build iOS app
```

### Code Generation

```bash
dart run build_runner build           # Generate code for freezed
dart run build_runner build --delete-conflicting-outputs  # Force rebuild
```

### Testing

```bash
flutter test                          # Run all unit and widget tests
flutter test --coverage              # Run tests with coverage
flutter test -t golden               # Run golden file tests only
```

### Integration Testing

実行手順の正は `integration_test/README.md`(前提: functionsのビルド(node 22)・Androidエミュレータ・Firebaseエミュレータ)。要点:

- `firebase/` から `emulators:exec` で実行し(Windowsでは単体バイナリの `firebase` でなく `npx firebase-tools@<mise.tomlのfirebaseのバージョン>` で。上のMonorepoのNotes参照)、**`--project household-accounts-1129d` と `--import ../integration_test/saved-data` は必須**。前者を欠くとFunctionsトリガが発火せず全テストがローディングでタイムアウトし、後者を欠くとシードユーザー不在で既存ユーザー系のテストが失敗する
- Windowsでは `emulators:exec` がスクリプトをcmd経由で実行するため `run.sh` を直接渡せない。代わりにコマンド文字列 `"cd .. && flutter test integration_test/integration_test.dart -d <deviceId>"` を渡す

### Golden Tests(canonical運用)

- 正本golden(`test/**/golden{,s}/**/*.png`)は**CI管理**。ローカルでのコミットは追加・変更・**削除**のいずれもpre-commitフック(`.githooks/pre-commit`)が拒否する。更新はPR作成後に `update-canonical-goldens.yml` をworkflow dispatchする(botがPRブランチへコミットし、参照されなくなった正本の削除も同時に行う)
- ローカル実行はgitignoreされた `.local/` 配下の基準画像と比較する。基準が無い環境では先に `flutter test --tags golden --update-goldens` で生成してから通常実行する

### Linting & Analysis

```bash
flutter analyze                       # Static analysis
dart analyze                          # Static analysis + household_lintsの規約lint
dart format .                         # Format code
```

Repository規約のlint(`packages/household_lints`)の検証には必ず `dart analyze` を使うこと。`flutter analyze` の一発実行はanalyzer pluginの診断をタイミング依存で取りこぼすため、規約違反の検知を保証しない(CIも同じ理由で `dart analyze` を使用している。詳細は `.github/workflows/pr-ci.yml` のコメント参照)。

## Architecture Overview

Two layers plus shared domain models. Dependencies point one way: UI → data. For comprehensive details, see @docs/architecture.md.

```
lib/
├── main.dart, firebase_options.dart
├── config/dependencies.dart   # appProviders(): Repositories and shared state
├── routing/                   # router.dart (go_router), routes.dart (path constants)
├── domain/models/             # freezed domain models, one type per file
├── data/repositories/<feature>/  # abstract Repository + Firestore implementation + DTO
│   └── firestore_shared/notebook_paths.dart
├── ui/
│   ├── core/                  # SelectedNotebook, Formatter, theme, shared widgets
│   ├── auth/                  # sign-in screen (the only place importing firebase_ui_auth)
│   ├── shell/                 # bottom navigation + drawer (notebook switch, logout)
│   └── dashboard/ record_entry/ calendar/ properties/ categories/ budget/ settings/
└── utils/                     # result.dart, command.dart, combine_latest.dart
```

### UI Layer (`lib/ui/`)

- **Screen** (`*_screen.dart`): builds widgets only; receives its ViewModel via the constructor and listens with `ListenableBuilder`
- **Host** (`*_screen_host.dart`): a `StatefulWidget` that creates the ViewModel in `initState` (Repositories via `context.read()`) and disposes it
- **ViewModel** (`*_view_model.dart`): `ChangeNotifier`; subscribes to Repository watches and exposes writes as `Command`s. ViewModel and Screen are 1:1. ViewModels are never registered in Provider
- Shared UI state across screens lives in `lib/ui/core/` (`SelectedNotebook`: the selected notebook kind and the pair ID)

### Domain Models (`lib/domain/models/`)

- Immutable freezed types: IDs (`RecordId`, `PropertyId`, ...), validated values (`Amount`, `RecordNote`, `CategoryName`, `PropertyName`, `UserName`, `Budget`), the unvalidated `RecordDate` (see below), entities (`Record` sealed union, `IncomeCategory`/`ExpenseCategory`, `Property`), `RecordContent`, `Period`/`FiscalMonth`, `Notebook`, `UserAuth`, `PairStatus`
- Small tuples are named-record typedefs, not freezed: `BalanceEffect`, `CategorySpending`
- Aggregations are pure functions on domain models (`RecordSummary.from`, `BudgetSummary.from`)

### Data Layer (`lib/data/repositories/`)

- Five Repositories: Auth, Profile, Record, Category, Property. Each is an `abstract interface class` with a Firestore implementation in the same folder
- Implementations use `cloud_firestore` directly (no wrapper layer between Repository and SDK). `withConverter` is not used
- Record / Category / Property: DTOs read documents (`fromSnapshot` → `toDomain()`, bad fields → `FormatException`); write JSON is built by top-level functions in the DTO file. `FirestoreProfileRepository` has no DTO and reads/writes document fields directly (a missing user name throws a plain `Exception`)
- One implementation per data type for both notebooks: the constructor takes a `Notebook`, and `notebookPath()` resolves `personalNotes/{uid}` or `sharedNotes/{pairId}`

## Key Architectural Patterns

### Data Flow

- Reads are watches: Repositories return plain `Stream<T>` backed by `snapshots()`, so changes from other devices or the paired user appear without reloading
- Writes and one-shot reads return `Future<Result<T>>`. ViewModels run them through `Command0` / `Command1` (`lib/utils/command.dart`), which expose `running` and the latest `Result` and block double execution. Streaming subscriptions are not wrapped in Commands
- Validation is a UI-layer concern held in ViewModel state (live validation; the save button is disabled while invalid). Save Commands accept only validated types (e.g. `Command1<void, UserName>`), so `Result.error` means a data-layer failure only

### Error Handling

- `Result<T>` (`lib/utils/result.dart`) is a sealed class (`Ok` / `Error`). Every public `Future<Result<T>>` method of a Repository implementation must be the one-liner `=> Result.guard(() => ...)` (no hand-written try/catch). `Result.guard` converts `Exception`s only; Dart `Error`s propagate (fail fast). Enforced by `packages/household_lints` via `dart analyze`
- Stream subscriptions must pass `onError`: an `Exception` becomes an error state (and is logged with `developer.log`), an `Error` is rethrown with `Error.throwWithStackTrace`
- Validated value types check in their constructors in all builds: `FormatException` for values a user can enter, `ArgumentError` for system invariants (IDs). They expose `static bool isValid(...)` for live validation
- Don't show un-actionable error screens for bad data: prevent invalid data at the source (input validation and Firestore Rules). Load failures (network, permissions) may show an error

### Dependency Injection

- `provider` only. `appProviders()` in `lib/config/dependencies.dart` registers `SelectedNotebook` (`ChangeNotifierProvider`), `AuthRepository`, `FirebaseFirestore`, `ProfileRepository`, `StreamProvider<UserAuth>` (`lazy: false` is required) and the notebook-dependent Repositories via `ProxyProvider2<SelectedNotebook, UserAuth, XxxRepository>`
- On a notebook switch, routes rebuild notebook-dependent Hosts with `ValueKey(notebook)`, so the old ViewModel is disposed (unsubscribed) and a new one subscribes to the new Repository
- On a displayed-period change (calendar month, budget period/mode), the ViewModel itself cancels and re-subscribes `watchPeriod`; it is not recreated
- The settings route's builder creates `SettingsViewModel` directly (no Host, never disposed, recreated if the builder re-runs). This is a legacy exception that is harmless only because that ViewModel holds no subscriptions; new screens use a Host

### Routing

- `go_router` with an auth `redirect` (reads `AuthRepository` directly; `/sign-in` ↔ `/dashboard`)
- Tabs are `StatefulShellRoute.indexedStack` branches (`/dashboard`, `/entry`, `/calendar`, `/properties`, `/categories`, `/budget`). Screens that cover the bottom navigation are root-level routes opened with `context.push` (`/settings`, `/calendar/:date`, `/properties/new|edit`, `/categories/new|edit`)
- Editor targets are passed via `extra`; an unexpected type is a bug and throws `ArgumentError`. The daily view's `:date` is built by the app (`Routes.calendarDayOf`); an unparsable value makes `DateTime.parse` throw an uncaught `FormatException`

### Records and Asset Balances

- `RecordRepository.add` uses a `WriteBatch` (no reads); `delete` uses `runTransaction` (re-reads the stored record to revert its balance effects). Criterion: whether the operation reads. No shared transaction runner
- Asset/category deletion has no reference guard (it cannot be made atomic or offline-safe); a confirmation dialog guards against mistakes, and dangling references are shown as 「削除済み」

## Code Conventions

For complete coding standards and patterns, see @docs/style_guide.md.

### File Structure

```
lib/ui/<feature>/
├── <feature>_screen.dart          # Screen widget
├── <feature>_screen_host.dart     # Owns the ViewModel's lifecycle
├── <feature>_view_model.dart      # State management
└── widgets/                       # Feature-specific widgets
```

A second screen of the same feature (editor, daily view) lives in the same folder.

### Naming Conventions

- Files/folders: `snake_case`, unique within the repository (no generic `page.dart`)
- Classes: `PascalCase` with role suffix (`DashboardScreen`, `DashboardScreenHost`, `DashboardViewModel`, `RecordRepository` / `FirestoreRecordRepository`, `PropertyDto`)
- Functions/variables: `camelCase`
- Tests: `前提のとき、期待値であること` format for unit tests, User Story format for integration tests

### Code Comments

- コードコメントに設計ドキュメントの決定番号(D1〜D10、O1〜O6など)を書かない。番号はドキュメント改訂で通じなくなるため、決定の**内容**を書く
- Comments explain why; tests describe what

### Domain Models & Value Objects

- One type per file in `lib/domain/models/`; IDs are freezed value types placed next to their model (no extension types, no `ids.dart`)
- Only IDs and validated values get value types; unvalidated values (e.g. an asset balance) stay plain
- Exception: `RecordDate` is a value type with no validation, on purpose. Production data (the old UI allowed future dates) and integration seeds (month-end 23:59:59 records) can hold future dates, so a constructor check would break reads. Future dates are rejected at the record-entry input boundary instead (DatePicker `lastDate` = today, plus a check in `submit`)
- Validate in constructors and throw (`FormatException` / `ArgumentError`); do not rely on `@Assert` for value validation (it only runs in debug builds)
- No UI wording in domain models; display text belongs to widgets

### ViewModels

- Inject Repository interfaces (not functions). The current time may be injected as a `DateTime Function()` clock (`now`; `clock` in record entry). Re-read it on each "today"-dependent check; Hosts call `refreshCurrentMonth()` / `refreshToday()` on app resume so a kept-alive tab notices a new month/day
- With several watches, keep the latest value and error per source; a good value clears only its own source's error
- Editors in edit mode pass only changed fields to `update`; an empty diff skips the Repository and closes as success
- Input checks are pure functions taking the input as an argument, not getters reading VM state
- Don't use input formatters that strip characters (they turn invalid input into a different valid value); validate the raw input instead
- One-off notifications (SnackBar) are shown by the Screen from a Command listener, then `clearResult()`. Confirmation dialogs live in the widget layer

## Testing Strategy

### Test Types & Locations

- **Unit Tests**: `test/domain/`, `test/data/`, `test/utils/` - domain models, DTOs and write JSON, utilities
- **ViewModel / Widget / Golden Tests**: `test/ui/` - mirrors `lib/ui/`
- **Integration Tests**: `integration_test/` - user-story flows against the Firebase emulators

### Test Practices

- Replace Repositories with hand-written Fakes (`test/test-util/fake_*_repository.dart`): `StreamController`s for watches, swappable results and recorded call arguments for writes. No mock-generation library is used
- ViewModel tests use plain `test` + `pumpEventQueue()` (awaiting `StreamController.close()` inside `testWidgets` hangs)
- Don't exhaustively assert Command internals (`running`/`error`/`completed`) in ViewModel tests; that is `test/utils/command_test.dart`'s job. Merge tests sharing the same premise into one behavior
- Firestore Repository implementations have no unit tests; paths, DTOs, write JSON and stream combination are unit-tested, and Firestore effects are verified by integration tests (`integration_test/util/firestore_probe.dart`)
- Goldens: `testGoldens` in `test/test-util/golden_helper.dart` captures 3 widths into `golden/` next to the test (see Golden Tests above for canonical operation)
- Integration UI operations are shared in `integration_test/util/` (`ui_operations.dart`, `record_entry_operations.dart`, `property_operations.dart`, `category_operations.dart`); data that cannot be entered via UI is seeded over REST (`record_seeding.dart`)

### Test Documentation

- Tests serve as specifications ("Test as Documentation")
- Test names describe behavior: `0文字のユーザー名はバリデーションエラーで保存に失敗すること`
- Integration tests use User Story format: `ユーザーは自分の家計簿でカテゴリを管理できるので、収支をカテゴリ別に整理できる`

## Firebase Configuration

For detailed database schema and constraints, see @docs/firestore_schema.md and @docs/firestore_constraints.md.

### Development Environment

- Uses Firebase emulators in debug mode (Auth: localhost:9099, Firestore: localhost:8081)
- Auto-connects to emulators when `kDebugMode` is true
- Persistence disabled for emulator usage

### Project Structure

- App code is under `lib/` (see Architecture Overview); there is no legacy generation left
- Firebase configuration in `firebase_options.dart`
- Firestore Rules (`firebase/firestore.rules`) enforce document shapes and value constraints (amount ≥ 1, note ≤ 100 chars, names 1–20 chars, budget ≥ 0, transfer source ≠ destination, referenced docs exist on create). For constraints that domain types check on read (and that would therefore turn a screen into an error), a Rule looser than the app is a bug to fix. The no-future-date rule is not in the Rules (they only check that `date` is a timestamp); it exists only at the record-entry input boundary

## Key Dependencies

### Production

- **provider**: Dependency injection (Repositories and shared state)
- **go_router**: Routing (auth redirect, `StatefulShellRoute` tabs)
- **firebase_core/cloud_firestore/firebase_auth**: Backend services
- **firebase_ui_auth**: Sign-in screen (imported only in `lib/ui/auth/`)
- **freezed_annotation**: Immutable domain models (with `freezed`)
- **intl**: Currency/date formatting
- **logging**: Log level constants for `developer.log`

### Development

- **build_runner** / **freezed**: Code generation
- **flutter_test** / **test**: Unit, widget and golden tests (`test` for Dart-only tests)
- **integration_test**: End-to-end testing
- **flutter_lints**: Lint rule set

Packages deliberately not used, and the reasons, are listed in @docs/style_guide.md.

## Development Guidelines

- Refer to @docs/architecture.md for detailed architecture decisions and patterns
- Follow coding standards in @docs/style_guide.md for consistent development practices
- Review @docs/firestore_schema.md and @docs/firestore_constraints.md for database operations
- Background of the design (snapshots, not live): `docs/features/202608_architecture_redesign.md` and `docs/features/202608_architecture_migration_plan.md`
- Use `provider` for DI; create ViewModels in Hosts, never in Provider (the settings route builder is the only, legacy exception)
- Repositories are the single source of truth; ViewModels subscribe to their watches instead of reloading manually
- Use `Command0`/`Command1` for user-initiated async operations, and accept only validated types in save Commands
- Verify lint rules with `dart analyze`; keep `flutter analyze` / `dart analyze` / `dart format` / all tests green
- Write tests as living specifications of component behavior
