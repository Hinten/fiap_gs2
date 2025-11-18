import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tema/tema.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider);

    return MaterialApp(
      title: 'Tema Example',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider);
    final brightness = ref.read(temaProvider.notifier).getEffectiveBrightness();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Package Example'),
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon(themeMode)),
            onPressed: () => ref.read(temaProvider.notifier).toggle(),
            tooltip: 'Alternar Tema',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status do Tema',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    'Modo Selecionado',
                    _getThemeName(themeMode),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Brilho Efetivo',
                    brightness == Brightness.light ? 'Claro' : 'Escuro',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme Controls Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controles de Tema',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.light_mode),
                    title: const Text('Tema Claro'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (_) =>
                          ref.read(temaProvider.notifier).setLight(),
                    ),
                    onTap: () => ref.read(temaProvider.notifier).setLight(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Tema Escuro'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (_) =>
                          ref.read(temaProvider.notifier).setDark(),
                    ),
                    onTap: () => ref.read(temaProvider.notifier).setDark(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_suggest),
                    title: const Text('Seguir Sistema'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: (_) =>
                          ref.read(temaProvider.notifier).setSystem(),
                    ),
                    onTap: () => ref.read(temaProvider.notifier).setSystem(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Alternar Tema'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ref.read(temaProvider.notifier).toggle(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Components Demo Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Componentes Demo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Elevated Button'),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Filled Button'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Outlined Button'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Text Button'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Text Field',
                      hintText: 'Digite algo aqui',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(value: 0.6),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const Text('Checkbox'),
                      const SizedBox(width: 16),
                      Switch(value: true, onChanged: (_) {}),
                      const Text('Switch'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Colors Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paleta de Cores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildColorSwatch(
                    context,
                    'Primary',
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  _buildColorSwatch(
                    context,
                    'Secondary',
                    Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  _buildColorSwatch(
                    context,
                    'Error',
                    Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  _buildColorSwatch(
                    context,
                    'Surface',
                    Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(height: 8),
                  _buildColorSwatch(
                    context,
                    'Background',
                    Theme.of(context).colorScheme.background,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(temaProvider.notifier).toggle(),
        tooltip: 'Alternar Tema',
        child: Icon(_getThemeIcon(themeMode)),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(BuildContext context, String name, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
