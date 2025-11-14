# Python Packages

Este diretório contém todos os pacotes Python do projeto FIAP AI-Enhanced Learning Platform. Cada pacote é independente e pode ser instalado separadamente.

## 📦 Pacotes Disponíveis

### ✅ Implementados e Funcionais

#### Serviços Backend
- ✅ **[auth_service](./auth_service)** - Serviço de autenticação e autorização com Firebase
  - Firebase Admin SDK, FastAPI middleware, RBAC, Multi-tenant
  - 6 módulos Python, 10 testes unitários
  - [README](./auth_service/README.md) | [CHANGELOG](./auth_service/CHANGELOG.md)

#### Agentes de IA
- ✅ **[content_reviewer_agent](./content_reviewer_agent)** - Agente para revisão contínua de conteúdo
  - Fact-checking, validação de fontes, detecção de desatualização
  - 18 módulos Python implementados
  - [README](./content_reviewer_agent/README.md) | [Roadmap](./content_reviewer_agent/roadmap.md)

### 📋 Planejados (Roadmap Disponível)

#### Serviços Backend
- 📋 **[research_management](./research_management)** - Sistema de gestão de iniciação científica

#### Agentes de IA
- 📋 **[code_review_agent](./code_review_agent)** - Agente para análise inteligente de código via GitHub API
- 📋 **[grading_agent](./grading_agent)** - Agente para correção automatizada com feedback personalizado
- 📋 **[award_methodology_agent](./award_methodology_agent)** - Agente para metodologias de premiação transparentes
- 📋 **[content_generator_agent](./content_generator_agent)** - Agente para geração de conteúdo educacional (vídeos, podcasts)
- 📋 **[mental_health_agent](./mental_health_agent)** - Agente para monitoramento de saúde mental
- 📋 **[plagiarism_detection_agent](./plagiarism_detection_agent)** - Agente para detecção de plágio em código e texto
- 📋 **[ai_usage_detection_agent](./ai_usage_detection_agent)** - Agente para detecção de uso excessivo de ferramentas de IA

## 🚀 Instalação

### Instalar um Pacote Específico

Para desenvolvimento local, instale em modo editável:

```bash
# Da raiz do projeto
pip install -e packages/auth_service

# Ou com dependências de desenvolvimento
pip install -e "packages/auth_service[dev]"
```

### Instalar Múltiplos Pacotes

```bash
# Instalar vários pacotes de uma vez
pip install -e packages/auth_service
pip install -e packages/code_review_agent
pip install -e packages/grading_agent
```

### Instalação em Ambiente Virtual

```bash
# Criar ambiente virtual (recomendado)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Instalar pacote
pip install -e "packages/auth_service[dev]"
```

## 🏗️ Estrutura de um Pacote

Cada pacote segue a seguinte estrutura:

```
package_name/
├── src/
│   └── package_name/        # Código fonte instalável
│       ├── __init__.py
│       ├── main.py          # Ponto de entrada
│       ├── api/             # Rotas e endpoints
│       ├── models/          # Modelos Pydantic
│       ├── services/        # Lógica de negócio
│       └── repositories/    # Acesso a dados
├── tests/                   # Testes unitários
│   ├── test_api.py
│   └── test_services.py
├── pyproject.toml           # Metadados e dependências
├── README.md                # Documentação do pacote
└── roadmap.md               # Roadmap de implementação
```

## 🧪 Testes

Para rodar testes de um pacote:

```bash
cd packages/auth_service
pytest

# Com cobertura
pytest --cov=src --cov-report=html

# Testes específicos
pytest tests/test_api.py -v
```

## 🎨 Formatação e Linting

```bash
cd packages/auth_service

# Formatar código
black .
isort .

# Verificar qualidade
flake8 .
mypy src
```

## 🔗 Dependências Entre Pacotes

Para usar um pacote como dependência de outro, adicione ao `pyproject.toml`:

```toml
[project]
dependencies = [
    "auth-service @ file:///absolute/path/to/packages/auth_service",
]
```

Ou para desenvolvimento local, use editable installs:

```bash
pip install -e packages/auth_service
pip install -e packages/code_review_agent
```

## 📚 Documentação

Cada pacote possui sua própria documentação:
- `README.md` - Visão geral e instruções de uso
- `roadmap.md` - Roadmap detalhado de implementação
- Docstrings no código seguindo o padrão Google/NumPy

## 🛠️ Desenvolvimento

1. Leia o `roadmap.md` do pacote antes de começar
2. Instale o pacote em modo editável: `pip install -e ".[dev]"`
3. Rode os testes frequentemente: `pytest`
4. Formate o código antes de commit: `black . && isort .`
5. Verifique a qualidade: `flake8 . && mypy src`

## 📝 Convenções

- **Imports**: Use imports absolutos do nome do pacote
- **Type hints**: Obrigatórios para todas as funções públicas
- **Docstrings**: Estilo Google ou NumPy para funções públicas
- **Testes**: Cobertura mínima de 80%
- **Formatação**: Black com line length 88
- **Linting**: Flake8 e MyPy

## 🔐 Segurança

- Nunca commite secrets ou credenciais
- Use variáveis de ambiente para configuração
- Siga as práticas de segurança do OWASP
- Valide todos os inputs com Pydantic

## 📄 Licença

Parte do projeto FIAP Global Solution 2025.2.
