# Profile Image Integration Plan

This plan captures the sequence of tasks for wiring the profile-picture feature into Firebase-backed storage and Firestore user data.

## Objectives
- Allow users to select or capture a profile photo via `image_picker`.
- Upload the selected image to Firebase Storage and store the download URL in Firestore.
- Surface the stored image across the profile experience (`ProfilePage`, edit flows, etc.).

## Key Assumptions
- User documents live at `users/<uid>` and contain the fields:
  - `firstName`, `lastName`, `email`, `age`, `totalScore`, `createdAt`, `image` (URL string).
- A Firebase project exists and will be wired into the Flutter app.
- Riverpod is available for state management (per `pubspec.yaml`).

## Work Breakdown

### 1. Firebase + Dependency Setup
- Add `firebase_core`, `firebase_auth`, `cloud_firestore`, and `firebase_storage` to `pubspec.yaml`.
- Run `flutterfire configure` (external to codebase) to generate platform configs.
- Initialize Firebase in `main.dart` before `runApp`.
- Ensure Firebase plugins are registered for iOS/Android (review generated files into source control).

### 2. Data Model & Providers
- Create a `UserProfile` model mirroring Firestore fields (including optional `image` URL).
- Implement a profile repository with methods:
  - `Future<UserProfile> fetchProfile(String uid)`
  - `Future<void> updateProfileImage({required String uid, required String imageUrl})`
- Expose repository and `AsyncNotifier`/`StreamProvider` for user profile via Riverpod.
- Provide a simple `currentUserIdProvider` hook (temporary stub until full auth integration).

### 3. Image Picker Flow
- Integrate `image_picker` inside `EditProfilePicturePage`:
  - Present modal for camera/gallery choice.
  - Display local preview of the newly selected image.
  - Allow clearing the selection before upload.
- Handle permission errors gracefully (snackbar/toast messaging).

### 4. Upload + Persistence
- On "Update Profile Picture" action:
  - Upload file to Firebase Storage (`profile_images/<uid>/<timestamp>.jpg`).
  - Retrieve download URL.
  - Call repository to persist URL to Firestore.
- Surface loading state, success toast, and error feedback.

### 5. Profile Consumption
- Update `ProfilePage` header to consume the profile provider and display the fetched image URL.
- Ensure fallback placeholder remains when URL is absent or fails to load.
- Consider caching/profile refresh triggers after image updates.

### 6. Testing & Verification
- Run `flutter pub get`, `flutter analyze`, and targeted widget tests covering the profile provider + page.
- Smoke-test on device/emulator for picker + upload behavior.

### 7. Follow-Up Enhancements (Optional)
- Add retry logic for flaky uploads.
- Introduce image cropping/resizing prior to upload.
- Track upload usage/storage quotas if needed.
