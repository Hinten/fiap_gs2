# Unified Dashboard - FIAP AI-Enhanced Learning Platform

Dashboard Flutter unificado integrando todas as interfaces implementadas do MVP.

## 🚀 Interfaces Integradas

### ✅ Implementadas e Ativas

1. **Tema** - Sistema de temas claro/escuro
2. **Dashboard Auth** - Autenticação Firebase
3. **Research Dashboard** - Dashboards de iniciação científica
4. **Approval Interface** - Interface de aprovação humana
5. **Content Review** - Interface completa de revisão de conteúdo com IA
6. **Student Wellbeing** - Monitoramento de bem-estar estudantil com alertas
7. **Adaptive Assessment** - Avaliações adaptativas com gamificação e acessibilidade

## 🌐 Plataformas Suportadas

- ✅ **Web** - Chrome, Firefox, Safari, Edge (com loader customizado)
- ✅ **Android** - Versão nativa
- ✅ **iOS** - Versão nativa
- ✅ **Desktop** - Windows, macOS, Linux (experimental)

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

## 🎯 Executando o Dashboard

### Modo Rápido (Script Automático)

```bash
# Web com modo demo (sem autenticação)
./run_dashboard.sh

# Web com autenticação Firebase
./run_dashboard.sh --with-auth

# Build para produção (web)
./run_dashboard.sh --release --web

# Executar em dispositivo móvel
./run_dashboard.sh --mobile

# Ver todas as opções
./run_dashboard.sh --help
```

### Modo Manual

#### Web (Recomendado para desenvolvimento)
```bash
# Desenvolvimento
flutter run -d chrome --dart-define=SKIP_AUTH=true

# Build para produção
flutter build web --release
```

#### Mobile
```bash
# Android
flutter run -d <device-id> --dart-define=SKIP_AUTH=true

# iOS
flutter run -d <device-id> --dart-define=SKIP_AUTH=true
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
flutter run --dart-define=USE_EMULATOR=true --dart-define=EMULATOR_HOST=localhost --dart-define=SKIP_AUTH=true -d chrome
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

O build web inclui:
- ✨ **Loader animado customizado** com tema da aplicação
- 🎨 Gradiente roxo (#667eea to #764ba2) matching o tema
- ⚡ Animações suaves de entrada e saída
- 📱 Design responsivo para todos os tamanhos de tela
- 🔄 Progress bar animado e spinner dual-ring
- 🎯 Auto-dismiss quando Flutter estiver pronto

Para mais detalhes sobre o suporte web, veja [WEB_SUPPORT.md](WEB_SUPPORT.md).

## 📱 Plataformas Suportadas

- ✅ Web (Chrome, Firefox, Edge, Safari) - **Com loader customizado**
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
- **Bem-Estar Estudantil**: Monitoramento e alertas de saúde mental
  - Alertas de tendências negativas
  - Check-in de bem-estar (demo)
  - Conformidade com LGPD/GDPR
- **Avaliações Adaptativas**: Sistema de provas inteligentes
  - Dificuldade adaptativa
  - Gamificação e pontos XP
  - Acessibilidade (texto-para-fala, alto contraste)

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
│           ├── approval_screen.dart
│           ├── wellbeing_screen.dart        # NEW: Bem-estar estudantil
│           └── adaptive_assessment_screen.dart  # NEW: Avaliações adaptativas
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
- `/wellbeing` - Bem-estar estudantil (alertas e check-ins)
- `/adaptive-assessment` - Avaliações adaptativas com gamificação

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
- [x] Student Wellbeing (bem-estar estudantil) ✅
- [x] Adaptive Assessment (avaliações adaptativas) ✅
- [ ] Code Review UI (integração com GitHub)
- [ ] Grading Dashboard (visualização de notas)

### 📦 Pacotes Integrados (de PR#17)

As seguintes funcionalidades foram integradas do PR#17 por luxyvsc:

#### Student Wellbeing (packages/student_wellbeing)
- Monitoramento de bem-estar estudantil com check-ins regulares
- Detecção de alertas e tendências negativas
- Dashboard de visualização para coordenadores/orientadores
- Conformidade com LGPD/GDPR (anonimização e consentimento)
- Armazenamento seguro local com flutter_secure_storage

#### Adaptive Assessment (packages_dashboard/adaptive_assessment)
- Sistema de avaliações adaptativas com dificuldade dinâmica
- Gamificação com pontos XP e níveis
- Recursos de acessibilidade (texto-para-fala, alto contraste, tamanhos de fonte)
- Suporte a múltiplos tipos de questões
- Visualização de progresso e estatísticas

## 📄 Licença

Este projeto é uma Prova de Conceito (POC) desenvolvida para o desafio Global Solution da FIAP 2025.2.
