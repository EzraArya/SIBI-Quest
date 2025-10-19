# Home Firestore Migration Plan

## Objectives
- Port the remaining Swift `SQHomeNetworkService` read helpers (`fetchSections`, `fetchLevels`) into Dart.
- Reuse shared `Section` and `Level` models to keep JSON contracts aligned across platforms.
- Expose Firestore-backed providers so the Home dashboard can read live data instead of stubs.

## Scope Breakdown

### 1. Service Enhancements
- Extend `HomeNetworkService` with:
  - `Future<List<Section>> fetchSections()` → query `sections` collection, promote `doc.id`, build `Section` instances.
  - `Future<List<Level>> fetchLevels()` → query `levels` collection, promote `doc.id`, build `Level` instances.
- Maintain Firestore injection pattern for testability.
- Mirror behavior from Swift: simple `.get()` reads, no pagination yet.

### 2. Riverpod Providers
- Update `home_providers.dart` to expose async providers:
  - `sectionsProvider` returning `AsyncValue<List<Section>>` by calling the service.
  - `levelsProvider` returning `AsyncValue<List<Level>>` by calling the service.
- Optionally add repository wrappers if more orchestration is needed later (e.g., joining with user progress).

### 3. Feature Integration
- Replace any temporary data sources in Home feature view models/widgets with the new providers.
- Ensure dashboard refresh flow triggers provider refresh (e.g., pull-to-refresh calling `ref.refresh`).

### 4. Validation
- Add unit tests for `HomeNetworkService.fetchSections` and `.fetchLevels` using mocked Firestore snapshots.
- Run `flutter analyze` and existing widget tests to ensure no regressions.

## Follow-up Considerations
- Introduce caching or memoization if the data is mostly static.
- Add filters or pagination when sections/levels grow large.
- Wire user progress merges (e.g., matching `Level` with `UserLevelData`) in a higher-level repository.
