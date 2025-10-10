import 'package:meta/meta.dart';

/// Dart counterpart to the Swift `SQUserLevelData` model. Keeps Firestore
/// payloads aligned across platforms.
@immutable
class UserLevelData {
  const UserLevelData({
    this.id,
    required this.status,
    required this.bestScore,
    this.lastAttempted,
  });

  final String? id;
  final UserLevelStatus status;
  final int bestScore;
  final DateTime? lastAttempted;

  UserLevelData copyWith({
    String? id,
    UserLevelStatus? status,
    int? bestScore,
    DateTime? lastAttempted,
  }) {
    return UserLevelData(
      id: id ?? this.id,
      status: status ?? this.status,
      bestScore: bestScore ?? this.bestScore,
      lastAttempted: lastAttempted ?? this.lastAttempted,
    );
  }

  factory UserLevelData.fromJson(Map<String, dynamic> json) {
    return UserLevelData(
      id: json['id'] as String?,
      status: UserLevelStatusX.fromJson(json['status'] as String?),
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      lastAttempted: _dateTimeFromJson(json['lastAttempted']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'status': status.json,
      'bestScore': bestScore,
      'lastAttempted': lastAttempted?.toIso8601String(),
    };
  }

  @override
  int get hashCode => Object.hash(id, status, bestScore, lastAttempted);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLevelData &&
        other.id == id &&
        other.status == status &&
        other.bestScore == bestScore &&
        other.lastAttempted == lastAttempted;
  }
}

enum UserLevelStatus { available, completed, locked }

extension UserLevelStatusX on UserLevelStatus {
  String get json => switch (this) {
    UserLevelStatus.available => 'available',
    UserLevelStatus.completed => 'completed',
    UserLevelStatus.locked => 'locked',
  };

  static UserLevelStatus fromJson(String? value) {
    return switch (value) {
      'completed' => UserLevelStatus.completed,
      'locked' => UserLevelStatus.locked,
      _ => UserLevelStatus.available,
    };
  }
}

DateTime? _dateTimeFromJson(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }

  try {
    final seconds = value.seconds as int;
    final nanoseconds = value.nanoseconds as int? ?? 0;
    final milliseconds = seconds * 1000 + nanoseconds ~/ 1000000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  } catch (_) {
    return null;
  }
}
