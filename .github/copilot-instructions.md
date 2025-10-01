# SIBI-Quest – AI Coding Playbook

## Project snapshot
- Flutter 3.8 app organised per feature; entrypoint `lib/main.dart` bootstraps `App` (`MaterialApp.router`) with a dark theme from `app/theme.dart` and a central `GoRouter` in `app/app_router.dart`.
- Design tokens live under `lib/shared/tokens/`; shared UI primitives are in `lib/shared/widgets/` and should be reused instead of raw Flutter widgets to match the visual language.

## Navigation & feature layout
- Each feature keeps its own router: e.g. `features/play/play_router.dart` wires `/loading`, `/play`, `/camera`, `/score`; onboarding/auth/dashboard follow the same pattern. Add new screens by extending the relevant router and exposing `$FeatureRoutes.routes()`.
- `DashboardRoutes` uses a `ShellRoute` with `DashboardShell` to host the tab bar. Changing tabs should go through `context.go('/dashboard/...')` so the shell keeps state.

## UI conventions
- Typography comes from `CustomText` and `AppText` styles (`CustomTextType` enum). Use these instead of manual `TextStyle`s.
- Buttons: `ActionButton` (pre-styled filled button with `ButtonType` variants) and `ElevatedButton` only when the layout needs something custom (see play pages). Text inputs rely on `CustomTextField` and its `TextFieldType` palette.
- Colours must come from `AppColors`; avoid hard-coded hex unless adding a new token.

## Play flow specifics
- `PlayPage` drives the multi-question game: it loads questions through `StaticQuestionsService`, tracks `currentQuestionIndex`, `score`, and swaps between `PlayTypeOne/Two/ThreePage` widgets based on `QuestionType`. When extending the game, respect `_resetQuestionState()` reset semantics and update the `StaticQuestionsService` helpers in sync.
- Questions live in `features/play/domain/models/questions.dart` (`Question`, `QuestionContent`, `Answer`). Reuse the JSON helpers when introducing persistence or API-backed data.

## Camera & gesture capture
- `PlayTypeThreePage` expects `onImageChanged` to receive a file path returned by the `CameraPage` route (`context.pushNamed(PlayRoutes.cameraName)` returns a `String`). Keep that contract if you change either screen.
- `CameraPage` handles runtime permissions via `permission_handler`, selects the back camera, and returns `Navigator.pop(context, picture.path)`. Maintain lifecycle hooks (`WidgetsBindingObserver`) or capturing will break after app resumes. Platform permissions are already declared (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`).

## Data & assets
- `assets/models/` contains `sibi.tflite` + `labels.txt` for future gesture recognition; the model is not yet wired up, so stubs (`Detected Gesture`, hard-coded confidence) appear in the UI. When integrating ML inference, surface results through the existing `gestureLabel`/`selectedImage` fields.
- Sample levels (`features/home/domain/models/level.dart`) power the `HomePage` grid via a `ValueNotifier` that toggles `LevelButton` popovers. Preserve the notifier pattern so multiple buttons don’t open at once.

## Toolchain & workflows
- Standard commands: `flutter pub get`, `flutter run -d <device>`, `flutter analyze`, `flutter test`. Widget tests currently fail because `test/widget_test.dart` still references the scaffolded `MyApp`; update or delete that test before relying on CI.
- Camera usage requires physical hardware or an emulator with camera support; guard camera flows (`PlayTypeThreePage`) behind fallbacks when targeting web or desktop.

## Gotchas & tips
- The theme assumes Material 3 dark mode; new screens should inherit `AppColors.background` and avoid `Scaffold` defaults that create light surfaces.
- `App` accepts optional `home`, `title`, `theme`, and `navigatorKey` overrides, which is useful for testing or storybook scenarios—leverage this instead of building alternate `MaterialApp`s.
- Lints are `flutter_lints` defaults (`analysis_options.yaml`); follow the package’s guidance and favour composable widgets over ad-hoc styling to keep the design system coherent.
