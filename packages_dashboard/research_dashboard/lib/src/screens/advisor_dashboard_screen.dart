import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard.dart';
import '../providers/service_providers.dart';
import '../widgets/metric_card.dart';
import '../widgets/project_card.dart';
import '../models/project.dart';

final advisorDashboardProvider =
    FutureProvider.family<AdvisorDashboard, String>((ref, advisorId) async {
  final service = ref.watch(researchServiceProvider);
  return service.getAdvisorDashboard(advisorId);
});

final advisorProjectsProvider =
    FutureProvider.family<List<ResearchProject>, String>((ref, advisorId) async {
  final service = ref.watch(researchServiceProvider);
  final projects = await service.getProjects(limit: 100);
  // Filter would be done server-side in real implementation
  return projects;
});

/// Advisor dashboard screen
class AdvisorDashboardScreen extends ConsumerWidget {
  final String advisorId;

  const AdvisorDashboardScreen({
    super.key,
    required this.advisorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(advisorDashboardProvider(advisorId));
    final projectsAsync = ref.watch(advisorProjectsProvider(advisorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Orientador'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(advisorDashboardProvider(advisorId));
          ref.invalidate(advisorProjectsProvider(advisorId));
        },
        child: dashboardAsync.when(
          data: (dashboard) =>
              _buildDashboard(context, dashboard, projectsAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text('Erro ao carregar dashboard'),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(advisorDashboardProvider(advisorId));
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
    AdvisorDashboard dashboard,
    AsyncValue<List<ResearchProject>> projectsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meus Projetos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Metrics
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              MetricCard(
                title: 'Projetos Totais',
                value: dashboard.totalProjects.toString(),
                icon: Icons.folder,
                color: Colors.blue,
              ),
              MetricCard(
                title: 'Projetos Ativos',
                value: dashboard.activeProjects.toString(),
                icon: Icons.folder_open,
                color: Colors.green,
              ),
              MetricCard(
                title: 'Total de Alunos',
                value: dashboard.totalStudents.toString(),
                icon: Icons.school,
                color: Colors.purple,
              ),
              MetricCard(
                title: 'Alertas Ativos',
                value: dashboard.activeAlerts.toString(),
                icon: Icons.notifications,
                color: dashboard.activeAlerts > 0 ? Colors.orange : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Projects List
          Text(
            'Lista de Projetos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text('Nenhum projeto encontrado'),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: projects[index],
                    onTap: () {
                      // Navigate to project details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Detalhes do projeto: ${projects[index].title}'),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Text('Erro ao carregar projetos: $error'),
          ),
        ],
      ),
    );
  }
}
