import 'package:adaptive_assessment/adaptive_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveAssessmentService', () {
    late AdaptiveAssessmentService service;

    setUp(() {
      service = AdaptiveAssessmentService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initial state is correct', () {
      final state = service.currentState;
      expect(state.currentDifficulty, 1);
      expect(state.totalAnswered, 0);
      expect(state.correctAnswers, 0);
      expect(state.totalScore, 0);
      expect(state.currentStreak, 0);
      expect(state.bestStreak, 0);
    });

    test('can get next question', () {
      final question = service.getNextQuestion();
      expect(question, isNotNull);
      expect(question!.difficulty, 1); // Initial difficulty
    });

    test('correct answer increases score and difficulty', () {
      final question = service.getNextQuestion()!;

      // Answer correctly 3 times to increase difficulty
      service.submitAnswer(
        question: question,
        selectedAnswerIndex: question.correctAnswerIndex,
      );
      service.submitAnswer(
        question: question,
        selectedAnswerIndex: question.correctAnswerIndex,
      );
      service.submitAnswer(
        question: question,
        selectedAnswerIndex: question.correctAnswerIndex,
      );

      final state = service.currentState;
      expect(state.correctAnswers, 3);
      expect(state.currentStreak, 3);
      expect(state.totalScore, greaterThan(0));
      // Difficulty should increase after 3 correct answers
      expect(state.currentDifficulty, 2);
    });

    test('incorrect answer breaks streak and decreases difficulty', () {
      final question = service.getNextQuestion()!;

      // Give a wrong answer
      final wrongIndex = question.correctAnswerIndex == 0 ? 1 : 0;
      service.submitAnswer(
        question: question,
        selectedAnswerIndex: wrongIndex,
      );

      final state = service.currentState;
      expect(state.correctAnswers, 0);
      expect(state.currentStreak, 0);
      expect(state.totalAnswered, 1);
    });

    test('badges are awarded correctly', () {
      final question = service.getNextQuestion()!;

      // Answer correctly 3 times to earn streak badge
      for (var i = 0; i < 3; i++) {
        service.submitAnswer(
          question: question,
          selectedAnswerIndex: question.correctAnswerIndex,
        );
      }

      final state = service.currentState;
      expect(state.badges, contains('streak_3'));
    });

    test('can reset assessment', () {
      final question = service.getNextQuestion()!;
      service.submitAnswer(
        question: question,
        selectedAnswerIndex: question.correctAnswerIndex,
      );

      service.resetAssessment();

      final state = service.currentState;
      expect(state.currentDifficulty, 1);
      expect(state.totalAnswered, 0);
      expect(state.correctAnswers, 0);
      expect(state.totalScore, 0);
    });

    test('theme configuration changes correctly', () {
      service.changeTheme(AccessibilityTheme.highContrast);
      expect(
        service.themeConfig.theme,
        AccessibilityTheme.highContrast,
      );

      service.changeTheme(AccessibilityTheme.dyslexiaFriendly);
      expect(
        service.themeConfig.theme,
        AccessibilityTheme.dyslexiaFriendly,
      );
      expect(service.themeConfig.ttsEnabled, true);
      expect(service.themeConfig.fontFamily, 'OpenDyslexic');
    });

    test('can toggle TTS', () {
      final initialTts = service.themeConfig.ttsEnabled;
      service.toggleTTS();
      expect(service.themeConfig.ttsEnabled, !initialTts);
    });

    test('can update font size', () {
      service.updateFontSize(1.5);
      expect(service.themeConfig.fontSizeMultiplier, 1.5);
    });

    test('can update letter spacing', () {
      service.updateLetterSpacing(2.0);
      expect(service.themeConfig.letterSpacing, 2.0);
    });

    test('state stream emits updates', () async {
      final question = service.getNextQuestion()!;

      expectLater(
        service.stateStream,
        emits(
          predicate<AssessmentState>(
            (state) => state.totalAnswered == 1,
          ),
        ),
      );

      service.submitAnswer(
        question: question,
        selectedAnswerIndex: question.correctAnswerIndex,
      );
    });

    test('theme stream emits updates', () async {
      expectLater(
        service.themeStream,
        emits(
          predicate<ThemeConfig>(
            (config) => config.theme == AccessibilityTheme.highContrast,
          ),
        ),
      );

      service.changeTheme(AccessibilityTheme.highContrast);
    });
  });

  group('Question', () {
    test('can be created from JSON', () {
      final json = {
        'id': 'q1',
        'text': 'Test question',
        'options': ['A', 'B', 'C', 'D'],
        'correctAnswerIndex': 1,
        'difficulty': 2,
        'category': 'Test',
      };

      final question = Question.fromJson(json);
      expect(question.id, 'q1');
      expect(question.text, 'Test question');
      expect(question.options.length, 4);
      expect(question.correctAnswerIndex, 1);
      expect(question.difficulty, 2);
      expect(question.category, 'Test');
    });

    test('can be converted to JSON', () {
      const question = Question(
        id: 'q1',
        text: 'Test question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 1,
        difficulty: 2,
        category: 'Test',
      );

      final json = question.toJson();
      expect(json['id'], 'q1');
      expect(json['text'], 'Test question');
      expect(json['correctAnswerIndex'], 1);
      expect(json['difficulty'], 2);
    });

    test('copyWith creates correct copy', () {
      const question = Question(
        id: 'q1',
        text: 'Test question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 1,
        difficulty: 2,
      );

      final copy = question.copyWith(difficulty: 3);
      expect(copy.id, question.id);
      expect(copy.text, question.text);
      expect(copy.difficulty, 3);
    });
  });

  group('AssessmentState', () {
    test('calculates accuracy correctly', () {
      const state = AssessmentState(
        totalAnswered: 10,
        correctAnswers: 7,
      );

      expect(state.accuracy, 70.0);
    });

    test('accuracy is zero when no questions answered', () {
      const state = AssessmentState();
      expect(state.accuracy, 0.0);
    });

    test('can be converted to/from JSON', () {
      const state = AssessmentState(
        currentDifficulty: 3,
        totalAnswered: 10,
        correctAnswers: 7,
        totalScore: 150,
        badges: ['badge1', 'badge2'],
        currentStreak: 2,
        bestStreak: 5,
      );

      final json = state.toJson();
      final restored = AssessmentState.fromJson(json);

      expect(restored.currentDifficulty, state.currentDifficulty);
      expect(restored.totalAnswered, state.totalAnswered);
      expect(restored.correctAnswers, state.correctAnswers);
      expect(restored.totalScore, state.totalScore);
      expect(restored.badges, state.badges);
      expect(restored.currentStreak, state.currentStreak);
      expect(restored.bestStreak, state.bestStreak);
    });
  });

  group('ThemeConfig', () {
    test('standard theme has correct defaults', () {
      final config = ThemeConfig.standard();
      expect(config.theme, AccessibilityTheme.standard);
      expect(config.fontSizeMultiplier, 1.0);
      expect(config.letterSpacing, 0.0);
      expect(config.fontFamily, null);
      expect(config.ttsEnabled, false);
    });

    test('high contrast theme has correct settings', () {
      final config = ThemeConfig.highContrast();
      expect(config.theme, AccessibilityTheme.highContrast);
      expect(config.fontSizeMultiplier, 1.2);
      expect(config.letterSpacing, 0.5);
    });

    test('dyslexia-friendly theme has correct settings', () {
      final config = ThemeConfig.dyslexiaFriendly();
      expect(config.theme, AccessibilityTheme.dyslexiaFriendly);
      expect(config.fontSizeMultiplier, 1.3);
      expect(config.letterSpacing, 1.5);
      expect(config.fontFamily, 'OpenDyslexic');
      expect(config.ttsEnabled, true);
    });

    test('can be converted to/from JSON', () {
      final config = ThemeConfig.dyslexiaFriendly();
      final json = config.toJson();
      final restored = ThemeConfig.fromJson(json);

      expect(restored.theme, config.theme);
      expect(restored.fontSizeMultiplier, config.fontSizeMultiplier);
      expect(restored.letterSpacing, config.letterSpacing);
      expect(restored.fontFamily, config.fontFamily);
      expect(restored.ttsEnabled, config.ttsEnabled);
    });
  });
}
