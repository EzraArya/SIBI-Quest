# SIBI-Quest – AI Coding Playbook

## Architecture & entrypoints
- `lib/main.dart` just hydrates Firebase, opens a `ProviderScope`, and mounts `App`; keep it thin and reuse `App(home: ...)` in tests when you need to bypass routing.
- `App` (`lib/app/app.dart`) wires the dark Material 3 theme via `buildDarkTheme` (`lib/app/theme.dart`) and central router config from `app_router.dart`.
- Features follow `lib/features/<feature>/{data,domain,presentation}/`; cross-cutting models/utilities sit under `lib/cores/`, shared UI tokens/widgets live in `lib/shared/`.
- Firebase is the only backend—Firestore collections mirror the `cores/models/*` contracts so Flutter and the Swift client share JSON shapes.

## Routing & state management
- `app_router.dart` aggregates each feature’s `routes()` helper and guards anything under `/dashboard` or `/play` behind the auth redirect; add new screens via the feature router, not directly in `app_router.dart`.
- Dashboard navigation uses a `ShellRoute` around `DashboardShell`; switch tabs with `context.go('/dashboard/<tab>')` so the shell keeps `selectedIndex` accurate.
- Pass per-screen data through query parameters (e.g. `context.go('/score?score=$score&levelId=$levelId')`) and read them via `state.uri.queryParameters`—never rely on global singletons.
- Riverpod 3 is standard: register listeners in `initState` with `ref.listenManual` and dispose the subscription; async controllers extend `AsyncNotifier` (`AuthController`, `ProfileController`) and expose loading/error state through `AsyncValue`.

## Data flow & Firebase usage
- Auth: `FirebaseAuthRepository` seeds Firestore via `AuthNetworkService.createUserProfile` and `createUserLevelDataBatch`; always throw domain-specific `AuthFailure` variants instead of raw Firebase exceptions.
- Home: `HomeNetworkService` pulls `sections`, `levels`, and per-user `levelData`; `homeLevelsProvider` merges raw Firestore documents with user progress (defaulting `level_1` to available).
- Profile: `ProfileNetworkService` wraps Firestore updates, password changes, Cloudinary uploads, and account deletion. Use the `profileControllerProvider` helpers so `currentUserProvider` invalidation stays consistent.
- Leaderboard: `leaderboardProvider` reads `users` ordered by `totalScore`; refresh it with `ref.invalidate` after score mutations.

## Play feature specifics
- `PlayPage` coordinates question state, scores, and camera handoffs; call its `_resetQuestionState()` before loading a new prompt or swapping levels.
- Questions are presently static from `StaticQuestionsService`; keep `QuestionType`, JSON helpers, and the static seeds in sync when adding new content or migrating to Firestore.
- Camera handoffs: `PlayTypeThreePage` pushes `PlayRoutes.cameraName` and expects a non-null image file path before invoking `_handleGestureImageChanged`.
- YOLO/TFLite integration lives in `features/play/data/services/yolo_service.dart`; call `init()` once per app lifetime and `dispose()` in tests to release interpreters.

## Shared UI system
- Typography flows through `CustomText` and tokens in `shared/tokens/typography.dart`; avoid raw `TextStyle` literals.
- Colors are centralized in `shared/tokens/colors.dart`; new widgets should inherit `AppColors` and the `buildDarkTheme()` palette.
- Buttons/text-fields use `ActionButton`, `CustomTextField`, and related enums—extend those widgets rather than rolling bespoke controls.
- `LevelButton`/`ChatBubblePopup` rely on the shared `activePopupNotifier`; follow that notifier pattern for mutually-exclusive overlays.

## External services & secrets
- Cloudinary uploads use `CloudinaryService`, which fetches credentials from `SecretManager` backed by Doppler; avoid hardcoding presets or keys and remember to call `ref.onDispose(service.dispose)` if you create new providers.
- `SecretManager` caches credentials for one hour and falls back to `DOPPLER_SERVICE_TOKEN`; replace the temporary token before shipping and never log secret responses.
- When adding new assets (models/images), declare them under `flutter.assets` in `pubspec.yaml`; TFLite models live in `assets/models/` and must match the associated `labels.txt`.

## Developer workflow
- Typical loop: `flutter pub get` → `flutter analyze` → targeted `flutter test test/<path>.dart`; widget specs reside under `test/features/**`.
- For manual smoke tests, run `flutter run -d <deviceId>`; camera/YOLO flows require granting camera permissions on the device or simulator.
- The repo’s README is a Flutter scaffold—prefer the patterns documented here when onboarding new contributors.

## Patterns worth copying
- Mirrored models (`cores/models/`) keep Flutter aligned with the iOS Swift client; extend these models instead of creating feature-specific duplicates.
- Feature routers (`play_router.dart`, `dashboard_router.dart`, etc.) encapsulate navigation; expose new route names/paths as statics so other features can link to them without string literals.
- In async controllers (`ProfileController._execute`), set `state = const AsyncLoading()` before awaiting mutations and surface errors via `AsyncError` so UIs can respond consistently.
