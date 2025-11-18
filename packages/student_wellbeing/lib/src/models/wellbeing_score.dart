import 'wellbeing_checkin.dart';

/// Represents a calculated wellbeing score over a time period.
///
/// Used for trend analysis and early warning detection.
class WellbeingScore {
  /// Unique identifier for this score calculation.
  final String id;

  /// Average wellbeing score (0-100).
  final double averageScore;

  /// Trend indicator: positive = improving, negative = declining.
  final double trend;

  /// Period start timestamp.
  final DateTime periodStart;

  /// Period end timestamp.
  final DateTime periodEnd;

  /// Number of check-ins used in calculation.
  final int sampleSize;

  /// Individual check-ins used in this score.
  final List<WellbeingCheckin> checkins;

  const WellbeingScore({
    required this.id,
    required this.averageScore,
    required this.trend,
    required this.periodStart,
    required this.periodEnd,
    required this.sampleSize,
    required this.checkins,
  });

  /// Calculates a wellbeing score from a list of check-ins.
  ///
  /// Uses simple moving average for the score and compares
  /// recent vs earlier periods for trend detection.
  factory WellbeingScore.calculate({
    required String id,
    required List<WellbeingCheckin> checkins,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    if (checkins.isEmpty) {
      return WellbeingScore(
        id: id,
        averageScore: 50.0, // Neutral score
        trend: 0.0,
        periodStart: periodStart,
        periodEnd: periodEnd,
        sampleSize: 0,
        checkins: const [],
      );
    }

    // Calculate average score
    final scores = checkins.map((c) => c.calculateScore()).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    // Calculate trend: compare first half vs second half
    double trend = 0.0;
    if (checkins.length >= 2) {
      final midpoint = checkins.length ~/ 2;
      final firstHalf = checkins.sublist(0, midpoint);
      final secondHalf = checkins.sublist(midpoint);

      final firstAvg = firstHalf.isEmpty
          ? 0.0
          : firstHalf
                  .map((c) => c.calculateScore())
                  .reduce((a, b) => a + b) /
              firstHalf.length;
      final secondAvg = secondHalf.isEmpty
          ? 0.0
          : secondHalf
                  .map((c) => c.calculateScore())
                  .reduce((a, b) => a + b) /
              secondHalf.length;

      trend = secondAvg - firstAvg;
    }

    return WellbeingScore(
      id: id,
      averageScore: averageScore,
      trend: trend,
      periodStart: periodStart,
      periodEnd: periodEnd,
      sampleSize: checkins.length,
      checkins: checkins,
    );
  }

  /// Checks if this score indicates a concerning pattern.
  ///
  /// Returns true if:
  /// - Average score is below 40 (low wellbeing)
  /// - Trend is declining by more than 15 points
  bool isConcerning() {
    return averageScore < 40 || trend < -15;
  }

  @override
  String toString() {
    return 'WellbeingScore(avg: ${averageScore.toStringAsFixed(1)}, '
        'trend: ${trend.toStringAsFixed(1)}, samples: $sampleSize)';
  }
}
