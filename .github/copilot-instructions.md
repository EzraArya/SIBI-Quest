# SIBI-Quest – AI Coding Playbook

## Architecture snapshot
- Entry starts at `lib/main.dart`, which boots `App` (`lib/app/app.dart`) to wire the dark theme (`buildDarkTheme`) and top-level `GoRouter` from `app_router.dart`.
- Feature code is split under `lib/features/<feature>/` into `data`, `domain`, and `presentation`; shared primitives live in `lib/shared/` and should be reused instead of raw Flutter widgets.
- Tokens for typography, colour, and fonts are codified under `lib/shared/tokens/`; extend these when introducing new design language.

## Navigation patterns
- `appRouter` composes slices from each feature via static `routes()` helpers (e.g. `OnboardingRoutes`, `PlayRoutes`); when adding screens, extend the feature router then fan-in at the app router.
- Dashboard navigation relies on `ShellRoute` + `DashboardShell`; emit paths like `/dashboard/<tab>` and switch tabs with `context.go` so the shell tracks `selectedIndex` correctly.
- Cross-feature flows pass context via query parameters (`levelId`, `score`), so use `GoRouterState.uri.queryParameters` instead of globals when ingesting state.

## UI system
- Typography comes from `CustomText` + `CustomTextType`, which draw styles from `AppText`; don’t hand-roll `TextStyle`s.
- Buttons follow `ActionButton` (`ButtonType` variants) and `CustomTextField` (`TextFieldType` backgrounds). Reach for raw `ElevatedButton` only when building complex layouts like `PlayPage`’s submit CTA.
- Colours must come from `AppColors`; stay within the Material 3 dark palette to avoid light backgrounds fighting the theme.

## Home & levels
- `HomePage` seeds sample `Level` data and uses a shared `ValueNotifier` (`activePopupNotifier`) so only one `LevelButton` popover is open; preserve that notifier pattern when mutating UI.
- `LevelButton` delegates visual state to `LevelButtonStyle` and calls the injected `action` before collapsing the popup—new behaviors should maintain this close-after-invoke flow.
- Launching gameplay uses `context.pushNamed(PlayRoutes.loadingName, queryParameters: {'levelId': ...})`, triggering the loading-to-play handoff; keep this sequence so the loading spinner remains reusable.

## Play flow
- `PlayPage` is the single source of truth for game state (questions, selections, scoring, YOLO flags). Reset via `_resetQuestionState()` before showing a new question or updating answers.
- Question data comes from `StaticQuestionsService`; when updating levels, modify its private helpers and keep `Question`/`QuestionContent` in sync with the enum-based `QuestionType`.
- Rendering splits into `PlayTypeOne/Two/ThreePage` widgets with well-defined contracts: index callbacks for select flows, `onImageChanged(String?)` for gesture capture. Respect those signatures when composing new question types.
- Score transitions call `context.go('/score?score=$score&levelId=$levelId')`; keep parameters percent-encoded if values can contain spaces.

## Camera & gesture tooling
- `PlayTypeThreePage` opens the camera via `context.pushNamed(PlayRoutes.cameraName)` and expects a file-system path on return. Validate the string before passing to `_handleGestureImageChanged`.
- `CameraPage` wraps `camera` + `permission_handler`, preferring the back lens and cleaning up controllers through `WidgetsBindingObserver`; maintain those lifecycle hooks or hot reload/resume will crash the preview.
- `YoloService` (singleton) loads `assets/models/sibi.tflite` + `labels.txt`, supports CPU/GPU delegates, and exposes `predict`/`predictAll`. Call `YoloService().init()` once, and dispose in tests with `YoloService().dispose()` to release interpreters.

## Data & assets
- `features/play/domain/models/questions.dart` provides JSON helpers and enum parsing—reuse them when introducing persistence or networking.
- Model assets sit under `assets/models/`; update both the `.tflite` and `labels.txt` together, and remember to bump `pubspec.yaml` asset entries if paths move.
- Fonts (Inter family) already bundled in `assets/fonts/`; align new typography with `AppText.of(...)` rather than embedding font files ad-hoc.

## Developer workflows
- Typical loop: `flutter pub get` → `flutter analyze` → targeted `flutter test test/<file>.dart`. Running all tests now fails because `test/widget_test.dart` still references the scaffolded `MyApp`; either rewrite it around `App(home: ...)` or quarantine it before CI.
- Use `flutter run -d <deviceId>` for manual smoke tests; camera + YOLO flows require a device/emulator with camera access.
- For integration-style checks, leverage `App`’s optional `home`/`navigatorKey` overrides to mount features without bringing up the full router.

## Gotchas & helpers
- `buildDarkTheme` fixes scaffold backgrounds and text colour—new `Scaffold`s should avoid default light surfaces or duplicate app bars.
- When adding dashboard tabs, mirror the `/dashboard/<route>` naming so `DashboardShell` continues mapping URLs to indices.
- Shared widgets under `lib/shared/widgets/` (e.g. `AppBanner`, `ChatBubblePopup`, `CustomLine`) encapsulate styling; extend them instead of rebuilding brand-specific chrome.
