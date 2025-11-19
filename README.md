# FIAP AI-Enhanced Learning Platform - POC Futuro do Trabalho

## 🚀 Visão Geral

**FIAP AI-Enhanced Learning Platform** é uma plataforma inovadora que utiliza agentes de IA e gamificação para transformar a experiência educacional na FIAP. O projeto foca em **bots e agentes inteligentes como parceiros de produtividade** e **soluções gamificadas para engajamento e aprendizado corporativo**.

### Objetivo

Responder ao desafio FIAP GS 2025.2: **"Como a tecnologia pode tornar o trabalho mais humano, inclusivo e sustentável no futuro?"** através da modernização do sistema educacional da FIAP com IA e gamificação.

## 🎯 Principais Funcionalidades

Abaixo estão as funcionalidades planejadas para o projeto, organizadas para deixar claro o que já tem responsável identificado e o que ainda precisa ser atribuído. Cada item tem uma breve descrição para facilitar o entendimento.

### Funcionalidades com responsável(s) identificados

- **Code Review Inteligente** — Lucas
  - Integração com a API do GitHub para análise automatizada de PRs, comentários e feedback personalizado para alunos.

- **Sistema de Premiação Transparente** — Leo
  - Agente que gera metodologias objetivas e auditáveis para premiações, rankings e critérios de avaliação.

- **Gerador de Conteúdo Educacional** — Leo
  - Geração de vídeos e materiais didáticos usando Veo3, NotebookLM, Grok e outras IAs.

- **Gestão de Iniciação Científica** — Lucas
  - Ferramenta para coordenadores gerenciarem grupos de pesquisa, submissões e histórico, com foco em inclusão.

- **Provas Gamificadas Inclusivas** — Pedro
  - Avaliações adaptativas e acessíveis (p.ex. suporte a dislexia) com mecânicas gamificadas.

- **Revisão Contínua de Conteúdo** — Lucas
  - Agentes que checam referências, atualizam conteúdos e removem inconsistências automaticamente (com aprovação humana).

- **Detecção de Saúde Mental** — Pedro
  - Monitoramento de bem-estar de alunos e alertas precoces para equipes de suporte (respeitando privacidade e LGPD/GDPR).

- **Frontend Moderno (tema claro/escuro)** — Leo
  - Interface com suporte a temas, foco em acessibilidade e usabilidade para web e mobile.

### Funcionalidades sem responsável (a atribuir)

- **Correção Automatizada com IA** — (sem responsável)
  - Agentes que aplicam rubricas, corrigem trabalhos e geram feedback para professores revisarem e aprovarem.

- **Alerta de Plágio** — (sem responsável)
  - Detecção semântica e estrutural de plágio em código e texto, com relatórios explicáveis.

- **Alerta de Uso de IA** — (sem responsável)
  - Identificação de uso excessivo de assistentes (p.ex. ChatGPT/Copilot) e sinalização para promoção de aprendizagem genuína.

- **Interface de Aprovação/Edição (Human-in-the-loop)** — (sem responsável)
  - Painel para revisão humana e aprovação final das ações dos agentes de IA (fluxo obrigatório para mudanças persistentes).

---

## 🏗️ Arquitetura

### Stack Tecnológico

- **Frontend**: Flutter (Web/Mobile/Desktop) com tema claro/escuro
- **Backend**: Python (Microservices Serverless)
- **Agentes IA**: CrewAI para orquestração de múltiplos agentes especializados
- **Infraestrutura**: Serverless (AWS Lambda/Google Cloud Functions/Azure Functions)
- **Database**: Serverless (DynamoDB/Aurora Serverless/Firebase)
- **Integrações**: GitHub API, Veo3, NotebookLM, Grok, APIs de geração de conteúdo

### Estrutura de Pastas

```
fiap_gs2/
├── production/          # 🚀 APLICAÇÃO UNIFICADA MVP (NOVO)
│   ├── backend/                   # Backend unificado Python
│   │   ├── main.py               # API FastAPI integrada
│   │   ├── pyproject.toml        # Dependências
│   │   ├── run_backend.sh        # Script de execução
│   │   └── README.md             # Documentação backend
│   └── dashboard/                # Dashboard unificado Flutter
│       ├── lib/                  # Código Flutter
│       ├── pubspec.yaml          # Dependências
│       ├── run_dashboard.sh      # Script de execução
│       └── README.md             # Documentação dashboard
├── packages/            # Pacotes Python (microservices)
│   ├── auth_service/              # ✅ Autenticação e autorização
│   ├── research_management/       # ✅ Gestão de iniciação científica
│   ├── content_reviewer_agent/    # ✅ Agente de revisão de conteúdo
│   ├── code_review_agent/         # ⏳ Agente de code review (GitHub API)
│   ├── grading_agent/             # ⏳ Agente de correção automatizada
│   ├── award_methodology_agent/   # ⏳ Agente de metodologia de premiação
│   ├── content_generator_agent/   # ⏳ Gerador de conteúdo educacional
│   ├── mental_health_agent/       # ⏳ Agente de detecção de saúde mental
│   ├── plagiarism_detection_agent/# ⏳ Agente de detecção de plágio
│   └── ai_usage_detection_agent/  # ⏳ Agente de detecção de uso de IA
├── packages_dashboard/  # Pacotes Flutter (interfaces)
│   ├── tema/                      # ✅ Sistema de temas claro/escuro
│   ├── dashboard_auth/            # ✅ Autenticação Firebase Flutter
│   ├── research_dashboard/        # ✅ Dashboards de IC
│   ├── approval_interface/        # ✅ Interface de aprovação/edição
│   ├── frontend_flutter/          # ⏳ Frontend Flutter (Web/Mobile)
│   └── gamified_exams/            # ⏳ Sistema de provas gamificadas
├── assets/              # Prints, anexos, imagens e recursos visuais
├── docs/                # Documentação completa do projeto
│   ├── roadmap-overview.md
│   ├── discipline-mapping.md
│   └── delivery-guidelines.md
└── .github/
    └── copilot-instructions.md      # Instruções para colaboradores
```

> **Nota**: Este projeto utiliza arquitetura de monorepo com pacotes independentes. Cada pacote em `packages/` e `packages_dashboard/` pode ser instalado e desenvolvido separadamente.

> **✨ NOVO**: A pasta `production/` contém a **aplicação unificada do MVP**, integrando todos os pacotes implementados em um backend e dashboard prontos para produção.

## 🎓 Integração Disciplinar FIAP

Este projeto integra todas as disciplinas do curso:

- **AICSS**: Agentes de IA para educação, ética e transparência em avaliações
- **Cybersecurity**: Autenticação segura, proteção de dados de alunos, auditoria
- **Machine Learning**: Modelos para análise de código, detecção de plágio, personalização
- **Redes Neurais**: NLP para análise de textos, geração de feedback, QA automático
- **Linguagem R**: Análise estatística de desempenho e engajamento
- **Python**: Backend serverless, agentes de IA, integrações
- **Computação em Nuvem**: Arquitetura serverless escalável e custo-efetiva
- **Banco de Dados**: Modelagem de dados acadêmicos e históricos
- **Formação Social**: Inclusão (dislexia), transparência, impacto educacional

## 🚀 Como Começar

### 🎯 Executar Aplicação Unificada (MVP - Recomendado)

O MVP está pronto para execução na pasta `production/`:

**Backend Unificado:**
```bash
cd production/backend

# Setup e execução (script automatizado)
./run_backend.sh

# OU manualmente:
# 1. Criar ambiente virtual
python -m venv .venv && source .venv/bin/activate

# 2. Instalar packages em modo editável
cd ../../packages/auth_service && pip install -e ".[dev]" && cd ../../production/backend
cd ../../packages/research_management && pip install -e ".[dev]" && cd ../../production/backend
cd ../../packages/content_reviewer_agent && pip install -e ".[dev]" && cd ../../production/backend

# 3. Configurar .env (copiar de .env.example)
cp .env.example .env
# Editar .env com suas credenciais

# 4. Executar
python main.py
```

**Dashboard Unificado:**
```bash
cd production/dashboard

# Setup e execução (script automatizado)
./run_dashboard.sh

# OU manualmente:
flutter pub get
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

**Modo Sem Autenticação (Emulador):**
```bash
# Backend - usar Firebase Emulator
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099

# Dashboard - modo demo sem login
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

### 📚 Ver Documentação Completa

- **[production/backend/README.md](production/backend/README.md)** - Guia do backend unificado
- **[production/dashboard/README.md](production/dashboard/README.md)** - Guia do dashboard unificado

### 🔧 Desenvolvimento de Pacotes Individuais

**Pacotes Python:**
```bash
# Instalar um pacote em modo editável
cd packages/auth_service
pip install -e ".[dev]"

# Executar testes
pytest

# Formatar código
black . && isort .
```

**Pacotes Flutter:**
```bash
# Instalar dependências
cd packages_dashboard/research_dashboard
flutter pub get

# Executar exemplo
cd example
flutter run -d chrome

# Executar testes
flutter test
```

### Documentação

📖 **[docs/developer-guide.md](docs/developer-guide.md)** - Guia completo para desenvolvedores

🔄 **[docs/migration-guide.md](docs/migration-guide.md)** - Guia de migração para nova estrutura de monorepo

📋 **[docs/roadmap-overview.md](docs/roadmap-overview.md)** - Roadmap detalhado de implementação

📚 **[docs/discipline-mapping.md](docs/discipline-mapping.md)** - Mapeamento por disciplinas

📦 **[docs/delivery-guidelines.md](docs/delivery-guidelines.md)** - Guia de entrega GS

## 📋 Status do MVP - O Que Foi Feito

### ✅ Implementado e Integrado

#### Backend Python (3/10 packages)
- ✅ **Auth Service** - Autenticação Firebase completa, middleware FastAPI, RBAC
- ✅ **Research Management** - Sistema completo de gestão de IC com dashboards e alertas
- ✅ **Content Reviewer Agent** - Agente de IA para revisão automatizada de conteúdo

#### Frontend Flutter (4/6 packages)
- ✅ **Tema** - Sistema de temas claro/escuro com persistência
- ✅ **Dashboard Auth** - Autenticação Firebase com suporte a emulador
- ✅ **Research Dashboard** - Dashboards para coordenador, orientador e aluno
- ✅ **Approval Interface** - Interface genérica de aprovação com filtros e bulk operations

#### Aplicação Unificada
- ✅ **Backend Unificado** (`production/backend/`) - API FastAPI integrando todos os serviços
- ✅ **Dashboard Unificado** (`production/dashboard/`) - App Flutter integrando todas as interfaces
- ✅ **Modo Sem Autenticação** - Suporte para rodar em modo demo sem Firebase
- ✅ **Scripts de Execução** - `run_backend.sh` e `run_dashboard.sh` automatizados
- ✅ **Documentação Completa** - READMEs com instruções de setup e execução

### ⏳ Planejado mas Não Implementado

#### Backend Python (7/10 packages)
- ⏳ **Code Review Agent** - Análise inteligente via GitHub API
- ⏳ **Grading Agent** - Correção automatizada com IA
- ⏳ **Award Methodology Agent** - Sistema de premiação transparente
- ⏳ **Content Generator Agent** - Geração com Veo3/NotebookLM/Grok
- ⏳ **Mental Health Agent** - Detecção de saúde mental
- ⏳ **Plagiarism Detection Agent** - Detecção semântica de plágio
- ⏳ **AI Usage Detection Agent** - Identificação de uso excessivo de IA

#### Frontend Flutter (2/6 packages)
- ⏳ **Frontend Flutter** - Landing page e interface principal
- ⏳ **Gamified Exams** - Sistema de provas gamificadas e acessíveis

### 📊 Estatísticas do MVP

- **Total de Packages**: 16 (10 Python + 6 Flutter)
- **Packages Implementados**: 7 (43.75%)
  - Python: 3/10 (30%)
  - Flutter: 4/6 (66.7%)
- **Linhas de Código**:
  - Python: ~50 arquivos implementados
  - Flutter: ~27 arquivos implementados
- **Cobertura de Testes**: Estrutura de testes implementada em todos os packages
- **Documentação**: 100% dos packages com README e roadmap

### 🎯 Funcionalidades Demonstráveis

1. ✅ **Gestão de Pesquisa Completa**
   - Dashboard do coordenador com métricas
   - Dashboard do orientador para acompanhamento
   - Dashboard do aluno com progresso
   - Sistema de alertas automatizado
   - API REST completa

2. ✅ **Revisão de Conteúdo com IA**
   - Múltiplos agentes especializados
   - Verificação de fontes
   - Detecção de erros
   - Sugestões de atualização

3. ✅ **Sistema de Aprovação Humana**
   - Interface genérica e reutilizável
   - Filtros avançados
   - Operações em lote
   - Dashboard com estatísticas

4. ✅ **Autenticação e Segurança**
   - Firebase Authentication
   - RBAC (Role-Based Access Control)
   - Modo demo para desenvolvimento
   - Suporte a emulador

5. ✅ **UX Moderna**
   - Tema claro/escuro
   - Design responsivo
   - Material Design 3
   - Navegação fluida com GoRouter

## 📋 Pacotes do Projeto

### Pacotes Python (`packages/`)

Cada pacote possui seu próprio roadmap e pode ser instalado independentemente:

- [Auth Service](packages/auth_service/roadmap.md) - Autenticação e autorização
- [Code Review Agent](packages/code_review_agent/roadmap.md) - Análise inteligente via GitHub
- [Grading Agent](packages/grading_agent/roadmap.md) - Correção automatizada
- [Award Methodology Agent](packages/award_methodology_agent/roadmap.md) - Sistema de premiação
- [Content Generator Agent](packages/content_generator_agent/roadmap.md) - Geração com Veo3/Grok
- [Research Management](packages/research_management/roadmap.md) - Iniciação científica
- [Content Reviewer Agent](packages/content_reviewer_agent/roadmap.md) - Revisão contínua
- [Mental Health Agent](packages/mental_health_agent/roadmap.md) - Detecção de saúde mental
- [Plagiarism Detection Agent](packages/plagiarism_detection_agent/roadmap.md) - Detecção de plágio
- [AI Usage Detection Agent](packages/ai_usage_detection_agent/roadmap.md) - Detecção de uso de IA

### Pacotes Flutter (`packages_dashboard/`)

- [Frontend Flutter](packages_dashboard/frontend_flutter/roadmap.md) - Interface com tema claro/escuro
- [Approval Interface](packages_dashboard/approval_interface/roadmap.md) - Interface de aprovação
- [Gamified Exams](packages_dashboard/gamified_exams/roadmap.md) - Provas inclusivas

## 🎬 Entrega GS 2025.2

### Requisitos Mínimos

✅ MVP funcional com aplicação de IA, ML e todas as disciplinas  
✅ Coleta, tratamento e análise de dados  
✅ Demonstração prática em vídeo  
✅ PDF único com estrutura completa  
✅ Link do YouTube (não listado) sem mascaramento  

### Concorrendo ao Pódio

Para concorrer aos prêmios (shape + camiseta FIAP):

1. Integrar máximo de disciplinas
2. Utilizar dados/automações reais
3. Mostrar integração hardware/software (se aplicável)
4. Vídeo de até 7 minutos com:
   - Nome do grupo + "QUERO CONCORRER"
   - Explicação clara da integração entre disciplinas
   - Postado no YouTube como "não listado"

## 👥 Equipe

[Nomes completos dos integrantes aqui - 3 a 5 pessoas]

## 📄 Licença

Este projeto é uma Prova de Conceito (POC) desenvolvida para o desafio Global Solution da FIAP 2025.2.

---

**Tema GS 2025.2**: O Futuro do Trabalho  
**Instituição**: FIAP  
**Ano**: 2025