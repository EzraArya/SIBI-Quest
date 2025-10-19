import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/cores/models/user_level_data.dart';
import 'package:sibi_quest/features/play/data/play_network_service.dart';
import 'package:sibi_quest/features/play/domain/models/questions.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart'
    as home_level;

final playFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final playNetworkServiceProvider = Provider<PlayNetworkService>((ref) {
  final firestore = ref.watch(playFirestoreProvider);
  return PlayNetworkService(firestore: firestore);
});

final playLevelProvider = FutureProvider.family<home_level.Level, String>((
  ref,
  levelId,
) async {
  final service = ref.watch(playNetworkServiceProvider);
  return service.fetchLevel(levelId: levelId);
});

final playQuestionsProvider = FutureProvider.family<List<Question>, String>((
  ref,
  levelId,
) async {
  final service = ref.watch(playNetworkServiceProvider);
  return service.fetchQuestions(levelId: levelId);
});

final playProgressControllerProvider =
    AsyncNotifierProvider<PlayProgressController, void>(
      PlayProgressController.new,
    );

class PlayProgressController extends AsyncNotifier<void> {
  PlayNetworkService get _service => ref.read(playNetworkServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<void> updateProgress({
    required String userId,
    required String levelId,
    required int score,
    home_level.Level? level,
  }) async {
    state = const AsyncLoading();
    try {
      home_level.Level? resolvedLevel = level;

      if (resolvedLevel == null) {
        try {
          resolvedLevel = await _service.fetchLevel(levelId: levelId);
        } catch (_) {
          resolvedLevel = null;
        }
      }

      final threshold = resolvedLevel?.minScore ?? 0;
      final hasClearedLevel = score >= threshold;

      final currentProgress = UserLevelData(
        status: hasClearedLevel
            ? UserLevelStatus.completed
            : UserLevelStatus.available,
        bestScore: score,
        lastAttempted: DateTime.now(),
      );

      ({String levelId, UserLevelData data})? unlockedLevel;

      if (hasClearedLevel && resolvedLevel != null) {
        final nextLevel = await _service.fetchNextLevel(
          sectionId: resolvedLevel.sectionId,
          currentNumber: resolvedLevel.number,
        );

        if (nextLevel != null) {
          unlockedLevel = (
            levelId: nextLevel.id,
            data: const UserLevelData(
              status: UserLevelStatus.available,
              bestScore: 0,
            ),
          );
        }
      }

      await _service.updateUserLevelData(
        userId: userId,
        levelId: levelId,
        userLevelData: currentProgress,
        unlockedLevel: unlockedLevel,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
