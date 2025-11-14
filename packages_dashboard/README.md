# Flutter Packages

Este diretório contém todos os pacotes Flutter do projeto FIAP AI-Enhanced Learning Platform. Cada pacote é independente e pode ser usado em outras aplicações Flutter.

## 📦 Pacotes Disponíveis

### ✅ Implementados e Funcionais

- ✅ **[dashboard_auth](./dashboard_auth)** - Autenticação Flutter com Firebase
  - Firebase Authentication, Multiple auth methods, Riverpod integration
  - 4 módulos Dart com exemplo funcional
  - [README](./dashboard_auth/README.md) | [CHANGELOG](./dashboard_auth/CHANGELOG.md)

- ✅ **[approval_interface](./approval_interface)** - Interface unificada para aprovação e edição de ações de IA
  - Dashboard genérico e reutilizável, Filtros avançados, Bulk operations
  - Material Design 3 com tema claro/escuro
  - 7 módulos Dart, 38 testes (18 unit + 20 widget)
  - [README](./approval_interface/README.md) | [CHANGELOG](./approval_interface/CHANGELOG.md)

### 📋 Planejados (Roadmap Disponível)

- 📋 **[frontend_flutter](./frontend_flutter)** - Frontend multi-plataforma principal (Web, iOS, Android)
- 📋 **[gamified_exams](./gamified_exams)** - Sistema de provas gamificadas e inclusivas

## 🚀 Instalação

### Instalar Dependências de um Pacote

```bash
cd packages_dashboard/frontend_flutter
flutter pub get
```

### Usar Pacote como Dependência

Para usar um pacote em outro, adicione ao `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Dependência local
  approval_interface:
    path: ../approval_interface
  
  gamified_exams:
    path: ../gamified_exams
```

Depois rode:

```bash
flutter pub get
```

## 🏗️ Estrutura de um Pacote

Cada pacote segue a seguinte estrutura:

```
package_name/
├── lib/
│   ├── src/                       # Implementação privada
│   │   ├── screens/               # Telas da aplicação
│   │   ├── widgets/               # Widgets reutilizáveis
│   │   ├── services/              # Serviços (API, local storage)
│   │   ├── models/                # Modelos de dados
│   │   └── providers/             # State management
│   └── package_name.dart          # Exports públicos
├── test/                          # Testes
│   ├── widget_test.dart
│   └── unit_test.dart
├── pubspec.yaml                   # Metadados e dependências
├── analysis_options.yaml          # Configuração de análise
├── README.md                      # Documentação do pacote
└── roadmap.md                     # Roadmap de implementação
```

## 🧪 Testes

Para rodar testes de um pacote:

```bash
cd packages_dashboard/frontend_flutter

# Rodar todos os testes
flutter test

# Rodar com cobertura
flutter test --coverage

# Testes específicos
flutter test test/widget_test.dart
```

## 🎨 Formatação e Análise

```bash
cd packages_dashboard/frontend_flutter

# Formatar código
flutter format .

# Análise estática
flutter analyze

# Verificar dependências
flutter pub outdated
```

## 🚀 Executar Aplicação

```bash
cd packages_dashboard/frontend_flutter

# Listar dispositivos disponíveis
flutter devices

# Executar no Chrome (web)
flutter run -d chrome

# Executar em dispositivo conectado
flutter run

# Executar com hot reload
flutter run --hot
```

## 📱 Plataformas Suportadas

Cada pacote pode suportar diferentes plataformas:

- **Web** (Chrome, Edge, Firefox, Safari)
- **Mobile** (iOS, Android)
- **Desktop** (Windows, macOS, Linux)

Verifique o `pubspec.yaml` de cada pacote para ver as plataformas suportadas.

## 🔗 Dependências Entre Pacotes

### Path Dependencies (Desenvolvimento Local)

```yaml
dependencies:
  approval_interface:
    path: ../approval_interface
```

### Git Dependencies (Produção)

```yaml
dependencies:
  approval_interface:
    git:
      url: https://github.com/Hinten/fiap_gs2.git
      path: packages_dashboard/approval_interface
```

## 🎯 State Management

Os pacotes utilizam **Riverpod** para state management:

```dart
// Provider example
final userProvider = StateProvider<User?>((ref) => null);

// Consumer example
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Text(user?.name ?? 'Guest');
  }
}
```

## 🌐 Networking

Os pacotes utilizam **Dio** para requisições HTTP:

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
));

final response = await dio.get('/users');
```

## 🎨 UI/UX

- **Material Design 3** para componentes visuais
- **Tema claro/escuro** suportado
- **Responsive design** para múltiplos tamanhos de tela
- **Acessibilidade** (WCAG 2.1 Level AA)

## 📚 Documentação

Cada pacote possui sua própria documentação:
- `README.md` - Visão geral e instruções de uso
- `roadmap.md` - Roadmap detalhado de implementação
- Documentação inline no código (DartDoc)

## 🛠️ Desenvolvimento

1. Leia o `roadmap.md` do pacote antes de começar
2. Instale as dependências: `flutter pub get`
3. Rode os testes frequentemente: `flutter test`
4. Formate o código antes de commit: `flutter format .`
5. Verifique a qualidade: `flutter analyze`

## 📝 Convenções

- **Imports**: Use imports relativos para arquivos no mesmo pacote
- **Nomenclatura**: camelCase para variáveis, PascalCase para classes
- **Widgets**: Prefira widgets stateless quando possível
- **State**: Use Riverpod para gerenciamento de estado
- **Testes**: Widget tests e unit tests para cobertura
- **Formatação**: Dart formatter padrão (dartfmt)

## 🌍 Internacionalização

Para adicionar suporte a múltiplos idiomas:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
```

```dart
return MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('pt', 'BR'),
    const Locale('en', 'US'),
  ],
);
```

## 🔐 Segurança

- Use **flutter_secure_storage** para dados sensíveis
- Valide inputs do usuário
- Use HTTPS para todas as comunicações
- Não armazene secrets no código

## 🎮 Features Especiais

### Gamified Exams
- Suporte para dislexia (fonte OpenDyslexic)
- Sistema de pontos e conquistas
- Feedback imediato

### Approval Interface
- Chat com agentes de IA
- Edição inline de conteúdo
- Histórico de aprovações

### Frontend Flutter
- Tema claro/escuro
- Real-time updates via WebSocket
- Dashboard responsivo

## 📄 Licença

Parte do projeto FIAP Global Solution 2025.2.
