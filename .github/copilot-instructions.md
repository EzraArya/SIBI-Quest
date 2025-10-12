# SIBI-Quest – AI Coding Playbook

## Architecture quickstart
- `lib/main.dart` boots `App` (`lib/app/app.dart`), which builds the dark theme via `buildDarkTheme` and wires `appRouter` from `app_router.dart`.
- Features live in `lib/features/<feature>/` with `data`, `domain`, and `presentation` subfolders; shared widgets/tokens sit in `lib/shared/`.
- `buildDarkTheme` establishes a Material 3 dark palette—new `Scaffold`s should inherit it; override sparingly.
- Firebase initializes before `runApp` and the widget tree is wrapped in `ProviderScope`; don’t bypass this when writing entrypoints or tests.

## Navigation & state
- Routes fan in through `appRouter` by collecting each feature’s static `routes()` helper (see `features/play/play_router.dart`).
- Dashboard uses a `ShellRoute` + `DashboardShell`; navigate tabs with `context.go('/dashboard/<tab>')` so the shell keeps `selectedIndex` in sync.
- Cross-screen data travels via GoRouter query parameters (`levelId`, `score`); read with `GoRouterState.uri.queryParameters` rather than globals.

## UI system
- Typography funnels through `CustomText` + `CustomTextType`, backed by tokens in `lib/shared/tokens/typography.dart`; avoid raw `TextStyle` literals.
- Buttons follow `ActionButton`/`ButtonType`; text fields wrap `CustomTextField` with the `TextFieldType` backgrounds.
- Colours must come from `AppColors` (`lib/shared/tokens/colors.dart`) to keep contrast consistent across dark surfaces.

## Gameplay flow
- `PlayPage` owns question state, scoring, and YOLO flags; always call `_resetQuestionState()` before loading a new prompt.
- Question content is static for now via `StaticQuestionsService` (`features/play/data`); keep enums in `QuestionType` and JSON helpers in sync when adding variants.
- Rendering splits into `PlayTypeOne/Two/ThreePage`—respect their callbacks (`onAnswerSelected`, `onImageChanged`) when composing new flows.
- Score transitions execute `context.go('/score?score=$score&levelId=$levelId')`; percent-encode parameters that may include spaces.

## Camera & ML integrations
- `PlayTypeThreePage` launches the camera with `context.pushNamed(PlayRoutes.cameraName)` and expects a filesystem path string back; null-check before forwarding to `_handleGestureImageChanged`.
- `CameraPage` manages `camera` + `permission_handler` lifecycles using `WidgetsBindingObserver`; preserve `didChangeAppLifecycleState` hooks to avoid preview crashes on resume.
- `YoloService` (singleton, `features/play/data/services/yolo_service.dart`) loads `assets/models/sibi.tflite` + `labels.txt`. Call `init()` once, reuse the instance, and `dispose()` in tests to release TFLite interpreters.

## Profile & shared patterns
- Profile feature composes avatars with `ProfileAvatar` and uses shared spacing constants from `lib/shared/widgets/`; reuse tokens instead of hardcoding paddings.
- `home` feature seeds level data and exposes a shared `activePopupNotifier` to ensure only one `LevelButton` popover is open—follow that notifier pattern for new popups.
- `ProfilePage` reads the signed-in user via `currentUserProvider`; when augmenting profile data, extend the core `User` model + Firestore sync rather than hardcoding placeholders.
- `features/profile/data/profile_network_service.dart` handles Firestore writes, password updates, and Cloudinary uploads using `SecretManager` + `CloudinaryService`.
- Providers in `features/profile/presentation/providers/profile_providers.dart` expose `profileControllerProvider`; invalidating it refreshes Cloudinary credentials and ensures controller state resets between flows.
- Edit/change profile UIs (`edit_profile_page.dart`, `change_password_page.dart`, `edit_profile_picture_page.dart`) call the controller for mutations and rely on its loading/error state for feedback.

## Leaderboard data
- `features/leaderboard/data/leaderboard_network_service.dart` fetches top users from Firestore (`users` collection ordered by `totalScore`).
- Riverpod wiring in `leaderboard_providers.dart` exposes `leaderboardProvider`; invalidate it to refresh the board.
- `LeaderboardPage` is a `ConsumerWidget` that renders loading/error/empty states based on that provider.

## Firebase auth & routing
- Firebase config lives in `lib/firebase_options.dart`; refresh it with `flutterfire configure` when environments change.
- `features/auth/data/firebase_auth_repository.dart` wraps `FirebaseAuth`, seeds a Firestore profile + initial level progress through `AuthNetworkService`, and surfaces failures via `AuthFailure`—use the repository instead of hitting the SDK directly.
- `features/auth/data/auth_network_service.dart` handles Firestore writes for new accounts (`users/{uid}` doc plus `levelData` seed); only auth code should depend on it.
- Riverpod providers in `features/auth/presentation/providers/auth_providers.dart` expose `authStateProvider`, `currentUserProvider`, and `authController`; reuse them for UI work.
- `LoginPage` and `SignupPage` already handle validation, loading, and error snackbars—tap into `authControllerProvider` when adding new auth surfaces.
- `app_router.dart` redirects based on auth state; protected routes should live under `/dashboard` or `/play` prefixes so the guard remains effective.

## Riverpod upgrade notes
- Project runs on Riverpod 3; listeners in `initState` must use `ref.listenManual` and close the returned subscription in `dispose` (see login/signup/profile pages for the pattern).
- `AuthController` extends `AsyncNotifier<void>`; wrap async mutations with `_run` to keep loading/error state consistent.

## Developer workflow
- Typical loop: `flutter pub get` → `flutter analyze` → targeted `flutter test test/<path>.dart`; widget coverage lives under `test/features/**`.
- Manual smoke: `flutter run -d <deviceId>`; camera + YOLO flows need a simulator/device with camera permission granted.
- `App` accepts `home` and `navigatorKey` overrides, letting you mount feature widgets directly in tests without spinning up the router.

## Assets & dependencies
- ML assets reside in `assets/models/`; if you swap `sibi.tflite`, update `pubspec.yaml` and keep `labels.txt` aligned.
- Fonts (Inter family) already bundled under `assets/fonts/`; extend typography by adding tokens, not by embedding new font files.
- Remember to update `pubspec.yaml` when adding new images, models, or JSON so Flutter’s asset bundler picks them up.
