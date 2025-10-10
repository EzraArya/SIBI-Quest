import 'package:meta/meta.dart';

/// Core representation of an authenticated user.
/// Mirrors the Swift `SQUser` model used in the iOS companion app so both
/// platforms can share Firestore JSON contracts.
@immutable
class User {
  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    this.createdAt,
    this.image,
    this.currentLevel,
    this.totalScore = 0,
  });

  /// Firestore document ID (nullable until persisted).
  final String? id;

  final String firstName;
  final String lastName;
  final String email;
  final int age;

  /// Populated by Firestore server when the document is written.
  final DateTime? createdAt;

  /// Public profile image URL or storage path.
  final String? image;

  /// Currently unlocked/active level identifier.
  final String? currentLevel;

  /// Running total score across completed levels.
  final int totalScore;

  /// Convenience accessor used heavily by the profile UI.
  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    DateTime? createdAt,
    String? image,
    String? currentLevel,
    int? totalScore,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      image: image ?? this.image,
      currentLevel: currentLevel ?? this.currentLevel,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      createdAt: _dateTimeFromJson(json['createdAt']),
      image: json['image'] as String?,
      currentLevel: json['currentLevel'] as String?,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      'createdAt': createdAt?.toIso8601String(),
      'image': image,
      'currentLevel': currentLevel,
      'totalScore': totalScore,
    };
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    email,
    age,
    createdAt,
    image,
    currentLevel,
    totalScore,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.age == age &&
        other.createdAt == createdAt &&
        other.image == image &&
        other.currentLevel == currentLevel &&
        other.totalScore == totalScore;
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

  // Support Firestore Timestamp without depending on the plugin yet.
  try {
    final seconds = value.seconds as int;
    final nanoseconds = value.nanoseconds as int? ?? 0;
    final milliseconds = seconds * 1000 + nanoseconds ~/ 1000000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  } catch (_) {
    return null;
  }
}
