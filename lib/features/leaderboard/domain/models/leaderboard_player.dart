class LeaderboardPlayer {
  final String id;
  final String firstName;
  final String? lastName;
  final int totalScore;
  final String? imageUrl;

  const LeaderboardPlayer({
    required this.id,
    required this.firstName,
    required this.totalScore,
    this.lastName,
    this.imageUrl,
  });

  String get displayName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  LeaderboardPlayer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? totalScore,
    String? imageUrl,
  }) {
    return LeaderboardPlayer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      totalScore: totalScore ?? this.totalScore,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      totalScore: json['totalScore'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'totalScore': totalScore,
      'imageUrl': imageUrl,
    };
  }
}
