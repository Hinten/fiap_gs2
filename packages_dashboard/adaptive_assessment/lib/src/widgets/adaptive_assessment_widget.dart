import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/assessment_state.dart';
import '../models/question.dart';
import '../models/theme_config.dart';
import '../services/adaptive_assessment_service.dart';

/// Widget for displaying adaptive assessments with accessibility features
class AdaptiveAssessmentWidget extends StatefulWidget {
  /// The assessment service to use
  final AdaptiveAssessmentService service;

  /// Callback when assessment is completed
  final VoidCallback? onComplete;

  /// Maximum number of questions in the assessment
  final int? maxQuestions;

  /// Creates a new AdaptiveAssessmentWidget instance
  const AdaptiveAssessmentWidget({
    required this.service,
    this.onComplete,
    this.maxQuestions,
    super.key,
  });

  @override
  State<AdaptiveAssessmentWidget> createState() =>
      _AdaptiveAssessmentWidgetState();
}

class _AdaptiveAssessmentWidgetState extends State<AdaptiveAssessmentWidget>
    with SingleTickerProviderStateMixin {
  Question? _currentQuestion;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  FlutterTts? _flutterTts;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadNextQuestion();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage('pt-BR');
    await _flutterTts?.setSpeechRate(widget.service.themeConfig.speechRate);
  }

  void _loadNextQuestion() {
    setState(() {
      _currentQuestion = widget.service.getNextQuestion();
      _selectedAnswer = null;
      _showFeedback = false;
      _isCorrect = false;
    });

    // Auto-read question if TTS is enabled
    if (widget.service.themeConfig.ttsEnabled && _currentQuestion != null) {
      _speakText(_currentQuestion!.text);
    }
  }

  Future<void> _speakText(String text) async {
    if (_flutterTts != null) {
      await _flutterTts!.speak(text);
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _currentQuestion == null) {
      return;
    }

    final isCorrect = widget.service.submitAnswer(
      question: _currentQuestion!,
      selectedAnswerIndex: _selectedAnswer!,
    );

    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
    });

    if (isCorrect) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    // Speak feedback
    if (widget.service.themeConfig.ttsEnabled) {
      _speakText(
          isCorrect ? 'Correto! Parabéns!' : 'Incorreto. Tente novamente!');
    }

    // Auto-advance after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final state = widget.service.currentState;
        if (widget.maxQuestions != null &&
            state.totalAnswered >= widget.maxQuestions!) {
          widget.onComplete?.call();
        } else {
          _loadNextQuestion();
        }
      }
    });
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<ThemeConfig>(
        stream: widget.service.themeStream,
        initialData: widget.service.themeConfig,
        builder: (context, themeSnapshot) {
          final themeConfig = themeSnapshot.data ?? ThemeConfig.standard();

          return StreamBuilder<AssessmentState>(
            stream: widget.service.stateStream,
            initialData: widget.service.currentState,
            builder: (context, stateSnapshot) {
              final state = stateSnapshot.data ?? const AssessmentState();

              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Avaliação Adaptativa',
                    style: TextStyle(
                      fontSize: 20 * themeConfig.fontSizeMultiplier,
                      letterSpacing: themeConfig.letterSpacing,
                      fontFamily: themeConfig.fontFamily,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_accessibility),
                      onPressed: () => _showAccessibilitySettings(context),
                      tooltip: 'Configurações de Acessibilidade',
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    _buildProgressBar(state, themeConfig),
                    _buildStatsBar(state, themeConfig),
                    _buildBadgesBar(state, themeConfig),
                    Expanded(
                      child: _currentQuestion != null
                          ? _buildQuestionCard(
                              _currentQuestion!,
                              themeConfig,
                            )
                          : _buildEmptyState(themeConfig),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

  Widget _buildProgressBar(
    AssessmentState state,
    ThemeConfig themeConfig,
  ) =>
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso',
                  style: TextStyle(
                    fontSize: 14 * themeConfig.fontSizeMultiplier,
                    fontWeight: FontWeight.bold,
                    letterSpacing: themeConfig.letterSpacing,
                    fontFamily: themeConfig.fontFamily,
                  ),
                ),
                Text(
                  '${state.totalAnswered} ${widget.maxQuestions != null ? '/ ${widget.maxQuestions}' : ''}',
                  style: TextStyle(
                    fontSize: 14 * themeConfig.fontSizeMultiplier,
                    letterSpacing: themeConfig.letterSpacing,
                    fontFamily: themeConfig.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.maxQuestions != null
                  ? state.totalAnswered / widget.maxQuestions!
                  : 0,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );

  Widget _buildStatsBar(
    AssessmentState state,
    ThemeConfig themeConfig,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.score,
              label: 'Pontos',
              value: '${state.totalScore}',
              themeConfig: themeConfig,
            ),
            _buildStatItem(
              icon: Icons.check_circle,
              label: 'Acertos',
              value: '${state.correctAnswers}/${state.totalAnswered}',
              themeConfig: themeConfig,
            ),
            _buildStatItem(
              icon: Icons.trending_up,
              label: 'Sequência',
              value: '${state.currentStreak}',
              themeConfig: themeConfig,
            ),
            _buildStatItem(
              icon: Icons.signal_cellular_alt,
              label: 'Nível',
              value: '${state.currentDifficulty}',
              themeConfig: themeConfig,
            ),
          ],
        ),
      );

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeConfig themeConfig,
  }) =>
      Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16 * themeConfig.fontSizeMultiplier,
              fontWeight: FontWeight.bold,
              letterSpacing: themeConfig.letterSpacing,
              fontFamily: themeConfig.fontFamily,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * themeConfig.fontSizeMultiplier,
              color: Colors.grey[600],
              letterSpacing: themeConfig.letterSpacing,
              fontFamily: themeConfig.fontFamily,
            ),
          ),
        ],
      );

  Widget _buildBadgesBar(
    AssessmentState state,
    ThemeConfig themeConfig,
  ) {
    if (state.badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: state.badges.map((badge) => _buildBadge(badge)).toList(),
      ),
    );
  }

  Widget _buildBadge(String badgeId) {
    IconData icon;
    String label;
    Color color;

    switch (badgeId) {
      case 'streak_3':
        icon = Icons.local_fire_department;
        label = '3 em sequência';
        color = Colors.orange;
        break;
      case 'streak_5':
        icon = Icons.whatshot;
        label = '5 em sequência';
        color = Colors.red;
        break;
      case 'answered_10':
        icon = Icons.stars;
        label = '10 questões';
        color = Colors.purple;
        break;
      default:
        icon = Icons.emoji_events;
        label = badgeId;
        color = Colors.blue;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildQuestionCard(
    Question question,
    ThemeConfig themeConfig,
  ) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (question.category != null)
                      Chip(
                        label: Text(question.category!),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    if (themeConfig.ttsEnabled)
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speakText(question.text),
                        tooltip: 'Ler pergunta',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    question.text,
                    style: TextStyle(
                      fontSize: 20 * themeConfig.fontSizeMultiplier,
                      fontWeight: FontWeight.bold,
                      letterSpacing: themeConfig.letterSpacing,
                      fontFamily: themeConfig.fontFamily,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return _buildOptionButton(
                    index: index,
                    option: option,
                    themeConfig: themeConfig,
                  );
                }),
                if (_showFeedback) ...[
                  const SizedBox(height: 24),
                  _buildFeedback(themeConfig),
                ],
                if (!_showFeedback && _selectedAnswer != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      textStyle: TextStyle(
                        fontSize: 18 * themeConfig.fontSizeMultiplier,
                        letterSpacing: themeConfig.letterSpacing,
                        fontFamily: themeConfig.fontFamily,
                      ),
                    ),
                    child: const Text('Confirmar Resposta'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _buildOptionButton({
    required int index,
    required String option,
    required ThemeConfig themeConfig,
  }) {
    final isSelected = _selectedAnswer == index;
    Color? backgroundColor;
    Color? borderColor;

    if (_showFeedback) {
      if (index == _currentQuestion!.correctAnswerIndex) {
        backgroundColor = Colors.green[100];
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red[100];
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _showFeedback
              ? null
              : () {
                  setState(() {
                    _selectedAnswer = index;
                  });
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ?? Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * themeConfig.fontSizeMultiplier,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16 * themeConfig.fontSizeMultiplier,
                      letterSpacing: themeConfig.letterSpacing,
                      fontFamily: themeConfig.fontFamily,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(ThemeConfig themeConfig) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isCorrect ? Colors.green[100] : Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _isCorrect
                    ? '🎉 Parabéns! Resposta correta!'
                    : '😔 Resposta incorreta. Continue tentando!',
                style: TextStyle(
                  fontSize: 16 * themeConfig.fontSizeMultiplier,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green[900] : Colors.red[900],
                  letterSpacing: themeConfig.letterSpacing,
                  fontFamily: themeConfig.fontFamily,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState(ThemeConfig themeConfig) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma pergunta disponível',
              style: TextStyle(
                fontSize: 18 * themeConfig.fontSizeMultiplier,
                color: Colors.grey[600],
                letterSpacing: themeConfig.letterSpacing,
                fontFamily: themeConfig.fontFamily,
              ),
            ),
          ],
        ),
      );

  void _showAccessibilitySettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _AccessibilitySettingsSheet(
        service: widget.service,
      ),
    );
  }
}

/// Bottom sheet for accessibility settings
class _AccessibilitySettingsSheet extends StatefulWidget {
  final AdaptiveAssessmentService service;

  const _AccessibilitySettingsSheet({
    required this.service,
  });

  @override
  State<_AccessibilitySettingsSheet> createState() =>
      _AccessibilitySettingsSheetState();
}

class _AccessibilitySettingsSheetState
    extends State<_AccessibilitySettingsSheet> {
  @override
  Widget build(BuildContext context) => StreamBuilder<ThemeConfig>(
        stream: widget.service.themeStream,
        initialData: widget.service.themeConfig,
        builder: (context, snapshot) {
          final config = snapshot.data ?? ThemeConfig.standard();

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Acessibilidade',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Tema:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Padrão'),
                      selected: config.theme == AccessibilityTheme.standard,
                      onSelected: (selected) {
                        if (selected) {
                          widget.service
                              .changeTheme(AccessibilityTheme.standard);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Alto Contraste'),
                      selected: config.theme == AccessibilityTheme.highContrast,
                      onSelected: (selected) {
                        if (selected) {
                          widget.service
                              .changeTheme(AccessibilityTheme.highContrast);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Dislexia'),
                      selected:
                          config.theme == AccessibilityTheme.dyslexiaFriendly,
                      onSelected: (selected) {
                        if (selected) {
                          widget.service
                              .changeTheme(AccessibilityTheme.dyslexiaFriendly);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Leitura Assistida (TTS)'),
                  subtitle: const Text('Narração em voz alta'),
                  value: config.ttsEnabled,
                  onChanged: (_) {
                    widget.service.toggleTTS();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Tamanho da Fonte: ${config.fontSizeMultiplier.toStringAsFixed(1)}x',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: config.fontSizeMultiplier,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${config.fontSizeMultiplier.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    widget.service.updateFontSize(value);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Espaçamento: ${config.letterSpacing.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: config.letterSpacing,
                  min: 0.0,
                  max: 3.0,
                  divisions: 6,
                  label: config.letterSpacing.toStringAsFixed(1),
                  onChanged: (value) {
                    widget.service.updateLetterSpacing(value);
                  },
                ),
              ],
            ),
          );
        },
      );
}
