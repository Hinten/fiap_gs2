/// Question model for adaptive assessments
class Question {
  /// Unique identifier for the question
  final String id;

  /// The text of the question
  final String text;

  /// List of possible answers
  final List<String> options;

  /// Index of the correct answer in the options list
  final int correctAnswerIndex;

  /// Difficulty level (1-5, where 5 is hardest)
  final int difficulty;

  /// Optional category or topic
  final String? category;

  /// Creates a new Question instance
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    this.category,
  });

  /// Creates a copy of this question with updated fields
  Question copyWith({
    String? id,
    String? text,
    List<String>? options,
    int? correctAnswerIndex,
    int? difficulty,
    String? category,
  }) =>
      Question(
        id: id ?? this.id,
        text: text ?? this.text,
        options: options ?? this.options,
        correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
        difficulty: difficulty ?? this.difficulty,
        category: category ?? this.category,
      );

  /// Converts this question to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'difficulty': difficulty,
        'category': category,
      };

  /// Creates a Question from a JSON map
  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        text: json['text'] as String,
        options:
            (json['options'] as List<dynamic>).map((e) => e as String).toList(),
        correctAnswerIndex: json['correctAnswerIndex'] as int,
        difficulty: json['difficulty'] as int,
        category: json['category'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          correctAnswerIndex == other.correctAnswerIndex &&
          difficulty == other.difficulty &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      correctAnswerIndex.hashCode ^
      difficulty.hashCode ^
      category.hashCode;
}
