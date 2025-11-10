# Content Reviewer Agent - Roadmap

## 🔍 Visão Geral

Agente de IA que revisa constantemente conteúdos educacionais, checa fontes, detecta erros e mantém materiais atualizados.

### Responsabilidades
- Revisão automática de conteúdos
- Checagem de fontes e referências
- Detecção de erros (técnicos, ortográficos, factuais)
- Sugestões de atualização
- Detecção de conteúdo desatualizado

---

## 🎯 Funcionalidades

### 1. Revisão Automática
- Análise de textos (slides, PDFs, vídeos com transcrição)
- Checagem ortográfica e gramatical
- Validação técnica (código, fórmulas, conceitos)
- Detecção de inconsistências

### 2. Fact-Checking e Fontes
- Verificação de afirmações
- Checagem de estatísticas e dados
- Validação de referências bibliográficas
- Links quebrados ou desatualizados
- Comparação com fontes confiáveis

### 3. Detecção de Conteúdo Desatualizado
- Monitoramento de novas versões de tecnologias
- Detecção de bibliotecas/frameworks obsoletos
- Alertas sobre mudanças em APIs
- Sugestões de atualização

### 4. Análise de Qualidade
- Clareza e didática
- Nível de dificuldade apropriado
- Completude (falta algum conceito?)
- Alinhamento com objetivos de aprendizagem

---

## 📋 Tarefas de Implementação

### Fase 1: Crawling e Indexação
- [ ] Scanner de conteúdos:
  - Slides (PPTX, PDF)
  - Vídeos (transcrição com Whisper)
  - Documentos (PDF, Word, Markdown)
  - Código-fonte (repos GitHub)
- [ ] Extração de texto
- [ ] Indexação para busca (Elasticsearch)
- [ ] Agendamento de revisões periódicas

### Fase 2: Checagem Ortográfica e Gramatical
- [ ] Integração LanguageTool (PT-BR)
- [ ] Detecção de erros:
  - Ortografia
  - Gramática
  - Pontuação
  - Concordância
- [ ] Sugestões de correção
- [ ] Ignorar termos técnicos (dicionário customizado)

### Fase 3: Validação Técnica
- [ ] **Código**: Análise de código em slides/docs
  - Syntax check
  - Deprecated APIs
  - Security issues
  - Best practices
- [ ] **Fórmulas**: Validação matemática/estatística
- [ ] **Conceitos**: Cross-reference com documentação oficial

### Fase 4: Fact-Checking com IA
- [ ] Agente CrewAI para fact-checking
- [ ] Busca em fontes confiáveis:
  - Wikipedia
  - Documentação oficial (Python, Java, etc)
  - Papers acadêmicos (Google Scholar)
  - Sites de referência (MDN, W3C, etc)
- [ ] Comparação de afirmações
- [ ] Score de confiança (0-100%)

Exemplo de prompt:
```python
FACTCHECK_PROMPT = """
Você é um revisor técnico especializado em {disciplina}.

Afirmação no material:
"{statement}"

Tarefa:
1. Pesquise em fontes confiáveis
2. Valide se a afirmação está correta
3. Se incorreta, forneça a versão correta
4. Cite as fontes

Resposta em JSON:
{
  "correct": true/false,
  "confidence": 0-100,
  "explanation": "...",
  "correct_version": "..." (if wrong),
  "sources": ["url1", "url2"]
}
"""
```

### Fase 5: Detecção de Conteúdo Desatualizado
- [ ] Monitor de versões:
  - Python: checar versão mencionada vs latest
  - Frameworks: React, Django, Flutter, etc
  - APIs: mudanças de endpoints
- [ ] Detecção de deprecated:
  ```python
  # Exemplo: detectar código desatualizado
  if "python 2" in content.lower():
      alert("Python 2 reached end-of-life in 2020. Update to Python 3.")
  
  if "react.createclass" in code:
      alert("React.createClass is deprecated. Use class components or hooks.")
  ```
- [ ] Alertas automáticos
- [ ] Sugestões de atualização

### Fase 6: Links e Referências
- [ ] Crawler de links em materiais
- [ ] Checagem HTTP status (404, 500, etc)
- [ ] Validação de certificados SSL
- [ ] Sugestões de alternativas para links quebrados
- [ ] Atualização de URLs (redirects)

### Fase 7: Análise de Qualidade Didática
- [ ] Métricas de legibilidade:
  - Flesch Reading Ease
  - Gunning Fog Index
  - Parágrafos muito longos
- [ ] Checagem de estrutura:
  - Introdução clara
  - Exemplos práticos
  - Exercícios
  - Conclusão/resumo
- [ ] Análise de alinhamento com objetivos de aprendizagem

### Fase 8: Dashboard de Revisão
- [ ] Lista de conteúdos revisados
- [ ] Issues encontrados (crítico, importante, sugestão)
- [ ] Filtros (disciplina, tipo de erro, data)
- [ ] Ações:
  - Ver detalhes do erro
  - Aceitar sugestão
  - Ignorar
  - Marcar como falso positivo
- [ ] Relatórios:
  - Erros corrigidos ao longo do tempo
  - Conteúdos com mais issues
  - Taxa de atualização

### Fase 9: Notificações
- [ ] Email para professores responsáveis
- [ ] Resumo semanal de issues
- [ ] Alertas críticos (ex: link do YouTube deletado)

### Fase 10: Testes e Deploy
- [ ] Testar com materiais reais
- [ ] Ajustar sensibilidade (evitar falsos positivos)
- [ ] Validar precisão de fact-checking
- [ ] Deploy serverless com scheduled jobs

---

## 🔌 Endpoints

- `POST /api/v1/content-review/scan` - Iniciar scan de conteúdo
- `GET /api/v1/content-review/issues` - Listar issues encontrados
- `GET /api/v1/content-review/issues/{id}` - Detalhes do issue
- `PUT /api/v1/content-review/issues/{id}/resolve` - Resolver issue
- `PUT /api/v1/content-review/issues/{id}/ignore` - Ignorar
- `GET /api/v1/content-review/reports/summary` - Relatório resumido
- `POST /api/v1/content-review/factcheck` - Fact-check manual

---

## 📊 Database Schema

### Table: content_items
```
PK: content_id
Attributes:
  - type (slide, video, pdf, code)
  - title
  - discipline
  - file_url
  - text_content (extracted)
  - last_reviewed_at
  - issues_count
  - status (up_to_date, needs_review, critical)
```

### Table: review_issues
```
PK: issue_id
Attributes:
  - content_id
  - type (spelling, grammar, factual, outdated, broken_link, technical)
  - severity (critical, important, suggestion)
  - description
  - location (page, timestamp, line)
  - suggested_fix
  - sources (URLs)
  - status (open, resolved, ignored, false_positive)
  - created_at
  - resolved_at
```

---

## 🤖 Agentes CrewAI

### Content Reviewer Agent
```python
reviewer_agent = Agent(
    role='Content Quality Reviewer',
    goal='Ensure all educational materials are accurate, up-to-date, and high quality',
    backstory="""Expert reviewer with deep technical knowledge and attention to detail.
    You catch errors that humans miss and keep content fresh.""",
    tools=[
        FactCheckTool(),
        SourceValidationTool(),
        CodeAnalysisTool(),
        LinkCheckerTool(),
    ],
)
```

### Fact-Checker Agent
```python
factchecker_agent = Agent(
    role='Fact-Checker Specialist',
    goal='Verify accuracy of technical claims and statistics',
    backstory="""Meticulous researcher who cross-references multiple sources
    and only trusts authoritative references.""",
    tools=[WebSearchTool(), ScholarSearchTool(), DocumentationTool()],
)
```

---

## 🔍 Tipos de Issues Detectados

### Críticos 🔴
- Informação factualmente incorreta
- Código com bugs ou vulnerabilidades
- Links para recursos principais quebrados
- Conceitos fundamentais errados

### Importantes 🟡
- Conteúdo desatualizado (versão antiga de lib)
- Deprecated APIs mencionadas
- Erros gramaticais graves
- Links secundários quebrados

### Sugestões 🟢
- Melhorias de clareza
- Exemplos adicionais recomendados
- Erros ortográficos leves
- Atualização de estatísticas

---

## 📈 Métricas de Sucesso

- **Precision**: % de issues reportados que são válidos (alvo: > 80%)
- **Recall**: % de erros reais detectados (alvo: > 70%)
- **Time to resolution**: Tempo médio para correção (alvo: < 7 dias)
- **Content freshness**: % de materiais revisados nos últimos 6 meses (alvo: > 90%)

---

## ✅ Critérios de Aceitação

- [ ] Scanner de múltiplos formatos funcionando
- [ ] Checagem ortográfica e gramatical
- [ ] Validação técnica de código
- [ ] Fact-checking com fontes
- [ ] Detecção de conteúdo desatualizado
- [ ] Link checker funcionando
- [ ] Dashboard de issues
- [ ] Notificações para professores
- [ ] Scheduled jobs rodando
- [ ] Precision > 75% (não muitos falsos positivos)
- [ ] Deploy serverless

---

## 📚 Referências

- [LanguageTool](https://languagetool.org/)
- [Fact-Checking with AI](https://arxiv.org/abs/example)
- [Content Quality Metrics](https://www.contentmarketinginstitute.com/)
- [Automated Proofreading](https://grammarly.com/)
