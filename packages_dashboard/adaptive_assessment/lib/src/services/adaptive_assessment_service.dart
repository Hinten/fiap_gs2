import 'dart:async';
import 'dart:math';

import '../models/assessment_state.dart';
import '../models/question.dart';
import '../models/theme_config.dart';

/// Service for managing adaptive assessments with accessibility features
class AdaptiveAssessmentService {
  /// Stream controller for assessment state changes
  final StreamController<AssessmentState> _stateController =
      StreamController<AssessmentState>.broadcast();

  /// Stream controller for theme configuration changes
  final StreamController<ThemeConfig> _themeController =
      StreamController<ThemeConfig>.broadcast();

  /// Current assessment state
  AssessmentState _currentState = const AssessmentState();

  /// Current theme configuration
  ThemeConfig _themeConfig = ThemeConfig.standard();

  /// Question bank for the assessment
  final List<Question> _questionBank = [];

  /// Set of question IDs that have been asked to avoid repetition
  final Set<String> _askedQuestionIds = {};

  /// Random number generator for question selection
  final Random _random = Random();

  /// Creates a new AdaptiveAssessmentService instance
  AdaptiveAssessmentService() {
    _initializeQuestionBank();
  }

  /// Stream of assessment state changes
  Stream<AssessmentState> get stateStream => _stateController.stream;

  /// Stream of theme configuration changes
  Stream<ThemeConfig> get themeStream => _themeController.stream;

  /// Current assessment state
  AssessmentState get currentState => _currentState;

  /// Current theme configuration
  ThemeConfig get themeConfig => _themeConfig;

  /// Initializes the question bank with sample questions
  void _initializeQuestionBank() {
    _questionBank.addAll([
      // Difficulty 1 - Easy
      const Question(
        id: 'q1',
        text: 'Qual é a capital do Brasil?',
        options: ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'],
        correctAnswerIndex: 2,
        difficulty: 1,
        category: 'Geografia',
      ),
      const Question(
        id: 'q2',
        text: 'Quanto é 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
        difficulty: 1,
        category: 'Matemática',
      ),
      const Question(
        id: 'q3',
        text: 'Qual cor é formada pela mistura de azul e amarelo?',
        options: ['Roxo', 'Verde', 'Laranja', 'Marrom'],
        correctAnswerIndex: 1,
        difficulty: 1,
        category: 'Cores',
      ),

      // Difficulty 2
      const Question(
        id: 'q4',
        text: 'Em que ano o Brasil foi descoberto?',
        options: ['1492', '1500', '1822', '1889'],
        correctAnswerIndex: 1,
        difficulty: 2,
        category: 'História',
      ),
      const Question(
        id: 'q5',
        text: 'Quanto é 15 × 3?',
        options: ['35', '45', '55', '65'],
        correctAnswerIndex: 1,
        difficulty: 2,
        category: 'Matemática',
      ),

      // Difficulty 3 - Medium
      const Question(
        id: 'q6',
        text: 'Qual é a fórmula química da água?',
        options: ['CO2', 'H2O', 'O2', 'NaCl'],
        correctAnswerIndex: 1,
        difficulty: 3,
        category: 'Química',
      ),
      const Question(
        id: 'q7',
        text: 'Quem escreveu "Dom Casmurro"?',
        options: [
          'José de Alencar',
          'Machado de Assis',
          'Carlos Drummond',
          'Clarice Lispector'
        ],
        correctAnswerIndex: 1,
        difficulty: 3,
        category: 'Literatura',
      ),

      // Difficulty 4
      const Question(
        id: 'q8',
        text: 'Qual a raiz quadrada de 144?',
        options: ['10', '11', '12', '13'],
        correctAnswerIndex: 2,
        difficulty: 4,
        category: 'Matemática',
      ),
      const Question(
        id: 'q9',
        text: 'Em que ano foi promulgada a Constituição brasileira atual?',
        options: ['1985', '1988', '1990', '1992'],
        correctAnswerIndex: 1,
        difficulty: 4,
        category: 'História',
      ),

      // Difficulty 5 - Hard
      const Question(
        id: 'q10',
        text: 'Qual é o teorema fundamental do cálculo?',
        options: [
          'Relaciona derivação e integração',
          'Define limites infinitos',
          'Estabelece séries convergentes',
          'Determina continuidade'
        ],
        correctAnswerIndex: 0,
        difficulty: 5,
        category: 'Matemática',
      ),
    ]);
  }

  /// Gets the next question based on current difficulty level
  Question? getNextQuestion() {
    // Filter questions by current difficulty level
    final targetDifficulty = _currentState.currentDifficulty;
    
    // Get questions that match difficulty and haven't been asked yet
    final availableQuestions = _questionBank
        .where((q) =>
            q.difficulty == targetDifficulty &&
            !_askedQuestionIds.contains(q.id))
        .toList();

    // If no unasked questions at this difficulty, try any unasked question
    if (availableQuestions.isEmpty) {
      final anyUnaskedQuestions = _questionBank
          .where((q) => !_askedQuestionIds.contains(q.id))
          .toList();
      
      if (anyUnaskedQuestions.isNotEmpty) {
        final selected = anyUnaskedQuestions[_random.nextInt(anyUnaskedQuestions.length)];
        _askedQuestionIds.add(selected.id);
        return selected;
      }
      
      // All questions have been asked, reset and start over
      _askedQuestionIds.clear();
      if (_questionBank.isNotEmpty) {
        final selected = _questionBank[_random.nextInt(_questionBank.length)];
        _askedQuestionIds.add(selected.id);
        return selected;
      }
      
      return null;
    }

    // Randomly select an unasked question from available ones
    final selected = availableQuestions[_random.nextInt(availableQuestions.length)];
    _askedQuestionIds.add(selected.id);
    return selected;
  }

  /// Submits an answer and updates the assessment state
  /// Returns true if the answer was correct
  bool submitAnswer({
    required Question question,
    required int selectedAnswerIndex,
  }) {
    final isCorrect = selectedAnswerIndex == question.correctAnswerIndex;

    // Calculate score based on difficulty and correctness
    final scoreIncrement = isCorrect ? question.difficulty * 10 : 0;

    // Update streak
    final newStreak = isCorrect ? _currentState.currentStreak + 1 : 0;
    final newBestStreak = max(newStreak, _currentState.bestStreak);

    // Adjust difficulty based on performance
    int newDifficulty = _currentState.currentDifficulty;
    if (isCorrect && _currentState.currentStreak >= 2) {
      // Increase difficulty after 3 correct answers in a row
      newDifficulty = min(5, newDifficulty + 1);
    } else if (!isCorrect && _currentState.currentStreak == 0) {
      // Decrease difficulty after wrong answer
      newDifficulty = max(1, newDifficulty - 1);
    }

    // Check for new badges
    final newBadges = List<String>.from(_currentState.badges);
    if (newStreak >= 3 && !newBadges.contains('streak_3')) {
      newBadges.add('streak_3');
    }
    if (newStreak >= 5 && !newBadges.contains('streak_5')) {
      newBadges.add('streak_5');
    }
    if (_currentState.totalAnswered + 1 >= 10 &&
        !newBadges.contains('answered_10')) {
      newBadges.add('answered_10');
    }

    // Update state
    _currentState = _currentState.copyWith(
      totalAnswered: _currentState.totalAnswered + 1,
      correctAnswers: _currentState.correctAnswers + (isCorrect ? 1 : 0),
      totalScore: _currentState.totalScore + scoreIncrement,
      currentDifficulty: newDifficulty,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      badges: newBadges,
    );

    // Notify listeners
    _stateController.add(_currentState);

    return isCorrect;
  }

  /// Resets the assessment to initial state
  void resetAssessment() {
    _currentState = const AssessmentState();
    _askedQuestionIds.clear();
    _stateController.add(_currentState);
  }

  /// Changes the accessibility theme
  void changeTheme(AccessibilityTheme theme) {
    switch (theme) {
      case AccessibilityTheme.standard:
        _themeConfig = ThemeConfig.standard();
        break;
      case AccessibilityTheme.highContrast:
        _themeConfig = ThemeConfig.highContrast();
        break;
      case AccessibilityTheme.dyslexiaFriendly:
        _themeConfig = ThemeConfig.dyslexiaFriendly();
        break;
    }
    _themeController.add(_themeConfig);
  }

  /// Updates theme configuration with custom settings
  void updateThemeConfig(ThemeConfig config) {
    _themeConfig = config;
    _themeController.add(_themeConfig);
  }

  /// Toggles text-to-speech feature
  void toggleTTS() {
    _themeConfig = _themeConfig.copyWith(ttsEnabled: !_themeConfig.ttsEnabled);
    _themeController.add(_themeConfig);
  }

  /// Updates font size multiplier
  void updateFontSize(double multiplier) {
    _themeConfig = _themeConfig.copyWith(fontSizeMultiplier: multiplier);
    _themeController.add(_themeConfig);
  }

  /// Updates letter spacing
  void updateLetterSpacing(double spacing) {
    _themeConfig = _themeConfig.copyWith(letterSpacing: spacing);
    _themeController.add(_themeConfig);
  }

  /// Updates speech rate for TTS
  void updateSpeechRate(double rate) {
    _themeConfig = _themeConfig.copyWith(speechRate: rate);
    _themeController.add(_themeConfig);
  }

  /// Adds custom questions to the question bank
  void addQuestions(List<Question> questions) {
    _questionBank.addAll(questions);
  }

  /// Clears all questions from the bank
  void clearQuestions() {
    _questionBank.clear();
    _initializeQuestionBank();
  }

  /// Disposes of resources
  void dispose() {
    _stateController.close();
    _themeController.close();
  }
}
