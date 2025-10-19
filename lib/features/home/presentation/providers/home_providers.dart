import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/cores/models/level.dart' as core_level;
import 'package:sibi_quest/cores/models/section.dart' as core_section;
import 'package:sibi_quest/cores/models/user_level_data.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/home/data/home_network_service.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart'
    as domain_level;

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final homeNetworkServiceProvider = Provider<HomeNetworkService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return HomeNetworkService(firestore: firestore);
});

final sectionsProvider = FutureProvider<List<core_section.Section>>((ref) {
  final service = ref.watch(homeNetworkServiceProvider);
  return service.fetchSections();
});

final rawLevelsProvider = FutureProvider<List<core_level.Level>>((ref) {
  final service = ref.watch(homeNetworkServiceProvider);
  return service.fetchLevels();
});

final userLevelDataProvider = FutureProvider<List<UserLevelData>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;
  if (userId == null || userId.isEmpty) {
    return const [];
  }

  final service = ref.watch(homeNetworkServiceProvider);
  return service.fetchUserLevelData(userId);
});

final homeLevelsProvider = FutureProvider<List<domain_level.Level>>((
  ref,
) async {
  final rawLevels = await ref.watch(rawLevelsProvider.future);
  final userProgress = await ref.watch(userLevelDataProvider.future);

  final progressById = <String, UserLevelData>{
    for (final progress in userProgress)
      if (progress.id != null) progress.id!: progress,
  };

  final levels = rawLevels.map((raw) {
    final fallbackId = 'level_${raw.number}';
    final progress =
        progressById[raw.id ?? fallbackId] ?? progressById[fallbackId];
    final status = _mapStatus(progress?.status, raw.number);

    return domain_level.Level(
      id: raw.id ?? fallbackId,
      title: raw.title,
      description: raw.description,
      minScore: raw.minScore,
      number: raw.number,
      sectionId: raw.sectionId,
      status: status,
    );
  }).toList();

  levels.sort((a, b) => a.number.compareTo(b.number));
  return levels;
});

domain_level.LevelStatus _mapStatus(UserLevelStatus? status, int levelNumber) {
  switch (status) {
    case UserLevelStatus.completed:
      return domain_level.LevelStatus.completed;
    case UserLevelStatus.available:
      return domain_level.LevelStatus.available;
    case UserLevelStatus.locked:
      return domain_level.LevelStatus.locked;
    case null:
      return levelNumber == 1
          ? domain_level.LevelStatus.available
          : domain_level.LevelStatus.locked;
  }
}
