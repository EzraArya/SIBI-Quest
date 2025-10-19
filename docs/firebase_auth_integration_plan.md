# Firebase Auth Integration Plan

## Phase 0 – Prerequisites (Owner: Platform)
- ✅ Confirm Firebase project IDs and create iOS (+macOS if needed) and Android apps in the Firebase console.
- ✅ Download `GoogleService-Info.plist` and `google-services.json`; keep them in a secure shared location.
- ✅ Replace the placeholder values in `lib/firebase_options.dart` after running `flutterfire configure`.
- ✅ Install `flutterfire_cli` locally (`dart pub global activate flutterfire_cli`).

## Phase 1 – Flutter project setup (Owner: Mobile)
1. **Dependencies**
   - ✅ Add `firebase_core`, `firebase_auth`, and `firebase_crashlytics` (optional future) to `pubspec.yaml`.
   - ✅ Run `flutter pub get`.
2. **Generate Firebase options**
   - ✅ Run `flutterfire configure --project <project-id>` to create `lib/firebase_options.dart`.
3. **Platform configuration**
   - ✅ Android: update `android/build.gradle` with Google services classpath, apply plugin in `android/app/build.gradle.kts`, and verify `minSdkVersion >= 21`.
   - ✅ iOS: add `GoogleService-Info.plist` to Runner, ensure `ios/Runner/Info.plist` contains the reversed client ID URL scheme, and run `pod install`.

## Phase 2 – App bootstrap (Owner: Mobile)
- ✅ Update `lib/main.dart` to `WidgetsFlutterBinding.ensureInitialized()` and `await Firebase.initializeApp(...)` using the generated options.
- ⬜ Introduce a lightweight `SplashBootstrap` widget that waits on Firebase initialization before rendering `App` (keeps `App` stateless).
- ⬜ Add sanity test ensuring initialization doesn’t throw (widget test using fake Firebase if possible).

## Phase 3 – Auth domain layer (Owner: Feature/Auth)
- ✅ Create `lib/features/auth/data/firebase_auth_repository.dart` wrapping the Firebase Auth SDK (sign-in, sign-up, sign-out, password reset, auth state).
- ✅ Define `AuthRepository` interface in `lib/features/auth/domain/auth_repository.dart` and implement it via Firebase service.
- ✅ Map Firebase `User` to `lib/cores/models/user.dart`; extend the model with factory `User.fromFirebaseUser` if helpful.
- ✅ Introduce sealed `AuthFailure` types for error handling (network, credential, unknown).

## Phase 4 – State management (Owner: Feature/Auth)
- ✅ Add Riverpod providers:
  - ✅ `authStateProvider` streaming `AsyncValue<User?>` via `FirebaseAuth.instance.authStateChanges()`.
  - ✅ `authControllerProvider` exposing async methods for sign-in/up/out.
- ✅ Ensure providers live in `lib/features/auth/presentation/providers/` alongside existing patterns.

## Phase 5 – UI & routing updates (Owner: Feature/Auth + App)
- ✅ Update auth screens to consume the new providers, displaying loading/error states via shared widgets (`ActionButton`, `CustomText`).
- ✅ Implement GoRouter redirect logic in `lib/app/app_router.dart` using a Riverpod listener (e.g., `GoRouterRefreshStream`).
- ⬜ Add splash / auth gate route that decides between onboarding/login and dashboard based on `User?`.

## Phase 6 – Firestore profile handshake (Owner: Feature/Profile)
- ⬜ On successful sign-in/up, upsert Firestore document in `users/{uid}` using `User.toJson()`; keep timestamps in server control.
- ⬜ Create `UserRepository` for profile data, reusing `lib/cores/models/user.dart` and `user_level_data.dart`.
- ⬜ Stub Firestore rules and document structure in a shared `docs/firestore_rules.md`.

## Phase 7 – Tooling & CI (Owner: DX)
- ⬜ Document setup in `README.md` and create `docs/firebase_setup.md` with platform-specific instructions.
- ✅ Add FlutterFire config files to source control; guard secrets via `.gitignore` if staging differs.
- ⬜ Update CI (if present) to run tests with `--dart-define`/mocked Firebase or to skip integration tests requiring credentials.

## Risks & follow-ups
- Emulator/device camera flows must handle auth gating gracefully.
- Investigate Firebase Auth + camera permissions interactions (iOS privacy strings already present?).
- Future work: integrate Firebase Crashlytics, Analytics, and Remote Config once auth is stable.
