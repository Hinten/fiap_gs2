/// Represents a wellbeing check-in entry from a student.
///
/// Contains self-assessment data including mood and stress levels.
/// All data is collected with explicit consent and stored temporarily.
class WellbeingCheckin {
  /// Unique identifier for this check-in.
  /// Uses rotating UUID to support anonymization.
  final String id;

  /// Optional student ID. Only stored locally with consent.
  /// Set to null when anonymized for transmission.
  final String? studentId;

  /// Timestamp when the check-in was created.
  final DateTime timestamp;

  /// Mood level on a scale of 1-5.
  /// 1 = Very sad, 2 = Sad, 3 = Neutral, 4 = Happy, 5 = Very happy
  final int moodLevel;

  /// Stress level on a scale of 1-5.
  /// 1 = Very low, 2 = Low, 3 = Moderate, 4 = High, 5 = Very high
  final int stressLevel;

  /// Optional notes from the student about their wellbeing.
  final String? notes;

  /// Whether the student has consented to share this data.
  final bool consentToShare;

  /// Whether this check-in has been anonymized.
  final bool isAnonymized;

  const WellbeingCheckin({
    required this.id,
    this.studentId,
    required this.timestamp,
    required this.moodLevel,
    required this.stressLevel,
    this.notes,
    required this.consentToShare,
    this.isAnonymized = false,
  });

  /// Creates a check-in from JSON data.
  factory WellbeingCheckin.fromJson(Map<String, dynamic> json) {
    return WellbeingCheckin(
      id: json['id'] as String,
      studentId: json['student_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      moodLevel: json['mood_level'] as int,
      stressLevel: json['stress_level'] as int,
      notes: json['notes'] as String?,
      consentToShare: json['consent_to_share'] as bool,
      isAnonymized: json['is_anonymized'] as bool? ?? false,
    );
  }

  /// Converts this check-in to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'timestamp': timestamp.toIso8601String(),
      'mood_level': moodLevel,
      'stress_level': stressLevel,
      'notes': notes,
      'consent_to_share': consentToShare,
      'is_anonymized': isAnonymized,
    };
  }

  /// Creates an anonymized copy of this check-in.
  ///
  /// Removes student ID and personal identifiers while preserving
  /// aggregate data useful for trend analysis.
  WellbeingCheckin anonymize({required String anonymousId}) {
    return WellbeingCheckin(
      id: anonymousId,
      studentId: null,
      timestamp: timestamp,
      moodLevel: moodLevel,
      stressLevel: stressLevel,
      notes: null, // Remove personal notes
      consentToShare: consentToShare,
      isAnonymized: true,
    );
  }

  /// Calculates a composite wellbeing score (0-100).
  ///
  /// Higher scores indicate better wellbeing.
  /// Formula: weighted average of inverted stress and mood.
  double calculateScore() {
    // Invert stress level (high stress = low score)
    final invertedStress = 6 - stressLevel;
    // mood: 1-5, stress inverted: 1-5
    // Average and scale to 0-100
    return ((moodLevel + invertedStress) / 2) * 20;
  }

  @override
  String toString() {
    return 'WellbeingCheckin(id: $id, mood: $moodLevel, '
        'stress: $stressLevel, timestamp: $timestamp)';
  }
}
