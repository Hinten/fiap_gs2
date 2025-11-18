import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:research_dashboard/research_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Research Dashboard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardSelector(),
    );
  }
}

class DashboardSelector extends StatefulWidget {
  const DashboardSelector({super.key});

  @override
  State<DashboardSelector> createState() => _DashboardSelectorState();
}

class _DashboardSelectorState extends State<DashboardSelector> {
  final TextEditingController _apiUrlController = TextEditingController(
    text: 'http://localhost:8002',
  );
  final TextEditingController _userIdController = TextEditingController(
    text: 'advisor-001',
  );

  @override
  void dispose() {
    _apiUrlController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Dashboard - Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuração da API',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da API Python',
                        hintText: 'http://localhost:8002',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Certifique-se de que a API está rodando:\npython -m research_management.main',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecione o Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              title: 'Dashboard do Coordenador',
              description:
                  'Visão geral de todos os projetos, métricas e alertas',
              icon: Icons.dashboard,
              color: Colors.blue,
              onTap: () => _navigateToDashboard(
                context,
                DashboardType.coordinator,
              ),
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Dashboard do Orientador',
              description: 'Projetos, alunos e alertas do orientador',
              icon: Icons.school,
              color: Colors.green,
              onTap: () => _showUserIdDialog(
                context,
                DashboardType.advisor,
                'ID do Orientador',
                'advisor-001',
              ),
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Dashboard do Aluno',
              description: 'Status do projeto e informações do aluno',
              icon: Icons.person,
              color: Colors.orange,
              onTap: () => _showUserIdDialog(
                context,
                DashboardType.student,
                'ID do Aluno',
                'student-001',
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber[50],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Para testar com dados reais, inicie a API Python e o Firebase emulator.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, DashboardType type) {
    Widget screen;
    
    switch (type) {
      case DashboardType.coordinator:
        screen = const CoordinatorDashboardScreen();
        break;
      case DashboardType.advisor:
        screen = AdvisorDashboardScreen(advisorId: _userIdController.text);
        break;
      case DashboardType.student:
        screen = StudentDashboardScreen(studentId: _userIdController.text);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showUserIdDialog(
    BuildContext context,
    DashboardType type,
    String title,
    String defaultValue,
  ) {
    _userIdController.text = defaultValue;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _userIdController,
          decoration: InputDecoration(
            labelText: 'ID do Usuário',
            hintText: defaultValue,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDashboard(context, type);
            },
            child: const Text('Abrir Dashboard'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum DashboardType { coordinator, advisor, student }
