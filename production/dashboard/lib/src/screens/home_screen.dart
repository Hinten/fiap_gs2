import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tema/tema.dart';

import '../core/auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authUserProvider);
    final skipAuth = ref.watch(skipAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FIAP AI-Enhanced Learning Platform'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(temaProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(temaProvider.notifier).toggle();
            },
          ),
          // Logout button
          if (!skipAuth)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
        ],
      ),
      body: authUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo, ${user?.displayName ?? user?.email ?? "Usuário"}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (skipAuth)
                          Chip(
                            label: const Text('Modo Demo - Sem Autenticação'),
                            backgroundColor: Colors.orange[100],
                          ),
                        if (user?.role != null)
                          Chip(
                            label: Text('Perfil: ${user!.role}'),
                            backgroundColor: Colors.blue[100],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Services grid
                Text(
                  'Serviços Disponíveis',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _ServiceCard(
                      title: 'Gestão de Pesquisa',
                      description: 'Sistema de iniciação científica',
                      icon: Icons.science,
                      color: Colors.blue,
                      onTap: () => context.go('/research'),
                    ),
                    _ServiceCard(
                      title: 'Revisão de Conteúdo',
                      description: 'Agente de IA para revisão',
                      icon: Icons.rate_review,
                      color: Colors.green,
                      onTap: () => context.go('/content-review'),
                    ),
                    _ServiceCard(
                      title: 'Aprovações',
                      description: 'Interface de aprovação humana',
                      icon: Icons.check_circle,
                      color: Colors.orange,
                      onTap: () => context.go('/approval'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // MVP status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status do MVP',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _StatusItem(
                          title: 'Backend Unificado',
                          status: true,
                        ),
                        _StatusItem(
                          title: 'Dashboard Unificado',
                          status: true,
                        ),
                        _StatusItem(
                          title: 'Sistema de Pesquisa',
                          status: true,
                        ),
                        _StatusItem(
                          title: 'Revisão de Conteúdo',
                          status: true,
                        ),
                        _StatusItem(
                          title: 'Interface de Aprovação',
                          status: true,
                        ),
                        _StatusItem(
                          title: 'Sistema de Temas',
                          status: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final bool status;

  const _StatusItem({
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}
