# Cactus HR 📱

Cactus HR is a mobile application built with Flutter, implementing Clean Architecture with Cubit, Dio, Hive, and Flutter Secure Storage.

## Features ✨

- **Clean Architecture with Feature-First Structure**
- **State Management:** `flutter_bloc` (Cubit)
- **Dependency Injection:** `get_it`
- **Networking:** `dio` with automated refresh token interceptor
- **Local Storage:** Hybrid secure storage (`flutter_secure_storage` for credentials + `hive_ce` for preferences)
- **Routing:** `go_router` declarative navigation
- **Theme Configuration:** System, Light, and Dark modes
- **Multi-Language:** English and Bahasa (ARB localization)
- **Responsive UI:** ScreenUtil scaling and custom theme extensions

## Pre-requisites 📐

| Technology | Recommended Version | Installation Guide |
|---|---|---|
| Flutter | v3.47.x | [Flutter Official Docs](https://flutter.dev/docs/get-started/install) |
| Dart | v3.13.x | Installed automatically with Flutter |

## Getting Started 🚀

1. Get dependencies:
```bash
fvm flutter pub get
```

2. Generate localization files:
```bash
fvm flutter gen-l10n
```

3. Run code generation:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:

- **Staging:**
```bash
fvm flutter run --flavor stg --target lib/main.dart --dart-define-from-file .env.stg.json
```

- **Production:**
```bash
fvm flutter run --flavor prd --target lib/main.dart --dart-define-from-file .env.prd.json
```

5. Build the app:

- **Staging APK:**
```bash
fvm flutter build apk --flavor stg --target lib/main.dart --dart-define-from-file .env.stg.json
```

- **Production APK:**
```bash
fvm flutter build apk --flavor prd --target lib/main.dart --dart-define-from-file .env.prd.json
```

## Quality Assurance & Verification 🔍

Run static analysis:
```bash
fvm flutter analyze
```

Run tests:
```bash
fvm flutter test
```
