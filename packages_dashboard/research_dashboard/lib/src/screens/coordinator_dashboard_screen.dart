import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard.dart';
import '../models/alert.dart';
import '../providers/service_providers.dart';
import '../widgets/metric_card.dart';
import '../widgets/alert_card.dart';

final coordinatorDashboardProvider = FutureProvider<CoordinatorDashboard>((ref) async {
  final service = ref.watch(researchServiceProvider);
  return service.getCoordinatorDashboard();
});

final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final service = ref.watch(researchServiceProvider);
  return service.getAlerts();
});

/// Coordinator dashboard screen
class CoordinatorDashboardScreen extends ConsumerWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(coordinatorDashboardProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Coordenador'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(coordinatorDashboardProvider);
          ref.invalidate(alertsProvider);
        },
        child: dashboardAsync.when(
          data: (dashboard) => _buildDashboard(context, dashboard, alertsAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Erro ao carregar dashboard'),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(coordinatorDashboardProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    CoordinatorDashboard dashboard,
    AsyncValue<List<Alert>> alertsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              MetricCard(
                title: 'Total de Projetos',
                value: dashboard.totalProjects.toString(),
                icon: Icons.folder,
                color: Colors.blue,
                subtitle: '${dashboard.activeProjects} ativos',
              ),
              MetricCard(
                title: 'Taxa de Conclusão',
                value: '${dashboard.completionRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              MetricCard(
                title: 'Projetos em Risco',
                value: dashboard.projectsInRisk.toString(),
                icon: Icons.warning,
                color: Colors.orange,
                subtitle: '${dashboard.criticalCount} críticos',
              ),
              MetricCard(
                title: 'Alunos por Orientador',
                value: dashboard.avgStudentsPerAdvisor.toStringAsFixed(1),
                icon: Icons.people,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Warning Cards
          if (dashboard.studentsWithoutAdvisor > 0)
            Card(
              color: Colors.red[50],
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(
                  '⚠️ ${dashboard.studentsWithoutAdvisor} aluno(s) sem orientador',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Ação necessária'),
              ),
            ),
          const SizedBox(height: 16),
          
          // Alerts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alertas Ativos (${dashboard.activeAlertsCount})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 48, color: Colors.green[300]),
                          const SizedBox(height: 12),
                          const Text('Nenhum alerta ativo'),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return AlertCard(
                    alert: alerts[index],
                    onResolve: () {
                      // TODO: Implement resolve action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alerta resolvido')),
                      );
                    },
                    onDismiss: () {
                      // TODO: Implement dismiss action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alerta dispensado')),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Erro ao carregar alertas: $error'),
          ),
        ],
      ),
    );
  }
}
