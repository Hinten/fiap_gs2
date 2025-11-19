/// Assessment state model tracking progress and performance
class AssessmentState {
  /// Current difficulty level (1-5)
  final int currentDifficulty;

  /// Total questions answered
  final int totalAnswered;

  /// Number of correct answers
  final int correctAnswers;

  /// Total score accumulated
  final int totalScore;

  /// List of earned badge identifiers
  final List<String> badges;

  /// Current streak of correct answers
  final int currentStreak;

  /// Best streak achieved in this session
  final int bestStreak;

  /// Creates a new AssessmentState instance
  const AssessmentState({
    this.currentDifficulty = 1,
    this.totalAnswered = 0,
    this.correctAnswers = 0,
    this.totalScore = 0,
    this.badges = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  /// Calculates the accuracy percentage
  double get accuracy =>
      totalAnswered > 0 ? (correctAnswers / totalAnswered) * 100 : 0;

  /// Creates a copy of this state with updated fields
  AssessmentState copyWith({
    int? currentDifficulty,
    int? totalAnswered,
    int? correctAnswers,
    int? totalScore,
    List<String>? badges,
    int? currentStreak,
    int? bestStreak,
  }) =>
      AssessmentState(
        currentDifficulty: currentDifficulty ?? this.currentDifficulty,
        totalAnswered: totalAnswered ?? this.totalAnswered,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        totalScore: totalScore ?? this.totalScore,
        badges: badges ?? this.badges,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
      );

  /// Converts this state to a JSON map
  Map<String, dynamic> toJson() => {
        'currentDifficulty': currentDifficulty,
        'totalAnswered': totalAnswered,
        'correctAnswers': correctAnswers,
        'totalScore': totalScore,
        'badges': badges,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
      };

  /// Creates an AssessmentState from a JSON map
  factory AssessmentState.fromJson(Map<String, dynamic> json) =>
      AssessmentState(
        currentDifficulty: json['currentDifficulty'] as int,
        totalAnswered: json['totalAnswered'] as int,
        correctAnswers: json['correctAnswers'] as int,
        totalScore: json['totalScore'] as int,
        badges:
            (json['badges'] as List<dynamic>).map((e) => e as String).toList(),
        currentStreak: json['currentStreak'] as int,
        bestStreak: json['bestStreak'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentState &&
          runtimeType == other.runtimeType &&
          currentDifficulty == other.currentDifficulty &&
          totalAnswered == other.totalAnswered &&
          correctAnswers == other.correctAnswers &&
          totalScore == other.totalScore &&
          currentStreak == other.currentStreak &&
          bestStreak == other.bestStreak;

  @override
  int get hashCode =>
      currentDifficulty.hashCode ^
      totalAnswered.hashCode ^
      correctAnswers.hashCode ^
      totalScore.hashCode ^
      currentStreak.hashCode ^
      bestStreak.hashCode;
}
