/// Adaptive Assessment Package
///
/// A Flutter package for creating adaptive and accessible assessments
/// with gamification features and dyslexia support.
///
/// ## Features
///
/// - 🎯 Adaptive difficulty adjustment based on user performance
/// - ♿ Accessibility support (dyslexia-friendly fonts, high contrast themes)
/// - 🗣️ Text-to-Speech (TTS) for assisted reading
/// - 🎮 Gamification (points, streaks, badges, progress tracking)
/// - 📊 Real-time performance metrics
/// - 🎨 Multiple theme options for accessibility
///
/// ## Quick Start
///
/// ```dart
/// import 'package:adaptive_assessment/adaptive_assessment.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final service = AdaptiveAssessmentService();
///
///     return MaterialApp(
///       home: AdaptiveAssessmentWidget(
///         service: service,
///         maxQuestions: 10,
///         onComplete: () {
///           print('Assessment completed!');
///         },
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Usage
///
/// ### Initialize the Service
///
/// ```dart
/// final service = AdaptiveAssessmentService();
/// ```
///
/// ### Display the Assessment Widget
///
/// ```dart
/// AdaptiveAssessmentWidget(
///   service: service,
///   maxQuestions: 10, // Optional: limit number of questions
///   onComplete: () {
///     // Handle assessment completion
///     final state = service.currentState;
///     print('Score: ${state.totalScore}');
///     print('Accuracy: ${state.accuracy}%');
///   },
/// )
/// ```
///
/// ### Listen to State Changes
///
/// ```dart
/// service.stateStream.listen((state) {
///   print('Questions answered: ${state.totalAnswered}');
///   print('Current difficulty: ${state.currentDifficulty}');
/// });
/// ```
///
/// ### Change Accessibility Theme
///
/// ```dart
/// // Switch to high contrast mode
/// service.changeTheme(AccessibilityTheme.highContrast);
///
/// // Switch to dyslexia-friendly mode
/// service.changeTheme(AccessibilityTheme.dyslexiaFriendly);
///
/// // Toggle text-to-speech
/// service.toggleTTS();
/// ```
///
/// ### Add Custom Questions
///
/// ```dart
/// service.addQuestions([
///   Question(
///     id: 'custom1',
///     text: 'What is 2 + 2?',
///     options: ['3', '4', '5', '6'],
///     correctAnswerIndex: 1,
///     difficulty: 1,
///     category: 'Math',
///   ),
/// ]);
/// ```
///
/// ## Accessibility Features
///
/// The package provides comprehensive accessibility support:
///
/// - **Dyslexia-friendly fonts**: OpenDyslexic font option
/// - **Adjustable font size**: 0.8x to 2.0x multiplier
/// - **Letter spacing**: Customizable for better readability
/// - **High contrast themes**: Better visibility for users with visual impairments
/// - **Text-to-Speech**: Automatic narration of questions and feedback
/// - **Keyboard navigation**: Full support for keyboard-only users
///
/// ## Gamification Elements
///
/// - **Progress tracking**: Visual progress bar
/// - **Scoring system**: Points based on difficulty level
/// - **Streaks**: Track consecutive correct answers
/// - **Badges**: Earn achievements for milestones
/// - **Difficulty adaptation**: Automatic adjustment based on performance
/// - **Visual feedback**: Animations for correct answers
///
/// ## Performance Metrics
///
/// The assessment tracks various metrics:
///
/// - Total questions answered
/// - Correct answers count
/// - Accuracy percentage
/// - Current difficulty level
/// - Current streak
/// - Best streak
/// - Total score
/// - Earned badges
library adaptive_assessment;

// Models
export 'src/models/assessment_state.dart';
export 'src/models/question.dart';
export 'src/models/theme_config.dart';

// Services
export 'src/services/adaptive_assessment_service.dart';

// Widgets
export 'src/widgets/adaptive_assessment_widget.dart';
