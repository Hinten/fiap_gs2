# Instruções para Colaboradores - FIAP AI-Enhanced Learning Platform

## 👋 Bem-vindo ao Projeto!

Este documento contém informações essenciais para desenvolvedores, agentes de IA e colaboradores que trabalharão neste projeto.

---

## 🎯 Visão Geral do Projeto

**FIAP AI-Enhanced Learning Platform** é uma plataforma que utiliza agentes de IA e gamificação para transformar a experiência educacional na FIAP, desenvolvida para a Global Solution 2025.2.

### Objetivo
Demonstrar como a tecnologia (especialmente IA e gamificação) pode tornar o trabalho educacional mais eficiente, inclusivo e humano.

### Conceito Principal
- **Agentes IA como Assistentes de Professores**: Automatizam tarefas repetitivas mas mantêm controle humano
- **Gamificação para Engajamento**: Aprendizado mais motivador e inclusivo
- **Transparência e Explicabilidade**: Todas decisões de IA são justificadas e aprovadas por humanos
- **Inclusão**: Suporte especial para dislexia e outras necessidades
- **Qualidade de Conteúdo**: Revisão contínua automática de materiais educacionais

---

## 🏗️ Arquitetura do Projeto

### Stack Tecnológico

#### Frontend
- **Framework**: Flutter 3.x (Dart) - Web e Mobile
- **State Management**: Riverpod / Bloc
- **UI**: Material Design 3 com tema claro/escuro
- **Charts**: fl_chart
- **Real-time**: WebSocket para chat com agentes

#### Backend
- **Linguagem**: Python 3.11+
- **Framework**: FastAPI
- **Arquitetura**: Microservices Serverless
- **Deployment**: AWS Lambda / Google Cloud Functions
- **API Style**: REST

#### Agentes de IA
- **Orquestração**: CrewAI
- **LLM Integration**: LangChain, OpenAI GPT-4 / Anthropic Claude
- **Integrações**: GitHub API, Veo3, NotebookLM, Grok, ElevenLabs

#### Machine Learning
- **Frameworks**: scikit-learn, TensorFlow (para modelos específicos)
- **NLP**: Transformers (BERT para detecção de plágio, sentiment analysis)
- **Code Analysis**: AST parsing, CodeBERT embeddings

#### Análise de Dados
- **Python**: pandas, numpy
- **R**: ggplot2, tidyverse para análises estatísticas de desempenho

#### Infraestrutura Cloud (Serverless)
- **Providers**: AWS (primário)
- **Compute**: Lambda Functions
- **API Gateway**: AWS API Gateway
- **Database**: 
  - NoSQL: DynamoDB (eventos, logs, documentos)
  - SQL: Aurora Serverless (dados relacionais, históricos)
- **Storage**: S3 para vídeos, PDFs, repos clonados
- **Messaging**: SQS (filas), SNS (notificações)

#### DevOps
- **CI/CD**: GitHub Actions
- **IaC**: Terraform ou Serverless Framework
- **Version Control**: Git + GitHub
- **Testing**: pytest (Python), flutter test (Dart)

---

## 📁 Estrutura de Pastas

```
fiap_gs2/
├── .github/
│   ├── workflows/              # GitHub Actions CI/CD
│   └── copilot-instructions.md # Este arquivo
│
├── assets/                     # Imagens, prints, recursos visuais
│
├── docs/                       # Documentação do projeto
│   ├── roadmap-overview.md
│   ├── discipline-mapping.md
│   └── delivery-guidelines.md
│
├── src/                        # Código-fonte
│   ├── apps/                   # Microservices e apps
│   │   ├── frontend_flutter/          # Frontend Flutter
│   │   ├── auth_service/              # Autenticação
│   │   ├── code_review_agent/         # Code review GitHub
│   │   ├── grading_agent/             # Correção automatizada
│   │   ├── award_methodology_agent/   # Sistema de premiação
│   │   ├── content_generator_agent/   # Geração de conteúdo
│   │   ├── research_management/       # Gestão IC
│   │   ├── gamified_exams/            # Provas gamificadas
│   │   ├── content_reviewer_agent/    # Revisão de conteúdo
│   │   └── approval_interface/        # Interface de aprovação
│   │
│   └── shared/                 # Código compartilhado (a criar)
│
├── infrastructure/             # IaC
└── .gitignore
```

---

## 🚀 Como Começar

### Pré-requisitos

#### Ferramentas Necessárias
- Git
- Python 3.11+
- Flutter SDK 3.x
- Docker (opcional)
- AWS CLI / gcloud CLI / Azure CLI (dependendo do cloud provider escolhido)
- Terraform ou Serverless Framework

#### Contas Necessárias
- GitHub (repositório)
- AWS / GCP / Azure (infraestrutura)
- OpenAI / Anthropic (para LLMs) ou usar modelos open-source

### Setup Inicial

#### 1. Clone o Repositório

```bash
git clone https://github.com/Hinten/fiap_gs2.git
cd fiap_gs2
```

#### 2. Configure Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto (NÃO commitar no Git):

```bash
# AWS Credentials (exemplo)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1

# Database
DYNAMODB_TABLE_PREFIX=symbiowork
AURORA_DB_ENDPOINT=your_db_endpoint

# API Keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# JWT Secret
JWT_SECRET_KEY=your_super_secret_key_change_this

# Frontend
FLUTTER_API_BASE_URL=http://localhost:8000  # ou URL de prod
```

#### 3. Setup Backend (Python)

Para cada microservice Python:

```bash
cd src/apps/auth_service  # ou outro serviço

# Criar ambiente virtual
python -m venv venv

# Ativar (Linux/Mac)
source venv/bin/activate
# Ativar (Windows)
venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Rodar testes
pytest

# Rodar localmente (se FastAPI)
uvicorn src.main:app --reload --port 8001
```

#### 4. Setup Frontend (Flutter)

```bash
cd src/apps/frontend_flutter

# Instalar dependências
flutter pub get

# Rodar analyzer
flutter analyze

# Rodar testes
flutter test

# Rodar app (escolher device)
flutter devices
flutter run
```

#### 5. Setup Infraestrutura (Terraform - exemplo AWS)

```bash
cd infrastructure/terraform

# Inicializar Terraform
terraform init

# Planejar mudanças
terraform plan

# Aplicar (cria recursos na AWS)
terraform apply

# Destruir (quando não precisar mais)
terraform destroy
```

---

## 💻 Desenvolvimento Local

### Emulando Serverless Localmente

#### Opção 1: LocalStack (AWS)

```bash
# Instalar LocalStack
pip install localstack

# Rodar LocalStack (simula serviços AWS)
localstack start

# Configurar AWS CLI para usar LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566
```

#### Opção 2: Functions Framework (Google Cloud)

```bash
# Instalar
pip install functions-framework

# Rodar função localmente
functions-framework --target=my_function --port=8080
```

### Docker Compose para Serviços Auxiliares

Crie `docker-compose.yml` na raiz:

```yaml
version: '3.8'

services:
  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=dynamodb,s3,sqs,lambda
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
      
  # Adicionar outros serviços conforme necessário
```

Rodar:
```bash
docker-compose up -d
```

---

## 📝 Padrões de Código

### Python

#### Style Guide
- **PEP 8** compliance
- Formatador: **black** (`black .`)
- Imports: **isort** (`isort .`)
- Linter: **flake8** ou **pylint**
- Type checking: **mypy** (opcional)

#### Exemplo de Código Python

```python
"""
Module for user authentication.

This module provides functions for user login, token generation,
and authorization checks.
"""

from typing import Optional
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException, status


def create_access_token(
    user_id: str, 
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    Create a JWT access token for a user.
    
    Args:
        user_id: The unique identifier of the user
        expires_delta: Optional custom expiration time
        
    Returns:
        Encoded JWT token as string
        
    Raises:
        ValueError: If user_id is empty
    """
    if not user_id:
        raise ValueError("user_id cannot be empty")
    
    if expires_delta is None:
        expires_delta = timedelta(hours=24)
        
    expire = datetime.utcnow() + expires_delta
    to_encode = {"sub": user_id, "exp": expire}
    
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.JWT_SECRET, 
        algorithm="HS256"
    )
    
    return encoded_jwt


# Usar type hints sempre
# Docstrings em estilo Google ou NumPy
# Logging estruturado
# Tratar erros explicitamente
```

#### Estrutura de um Microservice Python

```
service_name/
├── src/
│   ├── __init__.py
│   ├── main.py              # FastAPI app ou Lambda handler
│   ├── api/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   └── dependencies.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── services/
│   │   ├── __init__.py
│   │   └── auth_service.py
│   └── utils/
│       ├── __init__.py
│       └── config.py
├── tests/
│   ├── __init__.py
│   ├── test_api.py
│   └── test_services.py
├── requirements.txt
├── requirements-dev.txt     # Dependências de dev
├── pytest.ini
└── README.md
```

### Flutter (Dart)

#### Style Guide
- **Dart Style Guide** oficial
- Formatador: **dartfmt** (`flutter format .`)
- Analyzer: **flutter analyze**
- Linter: regras no `analysis_options.yaml`

#### Exemplo de Código Flutter

```dart
/// Service for handling wellbeing data and API calls.
class WellbeingService {
  final Dio _dio;
  final String _baseUrl;
  
  WellbeingService({
    required Dio dio,
    required String baseUrl,
  }) : _dio = dio, _baseUrl = baseUrl;
  
  /// Fetches wellbeing summary for a user.
  /// 
  /// Throws [NetworkException] if request fails.
  Future<WellbeingSummary> fetchSummary(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/v1/users/$userId/wellbeing',
      );
      
      return WellbeingSummary.fromJson(response.data);
    } on DioError catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}

// Usar widgets const quando possível
// State management: Provider/Riverpod/Bloc
// Separar lógica de UI
```

### R Scripts

#### Style Guide
- **Tidyverse Style Guide**
- Usar `<-` para atribuição
- snake_case para nomes de variáveis
- Comentários descritivos

```r
# Análise de Bem-Estar dos Usuários
# Autor: [Nome]
# Data: 2025-11-10

library(tidyverse)
library(ggplot2)

# Carregar dados
wellbeing_data <- read_csv("data/wellbeing_events.csv")

# Análise exploratória
summary_stats <- wellbeing_data %>%
  group_by(user_profile) %>%
  summarise(
    mean_stress = mean(stress_score, na.rm = TRUE),
    sd_stress = sd(stress_score, na.rm = TRUE),
    n = n()
  )

# Visualização
ggplot(summary_stats, aes(x = user_profile, y = mean_stress)) +
  geom_col(fill = "steelblue") +
  geom_errorbar(
    aes(ymin = mean_stress - sd_stress, 
        ymax = mean_stress + sd_stress),
    width = 0.2
  ) +
  theme_minimal() +
  labs(
    title = "Stress Médio por Perfil de Usuário",
    x = "Perfil",
    y = "Score de Stress"
  )
```

---

## 🧪 Testes

### Python - pytest

```python
# tests/test_auth_service.py
import pytest
from src.services.auth_service import create_access_token

def test_create_access_token_success():
    """Test that token is created successfully."""
    token = create_access_token(user_id="user-123")
    assert token is not None
    assert isinstance(token, str)
    assert len(token) > 0

def test_create_access_token_empty_user_id():
    """Test that empty user_id raises ValueError."""
    with pytest.raises(ValueError):
        create_access_token(user_id="")

# Fixtures para setup/teardown
@pytest.fixture
def mock_db():
    """Provide a mock database connection."""
    # Setup
    db = MockDatabase()
    yield db
    # Teardown
    db.close()
```

Rodar testes:
```bash
# Todos os testes
pytest

# Com cobertura
pytest --cov=src --cov-report=html

# Testes específicos
pytest tests/test_auth_service.py -v
```

### Flutter - flutter test

```dart
// test/services/wellbeing_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('WellbeingService', () {
    late WellbeingService service;
    late MockDio mockDio;
    
    setUp(() {
      mockDio = MockDio();
      service = WellbeingService(
        dio: mockDio,
        baseUrl: 'http://localhost:8000',
      );
    });
    
    test('fetchSummary returns WellbeingSummary on success', () async {
      // Arrange
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: {'stress_score': 7.5, 'risk_level': 'high'},
          statusCode: 200,
        ),
      );
      
      // Act
      final result = await service.fetchSummary('user-123');
      
      // Assert
      expect(result, isA<WellbeingSummary>());
      expect(result.stressScore, equals(7.5));
    });
  });
}
```

---

## 🔐 Segurança

### Boas Práticas

1. **Nunca commitar secrets**
   - Usar `.env` para desenvolvimento
   - AWS Secrets Manager / HashiCorp Vault para produção
   - Adicionar `.env` ao `.gitignore`

2. **Autenticação e Autorização**
   - JWT com expiração curta (15-60 min)
   - Refresh tokens para renovação
   - RBAC (Role-Based Access Control)
   - MFA quando possível

3. **Proteção de APIs**
   - Rate limiting (API Gateway)
   - CORS configurado corretamente
   - Input validation com Pydantic (Python) / validadores (Dart)
   - Sanitização de inputs (anti-XSS, SQLi)

4. **Dados Sensíveis**
   - Criptografia at rest (AES-256)
   - TLS 1.3 in transit
   - Tokenização de PII (Personally Identifiable Information)
   - LGPD/GDPR compliance

5. **Logging e Auditoria**
   - Logar ações críticas (login, mudanças de permissão)
   - Não logar secrets ou dados sensíveis
   - Usar structured logging (JSON)
   - Centralizar logs (CloudWatch, ELK)

### Checklist de Segurança

- [ ] Secrets em ambiente variables, não hardcoded
- [ ] Autenticação implementada em todos os endpoints
- [ ] Input validation em todos os inputs de usuário
- [ ] HTTPS/TLS em produção
- [ ] Rate limiting configurado
- [ ] Logs de auditoria funcionando
- [ ] Testes de segurança (OWASP Top 10)
- [ ] Dependências atualizadas (sem vulnerabilidades conhecidas)

---

## 🚀 Deploy

### CI/CD com GitHub Actions

Exemplo de workflow (`.github/workflows/deploy.yml`):

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r src/apps/auth_service/requirements.txt
          pip install pytest pytest-cov
          
      - name: Run tests
        run: |
          cd src/apps/auth_service
          pytest --cov=src --cov-report=xml
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Deploy with Terraform
        run: |
          cd infrastructure/terraform
          terraform init
          terraform apply -auto-approve
```

### Processo de Deploy

1. **Desenvolvimento**
   ```bash
   git checkout -b feature/nova-funcionalidade
   # Desenvolver
   git add .
   git commit -m "feat: adiciona nova funcionalidade"
   git push origin feature/nova-funcionalidade
   ```

2. **Pull Request**
   - Criar PR no GitHub
   - CI roda testes automaticamente
   - Code review por outro membro
   - Merge após aprovação

3. **Deploy Automático**
   - Merge para `main` trigga deploy
   - GitHub Actions executa pipeline
   - Deploy para ambiente de staging primeiro
   - Após validação, deploy para produção

---

## 🐛 Troubleshooting

### Problemas Comuns

#### Python: ModuleNotFoundError
```bash
# Certificar que está no virtualenv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Reinstalar dependências
pip install -r requirements.txt
```

#### Flutter: Package not found
```bash
# Limpar cache
flutter clean

# Reinstalar dependências
flutter pub get

# Se ainda não funcionar
flutter pub cache repair
```

#### AWS: Credentials not configured
```bash
# Configurar AWS CLI
aws configure

# Ou exportar variáveis
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

#### Cold Start em Lambda
- **Problema**: Primeira requisição lenta
- **Solução**: 
  - Provisioned concurrency (custa mais)
  - Scheduled warm-up (CloudWatch Events)
  - Otimizar tamanho do deployment package

---

## 📚 Recursos Úteis

### Documentação Oficial
- [FastAPI](https://fastapi.tiangolo.com/)
- [Flutter](https://docs.flutter.dev/)
- [CrewAI](https://docs.crewai.com/)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [Terraform](https://www.terraform.io/docs)

### Tutoriais e Guias
- [Building Serverless Apps with AWS](https://aws.amazon.com/serverless/)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [LangChain Documentation](https://python.langchain.com/)

### Comunidade
- GitHub Issues deste repositório
- Stack Overflow
- Discord/Slack do grupo (criar se necessário)

---

## 🤝 Workflow de Colaboração

### Branching Strategy

```
main (produção)
  ├── develop (integração)
  │   ├── feature/auth-service
  │   ├── feature/wellbeing-ml
  │   ├── feature/frontend-dashboard
  │   └── bugfix/login-error
  └── hotfix/critical-security-patch
```

### Convenções de Commit

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona modelo LSTM para previsão de stress
fix: corrige erro de autenticação no login
docs: atualiza README com instruções de setup
test: adiciona testes para wellbeing_service
refactor: reorganiza estrutura de pastas
chore: atualiza dependências do projeto
```

### Code Review Checklist

Revisor deve verificar:
- [ ] Código segue padrões do projeto
- [ ] Testes estão incluídos e passando
- [ ] Sem secrets hardcoded
- [ ] Documentação/comentários adequados
- [ ] Sem breaking changes não documentados
- [ ] Performance considerada
- [ ] Segurança revisada

---

## 🎯 Próximos Passos

### Para Novos Colaboradores

1. **Ler documentação completa**
   - Este arquivo
   - `docs/roadmap-overview.md`
   - `docs/discipline-mapping.md`
   - Roadmap do app que vai trabalhar

2. **Setup ambiente local**
   - Instalar ferramentas
   - Configurar credenciais
   - Rodar um serviço localmente

3. **Escolher uma task**
   - Ver issues do GitHub
   - Ou consultar roadmaps dos apps
   - Comunicar ao time qual task vai pegar

4. **Desenvolver e testar**
   - Criar branch
   - Desenvolver feature
   - Adicionar testes
   - Testar localmente

5. **Abrir PR e revisar**
   - Criar Pull Request
   - Aguardar code review
   - Fazer ajustes se necessário
   - Merge!

### Para Agentes de IA

Se você é um agente de IA (como Copilot) trabalhando neste projeto:

1. **Priorize os roadmaps** em `src/apps/<app_name>/roadmap.md`
2. **Siga os padrões de código** descritos neste documento
3. **Adicione testes** para qualquer código novo
4. **Documente** decisões importantes
5. **Considere segurança** em todas as implementações
6. **Integre disciplinas** conforme `docs/discipline-mapping.md`

---

## ❓ FAQ

**P: Qual cloud provider usar?**  
R: AWS é recomendado (mais maduro para serverless), mas GCP e Azure também funcionam.

**P: Preciso implementar tudo nos roadmaps?**  
R: Para a GS, implemente o MVP mínimo que demonstre integração de disciplinas. Features avançadas são opcionais.

**P: Posso usar outros frameworks além dos sugeridos?**  
R: Sim, mas justifique a escolha e atualize esta documentação.

**P: Como testar localmente sem gastar na cloud?**  
R: Use LocalStack (AWS), emuladores (GCP), ou LocalStack equivalente (Azure).

**P: Dados simulados são aceitos?**  
R: Sim! A GS é uma POC. Dados reais são um plus, mas simulações bem feitas são adequadas.

**P: Quanto tempo leva para implementar tudo?**  
R: MVP básico: 4-6 semanas com equipe de 3-5 pessoas trabalhando ~10h/semana cada.

---

## 📞 Contatos

### Mantenedores do Projeto
[Adicionar nomes e contatos dos membros do grupo]

### Professores Orientadores
[Adicionar contatos se aplicável]

---

## 📄 Licença

Este projeto é uma Prova de Conceito para fins educacionais (Global Solution FIAP 2025.2).

---

**Última atualização**: 2025-11-10  
**Versão**: 1.0

**Boa codificação! 🚀**
