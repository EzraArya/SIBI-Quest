import 'package:meta/meta.dart';

@immutable
class Section {
  const Section({
    this.id,
    required this.number,
    required this.title,
    required this.description,
  });

  final String? id;
  final int number;
  final String title;
  final String description;

  String get displayName => 'Section $number';

  Section copyWith({
    String? id,
    int? number,
    String? title,
    String? description,
  }) {
    return Section(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String?,
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'number': number,
      'title': title,
      'description': description,
    };
  }

  @override
  int get hashCode => Object.hash(id, number, title, description);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Section &&
        other.id == id &&
        other.number == number &&
        other.title == title &&
        other.description == description;
  }
}
