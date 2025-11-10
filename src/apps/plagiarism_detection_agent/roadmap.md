# Plagiarism Detection Agent - Roadmap

## 🔍 Visão Geral

Agente de IA especializado em detectar plágio e cópias em trabalhos acadêmicos, incluindo código, textos e documentos, com análise de similaridade estrutural e semântica.

### Responsabilidades
- Detecção de plágio entre trabalhos de alunos
- Identificação de código/texto copiado da internet
- Análise de similaridade semântica e estrutural
- Geração de relatórios detalhados de originalidade
- Suporte a múltiplas linguagens de programação e formatos

---

## 🎯 Funcionalidades

### 1. Detecção de Plágio em Código
- **Análise Sintática (AST)**:
  - Comparação de estruturas de código
  - Detecção de renomeação de variáveis
  - Identificação de reordenação de funções
- **Análise Semântica**:
  - Embeddings de código (CodeBERT, GraphCodeBERT)
  - Similaridade independente de estilo
- **Busca Externa**:
  - GitHub Code Search
  - Stack Overflow
  - Repositórios públicos

### 2. Detecção de Plágio em Textos
- **TF-IDF + Cosine Similarity**: Similaridade lexical
- **Semantic Embeddings**: BERT, Sentence Transformers
- **N-gram Analysis**: Sequências idênticas de palavras
- **Citation Check**: Verificação de referências apropriadas
- **Paraphrase Detection**: Identificação de paráfrases sem citação

### 3. Comparação Intra-Turma
- Comparação automática entre todos os trabalhos de uma turma
- Detecção de colaboração não autorizada
- Matriz de similaridade entre trabalhos
- Identificação de "clusters" de trabalhos similares

### 4. Relatório de Originalidade
- **Score de Originalidade** (0-100%)
- **Fontes de Similaridade**:
  - Outros trabalhos da turma (% match)
  - Fontes externas encontradas (URLs)
  - Trechos específicos marcados
- **Visualização**:
  - Heatmap de similaridade
  - Highlight de trechos copiados
  - Side-by-side comparison

---

## 📋 Tarefas de Implementação

### Fase 1: Análise de Código

#### Parser e AST
- [ ] Suporte para múltiplas linguagens:
  - Python (ast module)
  - Java (JavaParser)
  - JavaScript/TypeScript (Babel, TypeScript Compiler)
  - C/C++ (Clang)
  - Outros conforme demanda
- [ ] Normalização de AST:
  - Renomear variáveis para nomes genéricos
  - Remover comentários
  - Normalizar ordem de declarações

#### Code Embeddings
- [ ] Integração com CodeBERT ou GraphCodeBERT
- [ ] Geração de embeddings para cada função/classe
- [ ] Vector database para busca eficiente (FAISS, Pinecone)

#### Análise de Similaridade
- [ ] **Structural Similarity**:
  ```python
  def ast_similarity(ast1, ast2):
      # Tree edit distance
      # Retorna score 0-1
      pass
  ```
- [ ] **Semantic Similarity**:
  ```python
  def code_semantic_similarity(code1, code2):
      embedding1 = codebert.encode(code1)
      embedding2 = codebert.encode(code2)
      return cosine_similarity(embedding1, embedding2)
  ```

### Fase 2: Análise de Texto

#### TF-IDF
- [ ] Preprocessamento:
  - Tokenização
  - Remoção de stopwords
  - Stemming/Lemmatização (PT-BR)
- [ ] Cálculo de TF-IDF
- [ ] Cosine similarity entre documentos

#### Semantic Analysis
- [ ] BERT embeddings (neuralmind/bert-base-portuguese-cased)
- [ ] Sentence Transformers para PT-BR
- [ ] Comparação semântica mesmo com paráfrases

#### N-gram Analysis
- [ ] Detecção de sequências idênticas (3-grams, 5-grams)
- [ ] Threshold configurável (ex: 8+ palavras consecutivas)

### Fase 3: Busca Externa

#### GitHub Code Search
- [ ] Integração com GitHub API
- [ ] Busca por trechos de código
- [ ] Ranking de resultados por relevância

#### Web Search
- [ ] Busca em Stack Overflow, Medium, blogs
- [ ] Detecção de cópia de tutoriais
- [ ] Links para fontes encontradas

#### Academic Databases (Opcional)
- [ ] Google Scholar
- [ ] ArXiv, IEEE Xplore (para trabalhos acadêmicos)

### Fase 4: Comparação Intra-Turma

#### Batch Comparison
- [ ] Comparar todos os trabalhos entre si (N x N)
- [ ] Otimização para grandes turmas (> 100 alunos)
- [ ] Caching de embeddings

#### Clustering
- [ ] Identificar grupos de trabalhos similares
- [ ] Algoritmo: DBSCAN ou Hierarchical Clustering
- [ ] Visualização de clusters

### Fase 5: Relatório de Originalidade

#### Score Calculation
```python
def calculate_originality_score(submission):
    """
    Calcula score de originalidade (0-100%).
    100% = totalmente original
    0% = cópia completa
    """
    max_similarity = max([
        intra_class_similarity,
        external_similarity,
        internet_similarity
    ])
    
    originality = 100 - (max_similarity * 100)
    return originality
```

#### Detailed Report
- [ ] JSON com todos os matches:
  ```json
  {
    "submission_id": "abc123",
    "student_id": "student_456",
    "originality_score": 78,
    "matches": [
      {
        "type": "intra_class",
        "similarity": 0.45,
        "matched_with": "submission_xyz",
        "sections": [
          {
            "original_lines": "10-25",
            "matched_lines": "15-30",
            "excerpt": "..."
          }
        ]
      },
      {
        "type": "external",
        "similarity": 0.22,
        "source": "https://github.com/user/repo",
        "file": "main.py",
        "lines": "50-70"
      }
    ],
    "recommendations": [
      "Review lines 10-25 for proper citation",
      "Significant similarity with student X's work"
    ]
  }
  ```

#### Visualization
- [ ] Highlight de trechos copiados (color-coded)
- [ ] Side-by-side comparison
- [ ] Matriz de similaridade (heatmap)

### Fase 6: Interface de Professor

#### Dashboard
- [ ] Lista de trabalhos com scores de originalidade
- [ ] Filtros (score < X%, alto risco)
- [ ] Drill-down em cada trabalho
- [ ] Comparação visual entre trabalhos

#### Ações
- [ ] Marcar como "citação apropriada" (falso positivo)
- [ ] Solicitar explicação do aluno
- [ ] Escalar para investigação
- [ ] Gerar relatório formal

### Fase 7: Prevenção e Educação

#### Para Alunos
- [ ] Check de plágio antes de submissão (self-service)
- [ ] Dicas de citação apropriada
- [ ] Recursos sobre integridade acadêmica

#### Transparência
- [ ] Explicar como funciona a detecção
- [ ] Mostrar o que é verificado
- [ ] Oportunidade de corrigir antes de submissão final

### Fase 8: Testes e Validação
- [ ] Dataset de teste com casos conhecidos
- [ ] Validação de precision/recall
- [ ] Ajuste de thresholds
- [ ] Testes com diferentes linguagens e formatos

### Fase 9: Deploy
- [ ] Deploy serverless
- [ ] Processamento assíncrono (filas)
- [ ] Caching de embeddings
- [ ] Monitoramento de performance

---

## 🔌 Endpoints

- `POST /api/v1/plagiarism/analyze` - Analisar um trabalho
- `POST /api/v1/plagiarism/batch-analyze` - Analisar turma inteira
- `GET /api/v1/plagiarism/report/{submission_id}` - Relatório detalhado
- `GET /api/v1/plagiarism/compare/{id1}/{id2}` - Comparar 2 trabalhos
- `GET /api/v1/plagiarism/matrix/{assignment_id}` - Matriz de similaridade
- `POST /api/v1/plagiarism/mark-false-positive` - Marcar falso positivo
- `POST /api/v1/plagiarism/self-check` - Auto-verificação do aluno

---

## 📊 Database Schema

### Table: plagiarism_analyses
```
PK: analysis_id
Attributes:
  - submission_id
  - student_id
  - assignment_id
  - analyzed_at
  - originality_score (0-100)
  - status (analyzing, completed, manual_review)
```

### Table: plagiarism_matches
```
PK: match_id
Attributes:
  - analysis_id
  - match_type (intra_class, external, internet)
  - similarity_score (0-1)
  - matched_with (submission_id or URL)
  - matched_sections (JSON)
  - false_positive (boolean)
```

### Table: code_embeddings
```
PK: embedding_id
Attributes:
  - submission_id
  - code_hash
  - embedding_vector (binary)
  - created_at
```

---

## 🤖 Agente CrewAI

```python
plagiarism_detective_agent = Agent(
    role='Academic Integrity Specialist',
    goal='Detect plagiarism and promote original work',
    backstory="""You are an expert in identifying plagiarism using both 
    traditional and AI techniques. You understand the difference between 
    collaboration and copying, and between inspiration and plagiarism.""",
    tools=[
        ASTAnalysisTool(),
        CodeBERTTool(),
        SemanticSearchTool(),
        GitHubSearchTool(),
        NGramAnalysisTool(),
    ],
)
```

---

## 📈 Métricas de Qualidade

### Thresholds Sugeridos
- **Originalidade Alta**: 90-100% (verde)
- **Originalidade Aceitável**: 70-89% (amarelo)
- **Suspeito**: 50-69% (laranja)
- **Alto Risco**: 0-49% (vermelho)

### Configurável por Disciplina
- Trabalhos em grupo: thresholds mais altos permitidos
- Trabalhos individuais: thresholds mais rigorosos
- Exercícios práticos: pode ter similaridade estrutural esperada

---

## 🎯 Casos de Uso

### 1. Detecção de Cópia Literal
```
Aluno A: def soma(a, b): return a + b
Aluno B: def soma(a, b): return a + b
Similaridade: 100%
```

### 2. Detecção de Renomeação
```
Aluno A: def calcular_media(valores): return sum(valores) / len(valores)
Aluno B: def media(nums): return sum(nums) / len(nums)
Similaridade AST: 95% (estrutura idêntica, nomes diferentes)
```

### 3. Detecção de Cópia Externa
```
Aluno: [código similar a tutorial do Stack Overflow]
Match: https://stackoverflow.com/questions/12345
Similaridade: 85%
Ação: Solicitar citação apropriada
```

### 4. Paráfrase sem Citação (Texto)
```
Original (artigo): "A inteligência artificial está transformando..."
Aluno: "IA está mudando radicalmente..."
Similaridade semântica: 82%
Ação: Verificar citação
```

---

## ✅ Critérios de Aceitação

- [ ] Detecção de plágio em código (Python, Java, JS)
- [ ] Detecção de plágio em textos (PT-BR)
- [ ] Análise AST e semântica funcionando
- [ ] Busca externa (GitHub, Stack Overflow)
- [ ] Comparação intra-turma (batch)
- [ ] Relatório de originalidade com score
- [ ] Visualização de trechos copiados
- [ ] Dashboard para professores
- [ ] Self-check para alunos
- [ ] Precision > 85% (poucos falsos positivos)
- [ ] Recall > 80% (detecta a maioria dos casos)
- [ ] Performance OK (análise < 5min por trabalho)
- [ ] Deploy serverless

---

## 📚 Referências

- [CodeBERT: Pre-trained Model for Code](https://github.com/microsoft/CodeBERT)
- [Moss (Measure of Software Similarity)](http://theory.stanford.edu/~aiken/moss/)
- [JPlag - Java Plagiarism Detection](https://github.com/jplag/JPlag)
- [Turnitin Originality Check](https://www.turnitin.com/)
- [Sentence Transformers](https://www.sbert.net/)
- [Academic Integrity Resources](https://www.academicintegrity.org/)

---

## ⚠️ Considerações Éticas

### 1. Falsos Positivos
- Sistema não é 100% perfeito
- Sempre permitir revisão humana
- Aluno tem direito de explicação

### 2. Contexto Importa
- Exercícios básicos podem ter soluções similares naturalmente
- Colaboração autorizada vs cópia não autorizada
- Citações apropriadas são permitidas

### 3. Educação > Punição
- Foco em ensinar integridade acadêmica
- Oportunidade de corrigir antes de submissão final
- Recursos para aprender a citar corretamente

### 4. Privacidade
- Trabalhos de alunos são confidenciais
- Comparações apenas dentro do escopo autorizado
- LGPD compliance
