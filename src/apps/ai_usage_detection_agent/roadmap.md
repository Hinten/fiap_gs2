# AI Usage Detection Agent - Roadmap

## 🤖 Visão Geral

Agente de IA que detecta uso excessivo ou inadequado de ferramentas de IA (ChatGPT, Copilot, etc.) em trabalhos acadêmicos, promovendo uso ético e aprendizado genuíno.

### Responsabilidades
- Detectar textos gerados por LLMs (ChatGPT, GPT-4, Claude, etc.)
- Identificar código gerado por ferramentas de IA (GitHub Copilot, Tabnine)
- Analisar padrões de uso (adequado vs excessivo)
- Promover uso ético e educacional de IA
- Distinguir entre auxílio apropriado e substituição completa

---

## 🎯 Funcionalidades

### 1. Detecção de Texto Gerado por IA
- **Análise Estatística**:
  - Perplexity e burstiness (variação de complexidade)
  - Padrões típicos de LLMs
  - Consistência de estilo
- **Classificadores ML**:
  - Modelos treinados para detectar GPT-generated text
  - OpenAI Classifier (API)
  - GPTZero, Originality.ai (se APIs disponíveis)
- **Análise Linguística**:
  - Vocabulário incomum para o nível do aluno
  - Formalidade excessiva
  - Estruturas de frase muito perfeitas

### 2. Detecção de Código Gerado por IA
- **Padrões de Copilot/LLM**:
  - Comentários típicos gerados por IA
  - Estilos de código muito genéricos
  - Nomes de variáveis extremamente descritivos
  - Estruturas "textbook perfect"
- **Análise Contextual**:
  - Código muito avançado para o nível do aluno
  - Uso de bibliotecas/patterns não ensinados
  - Inconsistência com trabalhos anteriores
- **Temporal Analysis**:
  - Tempo de desenvolvimento muito rápido
  - Commits em blocos grandes vs incrementais

### 3. Análise de Padrões de Uso
- **Uso Adequado** (🟢 Permitido):
  - IA como ferramenta de pesquisa
  - Debugging assistido
  - Explicação de conceitos
  - Refatoração com compreensão
- **Uso Questionável** (🟡 Revisar):
  - Código gerado mas modificado/entendido
  - Auxílio significativo mas com aprendizado
- **Uso Inadequado** (🔴 Não Permitido):
  - Cópia direta sem compreensão
  - Trabalho inteiro gerado por IA
  - Zero esforço/aprendizado do aluno

### 4. Verificação de Compreensão
- **Perguntas Adaptativas**:
  - Se alto score de IA, solicitar explicação
  - Perguntas sobre o código/texto submetido
  - Quiz rápido sobre conceitos usados
- **Vídeo Explicativo** (Opcional):
  - Aluno explica o trabalho em vídeo curto
  - Análise de compreensão genuína

---

## 📋 Tarefas de Implementação

### Fase 1: Detecção de Texto Gerado por IA

#### Integração com Detectores Existentes
- [ ] **OpenAI Text Classifier** (se disponível):
  - API call para classificação
  - Score de probabilidade (0-1)
- [ ] **GPTZero API** (comercial):
  - Detecção especializada
  - Métricas: perplexity, burstiness
- [ ] **Custom Classifier**:
  - Treinar modelo próprio
  - Dataset: textos reais de alunos vs GPT-generated
  - Features: perplexity, sentence length variance, vocabulary richness

#### Análise Estatística
```python
def analyze_text_patterns(text):
    """
    Detecta padrões típicos de LLMs
    """
    features = {
        'perplexity': calculate_perplexity(text),
        'burstiness': calculate_burstiness(text),  # variação complexidade
        'avg_sentence_length': avg_sentence_length(text),
        'vocabulary_richness': len(set(words)) / len(words),
        'formality_score': calculate_formality(text),
        'transitional_phrases': count_transitions(text),  # "Furthermore", "Moreover"
    }
    
    # Score de probabilidade de ser gerado por IA
    ai_probability = classifier.predict(features)
    return ai_probability
```

#### Análise Contextual
- [ ] Comparar com trabalhos anteriores do aluno
- [ ] Detectar mudança súbita de estilo/qualidade
- [ ] Identificar vocabulário inconsistente com nível

### Fase 2: Detecção de Código Gerado por IA

#### Padrões de Código IA
```python
AI_CODE_PATTERNS = {
    'copilot_comments': [
        '# Function to ...',
        '# This function ...',
        '# Returns: ...',
        '"""This function calculates..."""'  # muito formal
    ],
    'generic_names': [
        'calculate_result',
        'process_data',
        'handle_request',
        'get_information'
    ],
    'perfect_structure': {
        'error_handling': 'comprehensive try-except',
        'type_hints': 'all functions typed',
        'docstrings': 'all functions documented',
    }
}
```

#### Análise de Commits (Git)
- [ ] Integração com histórico Git
- [ ] Análise de padrão de commits:
  - Incremental (humano) vs bulk (IA?)
  - Tempo entre commits
  - Tamanho de cada commit
- [ ] Comparação de timestamps vs complexidade

#### Análise de Complexidade
- [ ] Código muito avançado para o nível:
  - Design patterns não ensinados
  - Bibliotecas não mencionadas no curso
  - Otimizações prematuras
  - Abstrações excessivas

### Fase 3: Scoring e Classificação

#### AI Usage Score (0-100)
```python
def calculate_ai_usage_score(submission):
    """
    0-30: Uso mínimo/nenhum (verde)
    31-60: Uso moderado (amarelo)
    61-80: Uso significativo (laranja)
    81-100: Uso excessivo/provável cópia (vermelho)
    """
    scores = {
        'text_ai_probability': 0.0,
        'code_ai_probability': 0.0,
        'style_inconsistency': 0.0,
        'complexity_mismatch': 0.0,
        'temporal_anomaly': 0.0,
    }
    
    # Weighted average
    weights = [0.3, 0.3, 0.2, 0.1, 0.1]
    final_score = sum(s * w for s, w in zip(scores.values(), weights))
    
    return final_score * 100
```

#### Categorização
- 🟢 **Apropriado** (0-30): IA como ferramenta de apoio
- 🟡 **Moderado** (31-60): Uso significativo mas aceitável
- 🟠 **Questionável** (61-80): Requer verificação de compreensão
- 🔴 **Inadequado** (81-100): Provável cópia completa

### Fase 4: Verificação de Compreensão

#### Perguntas Automáticas
- [ ] Geração de perguntas sobre o trabalho:
  ```python
  questions = generate_comprehension_questions(submission)
  # Ex: "Explique o que faz a função X"
  #     "Por que você escolheu usar a biblioteca Y?"
  #     "O que acontece se o input for Z?"
  ```
- [ ] Quiz adaptativo:
  - Se score alto, perguntas mais difíceis
  - 3-5 perguntas sobre conceitos-chave

#### Vídeo Explicativo (Opcional)
- [ ] Solicitar vídeo de 2-3 minutos explicando o trabalho
- [ ] Análise automática (opcional):
  - Speech-to-text
  - Detecção de hesitações
  - Uso de vocabulário técnico apropriado

### Fase 5: Educação e Transparência

#### Para Alunos
- [ ] Guia de uso ético de IA:
  - O que é permitido
  - O que não é permitido
  - Como citar uso de IA
  - Exemplos de bom uso
- [ ] Self-check antes de submissão
- [ ] Oportunidade de corrigir

#### Declaração de Uso de IA
- [ ] Checkbox na submissão:
  - "Eu usei ferramentas de IA neste trabalho" (Sim/Não)
  - Se sim: "Descreva como e para quê"
- [ ] Honestidade é valorizada
- [ ] Penalização maior para não declarar

### Fase 6: Políticas e Diretrizes

#### Definir Políticas Claras
- [ ] Quando IA é permitida:
  - Pesquisa e exploração
  - Debugging e troubleshooting
  - Explicação de conceitos
  - Refatoração (com compreensão)
- [ ] Quando IA NÃO é permitida:
  - Gerar trabalho completo
  - Copiar código sem compreender
  - Escrever textos inteiros
  - Substituir aprendizado

#### Consequências
- [ ] **1ª Detecção** (score 61-80):
  - Conversa educativa
  - Verificação de compreensão
  - Oportunidade de refazer
- [ ] **2ª Detecção ou Score > 80**:
  - Nota reduzida
  - Trabalho substituto obrigatório
  - Possível escalação para comitê de ética

### Fase 7: Dashboard e Relatórios

#### Para Professores
- [ ] Lista de trabalhos com AI usage scores
- [ ] Filtros (score > X)
- [ ] Drill-down em cada trabalho:
  - Trechos destacados
  - Justificativa do score
  - Histórico do aluno
- [ ] Ações:
  - Solicitar verificação de compreensão
  - Marcar como falso positivo
  - Aplicar consequências

#### Para Coordenadores
- [ ] Métricas agregadas:
  - % de trabalhos com uso de IA
  - Tendências ao longo do tempo
  - Comparação entre turmas
- [ ] Insights para políticas

### Fase 8: Testes e Calibração
- [ ] Dataset de teste:
  - Trabalhos 100% gerados por IA
  - Trabalhos com auxílio moderado de IA
  - Trabalhos sem uso de IA
- [ ] Validação de precision/recall
- [ ] Ajuste de thresholds
- [ ] Redução de falsos positivos

### Fase 9: Deploy
- [ ] Deploy serverless
- [ ] Processamento assíncrono
- [ ] Caching de análises
- [ ] Monitoramento

---

## 🔌 Endpoints

- `POST /api/v1/ai-detection/analyze` - Analisar trabalho
- `GET /api/v1/ai-detection/report/{submission_id}` - Relatório detalhado
- `POST /api/v1/ai-detection/verify-comprehension` - Gerar perguntas
- `POST /api/v1/ai-detection/submit-answers` - Submeter respostas do quiz
- `GET /api/v1/ai-detection/guidelines` - Diretrizes de uso de IA
- `POST /api/v1/ai-detection/declare-usage` - Declarar uso de IA
- `GET /api/v1/ai-detection/dashboard` - Dashboard para professores

---

## 📊 Database Schema

### Table: ai_usage_analyses
```
PK: analysis_id
Attributes:
  - submission_id
  - student_id
  - analyzed_at
  - ai_usage_score (0-100)
  - category (appropriate, moderate, questionable, inadequate)
  - text_ai_probability
  - code_ai_probability
  - flags (List: style_inconsistency, complexity_mismatch, etc)
```

### Table: ai_usage_declarations
```
PK: declaration_id
Attributes:
  - submission_id
  - student_id
  - declared_usage (boolean)
  - usage_description (text)
  - declared_at
```

### Table: comprehension_verifications
```
PK: verification_id
Attributes:
  - submission_id
  - student_id
  - questions (JSON)
  - answers (JSON)
  - score (0-100)
  - passed (boolean)
  - timestamp
```

---

## 🤖 Agente CrewAI

```python
ai_usage_detector_agent = Agent(
    role='AI Usage Ethics Specialist',
    goal='Detect inappropriate AI usage while promoting ethical learning',
    backstory="""You understand that AI tools can be valuable learning aids 
    when used appropriately, but harmful when they replace genuine learning. 
    You promote ethical use and critical thinking.""",
    tools=[
        TextClassifierTool(),
        CodeAnalysisTool(),
        StyleConsistencyTool(),
        ComprehensionQuestionGenerator(),
    ],
)
```

---

## 📈 Exemplos de Detecção

### Exemplo 1: Texto Gerado por ChatGPT
```
Input: "Artificial Intelligence is a transformative technology that has 
revolutionized numerous sectors. Furthermore, it presents unprecedented 
opportunities for innovation. Moreover, the integration of AI systems..."

Analysis:
- Perplexity: Very low (too perfect)
- Burstiness: Low (uniform complexity)
- Transitional phrases: High ("Furthermore", "Moreover")
- Formality: Excessively high
AI Score: 85% (High probability)
```

### Exemplo 2: Código Copilot
```python
def calculate_fibonacci_sequence(n: int) -> List[int]:
    """
    This function calculates the Fibonacci sequence up to n terms.
    
    Args:
        n (int): The number of terms to generate
        
    Returns:
        List[int]: A list containing the Fibonacci sequence
        
    Raises:
        ValueError: If n is less than 1
    """
    if n < 1:
        raise ValueError("n must be at least 1")
    
    sequence = [0, 1]
    for i in range(2, n):
        sequence.append(sequence[i-1] + sequence[i-2])
    
    return sequence[:n]

Analysis:
- Perfect docstring (unusual for beginner)
- Comprehensive error handling
- Type hints
- Formal variable names
- Textbook structure
AI Score: 78% (High probability)
```

### Exemplo 3: Uso Apropriado
```python
# Usei ChatGPT para entender o algoritmo de Fibonacci
# e então implementei minha própria versão

def fib(n):
    # comecei com dois numeros
    a, b = 0, 1
    resultado = []
    
    # loop ate n vezes
    for _ in range(n):
        resultado.append(a)
        a, b = b, a + b  # essa parte foi complicada, mas entendi!
    
    return resultado

Analysis:
- Comments in student's style
- Less formal
- Some imperfections (normal)
- Declaration of AI usage
AI Score: 25% (Appropriate usage)
```

---

## ✅ Critérios de Aceitação

- [ ] Detecção de texto gerado por LLMs (precision > 80%)
- [ ] Detecção de código gerado por IA
- [ ] AI usage score calculado e categorizado
- [ ] Sistema de verificação de compreensão
- [ ] Diretrizes claras para alunos
- [ ] Declaração de uso de IA implementada
- [ ] Dashboard para professores
- [ ] Métricas agregadas para coordenadores
- [ ] Políticas de consequências definidas
- [ ] Testes de calibração OK
- [ ] Falsos positivos < 15%
- [ ] Deploy serverless

---

## 📚 Referências

- [GPTZero - AI Content Detector](https://gptzero.me/)
- [OpenAI AI Text Classifier](https://platform.openai.com/ai-text-classifier)
- [Detecting LLM-Generated Text](https://arxiv.org/abs/2301.11305)
- [Academic Integrity in the Age of AI](https://er.educause.edu/articles/2023/3/academic-integrity-in-the-age-of-generative-ai)
- [GitHub Copilot Academic Research](https://github.blog/2022-09-07-research-quantifying-github-copilots-impact-on-code-quality/)

---

## ⚠️ Considerações Éticas

### 1. Não Demonizar IA
- IA é ferramenta, não inimiga
- Ensinar uso ético, não proibir completamente
- Foco em aprendizado, não punição

### 2. Transparência
- Explicar como funciona a detecção
- Alunos devem saber o que é verificado
- Honestidade deve ser recompensada

### 3. Falibilidade
- Sistema não é 100% preciso
- Sempre permitir contestação
- Revisão humana final

### 4. Evolução das Políticas
- Políticas devem evoluir com a tecnologia
- Feedback contínuo de alunos e professores
- Adaptação às novas ferramentas de IA

### 5. Foco no Aprendizado
- Objetivo: promover aprendizado genuíno
- IA pode ser aliada se usada corretamente
- Desenvolver pensamento crítico sobre uso de IA
