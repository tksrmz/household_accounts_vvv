# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app for household expense tracking using Firebase as the backend. The app follows Clean Architecture principles with clear separation between presentation, domain, and data layers.

For detailed information, refer to the following documentation:

- @docs/architecture.md - Complete architecture overview and implementation patterns
- @docs/style_guide.md - Development conventions and coding standards  
- @docs/firestore_schema.md - Database schema and data structure definitions
- @docs/firestore_constraints.md - Database constraints and business rules

## Monorepo Structure

This repository contains both the app and its backend:

- Repository root: the Flutter app
- `firebase/`: the Firebase backend (TypeScript Cloud Functions in `firebase/functions/`, `firebase/firestore.rules`, Hosting content in `firebase/public/`)

Notes:

- Firebase CLI commands (`firebase deploy`, `firebase emulators:start`) are run from `firebase/`
- Backend tests run online against the dev project: `npm --prefix firebase/functions test`
- Emulator ports are defined in `firebase/firebase.json` (Firestore: 8081, Auth: 9099) and must stay in sync with `lib/main.dart`

## Development Commands

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
dart test test/                       # Run Dart-only tests
```

### Integration Testing

```bash
./integration_test/run.sh             # Run integration tests (uses emulator)
flutter test integration_test/integration_test.dart  # Direct integration test
```

### Linting & Analysis

```bash
flutter analyze                       # Static analysis
dart format .                         # Format code
```

## Architecture Overview

The app follows Clean Architecture with three main layers. For comprehensive architecture details, see @docs/architecture.md.

### Presentation Layer (`lib/presentation/`)

- **Pages**: Complete screens with ViewModels (1:1 relationship)
- **ViewModels**: State management using ChangeNotifier/ValueNotifier + Command pattern
- **Commands**: Encapsulate async operations (CRUD) with execution state
- **Widgets**: Reusable UI components

### Domain Layer (`lib/domain/`, `lib/entity/`)

- **Models/Entities**: Business objects using freezed
- **Value Objects**: Single-property immutable types with validation (`lib/vo/`)
- **Repository Interfaces**: Abstract data access contracts

### Data Layer (`lib/data/`)

- **Repository Implementations**: Concrete data access using Firebase
- **Models**: External service data representations
- **Services**: Low-level data access abstraction for external services

## Key Architectural Patterns

### Command Pattern

ViewModels use `AsyncCommand` classes for repository operations:

- Manages execution state (loading, success, error)
- Commands inherit from ChangeNotifier
- Separates UI state from business logic

### Dependency Injection

- **Provider**: Primary DI container for repositories and shared state
- **get_it**: Legacy DI (prefer Provider for new code)
- Repositories registered in `main.dart`, injected into ViewModels

### Error Handling Strategy

- **Data Layer**: Use `dartz.Either<Exception, T>` for safe data operations
- **Presentation Layer**: `rethrow` to convert Either to Exception, managed by Command pattern
- Layer boundary exception conversion prioritizes practicality and maintainability

## Code Conventions

For complete coding standards and patterns, see @docs/style_guide.md.

### File Structure

```
lib/presentation/pages/feature_name/
├── page.dart           # Screen widget (returns Scaffold)
├── view_model.dart     # State management
└── widgets/           # Feature-specific widgets
```

### Naming Conventions

- Files/folders: `snake_case`
- Classes: `PascalCase` with role suffix (`DashboardViewModel`, `HomePage`)
- Functions/variables: `camelCase`
- Tests: `前提のとき、期待値であること` format for unit tests, User Story format for integration tests

### Value Objects & Entities

- Use `freezed` annotation for immutable types
- Value Objects have single property + validation via `Assert`
- Entities contain multiple Value Objects
- Place in `lib/domain/models/` (entities) or `lib/domain/models/vo/` (value objects)

## Testing Strategy

### Test Types & Locations

- **Unit Tests**: `test/domain/`, `test/data/` - Business logic validation
- **Widget Tests**: `test/presentation/` - UI behavior and user interactions
- **Integration Tests**: `integration_test/` - End-to-end screen flows

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

- `lib/v2/`: New architecture implementation
- Legacy code in root `lib/` folders
- Firebase configuration in `firebase_options.dart`

## Key Dependencies

### Production

- **provider**: Dependency injection & state management
- **dartz**: Functional programming (Either for error handling)
- **freezed**: Immutable data classes
- **firebase_core/cloud_firestore/firebase_auth**: Backend services
- **fl_chart**: Chart visualization

### Development

- **build_runner**: Code generation
- **mockito**: Test mocking
- **integration_test**: End-to-end testing

## Development Guidelines

- Refer to @docs/architecture.md for detailed architecture decisions and patterns
- Follow coding standards in @docs/style_guide.md for consistent development practices
- Review @docs/firestore_schema.md and @docs/firestore_constraints.md for database operations
- Use Provider for new dependency injection (not get_it)
- Implement Repository pattern as Single Source of Truth
- Separate UI logic (View) from business logic (ViewModel)
- Use Command pattern for async operations in ViewModels
- Write tests as living specifications of component behavior
