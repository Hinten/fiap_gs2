import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:approval_interface/approval_interface.dart';
import 'mock_data.dart';

/// Example app demonstrating the approval_interface package
///
/// This app shows how to integrate the approval interface into your application.
/// It uses mock data to simulate API responses.
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approval Interface Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends ConsumerStatefulWidget {
  const ExampleHomePage({super.key});

  @override
  ConsumerState<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends ConsumerState<ExampleHomePage> {
  bool _useMockData = true;

  @override
  void initState() {
    super.initState();
    // Load mock data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useMockData) {
        _loadMockData();
      }
    });
  }

  void _loadMockData() {
    // In a real app, you would fetch from an API
    // Here we're using mock data for demonstration
    final mockItems = MockData.generateMockApprovalItems();

    // Update the provider with mock data
    // This is a workaround since we're not using a real API
    ref.read(approvalProvider.notifier).state = ApprovalState(
      items: mockItems,
      isLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Interface Demo'),
        actions: [
          IconButton(
            icon: Icon(_useMockData ? Icons.cloud_off : Icons.cloud),
            onPressed: () {
              setState(() {
                _useMockData = !_useMockData;
                if (_useMockData) {
                  _loadMockData();
                } else {
                  // Clear data or fetch from real API
                  ref.read(approvalProvider.notifier).fetchPendingItems();
                }
              });
            },
            tooltip: _useMockData ? 'Usando dados mock' : 'Usando API real',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
            tooltip: 'Informações',
          ),
        ],
      ),
      body: const ApprovalDashboardScreen(),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.approval,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Approval Interface',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Demo Application',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Histórico não implementado neste demo'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações não implementadas neste demo'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Ver Código Fonte'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veja o repositório GitHub para o código fonte'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre este Demo'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Este é um aplicativo de demonstração para o pacote approval_interface.',
              ),
              SizedBox(height: 16),
              Text(
                'Recursos demonstrados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Listagem de items pendentes'),
              Text('• Aprovação e rejeição de items'),
              Text('• Filtros por tipo e prioridade'),
              Text('• Modo de seleção para operações em massa'),
              Text('• Estatísticas em tempo real'),
              Text('• Interface responsiva e Material Design 3'),
              SizedBox(height: 16),
              Text(
                'Este demo usa dados mock. Em produção, conecte ao seu backend API.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
