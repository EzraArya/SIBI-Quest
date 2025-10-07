import 'dart:async';

import 'package:sibi_quest/features/leaderboard/domain/models/leaderboard_player.dart';

class StaticLeaderboardService {
  const StaticLeaderboardService._();

  static Future<List<LeaderboardPlayer>> fetchLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 450));
    final players = List<LeaderboardPlayer>.from(_players);
    players.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return players;
  }

  static const List<LeaderboardPlayer> _players = [
    LeaderboardPlayer(
      id: 'player-01',
      firstName: 'Ayame',
      lastName: 'Tan',
      totalScore: 9820,
      imageUrl: 'https://i.pravatar.cc/120?img=1',
    ),
    LeaderboardPlayer(
      id: 'player-02',
      firstName: 'Ezra',
      lastName: 'Wijaya',
      totalScore: 9575,
      imageUrl: 'https://i.pravatar.cc/120?img=5',
    ),
    LeaderboardPlayer(
      id: 'player-03',
      firstName: 'Keisha',
      lastName: 'Ling',
      totalScore: 9240,
      imageUrl: 'https://i.pravatar.cc/120?img=8',
    ),
    LeaderboardPlayer(
      id: 'player-04',
      firstName: 'Rafi',
      lastName: 'Sutanto',
      totalScore: 8910,
      imageUrl: 'https://i.pravatar.cc/120?img=12',
    ),
    LeaderboardPlayer(
      id: 'player-05',
      firstName: 'Nadia',
      lastName: 'Hartono',
      totalScore: 8675,
      imageUrl: 'https://i.pravatar.cc/120?img=15',
    ),
    LeaderboardPlayer(
      id: 'player-06',
      firstName: 'Bagas',
      lastName: 'Prasetyo',
      totalScore: 8425,
      imageUrl: 'https://i.pravatar.cc/120?img=19',
    ),
    LeaderboardPlayer(
      id: 'player-07',
      firstName: 'Salsa',
      lastName: 'Maryam',
      totalScore: 8120,
    ),
    LeaderboardPlayer(
      id: 'player-08',
      firstName: 'Michael',
      lastName: 'Lim',
      totalScore: 7980,
    ),
  ];
}
