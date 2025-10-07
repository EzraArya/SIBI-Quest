import 'package:flutter_test/flutter_test.dart';
import 'package:sibi_quest/features/leaderboard/data/static_leaderboard_service.dart';

void main() {
  group('StaticLeaderboardService', () {
    test('returns players sorted by descending score', () async {
      final players = await StaticLeaderboardService.fetchLeaderboard();

      expect(players, isNotEmpty);
      for (var i = 0; i < players.length - 1; i++) {
        expect(
          players[i].totalScore >= players[i + 1].totalScore,
          isTrue,
          reason: 'Players should be sorted by descending score',
        );
      }
    });

    test('produces a new list on each fetch', () async {
      final firstCall = await StaticLeaderboardService.fetchLeaderboard();
      final secondCall = await StaticLeaderboardService.fetchLeaderboard();

      expect(identical(firstCall, secondCall), isFalse);
    });
  });
}
