# Grading Agent - Roadmap

## 🎓 Visão Geral

Agente de IA que automatiza a criação de metodologias de correção, realiza correções automatizadas e gera feedback personalizado para aprovação do professor.

### Responsabilidades
- Criar tabelas de critérios e pesos de avaliação
- Analisar trabalhos e aplicar metodologia
- Gerar feedback personalizado por aluno
- Interface de aprovação para professores
- Conversação com professor para ajustes

---

## 🎯 Funcionalidades

### 1. Geração de Metodologia
- Análise do enunciado do trabalho
- Criação de rubrica com critérios objetivos
- Definição de pesos por critério
- Validação com histórico de avaliações anteriores

### 2. Correção Automatizada
- Análise de código/documentos
- Aplicação de critérios da rubrica
- Cálculo de nota final
- Geração de justificativas por critério

### 3. Feedback Personalizado
- Pontos fortes do trabalho
- Áreas de melhoria específicas
- Sugestões de estudo
- Comparação com média da turma (opcional)

### 4. Interface de Aprovação
- Visualização de correções pending
- Edição de notas e feedbacks
- Chat com agente para ajustes
- Aprovação com 1 clique → publica no sistema FIAP

---

## 📋 Tarefas de Implementação

### Fase 1: Geração de Metodologia
- [ ] Parser de enunciados (PDF, Markdown, HTML)
- [ ] Extração de requisitos e objetivos
- [ ] Agente CrewAI para criar rubrica
- [ ] Geração de tabela de critérios:
  ```
  | Critério | Peso | Descrição | Nota |
  |----------|------|-----------|------|
  | Funcionalidade | 30% | Sistema funciona conforme especificado | 0-10 |
  | Código | 25% | Qualidade, padrões, organização | 0-10 |
  | Documentação | 20% | README, comentários, diagramas | 0-10 |
  | Testes | 15% | Cobertura e qualidade de testes | 0-10 |
  | Apresentação | 10% | Vídeo, explicação, organização | 0-10 |
  ```
- [ ] Validação com professor antes de usar

### Fase 2: Correção Automatizada
- [ ] Clone do repositório do aluno
- [ ] Análise automatizada:
  - Código (linting, testes, cobertura)
  - Documentação (completude, clareza)
  - Commits (frequência, mensagens)
  - README (estrutura, instruções)
- [ ] Aplicação da rubrica
- [ ] Cálculo de nota ponderada
- [ ] Geração de justificativas

### Fase 3: Feedback Personalizado
- [ ] Prompt engineering para feedback educacional
- [ ] Análise de histórico do aluno
- [ ] Comparação com turma (percentil)
- [ ] Sugestões de melhoria específicas
- [ ] Links para materiais de estudo

Exemplo de prompt:
```python
GRADING_PROMPT = """
Você é um professor da FIAP avaliando o trabalho de um aluno.

Rubrica de Avaliação:
{rubrica}

Análise Automatizada do Trabalho:
{analise}

Gere um feedback personalizado que inclua:
1. Nota por critério com justificativa
2. Pontos fortes (celebrar conquistas)
3. Áreas de melhoria (específicas e acionáveis)
4. Sugestões de estudo
5. Nota final calculada

Mantenha tom encorajador e construtivo.
"""
```

### Fase 4: Interface de Aprovação
- [ ] Dashboard para professores
- [ ] Lista de trabalhos pendentes de correção
- [ ] Visualização de nota e feedback gerados
- [ ] Edição inline de notas e comentários
- [ ] Chat com agente:
  - "Reduza nota de documentação para 7"
  - "Adicione comentário sobre falta de testes unitários"
  - "Regenere feedback com tom mais encorajador"
- [ ] Botão "Aprovar e Publicar"
- [ ] Integração com sistema FIAP (API ou RPA)

### Fase 5: Conversação Inteligente
- [ ] LLM conversacional (GPT-4, Claude)
- [ ] Contexto da correção mantido na conversa
- [ ] Comandos suportados:
  - Ajustar nota de critério
  - Adicionar/remover comentários
  - Regenerar feedback
  - Solicitar análise adicional
  - Comparar com outro trabalho

### Fase 6: Testes e Deploy
- [ ] Testes com trabalhos reais (anonimizados)
- [ ] Validação de notas com professores
- [ ] Ajuste de prompts e rubricas
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `POST /api/v1/grading/methodology/generate` - Gerar rubrica
- `POST /api/v1/grading/grade` - Corrigir trabalho
- `GET /api/v1/grading/pending` - Lista trabalhos pendentes
- `GET /api/v1/grading/{grading_id}` - Detalhes da correção
- `PUT /api/v1/grading/{grading_id}/edit` - Editar nota/feedback
- `POST /api/v1/grading/{grading_id}/chat` - Conversar com agente
- `POST /api/v1/grading/{grading_id}/approve` - Aprovar e publicar
- `POST /api/v1/grading/bulk-approve` - Aprovar múltiplos

---

## 📊 Database Schema

### Table: grading_methodologies
```
PK: methodology_id
Attributes:
  - assignment_name
  - discipline
  - criteria (JSON: [{name, weight, description}])
  - created_by (professor)
  - approved (boolean)
  - created_at
```

### Table: gradings
```
PK: grading_id
Attributes:
  - student_id
  - assignment_id
  - methodology_id
  - repo_url
  - automated_analysis (JSON)
  - grades_by_criterion (JSON)
  - final_grade
  - feedback (Markdown)
  - status (pending, approved, published)
  - professor_edits (JSON: history)
  - conversation_history (JSON: messages)
  - created_at
  - approved_at
```

---

## 🤖 Agentes CrewAI

### Methodology Creator Agent
```python
methodology_agent = Agent(
    role='Grading Methodology Specialist',
    goal='Create fair and objective grading rubrics',
    backstory="""Expert in educational assessment and rubric design.
    You create clear, measurable criteria that align with learning objectives.""",
    tools=[AssignmentParserTool(), EducationalStandardsTool()],
)
```

### Grading Agent
```python
grading_agent = Agent(
    role='Automated Grader',
    goal='Fairly evaluate student work based on established rubrics',
    backstory="""Experienced evaluator who applies criteria consistently
    and provides constructive feedback.""",
    tools=[CodeAnalysisTool(), DocumentAnalysisTool(), ComparisonTool()],
)
```

---

## ✅ Critérios de Aceitação

- [ ] Geração de rubrica automatizada
- [ ] Correção automatizada com notas por critério
- [ ] Feedback personalizado e construtivo
- [ ] Interface de aprovação funcional
- [ ] Chat com agente para ajustes
- [ ] Integração com sistema FIAP (publicação de notas)
- [ ] Tempo de correção < 5 minutos por trabalho
- [ ] Concordância com professor > 85%
- [ ] Deploy serverless

---

## 📚 Referências

- [Rubric Design](https://www.cmu.edu/teaching/assessment/howto/assesslearning/rubrics.html)
- [Automated Grading Systems](https://en.wikipedia.org/wiki/Automatic_essay_scoring)
- [CrewAI Multi-Agent Systems](https://docs.crewai.com/)
