# Code Review Agent - Roadmap

## 🤖 Visão Geral

Agente de IA que integra com a GitHub API para fornecer code reviews inteligentes, personalizados e educacionais para trabalhos de alunos da FIAP.

### Responsabilidades
- Integração com GitHub API (repos, PRs, commits)
- Análise estática de código (qualidade, padrões, segurança)
- Geração de feedback personalizado e construtivo
- Detecção de plágio e similaridade entre trabalhos
- Sugestões de melhorias específicas por disciplina

---

## 🎯 Funcionalidades Principais

### 1. Integração GitHub
- Webhook para detectar novos PRs/commits
- Autenticação via GitHub App
- Acesso a repos de alunos (com permissão)
- Comentários automáticos em PRs

### 2. Análise de Código
- **Qualidade**: complexidade ciclomática, duplicação, code smells
- **Padrões**: PEP 8 (Python), ESLint (JS), Dart analyzer (Flutter)
- **Segurança**: OWASP Top 10, secrets no código, SQL injection
- **Arquitetura**: padrões de design, SOLID, Clean Code
- **Testes**: cobertura, qualidade de testes

### 3. Feedback Personalizado
- Análise do histórico do aluno (progressão)
- Tom educacional e encorajador
- Exemplos de código correto
- Links para documentação e tutoriais
- Níveis de severidade (crítico, importante, sugestão)

### 4. Detecção de Plágio
- Comparação entre trabalhos da mesma turma
- Detecção de código copiado da internet
- Análise de similaridade estrutural
- Geração de relatório de originalidade

---

## 📋 Tarefas de Implementação

### Fase 1: Setup e Integração GitHub
- [ ] Criar GitHub App com permissões necessárias
- [ ] Implementar autenticação OAuth
- [ ] Webhook endpoint para eventos (PR opened, commit pushed)
- [ ] API wrapper para GitHub REST API v3
- [ ] Testes de integração com repo de exemplo

**APIs Necessárias**:
- `POST /api/v1/github/webhook` - Recebe eventos do GitHub
- `GET /api/v1/github/repos/{owner}/{repo}/pulls` - Lista PRs
- `POST /api/v1/code-review/analyze` - Trigga análise de PR

### Fase 2: Análise Estática de Código
- [ ] Integrar ferramentas de linting:
  - Python: pylint, flake8, mypy
  - JavaScript: ESLint, Prettier
  - Flutter/Dart: dart analyze
- [ ] Análise de complexidade (radon para Python)
- [ ] Detecção de code smells (SonarQube ou Pylint)
- [ ] Scanner de segurança (bandit para Python, OWASP dependency-check)
- [ ] Aggregação de resultados em formato unificado

### Fase 3: Agente de IA para Feedback
- [ ] Prompt engineering para análise educacional
- [ ] Integração CrewAI/LangChain
- [ ] Contexto do aluno (disciplina, nível, histórico)
- [ ] Geração de comentários em Markdown
- [ ] Sistema de ranking de issues (P0, P1, P2, P3)

Exemplo de prompt:
```python
SYSTEM_PROMPT = """
Você é um professor assistente da FIAP especializado em revisão de código.
Seu objetivo é fornecer feedback construtivo e educacional para alunos.

Diretrizes:
- Seja encorajador e construtivo
- Explique o "porquê" das sugestões
- Forneça exemplos de código melhorado
- Referencie materiais de estudo
- Priorize aprendizado sobre perfeição
- Adapte o tom ao nível do aluno (iniciante, intermediário, avançado)
"""

USER_PROMPT = """
Analise o seguinte código Python de um aluno de {disciplina}:

```python
{codigo}
```

Problemas detectados por ferramentas automáticas:
{issues}

Gere um code review personalizado com:
1. Resumo geral (pontos positivos e áreas de melhoria)
2. Issues críticos (segurança, bugs)
3. Sugestões de refatoração
4. Recomendações de estudo
"""
```

### Fase 4: Detecção de Plágio
- [ ] Vector embeddings de código (CodeBERT, GraphCodeBERT)
- [ ] Similarity search entre trabalhos
- [ ] Análise de estrutura AST (Abstract Syntax Tree)
- [ ] Busca na internet (GitHub, StackOverflow)
- [ ] Relatório de similaridade com percentual

### Fase 5: Interface e Aprovação
- [ ] Dashboard para professores
  - Lista de PRs pendentes de review
  - Visualização de feedback gerado
  - Edição de comentários antes de postar
  - Aprovação com 1 clique
- [ ] Notificações para alunos
- [ ] Histórico de reviews por aluno

### Fase 6: Testes e Deploy
- [ ] Unit tests (mock GitHub API)
- [ ] Integration tests (repo de teste)
- [ ] Performance tests (análise de repo grande)
- [ ] Deploy serverless (Lambda + API Gateway)

---

## 🔌 Endpoints

- `POST /api/v1/github/webhook` - Webhook do GitHub
- `POST /api/v1/code-review/analyze` - Trigga análise manual
- `GET /api/v1/code-review/pending` - Lista reviews pendentes (professor)
- `GET /api/v1/code-review/{review_id}` - Detalhes do review
- `PUT /api/v1/code-review/{review_id}/approve` - Aprovar e postar
- `PUT /api/v1/code-review/{review_id}/edit` - Editar feedback
- `GET /api/v1/plagiarism/check?repo={repo}` - Checar plágio

---

## 📊 Database Schema

### Table: code_reviews
```
PK: review_id
Attributes:
  - repo_full_name (owner/repo)
  - pr_number
  - commit_sha
  - student_id
  - discipline
  - analysis_results (JSON: linting, security, complexity)
  - ai_feedback (Markdown)
  - status (pending, approved, posted, rejected)
  - professor_edits
  - created_at
  - approved_at
```

### Table: plagiarism_reports
```
PK: report_id
Attributes:
  - repo_a
  - repo_b
  - similarity_score (0-1)
  - similar_files (List)
  - sources_found (URLs)
  - created_at
```

---

## 🧪 Ferramentas de Análise

### Python
- **Linting**: pylint, flake8
- **Type Checking**: mypy
- **Security**: bandit
- **Complexity**: radon
- **Formatting**: black

### JavaScript/TypeScript
- **Linting**: ESLint
- **Formatting**: Prettier
- **Security**: npm audit

### Flutter/Dart
- **Analyzer**: dart analyze
- **Formatting**: dartfmt

### Multi-language
- **SonarQube**: análise multi-linguagem
- **OWASP Dependency-Check**: vulnerabilidades em deps

---

## 🤖 Agente de IA (CrewAI)

```python
from crewai import Agent, Task, Crew

code_reviewer_agent = Agent(
    role='Code Review Specialist',
    goal='Provide educational and constructive code reviews for students',
    backstory="""You are an experienced software engineer and educator at FIAP.
    You understand that students are learning and need guidance, not just criticism.
    You provide detailed explanations and examples to help students improve.""",
    tools=[CodeAnalysisTool(), GitHubTool(), DocumentationSearchTool()],
    verbose=True
)

review_task = Task(
    description="""
    Analyze the code in PR #{pr_number} from student {student_name}.
    Discipline: {discipline}
    
    1. Review static analysis results
    2. Identify critical issues (security, bugs)
    3. Suggest improvements with examples
    4. Provide learning resources
    5. Generate personalized feedback in Markdown
    """,
    agent=code_reviewer_agent
)
```

---

## ✅ Critérios de Aceitação

- [ ] Integração GitHub funcionando (webhook + API)
- [ ] Análise estática em múltiplas linguagens
- [ ] Feedback gerado por IA em < 2 minutos
- [ ] Interface de aprovação para professores
- [ ] Detecção de plágio com accuracy > 85%
- [ ] Comentários postados automaticamente no GitHub
- [ ] Dashboard com histórico de reviews
- [ ] Testes cobertura 70%+
- [ ] Deploy serverless OK

---

## 📚 Referências

- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub Webhooks](https://docs.github.com/en/developers/webhooks-and-events/webhooks)
- [CrewAI Documentation](https://docs.crewai.com/)
- [CodeBERT for Code Similarity](https://github.com/microsoft/CodeBERT)
- [SonarQube](https://www.sonarqube.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
