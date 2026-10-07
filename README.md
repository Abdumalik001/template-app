# Production Flutter Starter Kit & Boilerplate 📱

A modern, production-grade Flutter application template built with **Clean Architecture (Feature-First)**, **Cubit (`flutter_bloc`)**, **Dio**, **GetIt**, **Freezed**, and **Hybrid Secure Storage**.

---

## Architecture & Tech Stack ✨

| Concern | Solution | Details |
|---|---|---|
| **Architecture** | Clean Architecture | Feature-First (Data / Domain / Presentation) |
| **State Management** | `flutter_bloc` | **Cubit only** (no events/blocs), sealed Freezed states |
| **Dependency Injection** | `get_it` | Service locator accessed via `sl<T>()` |
| **Networking** | `dio` | Singleton client, connection pooling, dynamic `DioInterceptor`, automated 401 JWT refresh & retry |
| **Error Handling** | Functional `Either<Failure, T>` | Centralized semantic failures (`DioErrorHandler`) without exceptions leaking across layers |
| **Local Storage** | Hybrid Storage (`AppStorageContract`) | `FlutterSecureStorage` (Keychain / Keystore) for secrets + `Hive` for prefs and cache |
| **UI Kit & Widgets** | Reusable Component Library | Production `Button`, `TextF` (obscure toggle), `AppErrorView`, `Empty`, `PaginatedListView` |
| **Navigation** | `go_router` | Declarative routing with smooth page transitions |
| **Localization** | `flutter gen-l10n` | ARB templates (`en`, `uz`, `ru`) |
| **Responsive UI** | `flutter_screenutil` | Scaled against design specifications via `Dimens` |
| **Typography & Fonts** | Local Asset Fonts | High-quality `Instrument Sans` bundled locally for 100% offline reliability |

---

## Directory Structure 📂

```text
lib/
├── main.dart, app.dart
├── core/                       # Cross-feature infrastructure (no feature business logic)
│   ├── api/                    # DioClient, interceptors, endpoint constants (ListAPI), isolate parser
│   ├── bloc/                   # MainCubit (theme, locale)
│   ├── error/                  # Semantic Failure types + DioErrorHandler
│   ├── localization/           # ARB files + generated strings
│   ├── resources/              # Dimens, Palette, Images, styles, motion
│   ├── usecase/                # UseCase<T, Params>, NoParams
│   ├── widgets/                # Universal UI Kit (Button, TextF, AppErrorView, Empty, PaginatedListView)
│   ├── app_route.dart          # Routes enum + GoRouter configuration
│   └── dependencies_injection.dart
├── features/<feature>/
│   ├── data/                   # Datasources, models (*_response.dart), repositories (*_repository_impl.dart)
│   ├── domain/                 # Entities, abstract repository contracts, use cases (*_usecase.dart)
│   └── pages/                  # Screen folders, part sub-widgets, cubits
└── utils/                      # Extensions (context, string, text_theme), helpers, AppStorageContract
scripts/                        # rename.sh, rename_project.py, generate_icons_and_splash.sh
```

---

## Quick Start 🚀

### 1. Bootstrap project
```bash
fvm flutter pub get && fvm flutter gen-l10n && fvm dart run build_runner build --delete-conflicting-outputs
```

### 2. Run the App

- **Staging:**
  ```bash
  fvm flutter run --flavor stg --dart-define-from-file .env.stg.json
  ```

- **Production:**
  ```bash
  fvm flutter run --flavor prd --dart-define-from-file .env.prd.json
  ```

---

## Project Automation Scripts 🛠️

### 1. Rename Project (Starter Kit Setup)
Quickly rebrand the entire project (package name, Android application ID, iOS bundle identifier, app display title, and all Dart imports) with a single command:
```bash
./scripts/rename.sh <new_package_name> <app_id> "<App Title>"
# Example:
# ./scripts/rename.sh nova_hr com.company.novahr "Nova HR"
```

### 2. Generate App Launcher Icons & Native Splash Screens
Regenerate Android (adaptive, legacy, and Android 12+ splash) and iOS icons and storyboards across both Staging and Production flavors:
```bash
./scripts/generate_icons_and_splash.sh
```

---

## Quality Assurance & Verification 🔍

Run static analysis:
```bash
fvm flutter analyze
```

Run tests:
```bash
fvm flutter test
```
