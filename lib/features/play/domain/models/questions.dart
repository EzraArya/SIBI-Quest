enum QuestionType {
  selectAlphabet,
  selectGesture,
  performGesture;

  String get value {
    switch (this) {
      case QuestionType.selectAlphabet:
        return 'selectAlphabet';
      case QuestionType.selectGesture:
        return 'selectGesture';
      case QuestionType.performGesture:
        return 'performGesture';
    }
  }

  static QuestionType fromString(String value) {
    switch (value) {
      case 'selectAlphabet':
        return QuestionType.selectAlphabet;
      case 'selectGesture':
        return QuestionType.selectGesture;
      case 'performGesture':
        return QuestionType.performGesture;
      default:
        throw ArgumentError('Invalid QuestionType: $value');
    }
  }
}

class Answer {
  final String value;
  final bool isImage;

  const Answer({required this.value, required this.isImage});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      value: json['value'] as String,
      isImage: json['isImage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'isImage': isImage};
  }

  Answer copyWith({String? value, bool? isImage}) {
    return Answer(value: value ?? this.value, isImage: isImage ?? this.isImage);
  }

  @override
  String toString() => 'Answer(value: $value, isImage: $isImage)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Answer && other.value == value && other.isImage == isImage;
  }

  @override
  int get hashCode => value.hashCode ^ isImage.hashCode;
}

class QuestionContent {
  final String prompt;
  final bool isPromptImage;
  final List<Answer> answers;
  final String? exampleImage;

  const QuestionContent({
    required this.prompt,
    required this.isPromptImage,
    required this.answers,
    this.exampleImage,
  });

  factory QuestionContent.fromJson(Map<String, dynamic> json) {
    return QuestionContent(
      prompt: json['prompt'] as String,
      isPromptImage: json['isPromptImage'] as bool,
      answers: (json['answers'] as List)
          .map(
            (answerJson) => Answer.fromJson(answerJson as Map<String, dynamic>),
          )
          .toList(),
      exampleImage: json['exampleImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'isPromptImage': isPromptImage,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'exampleImage': exampleImage,
    };
  }

  QuestionContent copyWith({
    String? prompt,
    bool? isPromptImage,
    List<Answer>? answers,
    String? exampleImage,
  }) {
    return QuestionContent(
      prompt: prompt ?? this.prompt,
      isPromptImage: isPromptImage ?? this.isPromptImage,
      answers: answers ?? List<Answer>.from(this.answers),
      exampleImage: exampleImage ?? this.exampleImage,
    );
  }

  @override
  String toString() {
    return 'QuestionContent(prompt: $prompt, isPromptImage: $isPromptImage, answers: $answers, exampleImage: $exampleImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionContent &&
        other.prompt == prompt &&
        other.isPromptImage == isPromptImage &&
        other.answers.length == answers.length &&
        other.exampleImage == exampleImage;
  }

  @override
  int get hashCode {
    return prompt.hashCode ^
        isPromptImage.hashCode ^
        answers.hashCode ^
        exampleImage.hashCode;
  }
}

class Question {
  final String? id;
  final String levelId;
  final QuestionType type;
  final QuestionContent content;
  final int correctAnswerIndex;

  const Question({
    this.id,
    required this.levelId,
    required this.type,
    required this.content,
    required this.correctAnswerIndex,
  });

  /// Get the correct answer from the answers list
  Answer get correctAnswer => content.answers[correctAnswerIndex];

  /// Check if the given answer index is correct
  bool isCorrectAnswer(int answerIndex) {
    return answerIndex == correctAnswerIndex;
  }

  /// Safely get answer at index
  Answer? getAnswerAt(int index) {
    if (index < 0 || index >= content.answers.length) return null;
    return content.answers[index];
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String?,
      levelId: json['levelId'] as String,
      type: QuestionType.fromString(json['type'] as String),
      content: QuestionContent.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelId': levelId,
      'type': type.value,
      'content': content.toJson(),
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  Question copyWith({
    String? id,
    String? levelId,
    QuestionType? type,
    QuestionContent? content,
    int? correctAnswerIndex,
  }) {
    return Question(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      type: type ?? this.type,
      content: content ?? this.content,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, levelId: $levelId, type: $type, content: $content, correctAnswerIndex: $correctAnswerIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
