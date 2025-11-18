# Tema - Theme Package

Pacote Flutter para gerenciamento de temas claro e escuro com suporte ao tema do sistema e persistência de preferências do usuário.

## 🎨 Características

- ✅ **Temas Modernos**: Material Design 3 com esquemas de cores atraentes
- ✅ **Tema Claro e Escuro**: Definições completas para ambos os modos
- ✅ **Detecção do Sistema**: Segue automaticamente o tema do sistema operacional
- ✅ **Persistência**: Salva e carrega a preferência do usuário usando SharedPreferences
- ✅ **Fácil Integração**: Provider baseado em Riverpod para gerenciamento de estado
- ✅ **Alternância Simples**: Métodos convenientes para trocar entre temas

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  tema:
    path: ../tema
```

Depois execute:

```bash
flutter pub get
```

## 🚀 Uso Básico

### 1. Configure o ProviderScope

Envolva sua aplicação com `ProviderScope`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Use o Provider de Tema no MaterialApp

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tema/tema.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider);
    
    return MaterialApp(
      title: 'FIAP App',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
```

### 3. Controle o Tema

Use o provider para alterar o tema de qualquer lugar do app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tema/tema.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tema Claro'),
            leading: const Icon(Icons.light_mode),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (_) => ref.read(temaProvider.notifier).setLight(),
            ),
            onTap: () => ref.read(temaProvider.notifier).setLight(),
          ),
          ListTile(
            title: const Text('Tema Escuro'),
            leading: const Icon(Icons.dark_mode),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (_) => ref.read(temaProvider.notifier).setDark(),
            ),
            onTap: () => ref.read(temaProvider.notifier).setDark(),
          ),
          ListTile(
            title: const Text('Seguir Sistema'),
            leading: const Icon(Icons.settings_suggest),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: (_) => ref.read(temaProvider.notifier).setSystem(),
            ),
            onTap: () => ref.read(temaProvider.notifier).setSystem(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Alternar Tema'),
            leading: const Icon(Icons.brightness_6),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ref.read(temaProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 API

### TemaProvider

Provider principal para gerenciamento de tema:

```dart
final temaProvider = StateNotifierProvider<TemaNotifier, ThemeMode>((ref) {
  return TemaNotifier();
});
```

### TemaNotifier

Notificador de estado com os seguintes métodos:

- **`setLight()`**: Define o tema como claro
- **`setDark()`**: Define o tema como escuro
- **`setSystem()`**: Define para seguir o tema do sistema
- **`toggle()`**: Alterna entre tema claro e escuro
- **`getEffectiveBrightness()`**: Retorna o brilho efetivo atual

### AppThemes

Classe estática com definições de tema:

- **`AppThemes.light`**: ThemeData para tema claro
- **`AppThemes.dark`**: ThemeData para tema escuro

## 🎨 Personalização de Cores

### Tema Claro
- **Primary**: `#6750A4` (Roxo/Violeta)
- **Secondary**: `#00897B` (Teal)
- **Error**: `#BA1A1A`

### Tema Escuro
- **Primary**: `#D0BCFF` (Roxo claro)
- **Secondary**: `#4DB6AC` (Teal claro)
- **Error**: `#FFB4AB`

Para personalizar as cores, modifique os valores em `lib/src/themes.dart`.

## 🧪 Testes

Execute os testes:

```bash
cd packages_dashboard/tema
flutter test
```

Execute com cobertura:

```bash
flutter test --coverage
```

## 📱 Exemplo Completo

```dart
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
      title: 'Demo Tema',
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tema Atual: ${_getThemeName(themeMode)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(temaProvider.notifier).toggle(),
              icon: const Icon(Icons.brightness_6),
              label: const Text('Alternar Tema'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.read(temaProvider.notifier).setSystem(),
              child: const Text('Seguir Sistema'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(temaProvider.notifier).toggle(),
        child: const Icon(Icons.brightness_6),
      ),
    );
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
```

## 🔧 Dependências

- `flutter`: SDK Flutter
- `flutter_riverpod`: ^3.0.3 - Gerenciamento de estado
- `shared_preferences`: ^2.2.2 - Persistência de preferências

## 📝 Licença

Parte do projeto FIAP Global Solution 2025.2.

## 🤝 Contribuindo

1. Leia o roadmap antes de fazer mudanças
2. Formate o código: `flutter format .`
3. Execute os testes: `flutter test`
4. Execute análise estática: `flutter analyze`

## 📚 Documentação Adicional

- [Roadmap](./roadmap.md) - Roadmap detalhado de implementação
- [Flutter Riverpod](https://riverpod.dev/) - Documentação do Riverpod
- [Material Design 3](https://m3.material.io/) - Guia de design
