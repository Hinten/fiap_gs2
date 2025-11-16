# Adaptive Assessment

Um pacote Flutter para criar avaliações adaptativas e acessíveis com recursos de gamificação e suporte especial para dislexia.

## 🎯 Objetivo

Este módulo fornece uma solução completa para avaliações educacionais que se adaptam ao desempenho do usuário, oferecendo recursos avançados de acessibilidade e elementos de gamificação para aumentar o engajamento.

## ✨ Características

- 🎯 **Dificuldade Adaptativa**: Ajuste automático baseado no desempenho do usuário
- ♿ **Acessibilidade Completa**:
  - Fonte amigável para dislexia (OpenDyslexic)
  - Alto contraste
  - Ajuste de tamanho de fonte (0.8x - 2.0x)
  - Espaçamento de letras personalizável
- 🗣️ **Leitura Assistida**: Text-to-Speech (TTS) em português brasileiro
- 🎮 **Gamificação**:
  - Sistema de pontuação
  - Sequências (streaks)
  - Conquistas e badges
  - Barra de progresso visual
  - Feedback animado
- 📊 **Métricas em Tempo Real**: Acompanhamento de desempenho

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  adaptive_assessment:
    path: ../adaptive_assessment  # Para monorepo
  
  # Ou quando publicado:
  # adaptive_assessment: ^0.1.0
```

Execute:

```bash
flutter pub get
```

## 🚀 Uso Básico

### 1. Inicializar o Serviço

```dart
import 'package:adaptive_assessment/adaptive_assessment.dart';

final service = AdaptiveAssessmentService();
```

### 2. Usar o Widget

```dart
import 'package:flutter/material.dart';
import 'package:adaptive_assessment/adaptive_assessment.dart';

class AssessmentScreen extends StatelessWidget {
  final service = AdaptiveAssessmentService();

  @override
  Widget build(BuildContext context) {
    return AdaptiveAssessmentWidget(
      service: service,
      maxQuestions: 10,
      onComplete: () {
        final state = service.currentState;
        print('Pontuação: ${state.totalScore}');
        print('Acertos: ${state.correctAnswers}/${state.totalAnswered}');
        print('Precisão: ${state.accuracy}%');
      },
    );
  }
}
```

### 3. Escutar Mudanças de Estado

```dart
service.stateStream.listen((state) {
  print('Questões respondidas: ${state.totalAnswered}');
  print('Nível de dificuldade: ${state.currentDifficulty}');
  print('Sequência atual: ${state.currentStreak}');
  print('Conquistas: ${state.badges}');
});
```

## ♿ Opções de Acessibilidade

### Temas Pré-configurados

```dart
// Tema Padrão
service.changeTheme(AccessibilityTheme.standard);

// Alto Contraste
service.changeTheme(AccessibilityTheme.highContrast);

// Amigável para Dislexia
service.changeTheme(AccessibilityTheme.dyslexiaFriendly);
```

### Configurações Personalizadas

```dart
// Ativar/desativar Text-to-Speech
service.toggleTTS();

// Ajustar tamanho da fonte
service.updateFontSize(1.5); // 1.5x do tamanho padrão

// Ajustar espaçamento de letras
service.updateLetterSpacing(2.0);

// Ajustar velocidade da fala (TTS)
service.updateSpeechRate(0.9); // 0.5 a 1.5
```

### Tema Dislexia

O tema amigável para dislexia inclui:
- Fonte OpenDyslexic (otimizada para leitores com dislexia)
- Espaçamento aumentado entre letras (1.5)
- Tamanho de fonte maior (1.3x)
- Text-to-Speech ativado por padrão
- Velocidade de fala reduzida (0.9)

## 🎮 Elementos de Gamificação

### Sistema de Pontuação

```dart
// Pontos baseados na dificuldade da questão
// Questão nível 1: 10 pontos
// Questão nível 2: 20 pontos
// Questão nível 3: 30 pontos
// Questão nível 4: 40 pontos
// Questão nível 5: 50 pontos
```

### Conquistas (Badges)

- **streak_3**: 3 respostas corretas seguidas
- **streak_5**: 5 respostas corretas seguidas
- **answered_10**: 10 questões respondidas

### Mecânica de Dificuldade

- Resposta correta + sequência de 2: aumenta dificuldade
- Resposta incorreta: diminui dificuldade
- Dificuldade varia de 1 (fácil) a 5 (difícil)

## 📝 Adicionando Questões Personalizadas

```dart
service.addQuestions([
  Question(
    id: 'custom1',
    text: 'Qual é a capital da França?',
    options: ['Londres', 'Paris', 'Berlim', 'Roma'],
    correctAnswerIndex: 1,
    difficulty: 2,
    category: 'Geografia',
  ),
  Question(
    id: 'custom2',
    text: 'Quanto é 10 × 5?',
    options: ['40', '45', '50', '55'],
    correctAnswerIndex: 2,
    difficulty: 1,
    category: 'Matemática',
  ),
]);
```

## 🔧 API Completa

### AdaptiveAssessmentService

#### Métodos Principais

```dart
// Obter próxima questão
Question? getNextQuestion()

// Submeter resposta
bool submitAnswer({
  required Question question,
  required int selectedAnswerIndex,
})

// Resetar avaliação
void resetAssessment()

// Adicionar questões
void addQuestions(List<Question> questions)

// Limpar questões
void clearQuestions()

// Liberar recursos
void dispose()
```

#### Métodos de Acessibilidade

```dart
// Mudar tema
void changeTheme(AccessibilityTheme theme)

// Atualizar configuração de tema
void updateThemeConfig(ThemeConfig config)

// Alternar TTS
void toggleTTS()

// Atualizar tamanho de fonte
void updateFontSize(double multiplier)

// Atualizar espaçamento
void updateLetterSpacing(double spacing)

// Atualizar velocidade de fala
void updateSpeechRate(double rate)
```

#### Streams

```dart
// Stream de estado
Stream<AssessmentState> get stateStream

// Stream de tema
Stream<ThemeConfig> get themeStream
```

#### Propriedades

```dart
// Estado atual
AssessmentState get currentState

// Configuração de tema atual
ThemeConfig get themeConfig
```

### Modelos de Dados

#### Question

```dart
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final int difficulty; // 1-5
  final String? category;
}
```

#### AssessmentState

```dart
class AssessmentState {
  final int currentDifficulty; // 1-5
  final int totalAnswered;
  final int correctAnswers;
  final int totalScore;
  final List<String> badges;
  final int currentStreak;
  final int bestStreak;
  
  // Propriedade calculada
  double get accuracy; // 0-100
}
```

#### ThemeConfig

```dart
class ThemeConfig {
  final AccessibilityTheme theme;
  final double fontSizeMultiplier; // 0.8-2.0
  final double letterSpacing; // 0.0-3.0
  final String? fontFamily;
  final bool ttsEnabled;
  final double speechRate; // 0.5-1.5
}
```

## 🔌 Integração no App Principal

### 1. Adicionar Dependência

No `pubspec.yaml` do seu app principal:

```yaml
dependencies:
  adaptive_assessment:
    path: ../adaptive_assessment
```

### 2. Importar e Usar

```dart
import 'package:adaptive_assessment/adaptive_assessment.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AdaptiveAssessmentService service;

  @override
  void initState() {
    super.initState();
    service = AdaptiveAssessmentService();
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  void _startAssessment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdaptiveAssessmentWidget(
          service: service,
          maxQuestions: 10,
          onComplete: _showResults,
        ),
      ),
    );
  }

  void _showResults() {
    final state = service.currentState;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pontuação: ${state.totalScore}'),
            Text('Acertos: ${state.correctAnswers}'),
            Text('Precisão: ${state.accuracy.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meu App')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startAssessment,
          child: Text('Iniciar Avaliação'),
        ),
      ),
    );
  }
}
```

## 🧪 Testes

Execute os testes:

```bash
cd packages_dashboard/adaptive_assessment
flutter test
```

Execute com cobertura:

```bash
flutter test --coverage
```

## 📱 App de Exemplo

Um app de exemplo completo está disponível em `example/`:

```bash
cd example
flutter pub get
flutter run -d chrome
```

O app de exemplo demonstra:
- Todos os recursos do pacote
- Integração completa
- Configurações de acessibilidade
- Tela de resultados

## 🎨 Personalização

### Cores e Temas

O pacote usa Material Design 3 e respeita o tema do app:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    useMaterial3: true,
  ),
  home: AdaptiveAssessmentWidget(
    service: service,
  ),
);
```

### Configuração Personalizada

```dart
final customConfig = ThemeConfig(
  theme: AccessibilityTheme.dyslexiaFriendly,
  fontSizeMultiplier: 1.5,
  letterSpacing: 2.0,
  fontFamily: 'OpenDyslexic',
  ttsEnabled: true,
  speechRate: 0.8,
);

service.updateThemeConfig(customConfig);
```

## 📊 Métricas Disponíveis

O serviço rastreia várias métricas:

- Total de questões respondidas
- Número de acertos
- Percentual de precisão
- Nível de dificuldade atual
- Sequência atual de acertos
- Melhor sequência alcançada
- Pontuação total
- Conquistas desbloqueadas

## 🔐 Privacidade

Este pacote:
- Não coleta dados do usuário
- Não faz chamadas de rede
- Funciona completamente offline
- Todos os dados ficam em memória

## 🤝 Contribuindo

Este pacote faz parte do projeto FIAP Global Solution 2025.2. Para contribuir:

1. Siga o guia de estilo Dart
2. Mantenha cobertura de testes acima de 80%
3. Document todas as APIs públicas
4. Use commits significativos

## 📄 Licença

Parte do projeto FIAP Global Solution 2025.2.

## 🆘 Suporte

Para problemas ou dúvidas:
- Abra uma issue no repositório
- Consulte a documentação do código
- Veja o app de exemplo

## 🗺️ Roadmap

Próximas features planejadas:
- [ ] Persistência de estado (SharedPreferences)
- [ ] Sincronização com backend
- [ ] Mais tipos de questões (múltipla escolha, verdadeiro/falso, dissertativa)
- [ ] Estatísticas por categoria
- [ ] Modo offline completo
- [ ] Exportar relatórios
- [ ] Mais temas de acessibilidade
- [ ] Suporte a mais idiomas

## 📚 Referências

- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [OpenDyslexic Font](https://opendyslexic.org/)
- [Material Design 3](https://m3.material.io/)
- [Flutter TTS](https://pub.dev/packages/flutter_tts)
