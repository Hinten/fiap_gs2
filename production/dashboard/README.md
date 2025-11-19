# Unified Dashboard - FIAP AI-Enhanced Learning Platform

Dashboard Flutter unificado integrando todas as interfaces implementadas do MVP.

## 🚀 Interfaces Integradas

### ✅ Implementadas e Ativas

1. **Tema** - Sistema de temas claro/escuro
2. **Dashboard Auth** - Autenticação Firebase
3. **Research Dashboard** - Dashboards de iniciação científica
4. **Approval Interface** - Interface de aprovação humana

## 📦 Instalação

### Requisitos

- Flutter 3.0+
- Dart 3.0+
- Firebase project configurado (ou modo sem autenticação)

### Setup

```bash
cd production/dashboard

# Instalar dependências
flutter pub get

# Executar testes
flutter test

# Analisar código
flutter analyze
```

## 🎯 Modo Sem Autenticação (Emulador)

O dashboard suporta execução **sem autenticação Firebase**, ideal para desenvolvimento e demonstração:

```bash
# Executar sem autenticação (modo demo)
flutter run --dart-define=SKIP_AUTH=true -d chrome

# Ou para Android/iOS
flutter run --dart-define=SKIP_AUTH=true -d <device-id>
```

No modo sem autenticação:
- ✅ Acesso direto às funcionalidades
- ✅ Usuário demo pré-configurado
- ✅ Sem necessidade de credenciais Firebase
- ⚠️ Não usar em produção

## ⚙️ Configuração Firebase

### Para Produção (com autenticação)

Configure as variáveis de ambiente:

```bash
# Executar com Firebase em produção
flutter run \
  --dart-define=FIREBASE_API_KEY=your_api_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  -d chrome
```

### Para Desenvolvimento (com emulador Firebase)

```bash
# Iniciar emuladores Firebase primeiro
firebase emulators:start

# Executar dashboard apontando para emulador
flutter run \
  --dart-define=USE_EMULATOR=true \
  --dart-define=EMULATOR_HOST=localhost \
  -d chrome
```

## 🏃 Executando

### Modo Rápido (sem auth)

```bash
# Via script
./run_dashboard.sh

# Ou manualmente
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

### Modo Produção (com auth)

```bash
flutter run -d chrome
```

### Listar Dispositivos

```bash
flutter devices
```

### Build para Web

```bash
flutter build web --dart-define=SKIP_AUTH=true
```

## 📱 Plataformas Suportadas

- ✅ Web (Chrome, Firefox, Edge)
- ✅ Android
- ✅ iOS
- ✅ Windows (desktop)
- ✅ macOS (desktop)
- ✅ Linux (desktop)

## 🎨 Funcionalidades

### Sistema de Temas
- Tema claro e escuro
- Detecção automática do tema do sistema
- Persistência da preferência do usuário
- Alternância fácil via UI

### Autenticação
- Login/logout com Firebase
- Modo demo sem autenticação
- RBAC (Role-Based Access Control)
- Gerenciamento de sessão

### Dashboards
- **Home**: Visão geral e navegação
- **Pesquisa**: Gestão de iniciação científica
  - Dashboard do coordenador
  - Dashboard do orientador
  - Dashboard do aluno
- **Revisão de Conteúdo**: Interface do agente de IA
- **Aprovações**: Sistema de aprovação humana

## 📂 Estrutura

```
production/dashboard/
├── lib/
│   ├── main.dart                    # Entry point
│   └── src/
│       ├── config/
│       │   └── firebase_config.dart # Firebase config
│       ├── core/
│       │   ├── auth/
│       │   │   └── auth_provider.dart
│       │   └── routing/
│       │       └── router.dart      # GoRouter config
│       └── screens/
│           ├── home_screen.dart
│           ├── login_screen.dart
│           ├── research_screen.dart
│           ├── content_review_screen.dart
│           └── approval_screen.dart
├── pubspec.yaml                     # Dependencies
├── README.md                        # Esta documentação
└── run_dashboard.sh                # Script de execução
```

## 🧪 Testes

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/screens/home_screen_test.dart

# Com coverage
flutter test --coverage
```

## 🎯 Navegação

O dashboard usa **GoRouter** para navegação:

- `/` - Home (dashboard principal)
- `/login` - Tela de login (quando auth habilitada)
- `/research` - Gestão de pesquisa
- `/content-review` - Revisão de conteúdo
- `/approval` - Interface de aprovação

Navegação automática com guard de autenticação (quando não em modo demo).

## 🔗 Integração com Backend

Configure a URL do backend:

```dart
// Em lib/src/config/api_config.dart (criar se necessário)
const String backendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://localhost:8000',
);
```

Depois execute:

```bash
flutter run --dart-define=BACKEND_URL=http://localhost:8000 -d chrome
```

## 🐛 Troubleshooting

### Erro: "Dependências não instaladas"
```bash
flutter pub get
flutter pub upgrade
```

### Erro: "Firebase not initialized"
```bash
# Execute em modo sem autenticação
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

### Erro: "No devices found"
```bash
# Para web
flutter config --enable-web
flutter devices

# Para desktop (opcional)
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

## 📝 Desenvolvimento

### Linting e Formatação

```bash
# Formatar código
flutter format .

# Analisar código
flutter analyze

# Verificar pubspec
flutter pub get --dry-run
```

### Hot Reload

Durante desenvolvimento, use hot reload:
- `r` - hot reload
- `R` - hot restart
- `q` - quit

## 🚧 Roadmap

### ⏳ Próximas Interfaces a Integrar

- [ ] Frontend Flutter completo (landing page, etc)
- [ ] Gamified Exams (provas gamificadas)
- [ ] Code Review UI (integração com GitHub)
- [ ] Grading Dashboard (visualização de notas)

## 📄 Licença

Este projeto é uma Prova de Conceito (POC) desenvolvida para o desafio Global Solution da FIAP 2025.2.
