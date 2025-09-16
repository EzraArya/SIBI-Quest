class Level {
  final String id;
  final String title;
  final String description;
  final int minScore;
  final int number;
  final String sectionId;
  final LevelStatus
  status; // This will be determined by app logic, not from API

  const Level({
    required this.id,
    required this.title,
    required this.description,
    required this.minScore,
    required this.number,
    required this.sectionId,
    this.status = LevelStatus.locked, // Default to locked
  });

  Level copyWith({
    String? id,
    String? title,
    String? description,
    int? minScore,
    int? number,
    String? sectionId,
    LevelStatus? status,
  }) {
    return Level(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      minScore: minScore ?? this.minScore,
      number: number ?? this.number,
      sectionId: sectionId ?? this.sectionId,
      status: status ?? this.status,
    );
  }

  // Factory constructor for creating Level from JSON/API data
  factory Level.fromJson(Map<String, dynamic> json, {LevelStatus? status}) {
    return Level(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      minScore: json['minScore'] as int,
      number: json['number'] as int,
      sectionId: json['sectionId'] as String,
      status: status ?? LevelStatus.locked,
    );
  }

  // Convert Level to JSON (for caching or API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minScore': minScore,
      'number': number,
      'sectionId': sectionId,
    };
  }
}

enum LevelStatus { locked, available, completed }
