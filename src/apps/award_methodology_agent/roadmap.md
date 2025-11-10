# Award Methodology Agent - Roadmap

## 🏆 Visão Geral

Agente de IA que gera metodologias objetivas e transparentes para premiações, competições e rankings acadêmicos.

### Responsabilidades
- Criar critérios claros de premiação
- Avaliar trabalhos competitivos
- Gerar ranking transparente com justificativas
- Explicar decisões de forma compreensível
- Mostrar o que faltou para posições superiores

---

## 🎯 Funcionalidades

### 1. Geração de Metodologia de Premiação
- Análise de objetivos da competição
- Definição de critérios mensuráveis
- Pesos por critério
- Regras de desempate
- Validação de fairness (sem viés)

### 2. Avaliação Competitiva
- Análise comparativa entre trabalhos
- Aplicação de critérios
- Cálculo de pontuação
- Ranking automático

### 3. Transparência e Explicabilidade
- Justificativa clara para cada pontuação
- Comparação entre trabalhos
- "O que faltou" para posição superior
- Visualizações de scores

### 4. Interface de Aprovação
- Visualização de ranking gerado
- Edição de pontuações
- Conversa com agente para ajustes
- Aprovação final

---

## 📋 Tarefas de Implementação

### Fase 1: Geração de Metodologia
- [ ] Parser de regras de competição
- [ ] Agente CrewAI para criar critérios
- [ ] Exemplo de metodologia:
  ```
  Competição: Hackathon FIAP 2025
  
  Critérios:
  1. Inovação (30%)
     - Originalidade da ideia (0-10)
     - Viabilidade técnica (0-10)
  
  2. Execução Técnica (30%)
     - Qualidade do código (0-10)
     - Arquitetura (0-10)
  
  3. Apresentação (20%)
     - Clareza da explicação (0-10)
     - Qualidade do vídeo (0-10)
  
  4. Impacto (20%)
     - Relevância do problema (0-10)
     - Potencial de uso real (0-10)
  
  Desempate: Maior nota em Inovação
  ```

### Fase 2: Avaliação Automatizada
- [ ] Análise de cada trabalho conforme critérios
- [ ] Pontuação automatizada onde possível
- [ ] Comparação relativa entre trabalhos
- [ ] Detecção de outliers (excepcional ou fraco)

### Fase 3: Geração de Ranking e Justificativas
- [ ] Cálculo de pontuação total
- [ ] Ordenação dos trabalhos
- [ ] Geração de justificativas:
  ```markdown
  ## Ranking Final - Hackathon FIAP 2025
  
  ### 🥇 1º Lugar - Grupo Alpha (91.5 pontos)
  **Por que ganhou:**
  - Inovação excepcional (28/30): Solução única que ninguém mais pensou
  - Execução técnica sólida (26/30): Código limpo e bem arquitetado
  - Apresentação clara (18/20): Vídeo profissional e bem explicado
  - Impacto relevante (19/20): Problema real com solução viável
  
  ### 🥈 2º Lugar - Grupo Beta (88.0 pontos)
  **Pontos fortes:**
  - Execução técnica excelente (29/30): Melhor código da competição
  - Apresentação impecável (20/20): Melhor apresentação
  
  **O que faltou para o 1º lugar:**
  - Inovação (24/30 vs 28/30): Ideia boa mas não tão original
  - Diferença total: 3.5 pontos
  
  ### 🥉 3º Lugar - Grupo Gamma (85.5 pontos)
  **Pontos fortes:**
  - Inovação criativa (27/30)
  - Impacto social importante (18/20)
  
  **O que faltou para o 2º lugar:**
  - Execução técnica (21/30): Código com várias melhorias possíveis
  - Apresentação (16/20): Vídeo poderia ser mais claro
  - Diferença total: 2.5 pontos
  ```

### Fase 4: Visualizações
- [ ] Gráfico radar por critério
- [ ] Heatmap de comparação entre grupos
- [ ] Timeline de pontuação (se múltiplas etapas)
- [ ] Boxplot de distribuição de notas

### Fase 5: Interface de Aprovação
- [ ] Dashboard com ranking proposto
- [ ] Drill-down em cada grupo
- [ ] Edição de pontuações
- [ ] Chat com agente para ajustes
- [ ] Aprovação e publicação

### Fase 6: Testes e Deploy
- [ ] Validação com competições anteriores
- [ ] Teste de fairness (sem viés)
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `POST /api/v1/awards/methodology/generate` - Gerar metodologia
- `POST /api/v1/awards/evaluate` - Avaliar competição
- `GET /api/v1/awards/ranking/{competition_id}` - Ver ranking
- `GET /api/v1/awards/explanation/{group_id}` - Explicação detalhada
- `PUT /api/v1/awards/ranking/{competition_id}/edit` - Editar
- `POST /api/v1/awards/ranking/{competition_id}/approve` - Aprovar

---

## 📊 Database Schema

### Table: award_methodologies
```
PK: methodology_id
Attributes:
  - competition_name
  - criteria (JSON)
  - weights (JSON)
  - tiebreaker_rules
  - created_at
```

### Table: competition_rankings
```
PK: ranking_id
Attributes:
  - competition_id
  - methodology_id
  - groups_evaluated (JSON: [{group, scores, total}])
  - ranking_order (List)
  - explanations (JSON)
  - status (pending, approved, published)
  - created_at
```

---

## 🤖 Agente CrewAI

```python
award_methodology_agent = Agent(
    role='Award Methodology Designer',
    goal='Create fair, transparent, and objective award criteria',
    backstory="""Expert in competition design and evaluation.
    You ensure that all participants understand why winners won
    and what they need to improve.""",
    tools=[CriteriaDesignTool(), FairnessCheckerTool()],
)
```

---

## ✅ Critérios de Aceitação

- [ ] Metodologia clara e objetiva gerada
- [ ] Ranking automatizado com justificativas
- [ ] Explicação do "o que faltou" para cada grupo
- [ ] Visualizações intuitivas
- [ ] Interface de aprovação funcional
- [ ] Testes de fairness (sem viés)
- [ ] Deploy serverless

---

## 📚 Referências

- [Competition Design Principles](https://www.kaggle.com/competitions)
- [Fairness in Ranking Systems](https://arxiv.org/abs/example)
- [Explainable AI](https://christophm.github.io/interpretable-ml-book/)
