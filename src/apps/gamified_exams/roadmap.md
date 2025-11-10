# Gamified Exams - Roadmap

## 🎮 Visão Geral

Sistema de provas gamificadas que promovem engajamento, reduzem ansiedade e são inclusivas para alunos com dislexia e outras necessidades especiais.

### Responsabilidades
- Criar provas interativas e gamificadas
- Adaptação para dislexia (fonte, espaçamento, tempo)
- Sistema de pontos e recompensas
- Feedback imediato
- Análise de desempenho

---

## 🎯 Funcionalidades

### 1. Tipos de Questões Gamificadas
- **Múltipla escolha interativa**: Arrastar e soltar
- **Código interativo**: Editor integrado com validação em tempo real
- **Quebra-cabeças**: Ordenar passos de algoritmo
- **Simulações**: Resolver problemas práticos em ambientes virtuais
- **Desafios cronometrados**: Speed rounds
- **Questões colaborativas**: Mini-competições entre grupos

### 2. Acessibilidade e Inclusão
- **Fonte dyslexia-friendly**: OpenDyslexic, Comic Sans
- **Espaçamento aumentado**: Line height, letter spacing
- **Tempo extra**: +50% para alunos com dislexia
- **Leitura em voz alta**: Text-to-speech integrado
- **Alto contraste**: Temas claro/escuro otimizados
- **Sem penalização por erros de digitação**: Fuzzy matching

### 3. Gamificação
- **Pontos e XP**: Ganhar pontos por acertos
- **Badges e conquistas**: "First Blood", "Perfect Score", "Speed Demon"
- **Níveis**: Progressão visual (Bronze → Prata → Ouro → Platina)
- **Power-ups**: Eliminar 2 alternativas, pular questão, dica
- **Leaderboard**: Ranking em tempo real (opcional: anônimo)
- **Streak**: Dias consecutivos de estudo/prática

### 4. Feedback Imediato
- Correção instantânea após cada questão
- Explicação da resposta correta
- Links para materiais de estudo
- Sugestões personalizadas

### 5. Análise de Desempenho
- Relatório individual detalhado
- Comparação com turma (percentil)
- Identificação de pontos fracos
- Recomendações de estudo

---

## 📋 Tarefas de Implementação

### Fase 1: Engine de Questões
- [ ] Tipos de questões suportados:
  - Multiple choice
  - True/False
  - Fill in the blank
  - Code completion
  - Drag and drop
  - Matching
  - Short answer (auto-graded com NLP)
- [ ] Editor de questões para professores
- [ ] Banco de questões reutilizáveis
- [ ] Tags e categorização (disciplina, tópico, dificuldade)

### Fase 2: Acessibilidade para Dislexia
- [ ] Seletor de fonte (OpenDyslexic, Arial, Verdana)
- [ ] Ajuste de tamanho de fonte (12pt - 24pt)
- [ ] Ajuste de espaçamento:
  - Line height: 1.5 - 2.5
  - Letter spacing: 0 - 5px
- [ ] Temas de alto contraste
- [ ] Text-to-speech (Web Speech API):
  ```javascript
  const speak = (text) => {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'pt-BR';
    utterance.rate = 0.9; // Mais devagar
    speechSynthesis.speak(utterance);
  };
  ```
- [ ] Tempo extra automático (flag no perfil do aluno)
- [ ] Corretor ortográfico tolerante

### Fase 3: Gamificação
- [ ] Sistema de pontos:
  - Acerto: +10 pontos
  - Acerto rápido: +15 pontos (< 30s)
  - Streak de 5 acertos: +bonus de 25 pontos
  - Erro: -0 pontos (sem penalização)
- [ ] Badges:
  ```
  🥇 Perfect Score: 100% de acertos
  ⚡ Speed Demon: Terminou em < 50% do tempo
  🔥 Hot Streak: 10 acertos consecutivos
  🎯 Sharpshooter: 90%+ de acertos
  📚 Bookworm: Estudou todo material recomendado
  ```
- [ ] Power-ups (ganhos por engajamento):
  - 50/50: Elimina 2 alternativas erradas
  - Skip: Pula questão sem perder pontos
  - Hint: Dica sobre a resposta
  - Time Freeze: +2 minutos extras
- [ ] Leaderboard em tempo real
- [ ] Progresso visual (barra de XP, avatar)

### Fase 4: Feedback Imediato
- [ ] Após cada questão:
  - ✅ Correto! +10 pontos
  - ❌ Incorreto. A resposta certa é X porque...
  - 💡 Dica: Revise o conceito de Y
  - 📖 Material recomendado: [Link]
- [ ] Explicações geradas por IA (GPT-4):
  ```python
  EXPLANATION_PROMPT = """
  Questão: {question}
  Resposta do aluno: {student_answer}
  Resposta correta: {correct_answer}
  
  Gere uma explicação educacional que:
  1. Explique por que a resposta correta está certa
  2. Mostre por que as outras estão erradas
  3. Dê um exemplo prático
  4. Seja encorajador
  
  Máximo 150 palavras.
  """
  ```

### Fase 5: Análise de Desempenho
- [ ] Relatório pós-prova:
  - Nota final
  - Tempo gasto
  - Questões por tópico (acertos/erros)
  - Comparação com turma
  - Pontos fortes e fracos
- [ ] Gráficos:
  - Radar chart por tópico
  - Timeline de acertos (foi melhorando?)
  - Distribuição de tempo por questão
- [ ] Recomendações de estudo
- [ ] Exportação em PDF

### Fase 6: Modo Prática vs Modo Prova
- **Modo Prática**:
  - Sem limite de tempo
  - Pode rever questões
  - Feedback imediato
  - Power-ups ilimitados
  - Leaderboard separado
- **Modo Prova**:
  - Tempo limitado
  - Sem poder voltar
  - Feedback ao final
  - Power-ups limitados (se houver)
  - Anti-cheating measures

### Fase 7: Anti-Cheating
- [ ] Randomização de questões e alternativas
- [ ] Detecção de mudança de aba (fullscreen API)
- [ ] Proctoring com webcam (opcional, com consentimento)
- [ ] Análise de padrões suspeitos (tempo muito rápido, similaridade entre alunos)

### Fase 8: Interface Flutter
- [ ] Tela de prova gamificada:
  - Questão atual centralizada
  - Barra de progresso animada
  - Timer (com opção de ocultar para reduzir ansiedade)
  - Pontuação em tempo real
  - Avatars e elementos visuais
- [ ] Animações:
  - Confetti ao acertar
  - Shake ao errar
  - Level up animation
  - Badge unlocked
- [ ] Sons (opcional, pode ser desabilitado):
  - Acerto: "ding"
  - Erro: "buzz"
  - Badge: fanfare
- [ ] Tema claro/escuro

### Fase 9: Testes e Deploy
- [ ] Testes com alunos reais
- [ ] Feedback sobre acessibilidade
- [ ] Ajustes de gamificação (não muito difícil, não muito fácil)
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `GET /api/v1/exams` - Listar provas disponíveis
- `GET /api/v1/exams/{id}` - Detalhes da prova
- `POST /api/v1/exams/{id}/start` - Iniciar tentativa
- `POST /api/v1/exams/{id}/submit-answer` - Submeter resposta
- `POST /api/v1/exams/{id}/use-powerup` - Usar power-up
- `POST /api/v1/exams/{id}/finish` - Finalizar prova
- `GET /api/v1/exams/{id}/results` - Ver resultados
- `GET /api/v1/exams/{id}/leaderboard` - Leaderboard
- `GET /api/v1/students/{id}/stats` - Estatísticas do aluno

---

## 📊 Database Schema

### Table: exams
```
PK: exam_id
Attributes:
  - title
  - description
  - discipline
  - duration_minutes
  - total_points
  - passing_score
  - mode (practice, exam)
  - accessibility_options (JSON)
  - created_by
  - created_at
```

### Table: exam_attempts
```
PK: attempt_id
Attributes:
  - exam_id
  - student_id
  - started_at
  - finished_at
  - score
  - max_score
  - percentage
  - answers (JSON: [{question_id, answer, correct, points}])
  - powerups_used (JSON)
  - badges_earned (List)
```

### Table: questions
```
PK: question_id
Attributes:
  - type (multiple_choice, code, etc)
  - content (Markdown)
  - options (JSON for MC)
  - correct_answer
  - explanation (Markdown)
  - points
  - difficulty (easy, medium, hard)
  - tags (List)
```

---

## 🎨 Design para Dislexia

### Princípios
1. **Fonte**: OpenDyslexic ou sans-serif limpa
2. **Tamanho**: Mínimo 14pt, ideal 16-18pt
3. **Espaçamento**: Line height 1.5+, letter spacing aumentado
4. **Contraste**: Evitar branco puro no fundo (usar off-white ou azul claro)
5. **Parágrafos curtos**: Máximo 3-4 linhas
6. **Listas**: Preferir bullets a parágrafos longos
7. **Cores**: Evitar vermelho/verde (daltonismo)
8. **Imagens**: Usar para quebrar texto e ilustrar conceitos

---

## ✅ Critérios de Aceitação

- [ ] Múltiplos tipos de questões implementados
- [ ] Acessibilidade para dislexia (fonte, espaçamento, tempo, TTS)
- [ ] Sistema de gamificação com pontos e badges
- [ ] Feedback imediato após questões
- [ ] Análise de desempenho com gráficos
- [ ] Modo prática e modo prova
- [ ] Anti-cheating básico
- [ ] Interface Flutter com animações
- [ ] Tema claro/escuro
- [ ] Testes com alunos (feedback positivo)
- [ ] Deploy serverless

---

## 📚 Referências

- [OpenDyslexic Font](https://opendyslexic.org/)
- [Gamification in Education](https://www.gamify.com/gamification-blog/gamification-in-education)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Dyslexia-Friendly Design](https://www.bdadyslexia.org.uk/advice/employers/creating-a-dyslexia-friendly-workplace/dyslexia-friendly-style-guide)
