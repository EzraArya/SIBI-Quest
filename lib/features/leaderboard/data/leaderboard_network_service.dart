import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sibi_quest/features/leaderboard/domain/models/leaderboard_player.dart';

/// Firestore-backed implementation of the leaderboard gateway.
///
/// Mirrors the behaviour of the iOS `SQLeaderboardNetworkService`, returning
/// the top players ordered by their `totalScore` field.
class LeaderboardNetworkService {
  LeaderboardNetworkService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  /// Fetches the leaderboard ordered by `totalScore` descending.
  ///
  /// Defaults to the top 10 entries, which lines up with the Swift service.
  Future<List<LeaderboardPlayer>> fetchTopPlayers({int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();

    final players = <LeaderboardPlayer>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.isEmpty) {
        continue;
      }

      final totalScore = (data['totalScore'] as num?)?.toInt() ?? 0;
      final firstName = _stringOrNull(data['firstName']) ?? 'Explorer';
      final lastName = _stringOrNull(data['lastName']);
      final imageUrl =
          _stringOrNull(data['image']) ?? _stringOrNull(data['imageUrl']);

      players.add(
        LeaderboardPlayer(
          id: doc.id,
          firstName: firstName,
          lastName: lastName,
          totalScore: totalScore,
          imageUrl: imageUrl,
        ),
      );
    }

    return players;
  }

  static String? _stringOrNull(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }
}
