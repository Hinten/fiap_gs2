import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:research_dashboard/research_dashboard.dart';

class ResearchScreen extends ConsumerStatefulWidget {
  const ResearchScreen({super.key});

  @override
  ConsumerState<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends ConsumerState<ResearchScreen> {
  String _selectedRole = 'coordinator';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Pesquisa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // Role selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'coordinator',
                  label: Text('Coordenador'),
                  icon: Icon(Icons.admin_panel_settings),
                ),
                ButtonSegment(
                  value: 'advisor',
                  label: Text('Orientador'),
                  icon: Icon(Icons.school),
                ),
                ButtonSegment(
                  value: 'student',
                  label: Text('Aluno'),
                  icon: Icon(Icons.person),
                ),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedRole = newSelection.first;
                });
              },
            ),
          ),
          
          // Dashboard based on role
          Expanded(
            child: _buildDashboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    switch (_selectedRole) {
      case 'coordinator':
        return const CoordinatorDashboardScreen();
      case 'advisor':
        return const AdvisorDashboardScreen(advisorId: 'demo-advisor-id');
      case 'student':
        return const StudentDashboardScreen(studentId: 'demo-student-id');
      default:
        return const Center(child: Text('Selecione um perfil'));
    }
  }
}
