import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard.dart';
import '../providers/service_providers.dart';

final studentDashboardProvider =
    FutureProvider.family<StudentDashboard, String>((ref, studentId) async {
  final service = ref.watch(researchServiceProvider);
  return service.getStudentDashboard(studentId);
});

/// Student dashboard screen
class StudentDashboardScreen extends ConsumerWidget {
  final String studentId;

  const StudentDashboardScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(studentDashboardProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Aluno'),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentDashboardProvider(studentId));
        },
        child: dashboardAsync.when(
          data: (dashboard) => _buildDashboard(context, dashboard),
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
                    ref.invalidate(studentDashboardProvider(studentId));
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

  Widget _buildDashboard(BuildContext context, StudentDashboard dashboard) {
    if (!dashboard.hasProject) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                dashboard.message ?? 'Nenhum projeto ativo encontrado',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Entre em contato com a coordenação para ser alocado em um projeto',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meu Projeto',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Project Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dashboard.projectTitle ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        _getHealthEmoji(dashboard.healthStatus),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.category,
                    'Área',
                    dashboard.area ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.flag,
                    'Status',
                    _getStatusDisplay(dashboard.status),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.health_and_safety,
                    'Saúde do Projeto',
                    _getHealthDisplay(dashboard.healthStatus),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.person,
                    'Orientador',
                    dashboard.hasAdvisor == true
                        ? '✅ Atribuído'
                        : '⚠️ Não atribuído',
                    isWarning: dashboard.hasAdvisor != true,
                  ),
                  if (dashboard.expectedEndDate != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Prazo Esperado',
                      _formatDate(dashboard.expectedEndDate!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Alerts Section
          if ((dashboard.activeAlerts ?? 0) > 0) ...[
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(
                  '${dashboard.activeAlerts} alerta(s) ativo(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Verifique com seu orientador'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ver alertas')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick Actions
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submeter atualização')),
                    );
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Submeter Atualização'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ver timeline')),
                    );
                  },
                  icon: const Icon(Icons.timeline),
                  label: const Text('Ver Timeline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isWarning ? Colors.orange : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? Colors.orange : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusDisplay(String? status) {
    if (status == null) return 'N/A';
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'proposal':
        return 'Proposta';
      case 'paused':
        return 'Pausado';
      case 'completed':
        return 'Concluído';
      case 'archived':
        return 'Arquivado';
      default:
        return status;
    }
  }

  String _getHealthDisplay(String? healthStatus) {
    if (healthStatus == null) return 'N/A';
    switch (healthStatus) {
      case 'on_track':
        return '🟢 No Prazo';
      case 'at_risk':
        return '🟡 Em Risco';
      case 'critical':
        return '🔴 Crítico';
      default:
        return healthStatus;
    }
  }

  String _getHealthEmoji(String? healthStatus) {
    if (healthStatus == null) return '❓';
    switch (healthStatus) {
      case 'on_track':
        return '🟢';
      case 'at_risk':
        return '🟡';
      case 'critical':
        return '🔴';
      default:
        return '❓';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
