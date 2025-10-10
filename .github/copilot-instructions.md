# SIBI-Quest – AI Coding Playbook

## Architecture quickstart
- `lib/main.dart` boots `App` (`lib/app/app.dart`), which builds the dark theme via `buildDarkTheme` and wires `appRouter` from `app_router.dart`.
- Features live in `lib/features/<feature>/` with `data`, `domain`, and `presentation` subfolders; shared widgets/tokens sit in `lib/shared/`.
- `buildDarkTheme` establishes a Material 3 dark palette—new `Scaffold`s should inherit it; override sparingly.

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

## Developer workflow
- Typical loop: `flutter pub get` → `flutter analyze` → targeted `flutter test test/<path>.dart`; widget coverage lives under `test/features/**`.
- Manual smoke: `flutter run -d <deviceId>`; camera + YOLO flows need a simulator/device with camera permission granted.
- `App` accepts `home` and `navigatorKey` overrides, letting you mount feature widgets directly in tests without spinning up the router.

## Assets & dependencies
- ML assets reside in `assets/models/`; if you swap `sibi.tflite`, update `pubspec.yaml` and keep `labels.txt` aligned.
- Fonts (Inter family) already bundled under `assets/fonts/`; extend typography by adding tokens, not by embedding new font files.
- Remember to update `pubspec.yaml` when adding new images, models, or JSON so Flutter’s asset bundler picks them up.
