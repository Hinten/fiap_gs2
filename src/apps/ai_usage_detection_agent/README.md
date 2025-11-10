# AI Usage Detection Agent

🤖 Agente de IA para detectar uso inadequado de ferramentas de IA em trabalhos acadêmicos, promovendo uso ético e aprendizado genuíno.

## 📋 Visão Geral

O **AI Usage Detection Agent** analisa submissões acadêmicas (texto e código) para identificar quando estudantes podem estar usando ferramentas de IA (ChatGPT, Copilot, etc.) de forma inadequada. O objetivo não é punir, mas promover uso ético e garantir aprendizado genuíno.

### Funcionalidades Principais

- ✅ **Detecção de Texto Gerado por IA**: Análise estatística de padrões típicos de LLMs
- ✅ **Detecção de Código Gerado por IA**: Identificação de padrões de Copilot e outros geradores
- ✅ **Scoring e Categorização**: Score de 0-1 com categorias claras
- ✅ **Explicabilidade**: Todas as análises incluem justificativas detalhadas
- ✅ **Diretrizes Claras**: Guias para estudantes sobre uso apropriado de IA

## 🏗️ Arquitetura

### Stack Tecnológico

- **Framework**: FastAPI (Python 3.11+)
- **Análise de Texto**: Análise estatística customizada (perplexity, burstiness)
- **Análise de Código**: Pattern matching e análise estrutural
- **Validação**: Pydantic para dados
- **Testing**: pytest com >80% coverage
- **Deployment**: Serverless-ready (AWS Lambda)

### Estrutura do Projeto

```
ai_usage_detection_agent/
├── src/
│   ├── api/                    # FastAPI routes
│   │   └── routes.py
│   ├── models/                 # Pydantic models
│   │   └── schemas.py
│   ├── services/               # Core business logic
│   │   ├── text_analyzer.py
│   │   ├── code_analyzer.py
│   │   └── detection_service.py
│   ├── utils/                  # Configuration and logging
│   │   ├── config.py
│   │   └── logger.py
│   └── main.py                 # FastAPI app
├── tests/                      # Comprehensive tests
│   ├── test_text_analyzer.py
│   ├── test_code_analyzer.py
│   ├── test_detection_service.py
│   └── test_api.py
├── requirements.txt
├── requirements-dev.txt
├── pytest.ini
└── README.md
```

## 🚀 Instalação e Setup

### Pré-requisitos

- Python 3.11+
- pip ou poetry

### Instalação

```bash
# Clone o repositório
cd src/apps/ai_usage_detection_agent

# Crie ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Instale dependências
pip install -r requirements.txt

# Para desenvolvimento
pip install -r requirements-dev.txt
```

### Configuração

Crie arquivo `.env` na raiz do projeto:

```env
# API Configuration
DEBUG=true
HOST=0.0.0.0
PORT=8002

# Detection Thresholds
AI_USAGE_THRESHOLD_MODERATE=0.30
AI_USAGE_THRESHOLD_QUESTIONABLE=0.60
AI_USAGE_THRESHOLD_INADEQUATE=0.80

# Feature Weights
TEXT_AI_WEIGHT=0.30
CODE_AI_WEIGHT=0.30

# Logging
LOG_LEVEL=INFO
```

## 💻 Uso

### Iniciar o Servidor

```bash
# Modo desenvolvimento (com reload)
python -m uvicorn src.main:app --reload --port 8002

# Ou usando o script principal
python src/main.py
```

O servidor estará disponível em `http://localhost:8002`

### Documentação da API

Acesse a documentação interativa:
- Swagger UI: `http://localhost:8002/docs`
- ReDoc: `http://localhost:8002/redoc`

### Exemplos de Uso

#### 1. Analisar uma Submissão de Texto

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-001",
    "student_id": "student-123",
    "content": "Este é meu trabalho sobre IA...",
    "submission_type": "text"
  }'
```

#### 2. Analisar Código

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-002",
    "student_id": "student-123",
    "content": "def fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n-1) + fibonacci(n-2)",
    "submission_type": "code"
  }'
```

#### 3. Obter Diretrizes

```bash
curl "http://localhost:8002/api/v1/ai-detection/guidelines"
```

#### 4. Declarar Uso de IA

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/declare-usage" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-001",
    "student_id": "student-123",
    "declared_usage": true,
    "usage_description": "Usei ChatGPT para entender o algoritmo"
  }'
```

## 🧪 Testes

### Executar Todos os Testes

```bash
pytest
```

### Com Cobertura

```bash
pytest --cov=src --cov-report=html
```

### Testes Específicos

```bash
# Testar apenas text analyzer
pytest tests/test_text_analyzer.py

# Testar apenas API
pytest tests/test_api.py -v
```

### Cobertura Esperada

O projeto possui >80% de cobertura de testes:
- ✅ Text Analyzer: ~95%
- ✅ Code Analyzer: ~95%
- ✅ Detection Service: ~90%
- ✅ API Routes: ~85%

## 📊 Como Funciona

### Detecção de Texto

O analisador de texto calcula várias métricas:

1. **Perplexity**: Quão previsível é o texto
   - Baixa perplexity = texto muito perfeito (suspeito)
   
2. **Burstiness**: Variação na complexidade das sentenças
   - Baixa burstiness = uniformidade suspeita
   
3. **Formality Score**: Nível de formalidade
   - Alta formalidade = pode ser IA
   
4. **Transitional Phrases**: Frases de transição típicas de IA
   - "Furthermore", "Moreover", "Consequently", etc.

### Detecção de Código

O analisador de código verifica:

1. **Docstrings Perfeitas**: Todas as funções documentadas (raro em estudantes)
2. **Type Hints**: Todas as funções com tipos (incomum)
3. **Error Handling**: Try-except em excesso
4. **Nomes Genéricos**: `calculate_result`, `process_data`, etc.
5. **Comentários Formais**: "Function to...", "This function..."

### Categorização

| Score | Categoria | Descrição | Ação |
|-------|-----------|-----------|------|
| 0-30% | 🟢 Apropriado | Uso mínimo/adequado | Nenhuma |
| 31-60% | 🟡 Moderado | Uso significativo mas aceitável | Revisar |
| 61-80% | 🟠 Questionável | Requer verificação | Verificar compreensão |
| 81-100% | 🔴 Inadequado | Provável cópia | Re-submissão obrigatória |

## 🔒 Considerações de Segurança

- ✅ Validação de entrada com Pydantic
- ✅ Logging estruturado (sem PII)
- ✅ Rate limiting (configurar no API Gateway)
- ✅ HTTPS obrigatório em produção

## 🚢 Deploy

### Serverless (AWS Lambda)

```bash
# Instalar Serverless Framework
npm install -g serverless

# Deploy
serverless deploy --stage prod
```

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ ./src/
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8002"]
```

## 📝 Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/api/v1/ai-detection/analyze` | Analisar submissão |
| GET | `/api/v1/ai-detection/report/{id}` | Obter relatório detalhado |
| GET | `/api/v1/ai-detection/guidelines` | Diretrizes de uso ético |
| POST | `/api/v1/ai-detection/declare-usage` | Declarar uso de IA |
| GET | `/api/v1/ai-detection/health` | Health check |

## 🤝 Contribuindo

### Estilo de Código

- **Python**: PEP 8, black formatter, type hints obrigatórios
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`)
- **Testes**: Escrever testes para novos recursos

### Rodando Linters

```bash
# Format
black .

# Sort imports
isort .

# Lint
flake8 .
```

## 📚 Referências

- [Roadmap Completo](./roadmap.md)
- [Developer Guide](../../../docs/developer-guide.md)
- [GPTZero - AI Content Detector](https://gptzero.me/)
- [Detecting LLM-Generated Text](https://arxiv.org/abs/2301.11305)

## ⚠️ Limitações

1. **Não é 100% Preciso**: Falsos positivos e negativos podem ocorrer
2. **Detecção Heurística**: Não usa modelos ML treinados (por simplicidade inicial)
3. **Contexto Limitado**: Não considera histórico do aluno
4. **Sem Git Analysis**: Não analisa padrões de commits (ainda)

## 🗺️ Roadmap

- [ ] Integrar com OpenAI Classifier API
- [ ] Análise temporal de commits Git
- [ ] Comparação com trabalhos anteriores
- [ ] Sistema de perguntas de verificação automatizadas
- [ ] Dashboard para professores
- [ ] Métricas agregadas
- [ ] Integração com LMS

## 📄 Licença

Este projeto faz parte da FIAP Global Solution 2025.2

## 👥 Autores

Desenvolvido para o projeto FIAP AI-Enhanced Learning Platform

---

**Status**: ✅ MVP Implementado | **Versão**: 1.0.0 | **Última Atualização**: 2025-11-10
