import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_assessment/adaptive_assessment.dart';

/// Screen for adaptive assessments with gamification
class AdaptiveAssessmentScreen extends ConsumerStatefulWidget {
  const AdaptiveAssessmentScreen({super.key});

  @override
  ConsumerState<AdaptiveAssessmentScreen> createState() =>
      _AdaptiveAssessmentScreenState();
}

class _AdaptiveAssessmentScreenState
    extends ConsumerState<AdaptiveAssessmentScreen> {
  late AdaptiveAssessmentService _assessmentService;

  @override
  void initState() {
    super.initState();
    _assessmentService = AdaptiveAssessmentService();
  }

  @override
  void dispose() {
    _assessmentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações Adaptativas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sistema de avaliação adaptativa com gamificação e acessibilidade.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          // Assessment widget
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: AdaptiveAssessmentWidget(
                  service: _assessmentService,
                  maxQuestions: 10, // Limit to 10 questions
                  onComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Avaliação concluída com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
