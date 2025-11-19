import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_wellbeing/student_wellbeing.dart';

/// Screen for viewing student wellbeing analytics and alerts
class WellbeingScreen extends ConsumerStatefulWidget {
  const WellbeingScreen({super.key});

  @override
  ConsumerState<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends ConsumerState<WellbeingScreen> {
  late WellbeingMonitoringService _wellbeingService;

  @override
  void initState() {
    super.initState();
    _wellbeingService = WellbeingMonitoringService(
      retentionDays: 30,
      alertWindowDays: 7,
      stressThreshold: 4.0,
      scoreThreshold: 40.0,
    );
    _wellbeingService.initialize();
  }

  @override
  void dispose() {
    _wellbeingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-Estar Estudantil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.warning), text: 'Alertas'),
                Tab(icon: Icon(Icons.person), text: 'Check-in Demo'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Alerts dashboard
                  EarlyAlertDashboard(service: _wellbeingService),
                  
                  // Demo check-in (normally students would use this on mobile app)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Colors.blue[50],
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Demonstração: Normalmente os estudantes usariam um aplicativo móvel para fazer check-ins.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        WellbeingCheckinWidget(
                          studentId: 'demo-student-001',
                          service: _wellbeingService,
                          onCheckinRecorded: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Check-in registrado com sucesso!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
