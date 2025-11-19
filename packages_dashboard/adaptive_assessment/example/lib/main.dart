import 'package:adaptive_assessment/adaptive_assessment.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example app demonstrating the adaptive assessment package
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Adaptive Assessment Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
}

/// Home screen with options to start assessment
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AdaptiveAssessmentService _service;

  @override
  void initState() {
    super.initState();
    _service = AdaptiveAssessmentService();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _startAssessment() {
    _service.resetAssessment();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => AdaptiveAssessmentWidget(
          service: _service,
          maxQuestions: 10,
          onComplete: () {
            _showResults();
          },
        ),
      ),
    );
  }

  void _showResults() {
    final state = _service.currentState;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Avaliação Concluída!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pontuação Total: ${state.totalScore}'),
            Text('Questões Respondidas: ${state.totalAnswered}'),
            Text('Acertos: ${state.correctAnswers}'),
            Text('Precisão: ${state.accuracy.toStringAsFixed(1)}%'),
            Text('Melhor Sequência: ${state.bestStreak}'),
            const SizedBox(height: 16),
            if (state.badges.isNotEmpty) ...[
              const Text(
                'Conquistas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: state.badges
                    .map((badge) => Chip(label: Text(badge)))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startAssessment();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Avaliação Adaptativa'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Avaliação Adaptativa com Gamificação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sistema de avaliação que se adapta ao seu desempenho com recursos de acessibilidade',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recursos:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeature(
                          Icons.accessibility_new,
                          'Acessibilidade',
                          'Suporte para dislexia, alto contraste e ajuste de fontes',
                        ),
                        _buildFeature(
                          Icons.volume_up,
                          'Leitura Assistida',
                          'Text-to-Speech para narração de perguntas',
                        ),
                        _buildFeature(
                          Icons.trending_up,
                          'Dificuldade Adaptativa',
                          'Ajuste automático baseado no desempenho',
                        ),
                        _buildFeature(
                          Icons.emoji_events,
                          'Gamificação',
                          'Pontos, sequências e conquistas',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _startAssessment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Iniciar Avaliação'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFeature(IconData icon, String title, String description) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
