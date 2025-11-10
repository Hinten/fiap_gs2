# Frontend Flutter - Roadmap

## 📱 Visão Geral

Interface do usuário multi-plataforma (Web, iOS, Android) construída em Flutter, seguindo arquitetura de microfrontends modular.

### Responsabilidades
- Interface de usuário responsiva e acessível
- Comunicação com backend via APIs REST
- State management para dados do aplicativo
- Experiência de usuário fluida e intuitiva
- Real-time updates via WebSocket

---

## 🎯 Objetivos

1. Criar aplicação Flutter modular e escalável
2. Implementar todas as telas do SymbioWork
3. Integrar com todos os microservices backend
4. Garantir experiência responsiva (mobile, tablet, desktop, web)
5. Implementar real-time para atualizações de agentes

---

## 🏗️ Arquitetura

### Stack Tecnológico
- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod (recomendado) ou Bloc
- **Networking**: Dio para HTTP, web_socket_channel para WebSocket
- **UI Components**: Material Design 3
- **Charts**: fl_chart
- **Local Storage**: shared_preferences, hive
- **Authentication**: flutter_secure_storage para tokens

### Estrutura de Pastas

```
frontend_flutter/
├── lib/
│   ├── main.dart                   # Entry point
│   ├── app.dart                    # MaterialApp config
│   │
│   ├── core/                       # Core utilities
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   └── environment.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   └── websocket_client.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── colors.dart
│   │
│   ├── features/                   # Features (microfrontends)
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       └── usecases/
│   │   │
│   │   ├── dashboard/              # Dashboard principal
│   │   ├── wellbeing/              # Monitoramento bem-estar
│   │   ├── collaboration/          # Ambientes colaborativos
│   │   ├── recruitment/            # Portal RH
│   │   ├── green_work/             # Sustentabilidade
│   │   ├── agents/                 # Visualização agentes IA
│   │   └── profile/                # Perfil do usuário
│   │
│   └── shared/                     # Widgets compartilhados
│       ├── widgets/
│       ├── utils/
│       └── constants/
│
├── test/                           # Testes
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/                         # Assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml                    # Dependencies
├── analysis_options.yaml           # Linter config
└── README.md
```

---

## 📋 Tarefas de Implementação

### Sprint 1: Setup e Autenticação

#### 1.1 Setup do Projeto
- [ ] Criar projeto Flutter (`flutter create frontend_flutter`)
- [ ] Configurar `pubspec.yaml` com dependências:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    dio: ^5.4.0
    flutter_riverpod: ^2.4.0
    go_router: ^12.1.0
    flutter_secure_storage: ^9.0.0
    web_socket_channel: ^2.4.0
    fl_chart: ^0.65.0
    google_fonts: ^6.1.0
    intl: ^0.19.0
  
  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^3.0.0
    mockito: ^5.4.0
    build_runner: ^2.4.0
  ```
- [ ] Configurar `analysis_options.yaml` com regras de lint
- [ ] Setup estrutura de pastas (core, features, shared)
- [ ] Configurar CI/CD para Flutter no GitHub Actions

**Critérios de Aceitação**:
- Projeto Flutter compila sem erros
- Estrutura de pastas criada
- Dependências instaladas

#### 1.2 Core Infrastructure
- [ ] Implementar `ApiClient` com Dio
  - Base URL configurável por ambiente
  - Interceptors para auth token
  - Error handling
  - Retry logic
- [ ] Implementar `WebSocketClient` para real-time
- [ ] Configurar `AppRouter` com go_router
- [ ] Criar `AppTheme` com Material Design 3
- [ ] Setup de environments (dev, staging, prod)

**Critérios de Aceitação**:
- ApiClient faz requests HTTP
- WebSocket conecta e recebe mensagens
- Navegação funciona entre telas
- Tema aplicado globalmente

#### 1.3 Feature: Autenticação
- [ ] Tela de Login
  - Email/senha
  - OAuth2 buttons (Google, Microsoft)
  - "Esqueci a senha"
  - Validação de campos
- [ ] Tela de Registro
  - Formulário de cadastro
  - Validação de email, senha forte
  - Termos de uso
- [ ] Integração com Auth Service
  - Login endpoint
  - Token storage (flutter_secure_storage)
  - Auto-login se token válido
- [ ] Logout e refresh token

**APIs Necessárias**:
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

**Critérios de Aceitação**:
- Usuário consegue fazer login
- Token JWT armazenado com segurança
- Navegação protegida (redirect se não autenticado)

---

### Sprint 2: Dashboard e Bem-Estar

#### 2.1 Dashboard Principal
- [ ] Layout responsivo (mobile, tablet, web)
- [ ] Cards de resumo:
  - Bem-estar atual (score de stress)
  - Tarefas do dia
  - Próximas reuniões
  - Notificações de agentes IA
- [ ] Navigation drawer / bottom navigation
- [ ] Perfil do usuário (canto superior)

**Critérios de Aceitação**:
- Dashboard carrega dados do backend
- Cards exibem informações relevantes
- Navegação para outras seções funciona

#### 2.2 Feature: Wellbeing (Bem-Estar)
- [ ] Tela de Bem-Estar Pessoal
  - Gráfico de stress ao longo do tempo (fl_chart)
  - Score de risco (low, medium, high)
  - Histórico de eventos
  - Recomendações dos agentes
- [ ] Input de dados manual
  - "Como você está se sentindo?" (1-10)
  - Tags: stress, energia, foco, humor
  - Contexto opcional (texto livre)
- [ ] Alertas e notificações
  - Push notifications para alertas de risco
  - Sugestões de pausas
- [ ] Integração com Wellbeing Service

**APIs Necessárias**:
- `GET /api/v1/users/{id}/wellbeing` - Resumo
- `POST /api/v1/wellbeing/events` - Criar evento
- `GET /api/v1/wellbeing/events?user_id={id}` - Histórico
- `GET /api/v1/wellbeing/recommendations?user_id={id}` - Recomendações

**Critérios de Aceitação**:
- Gráficos renderizam corretamente
- Usuário envia eventos de bem-estar
- Recomendações são exibidas

#### 2.3 Visualizações e Charts
- [ ] Line chart para séries temporais (stress over time)
- [ ] Bar chart para comparações (hoje vs ontem)
- [ ] Gauge chart para score de risco
- [ ] Animações suaves

---

### Sprint 3: Agentes IA e Analytics

#### 3.1 Feature: Agentes IA
- [ ] Tela de Agentes IA
  - Lista de agentes ativos:
    - Productivity Agent
    - Wellbeing Agent
    - Learning Agent
  - Status de cada agente (ativo, idle, trabalhando)
  - Últimas ações realizadas
- [ ] Chat interface com agentes
  - Input de texto
  - Histórico de conversas
  - Respostas em streaming (WebSocket)
- [ ] Recomendações dos agentes
  - Card de recomendação
  - Aceitar / descartar / postergar
  - Feedback sobre utilidade

**APIs Necessárias**:
- `GET /api/v1/agents` - Lista de agentes
- `GET /api/v1/agents/{id}/status` - Status do agente
- `GET /api/v1/agents/{id}/actions` - Histórico de ações
- `POST /api/v1/agents/{id}/chat` - Enviar mensagem
- `WebSocket /ws/agents/{id}` - Real-time updates

**Critérios de Aceitação**:
- Lista de agentes exibida
- Chat funciona com respostas em tempo real
- Recomendações podem ser aceitas/descartadas

#### 3.2 Feature: Analytics Dashboard
- [ ] Tela de Analytics
  - Métricas agregadas (últimos 7/30/90 dias)
  - Comparações (semana atual vs anterior)
  - Tendências (melhorando, piorando, estável)
- [ ] Filtros
  - Período (dia, semana, mês, custom)
  - Tipo de métrica
- [ ] Exportar dados (CSV, PDF)

**APIs Necessárias**:
- `GET /api/v1/analytics/summary?period={period}`
- `GET /api/v1/analytics/trends?metric={metric}`
- `GET /api/v1/analytics/export?format={csv|pdf}`

**Critérios de Aceitação**:
- Analytics carregam e exibem dados
- Filtros funcionam
- Exportação gera arquivo

---

### Sprint 4: Colaboração e Recrutamento

#### 4.1 Feature: Collaboration (Ambientes Colaborativos)
- [ ] Tela de Ambientes
  - Lista de ambientes disponíveis (públicos, privados)
  - Criar novo ambiente
  - Entrar em ambiente
- [ ] Dentro do Ambiente
  - Lista de participantes (avatares)
  - Status de cada um (disponível, ocupado, foco)
  - Chat de texto
  - Controles de ambiente (iluminação virtual, ruído)
  - Botão de "Do Not Disturb"
- [ ] Notificações de presença (quem entrou/saiu)

**APIs Necessárias**:
- `GET /api/v1/collaboration/environments` - Lista
- `POST /api/v1/collaboration/environments` - Criar
- `POST /api/v1/collaboration/environments/{id}/join` - Entrar
- `GET /api/v1/collaboration/environments/{id}/participants` - Participantes
- `WebSocket /ws/collaboration/{env_id}` - Real-time updates

**Critérios de Aceitação**:
- Usuário entra em ambiente colaborativo
- Presença de outros usuários é visível
- Chat funciona em tempo real

#### 4.2 Feature: Recruitment (Recrutamento Inclusivo)
- [ ] Tela de Vagas (para candidatos)
  - Lista de vagas abertas
  - Filtros (área, senioridade, remoto/presencial)
  - Detalhes da vaga
  - Botão "Aplicar"
- [ ] Formulário de Candidatura
  - Upload de currículo
  - Responder questões
  - Consentimento para uso de IA
- [ ] Painel do Recrutador (para RH)
  - Lista de candidatos
  - Scores e matching (com explicabilidade)
  - Análise de diversidade
  - Detecção de viés (alertas)
- [ ] Explicabilidade de IA
  - "Por que este candidato foi rankeado assim?"
  - SHAP values visualizados

**APIs Necessárias**:
- `GET /api/v1/recruitment/jobs` - Vagas
- `GET /api/v1/recruitment/jobs/{id}` - Detalhes
- `POST /api/v1/recruitment/applications` - Candidatar
- `GET /api/v1/recruitment/candidates` - Lista (RH)
- `GET /api/v1/recruitment/candidates/{id}/explainability` - Explicação

**Critérios de Aceitação**:
- Candidatos veem vagas e se candidatam
- Recrutadores veem candidatos com scores
- Explicabilidade é clara e compreensível

---

### Sprint 5: Sustentabilidade e Gamificação

#### 5.1 Feature: Green Work (Sustentabilidade)
- [ ] Tela de Sustentabilidade
  - Carbon footprint pessoal (kg CO2)
  - Comparação (você vs média)
  - Breakdown (transporte, energia, etc)
  - Evolução ao longo do tempo
- [ ] Recomendações sustentáveis
  - "Trabalhe de casa 2x/semana para reduzir 10kg CO2/mês"
  - "Desligue câmera em reuniões = -2kg CO2/mês"
- [ ] Conquistas verdes (badges)
  - "1 mês sem carro"
  - "Reduziu 50kg CO2"
- [ ] Leaderboard de sustentabilidade (opcional)

**APIs Necessárias**:
- `GET /api/v1/green-work/footprint?user_id={id}`
- `GET /api/v1/green-work/recommendations?user_id={id}`
- `GET /api/v1/green-work/achievements?user_id={id}`
- `GET /api/v1/green-work/leaderboard`

**Critérios de Aceitação**:
- Carbon footprint calculado e exibido
- Recomendações são relevantes
- Badges são desbloqueados ao atingir metas

#### 5.2 Gamificação
- [ ] Sistema de Pontos e XP
  - Ganhar pontos por ações (completar tarefas, pausas saudáveis, etc)
  - Níveis (Iniciante, Intermediário, Avançado, Expert)
  - Barra de progresso para próximo nível
- [ ] Badges e Conquistas
  - "Madrugador" - login antes das 7h por 5 dias
  - "Zen Master" - 30 dias com stress baixo
  - "Team Player" - participou de 10 ambientes colaborativos
- [ ] Desafios e Missões
  - Diários: "Complete 5 tarefas hoje"
  - Semanais: "Faça 3 pausas para meditação"
  - Mensais: "Reduza stress em 20%"
- [ ] Leaderboard (opcional)
  - Ranking entre colegas de equipe
  - Filtrável por período

**APIs Necessárias**:
- `GET /api/v1/gamification/user/{id}/points`
- `GET /api/v1/gamification/user/{id}/badges`
- `GET /api/v1/gamification/challenges?user_id={id}`
- `POST /api/v1/gamification/challenges/{id}/complete`

**Critérios de Aceitação**:
- Pontos aumentam ao completar ações
- Badges são desbloqueados e exibidos
- Desafios são listados e podem ser completados

---

### Sprint 6: Polimento e Testes

#### 6.1 Acessibilidade
- [ ] Navegação por teclado (web)
- [ ] Screen reader support (semantics)
- [ ] Contraste adequado (WCAG AA)
- [ ] Tamanhos de fonte ajustáveis
- [ ] Suporte a temas (light, dark, high contrast)

#### 6.2 Performance
- [ ] Lazy loading de listas
- [ ] Caching de imagens
- [ ] Debounce em inputs de busca
- [ ] Otimização de rebuilds (const constructors)
- [ ] Minimizar tamanho do bundle

#### 6.3 Testes
- [ ] **Unit tests** para repositories, providers
  - Cobertura mínima: 70%
- [ ] **Widget tests** para componentes UI
  - Testar interações de usuário
  - Testar estados (loading, error, success)
- [ ] **Integration tests** (opcional)
  - Fluxo completo de login
  - Fluxo de candidatura a vaga
- [ ] **Golden tests** para consistência visual (opcional)

Exemplo de teste:
```dart
void main() {
  testWidgets('Login screen has email and password fields', (tester) async {
    await tester.pumpWidget(MyApp());
    
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

#### 6.4 Documentação
- [ ] README com:
  - Como rodar o projeto
  - Como rodar testes
  - Estrutura de pastas explicada
- [ ] Comentários em código complexo
- [ ] Storybook (opcional) para componentes

---

## 🔌 APIs Necessárias (Resumo)

### Auth Service
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/refresh`

### Wellbeing Service
- `GET /api/v1/users/{id}/wellbeing`
- `POST /api/v1/wellbeing/events`
- `GET /api/v1/wellbeing/recommendations`

### Agents Orchestrator
- `GET /api/v1/agents`
- `GET /api/v1/agents/{id}/actions`
- `POST /api/v1/agents/{id}/chat`
- `WebSocket /ws/agents`

### Collaboration Service
- `GET /api/v1/collaboration/environments`
- `POST /api/v1/collaboration/environments/{id}/join`
- `WebSocket /ws/collaboration/{id}`

### Recruitment Service
- `GET /api/v1/recruitment/jobs`
- `POST /api/v1/recruitment/applications`
- `GET /api/v1/recruitment/candidates/{id}/explainability`

### Green Work Service
- `GET /api/v1/green-work/footprint`
- `GET /api/v1/green-work/recommendations`

### Analytics Service
- `GET /api/v1/analytics/summary`
- `GET /api/v1/analytics/trends`

### Dashboard Service
- `GET /api/v1/dashboard/overview`

---

## 📱 Mockups e Design

### Telas Principais
1. **Login** - Email/senha + OAuth2
2. **Dashboard** - Cards de resumo, navegação
3. **Wellbeing** - Gráficos, input manual, recomendações
4. **Agentes IA** - Lista, chat, recomendações
5. **Collaboration** - Ambientes, participantes, chat
6. **Recruitment** - Vagas, candidatura, painel RH
7. **Green Work** - Carbon footprint, recomendações, badges
8. **Profile** - Dados do usuário, configurações

### Design System
- **Cores**: Material Design palette (primária, secundária, erro, etc)
- **Tipografia**: Google Fonts (ex: Roboto, Inter)
- **Spacing**: Sistema de 8pt grid
- **Componentes**: Botões, cards, inputs, dialogs

---

## ✅ Critérios de Aceitação Final

- [ ] Todas as telas implementadas
- [ ] Integração com todos os serviços backend
- [ ] Autenticação funcionando (login, logout, refresh)
- [ ] Real-time updates via WebSocket
- [ ] Responsivo (mobile, tablet, web)
- [ ] Acessível (WCAG AA)
- [ ] Testes com cobertura 70%+
- [ ] Performance otimizada (sem jank)
- [ ] Documentação completa

---

## 🚀 Como Rodar

```bash
# Clonar repositório
git clone https://github.com/Hinten/fiap_gs2.git
cd fiap_gs2/src/apps/frontend_flutter

# Instalar dependências
flutter pub get

# Rodar em desenvolvimento
flutter run

# Rodar testes
flutter test

# Gerar coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Build para produção (web)
flutter build web --release
```

---

## 📚 Referências

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [Dio](https://pub.dev/packages/dio)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [Material Design 3](https://m3.material.io/)
