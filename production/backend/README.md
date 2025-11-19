# Unified Backend - FIAP AI-Enhanced Learning Platform

Backend unificado integrando todos os microserviços implementados do MVP.

## 🚀 Serviços Integrados

### ✅ Implementados e Ativos

1. **Research Management System** (`/api/v1/research/*`)
   - Gestão de projetos de iniciação científica
   - Dashboards para coordenadores, orientadores e alunos
   - Sistema de alertas automatizado
   - Tracking de progresso

2. **Content Reviewer Agent** (`/api/v1/content-review/*`)
   - Revisão automatizada de conteúdo educacional
   - Verificação de fontes
   - Detecção de erros
   - Sugestões de atualização

3. **Auth Service** (compartilhado)
   - Autenticação Firebase
   - Middleware de autorização
   - RBAC (Role-Based Access Control)

## 📦 Instalação

### Requisitos

- Python 3.11+
- Firebase project configurado
- Packages instalados em modo editável

### Setup

```bash
cd production/backend

# Criar ambiente virtual
python -m venv .venv
source .venv/bin/activate  # No Windows: .venv\Scripts\activate

# Instalar packages individuais primeiro (em modo editável)
cd ../../packages/auth_service && pip install -e ".[dev]" && cd ../../production/backend
cd ../../packages/research_management && pip install -e ".[dev]" && cd ../../production/backend
cd ../../packages/content_reviewer_agent && pip install -e ".[dev]" && cd ../../production/backend

# Instalar dependências do backend unificado
pip install -e ".[dev]"
```

## ⚙️ Configuração

Crie um arquivo `.env` na raiz do backend:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_BASE64=your_base64_encoded_credentials
# OU
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Firebase Emulator (para desenvolvimento local)
FIRESTORE_EMULATOR_HOST=localhost:8080
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099

# API Configuration
API_VERSION=v1

# Content Reviewer Agent (OpenAI/Anthropic)
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
```

## 🏃 Executando

### Modo Desenvolvimento

```bash
# Ativar ambiente virtual
source .venv/bin/activate

# Executar com hot-reload
python main.py

# OU
uvicorn main:app --reload --port 8000
```

### Modo Produção

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## 📚 Documentação da API

Após iniciar o servidor, acesse:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

## 🧪 Testes

```bash
# Todos os testes
pytest

# Com coverage
pytest --cov=. --cov-report=html

# Testes específicos
pytest tests/test_integration.py -v
```

## 📂 Estrutura

```
production/backend/
├── main.py              # Aplicação unificada FastAPI
├── pyproject.toml       # Dependências e configuração
├── README.md           # Esta documentação
├── .env                # Variáveis de ambiente (não commitado)
├── .env.example        # Template de variáveis
└── tests/              # Testes de integração
    └── test_integration.py
```

## 🔗 Endpoints Principais

### Research Management

- `GET /api/v1/research/projects` - Listar projetos
- `POST /api/v1/research/projects` - Criar projeto
- `GET /api/v1/research/dashboard/coordinator` - Dashboard coordenador
- `GET /api/v1/research/alerts` - Sistema de alertas

### Content Review

- `POST /api/v1/content-review/review` - Revisar conteúdo
- `GET /api/v1/content-review/health` - Status do agente

## 🐛 Troubleshooting

### Erro: "Module not found: auth_service"
```bash
# Instale os packages em modo editável
cd ../../packages/auth_service && pip install -e . && cd ../../production/backend
```

### Erro: "Firebase initialization failed"
```bash
# Verifique as credenciais do Firebase
echo $FIREBASE_PROJECT_ID
# Configure o emulador para desenvolvimento local
export FIRESTORE_EMULATOR_HOST=localhost:8080
```

## 📝 Desenvolvimento

### Linting

```bash
# Formatar código
black .
isort .

# Verificar qualidade
flake8 .
mypy .
```

## 🚧 Roadmap

### ⏳ Próximos Serviços a Integrar

- [ ] Code Review Agent (GitHub integration)
- [ ] Grading Agent (Automated assessment)
- [ ] Award Methodology Agent (Transparent awards)
- [ ] Plagiarism Detection Agent
- [ ] AI Usage Detection Agent
- [ ] Mental Health Agent
- [ ] Content Generator Agent

## 📄 Licença

Este projeto é uma Prova de Conceito (POC) desenvolvida para o desafio Global Solution da FIAP 2025.2.
