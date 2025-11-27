import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/features/leaderboard/data/leaderboard_network_service.dart';
import 'package:sibi_quest/features/leaderboard/domain/models/leaderboard_player.dart';

final leaderboardFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final leaderboardNetworkServiceProvider = Provider<LeaderboardNetworkService>((
  ref,
) {
  final firestore = ref.watch(leaderboardFirestoreProvider);
  return LeaderboardNetworkService(firestore: firestore);
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardPlayer>>((ref) {
  final service = ref.watch(leaderboardNetworkServiceProvider);
  return service.fetchTopPlayers();
});
