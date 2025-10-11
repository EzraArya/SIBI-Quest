import 'package:meta/meta.dart';

@immutable
class Level {
  const Level({
    this.id,
    required this.sectionId,
    required this.number,
    required this.minScore,
    required this.title,
    required this.description,
  });

  final String? id;
  final String sectionId;
  final int number;
  final int minScore;
  final String title;
  final String description;

  String get displayName => number.toString();

  Level copyWith({
    String? id,
    String? sectionId,
    int? number,
    int? minScore,
    String? title,
    String? description,
  }) {
    return Level(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      number: number ?? this.number,
      minScore: minScore ?? this.minScore,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String?,
      sectionId: json['sectionId'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      minScore: (json['minScore'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'sectionId': sectionId,
      'number': number,
      'minScore': minScore,
      'title': title,
      'description': description,
    };
  }

  @override
  int get hashCode =>
      Object.hash(id, sectionId, number, minScore, title, description);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Level &&
        other.id == id &&
        other.sectionId == sectionId &&
        other.number == number &&
        other.minScore == minScore &&
        other.title == title &&
        other.description == description;
  }
}
