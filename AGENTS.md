# AGENTS

## Architecture & Entry Points
- Flutter app backed by Firebase; `lib/main.dart` only initializes FlutterFire then mounts `App` inside a global `ProviderScope`.
- `lib/app/app.dart` owns theming and routing; pass `home:` when mounting screens in widget tests to skip GoRouter.
- Features follow `lib/features/<feature>/{data,domain,presentation}/`; shared models/utilities live in `lib/cores`, design tokens/widgets in `lib/shared`.
- `lib/app/app_router.dart` merges feature routers and guards `/dashboard` + `/play` behind Firebase Auth; register new screens in the feature router (e.g. `lib/features/dashboard/dashboard_router.dart`) so redirects stay centralized.

## State & Navigation
- Riverpod 3 is the only state layer; async controllers extend `AsyncNotifier` and expose `AsyncValue` loading/error states.
- UI listeners use `ref.listenManual` (see `lib/features/auth/presentation/pages/login_page.dart`); always close the subscription in `dispose()`.
- Exchange screen data through GoRouter query params (e.g. `/score?score=$score&levelId=$id`) and read via `state.uri.queryParameters`; avoid singletons.
- Dashboard uses a `ShellRoute` around `DashboardShell`; switch tabs with `context.go(`/dashboard/<tab>`)` so the shell keeps `selectedIndex` accurate.

## Auth & Profile
- `FirebaseAuthRepository` wraps Firebase Auth and delegates Firestore writes to `AuthNetworkService`; always surface failures as `AuthFailure` variants and follow that pattern in new repositories (e.g. map Firestore errors to feature-specific exceptions before bubbling to the UI).
- `AuthNetworkService.buildInitialLevelDataSeed()` seeds `users/{uid}/levelData` with `level_1` available—update it when new levels ship.
- `currentUserProvider` merges the auth stream with the cached repository user; read it instead of hitting Firebase SDKs in widgets.

## Play & Progression
- `PlayNetworkService.fetchQuestions` filters `questions` by `levelId`, sorts on `order`, and falls back to `StaticQuestionsService` when Firestore is empty; keep that static fallback (`lib/features/play/data/static_questions_service.dart`) in sync with live question updates.
- `PlayProgressController.updateProgress` updates `users/{uid}/levelData`, increments `users.totalScore`, and unlocks the next level; reuse it rather than manual writes.
- `PlayRoutes` (in `lib/features/play/play_router.dart`) define navigation constants; `PlayPage` relies on `_resetQuestionState()` whenever the level changes.
- `YoloService` is a singleton; call `YoloService().init()` once, tweak behavior via `YoloService(options: ...)`, and `dispose()` it in tests to release interpreters.

## Shared UI & Tokens
- Typography goes through `CustomText` + `lib/shared/tokens/typography.dart`; avoid ad-hoc `TextStyle`s.
- Palette comes from `lib/shared/tokens/colors.dart` and `buildDarkTheme()`; keep new widgets on those tokens.
- Reuse shared controls (`ActionButton`, `CustomTextField`, `AppAlert`) instead of bespoke variants.
- Overlay widgets (`LevelButton`, `ChatBubblePopup`) coordinate via the shared `activePopupNotifier`; follow that notifier pattern for mutually-exclusive popups.

## External Services
- Secrets load through `SecretManager`, which pulls Doppler credentials via the `DOPPLER_SERVICE_TOKEN` compile-time define; replace the fallback token and never log the payload.
- `CloudinaryService.uploadProfileImage` uploads to `profiles/<uid>` using the unsigned preset from Doppler; supply raw image bytes and optional metadata context.
- Firestore contracts mirror the Swift client; extend shared models under `lib/cores/models/*` whenever you add fields and keep the manual `fromJson`/timestamp handling consistent (see `lib/cores/models/user.dart`, `lib/cores/models/user_level_data.dart`).

## Assets & Build
- TFLite models + labels live in `assets/models/`; register additions in `pubspec.yaml` under `flutter.assets` or they will be excluded.
- Camera + YOLO routes depend on permissions declared in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`; keep strings in sync.
- Standard loop: `flutter pub get` → `flutter analyze` → targeted `flutter test test/<suite>.dart` (widget specs reside under `test/features/**`); prefer widget tests that wrap screens in `ProviderScope`/`MaterialApp` and inject mocked providers, as in `test/shared/widgets/app_alert_test.dart`.
- Run manual checks with `flutter run -d <deviceId>`; routes hitting `PlayRoutes.cameraPath` need a device/emulator with camera access.

## AI Helper (Gemini CLI)
- Use the Gemini CLI (gemini) to accelerate common tasks and enforce conventions.
- Scaffold new features: gemini ai "Scaffold a new feature slice named `profile` under `lib/features/`. It must follow the `data, domain, presentation` structure. Create placeholder repository, controller, and page files that align with existing features like `auth`."
- Generate Riverpod Controllers: gemini ai "Create a new Riverpod 3 controller `ProfileController` in `lib/features/profile/presentation/`. It must extend `AsyncNotifier`, expose an `AsyncValue`, and follow the pattern of `PlayProgressController`."
- Generate Widget Tests: gemini ai "Write a widget test for `ProfilePage`. The test must wrap the widget in a `ProviderScope` and a `MaterialApp`. When mounting `ProfilePage`, pass it to the `home:` parameter of `MaterialApp` to bypass GoRouter, as per project standards."
- Refactor to Shared UI: gemini ai "Analyze `lib/features/profile/presentation/profile_page.dart`. Find any ad-hoc `TextStyle` or `Color` usages and refactor them to use `CustomText` from `lib/shared/tokens/typography.dart` and colors from `lib/shared/tokens/colors.dart`."
