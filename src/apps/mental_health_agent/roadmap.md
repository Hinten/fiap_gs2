# Mental Health Detection Agent - Roadmap

## 🧠 Visão Geral

Agente de IA que monitora indicadores de saúde mental de alunos, professores e colaboradores, identificando sinais de alerta precocemente e recomendando intervenções apropriadas.

### Responsabilidades
- Monitoramento passivo de indicadores comportamentais
- Análise de padrões de comunicação e engajamento
- Detecção de sinais de burnout, ansiedade e depressão
- Recomendações de suporte e recursos
- Alertas confidenciais para responsáveis autorizados

---

## 🎯 Funcionalidades

### 1. Coleta de Indicadores (Não-Invasiva)
- **Padrões de Atividade**:
  - Frequência de login e horários
  - Tempo gasto no sistema
  - Padrões de entrega (last-minute vs planejado)
  - Engajamento em fóruns e chats
- **Comunicação**:
  - Tom das mensagens (sentiment analysis)
  - Frequência de interação
  - Resposta a mensagens de suporte
- **Desempenho Acadêmico**:
  - Queda súbita em notas
  - Aumento de faltas
  - Trabalhos não entregues
- **Auto-relato** (Opcional):
  - Check-ins semanais voluntários
  - Escala de bem-estar (1-10)

### 2. Análise com Machine Learning
- **Sentiment Analysis**: Análise de texto de mensagens, comentários
- **Anomaly Detection**: Identificação de mudanças comportamentais súbitas
- **Pattern Recognition**: Comparação com padrões de risco conhecidos
- **Risk Scoring**: Score de risco (0-100) com categorias:
  - 🟢 Saudável (0-30)
  - 🟡 Atenção (31-60)
  - 🟠 Preocupante (61-80)
  - 🔴 Crítico (81-100)

### 3. Recomendações Personalizadas
- **Para o indivíduo**:
  - Recursos de apoio (artigos, vídeos)
  - Exercícios de mindfulness
  - Sugestões de pausas e descanso
  - Contatos de suporte (psicólogos, ouvidoria)
- **Para responsáveis** (com consentimento):
  - Alertas confidenciais
  - Sugestões de abordagem
  - Recursos de intervenção

### 4. Dashboard de Bem-Estar
- **Individual**: 
  - Histórico de bem-estar
  - Insights e tendências
  - Recursos recomendados
- **Coordenadores** (dados agregados e anonimizados):
  - Métricas de bem-estar da turma/departamento
  - Identificação de períodos críticos (provas, deadlines)
  - Eficácia de intervenções

---

## 📋 Tarefas de Implementação

### Fase 1: Coleta de Dados (Ética e Consentimento)
- [ ] **Termo de Consentimento**:
  - Explicação clara do que é monitorado
  - Opt-in obrigatório
  - Possibilidade de opt-out a qualquer momento
  - LGPD compliance
- [ ] **Coleta Passiva**:
  - Logs de login/logout
  - Tempo de sessão
  - Páginas visitadas (agregado)
  - Interações em fóruns
- [ ] **Coleta Ativa** (Opcional):
  - Check-in semanal: "Como você está se sentindo?"
  - Escala de bem-estar (0-10)
  - Comentário livre (opcional)

### Fase 2: Feature Engineering
- [ ] Métricas comportamentais:
  ```python
  features = {
      'login_frequency': float,        # logins por semana
      'session_duration_avg': float,   # minutos médios
      'late_night_activity': float,    # % atividade 22h-6h
      'deadline_pattern': str,         # early/on-time/late/missing
      'forum_engagement': float,       # posts/comments por semana
      'message_response_time': float,  # horas médias para responder
      'grade_trend': str,              # improving/stable/declining
      'absence_count': int,            # faltas no mês
      'sentiment_score': float,        # -1 (negativo) a +1 (positivo)
      'self_reported_wellbeing': float # 0-10 (se disponível)
  }
  ```

### Fase 3: Modelos de Machine Learning
- [ ] **Sentiment Analysis**:
  - Modelo: BERT fine-tuned para PT-BR
  - Input: Textos de mensagens, posts
  - Output: Score de sentimento (-1 a +1)
- [ ] **Anomaly Detection**:
  - Modelo: Isolation Forest ou Autoencoders
  - Detecta padrões anormais vs baseline do indivíduo
- [ ] **Risk Prediction**:
  - Modelo: Random Forest ou XGBoost
  - Features: Todos os indicadores acima
  - Output: Risk score (0-100) + categoria
  - Target: Baseado em dados históricos ou especialistas

### Fase 4: Sistema de Alertas
- [ ] **Alertas Individuais** (para o próprio usuário):
  - "Notamos que você tem estudado até tarde. Considere fazer pausas."
  - "Parece que você está sobrecarregado. Confira estes recursos de apoio."
- [ ] **Alertas Confidenciais** (para responsáveis autorizados):
  - Apenas se risco >= 61 (preocupante)
  - Notificação para coordenador/orientador
  - Não inclui dados específicos, apenas alerta
- [ ] **Escalação Crítica**:
  - Risco >= 81: Alerta imediato para suporte psicológico
  - Protocolo de crise definido

### Fase 5: Recomendações e Recursos
- [ ] Base de conhecimento de recursos:
  - Artigos sobre gerenciamento de stress
  - Vídeos de mindfulness e meditação
  - Contatos de apoio psicológico (FIAP/externos)
  - Técnicas de estudo e organização
- [ ] Sistema de recomendação:
  - Baseado no score de risco e padrões detectados
  - Personalizado por contexto (estudante, professor, colaborador)

### Fase 6: Interface e Dashboard
- [ ] **Para Usuários**:
  - Dashboard de bem-estar pessoal
  - Gráfico de tendência ao longo do tempo
  - Check-in rápido (emoji + escala)
  - Acesso a recursos recomendados
  - Configurações de privacidade
- [ ] **Para Coordenadores** (dados agregados):
  - Métricas gerais de bem-estar
  - Identificação de períodos de alto stress
  - Comparação entre turmas/semestres
  - Eficácia de intervenções

### Fase 7: Privacidade e Ética
- [ ] **Anonimização**:
  - Dados agregados não identificam indivíduos
  - Pseudonimização em análises
- [ ] **Controle do Usuário**:
  - Ver quais dados são coletados
  - Exportar seus próprios dados
  - Deletar histórico (LGPD right to erasure)
  - Opt-out a qualquer momento
- [ ] **Auditoria**:
  - Log de quem acessa dados sensíveis
  - Revisão regular por comitê de ética

### Fase 8: Validação e Testes
- [ ] Validação com profissionais de saúde mental
- [ ] Testes com grupo piloto (voluntários)
- [ ] Ajuste de thresholds de alerta
- [ ] Avaliação de falsos positivos/negativos

### Fase 9: Deploy e Monitoramento
- [ ] Deploy serverless
- [ ] Monitoramento contínuo de modelos (drift detection)
- [ ] Feedback loop para melhoria contínua

---

## 🔌 Endpoints

- `POST /api/v1/mental-health/consent` - Registrar consentimento
- `POST /api/v1/mental-health/checkin` - Check-in voluntário
- `GET /api/v1/mental-health/dashboard/{user_id}` - Dashboard pessoal
- `GET /api/v1/mental-health/resources` - Recursos de apoio
- `GET /api/v1/mental-health/aggregated` - Dados agregados (coordenadores)
- `PUT /api/v1/mental-health/settings` - Configurações de privacidade
- `DELETE /api/v1/mental-health/data/{user_id}` - Deletar dados (LGPD)

---

## 📊 Database Schema

### Table: mental_health_consent
```
PK: user_id
Attributes:
  - consented (boolean)
  - consent_date
  - opt_out_date (nullable)
  - data_usage_accepted (list: monitoring, recommendations, research)
```

### Table: behavioral_metrics
```
PK: user_id#date
Attributes:
  - date
  - login_frequency
  - session_duration_avg
  - late_night_activity_pct
  - forum_engagement_score
  - sentiment_score_avg
  - grade_trend
  - absence_count
  - encrypted_data (JSON)
```

### Table: risk_assessments
```
PK: assessment_id
Attributes:
  - user_id (encrypted)
  - timestamp
  - risk_score (0-100)
  - risk_category (healthy, attention, concerning, critical)
  - contributing_factors (List)
  - recommendations (List)
```

### Table: mental_health_alerts
```
PK: alert_id
Attributes:
  - user_id (encrypted)
  - timestamp
  - severity (medium, high, critical)
  - notified_to (list of user_ids)
  - status (pending, acknowledged, resolved)
  - follow_up_actions (JSON)
```

---

## 🤖 Agente CrewAI

```python
mental_health_agent = Agent(
    role='Mental Health Support Specialist',
    goal='Monitor wellbeing indicators and provide supportive recommendations',
    backstory="""You are a compassionate AI trained to recognize signs of 
    mental health challenges. You prioritize privacy, consent, and non-judgmental 
    support. You know when to recommend professional help.""",
    tools=[
        SentimentAnalysisTool(),
        AnomalyDetectionTool(),
        ResourceRecommendationTool(),
        CrisisProtocolTool(),
    ],
)
```

---

## 🔒 Considerações Éticas Críticas

### 1. Consentimento Informado
- Explicar claramente o que é monitorado
- Opt-in explícito, não assumido
- Possibilidade de opt-out sem penalização

### 2. Privacidade e Confidencialidade
- Criptografia de dados sensíveis
- Acesso restrito a profissionais autorizados
- Anonimização em análises agregadas

### 3. Não-Diagnóstico
- Sistema **não diagnostica** condições de saúde mental
- Apenas identifica **indicadores de risco**
- Sempre recomenda profissionais qualificados

### 4. Evitar Estigmatização
- Comunicação empática e não-julgadora
- Foco em suporte, não punição
- Normalização de buscar ajuda

### 5. Falibilidade do Sistema
- Reconhecer limitações da IA
- Permitir contestação de alertas
- Revisão humana de casos críticos

---

## 📈 Indicadores de Risco (Exemplos)

### Sinais de Alerta (Score ↑)
- Atividade constante em horários de madrugada
- Queda súbita em engajamento (ausências)
- Linguagem com sentimento muito negativo
- Múltiplos prazos perdidos consecutivos
- Isolamento social (sem interação)
- Resposta lenta ou nenhuma resposta a mensagens de suporte

### Sinais Positivos (Score ↓)
- Padrões regulares de sono (inferido)
- Engajamento consistente
- Sentimento neutro ou positivo
- Entregas no prazo
- Interação social saudável
- Resposta ativa a check-ins

---

## ✅ Critérios de Aceitação

- [ ] Sistema de consentimento implementado e LGPD compliant
- [ ] Coleta de dados comportamentais não-invasiva
- [ ] Modelos de ML treinados e validados (precision > 75%)
- [ ] Sentiment analysis funcionando (PT-BR)
- [ ] Risk scoring com categorização
- [ ] Sistema de alertas confidenciais
- [ ] Recursos de apoio curados e acessíveis
- [ ] Dashboard pessoal de bem-estar
- [ ] Dashboard agregado para coordenadores
- [ ] Validação com profissionais de saúde mental
- [ ] Auditoria de privacidade OK
- [ ] Testes com grupo piloto (feedback positivo)
- [ ] Deploy serverless

---

## 📚 Referências

- [WHO - Mental Health in the Workplace](https://www.who.int/mental_health/in_the_workplace/en/)
- [Ethics of AI in Mental Health](https://www.nature.com/articles/s41746-021-00515-w)
- [LGPD - Sensitive Personal Data](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)
- [Sentiment Analysis with BERT](https://huggingface.co/neuralmind/bert-base-portuguese-cased)
- [Anomaly Detection in Healthcare](https://arxiv.org/abs/2007.15147)

---

## ⚠️ IMPORTANTE

Este sistema é uma **ferramenta de apoio**, não substitui avaliação profissional. Sempre que possível, deve haver profissionais de saúde mental envolvidos na revisão e interpretação dos dados.
