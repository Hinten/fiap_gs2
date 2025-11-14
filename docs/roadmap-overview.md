# Roadmap de Implementação - SymbioWork

## 📊 Status Atual do Projeto (Última atualização: 2025-11-13)

### ✅ Componentes Implementados e Funcionais

| Componente | Tipo | Status | Testes | Documentação |
|------------|------|--------|--------|--------------|
| **Auth Service** | Python Backend | ✅ Completo | 10/10 ✅ | 4 guias completos |
| **Dashboard Auth** | Flutter Frontend | ✅ Completo | ✅ Testes | README + Exemplo |
| **Approval Interface** | Flutter Frontend | ✅ Completo | 15+ testes ✅ | README + Exemplo |
| **Content Reviewer Agent** | Python Backend | ✅ Completo | - | README básico |

### 📈 Progresso Geral

- **Sprints Concluídos**: 1 de 7 (Sprint 1 - Fundação e Infraestrutura)
- **Sprints Parciais**: 2 de 7 (Sprint 4 e 5)
- **Pacotes Implementados**: 4 de 13 (31%)
- **Linhas de Código**: ~2,000+ linhas (Python + Dart)
- **Testes Automatizados**: 25+ testes unitários e de widget
- **Documentação**: 8+ arquivos .md com guias completos

### 🎯 Próximos Passos Prioritários

1. **Finalizar CI/CD**: Configurar GitHub Actions para testes automatizados
2. **Deploy Serverless**: Configurar Google Cloud Functions para backend
3. **Implementar Agentes Educacionais**: Grading Agent, Code Review Agent
4. **Expandir Frontend**: Frontend Flutter principal com dashboard unificado
5. **Testes de Integração**: Conectar todos os componentes

## 📋 Visão Geral do Projeto

**SymbioWork** é um ecossistema de assistentes de IA e ambientes de trabalho adaptativos que promove bem-estar, inclusão e sustentabilidade no trabalho do futuro, com foco especial em educação e desenvolvimento profissional.

### Proposta de Valor

- **Problema**: O futuro do trabalho precisa equilibrar avanços tecnológicos com humanização, inclusão e sustentabilidade, especialmente na educação onde alunos precisam de suporte personalizado e ético no uso de IA
- **Solução**: Plataforma serverless com múltiplos agentes IA especializados (CrewAI) que atuam como companheiros educacionais e profissionais, promovendo bem-estar, produtividade consciente e práticas sustentáveis
- **Diferencial**: Integração de 13+ agentes IA especializados com análise preditiva, detecção de plágio/uso inadequado de IA, geração de conteúdo educacional, e ambientes gamificados

### MVP - Critérios Mínimos GS

Para garantir nota da GS, o MVP deve incluir:

✅ Aplicação de IA e Machine Learning em múltiplos contextos educacionais  
✅ Todas as disciplinas do curso integradas (exceto AI Challenge que é o vídeo)  
✅ Coleta, tratamento e análise de dados (simulados ou reais)  
✅ Demonstração prática em vídeo de até 7 minutos  
✅ Código operacional e testado  

## 🎯 Objetivos e Metas

### Objetivo Principal
Desenvolver POC funcional que demonstre como IA e tecnologia podem tornar a educação e o trabalho mais humanos, inclusivos e éticos.

### Metas Específicas
1. Implementar 13+ agentes IA especializados usando CrewAI
2. Criar dashboard unificado com visualizações em tempo real
3. Demonstrar análise preditiva de bem-estar mental e detecção de burnout
4. Implementar sistema de avaliação automatizada com feedback personalizado
5. Desenvolver plataforma de exames gamificados acessíveis
6. Integrar detecção de plágio e uso ético de IA
7. Criar sistema de geração e revisão de conteúdo educacional
8. Implementar gestão automatizada de iniciação científica

## 🏗️ Arquitetura de Agentes

### Agentes Core Implementados

#### 🤖 **AI Usage Detection Agent** - 📋 PLANEJADO
- Detecta uso excessivo/inadequado de ferramentas IA (ChatGPT, Copilot)
- Analisa padrões de uso ético vs substituição completa
- Promove aprendizado genuíno

#### ✅ **Approval Interface** - ✅ IMPLEMENTADO
- Dashboard unificado para aprovações de professores
- Preview e filtros avançados de items pendentes
- Operações em massa (bulk approve/reject)

#### 🏆 **Award Methodology Agent**
- Cria metodologias objetivas para premiações
- Avaliação transparente com justificativas
- Rankings explicáveis

#### 🏆 **Award Methodology Agent** - 📋 PLANEJADO
- Cria metodologias objetivas para premiações
- Avaliação transparente com justificativas
- Rankings explicáveis

#### 🔍 **Code Review Agent** - 📋 PLANEJADO
- Integração GitHub para reviews automatizados
- Feedback educacional personalizado
- Detecção de plágio entre trabalhos

#### 🎬 **Content Generator Agent** - 📋 PLANEJADO
- Geração de vídeos educacionais (Veo3, Sora)
- Produção de podcasts (NotebookLM)
- Criação de materiais de apoio

#### 📝 **Content Reviewer Agent** - ✅ IMPLEMENTADO
- Revisão automática de conteúdos educacionais
- Fact-checking e validação de fontes
- Detecção de material desatualizado
- **18 módulos Python implementados**

#### 🎓 **Grading Agent** - 📋 PLANEJADO
- Correção automatizada com rubricas personalizadas
- Feedback personalizado por aluno
- Interface de aprovação para professores

#### 🎮 **Gamified Exams** - 📋 PLANEJADO
- Provas interativas e acessíveis
- Adaptação para dislexia e necessidades especiais
- Sistema de pontos e conquistas

#### 🧠 **Mental Health Agent** - 📋 PLANEJADO
- Monitoramento de indicadores de saúde mental
- Detecção precoce de burnout e ansiedade
- Recomendações personalizadas de suporte

#### 🔍 **Plagiarism Detection Agent** - 📋 PLANEJADO
- Detecção de plágio em código e texto
- Análise semântica e estrutural
- Relatórios detalhados de originalidade

#### 🔬 **Research Management** - 📋 PLANEJADO
- Gestão de projetos de iniciação científica
- Acompanhamento automático de progresso
- Alertas para alunos/orientadores sem atividade

#### 🔐 **Auth Service** - ✅ IMPLEMENTADO
- Autenticação Firebase (substituindo OAuth2/JWT customizado)
- Firebase Admin SDK integrado
- Gerenciamento de usuários e custom claims
- RBAC (Role-Based Access Control)
- Multi-tenant support
- **6 módulos Python + 10 testes**

#### 📱 **Dashboard Auth** - ✅ IMPLEMENTADO
- Firebase Authentication no Flutter
- Múltiplos métodos de autenticação
- Riverpod state management
- Auth wrapper widgets
- **4 módulos Dart com exemplo funcional**

#### 📱 **Frontend Flutter** - 📋 PLANEJADO
- Interface multi-plataforma responsiva
- Microfrontends modulares
- Real-time updates

## 📅 Roadmap por Sprints

### Sprint 1 (Semana 1): Fundação e Infraestrutura ✅ **CONCLUÍDO**
**Objetivo**: Configurar infraestrutura base e autenticação

#### Tarefas
- [x] Configurar repositório e estrutura de pastas ✅
- [x] Implementar Auth Service ✅
  - [x] Sistema de autenticação com Firebase (substituindo JWT customizado)
  - [x] Integração Firebase Admin SDK
  - [x] Firebase Authentication (Email/Password, Google)
  - [x] Gerenciamento de usuários e permissões
  - [x] RBAC (Role-Based Access Control)
  - [x] Multi-tenant support
  - [x] FastAPI middleware para verificação de tokens
  - [x] Custom claims management
- [x] Criar estrutura base do Frontend Flutter ✅
  - [x] Dashboard Auth package implementado
  - [x] Integração Firebase Authentication no Flutter
  - [x] Riverpod state management
  - [x] Auth wrapper widgets para proteção de rotas
  - [x] Dio interceptor para chamadas API autenticadas
- [x] Configurar Firebase ✅
  - [x] Firebase project configurado
  - [x] Firebase Emulators para testes locais
  - [x] Firestore (Database)
- [ ] Configurar ambiente serverless (AWS/GCP/Azure) - **EM PLANEJAMENTO**
  - [ ] Criar contas e configurar IAM/permissões
  - [ ] Configurar CI/CD com GitHub Actions
  - [ ] Definir arquitetura de deploy serverless

**Entregáveis**: ✅
- ✅ Ambiente de desenvolvimento configurado
- ✅ Auth Service funcional com Firebase Admin SDK
- ✅ Dashboard Auth (Flutter) com Firebase Authentication
- ✅ 10 testes unitários passando (auth_service)
- ✅ Documentação completa (4 guias)
- ✅ Firebase Emulators configurados
- ✅ Exemplo funcional de integração backend-frontend

**Critérios de Aceitação**: ✅
- ✅ Usuário consegue fazer login via Firebase (Email/Password, Google)
- ✅ Token Firebase ID validado corretamente no backend
- ✅ Frontend conecta ao backend via API com autenticação
- ✅ RBAC implementado com custom claims
- ✅ Multi-tenant support implementado

---

### Sprint 2 (Semana 2): Serviços Core de Bem-Estar e Colaboração
**Objetivo**: Implementar monitoramento de bem-estar e ambientes colaborativos

#### Tarefas
- [ ] Implementar Mental Health Agent
  - [ ] API para coleta de indicadores comportamentais
  - [ ] Modelo ML para detecção de stress/burnout
  - [ ] Sistema de alertas e recomendações
  - [ ] Dashboard de bem-estar individual/coletivo
- [ ] Implementar Research Management
  - [ ] CRUD de projetos de IC
  - [ ] Sistema de acompanhamento de progresso
  - [ ] Alertas automáticos para inatividade
  - [ ] Relatórios para coordenadores
- [ ] Criar interfaces Flutter para:
  - [ ] Dashboard de bem-estar pessoal
  - [ ] Portal de gestão de pesquisa
  - [ ] Visualizações de métricas

**Entregáveis**:
- Mental Health Agent com modelo ML treinado
- Research Management funcional
- Telas de bem-estar e pesquisa no Flutter

**Critérios de Aceitação**:
- Sistema coleta e armazena indicadores de saúde mental
- Modelo ML identifica padrões de risco com 70%+ acurácia
- Alertas automáticos para projetos sem atividade

---

### Sprint 3 (Semana 3): Agentes Educacionais e Avaliação
**Objetivo**: Implementar agentes para educação e avaliação

#### Tarefas
- [ ] Implementar Grading Agent
  - [ ] Geração automática de rubricas
  - [ ] Correção automatizada de trabalhos
  - [ ] Feedback personalizado
  - [ ] Interface de aprovação
- [ ] Implementar Code Review Agent
  - [ ] Integração GitHub API
  - [ ] Análise estática de código
  - [ ] Reviews educacionais automatizados
  - [ ] Detecção de plágio
- [ ] Implementar Gamified Exams
  - [ ] Engine de questões interativas
  - [ ] Acessibilidade para dislexia
  - [ ] Sistema de gamificação
- [ ] Integrar agentes no Dashboard
  - [ ] Visualização de ações dos agentes
  - [ ] Chat interface com agentes
  - [ ] Recomendações e insights

**Entregáveis**:
- Grading Agent com correção automatizada
- Code Review Agent integrado ao GitHub
- Gamified Exams com acessibilidade
- Dashboard mostrando ações dos agentes educacionais

**Critérios de Aceitação**:
- Sistema corrige trabalhos automaticamente com feedback
- Code reviews aparecem automaticamente no GitHub
- Exames gamificados suportam alunos com dislexia

---

### Sprint 4 (Semana 4): Detecção e Ética em IA - **PARCIALMENTE CONCLUÍDO**
**Objetivo**: Implementar detecção de plágio e uso ético de IA

#### Tarefas
- [ ] Implementar Plagiarism Detection Agent
  - [ ] Análise de código (AST + embeddings)
  - [ ] Análise de texto (TF-IDF + semantic)
  - [ ] Comparação intra-turma
  - [ ] Relatórios de originalidade
- [ ] Implementar AI Usage Detection Agent
  - [ ] Detecção de texto gerado por LLMs
  - [ ] Análise de código gerado por IA
  - [ ] Padrões de uso adequado vs inadequado
  - [ ] Verificação de compreensão
- [x] Implementar Approval Interface ✅ **CONCLUÍDO**
  - [x] Dashboard unificado de aprovações
  - [x] Preview de conteúdos (ApprovalCard)
  - [x] Filtros avançados (por tipo, prioridade, status)
  - [x] Estatísticas em tempo real
  - [x] Operações individuais (aprovar/rejeitar)
  - [x] Operações em massa (bulk approve)
  - [x] Material Design 3 com tema claro/escuro
  - [x] Responsivo (mobile, web, desktop)
  - [x] 15+ testes unitários e de widget
  - [x] Exemplo funcional completo
  - [ ] Aprovação em massa

**Entregáveis**: ✅ Parcial
- [ ] Plagiarism Detection Agent com análise semântica
- [ ] AI Usage Detection Agent funcional
- ✅ Approval Interface para professores **IMPLEMENTADO**

**Critérios de Aceitação**: ✅ Parcial
- [ ] Sistema detecta plágio com 85%+ acurácia
- [ ] Identifica uso inadequado de IA em trabalhos
- ✅ Professores podem aprovar/rejeitar items em uma interface unificada

---

### Sprint 5 (Semana 5): Geração e Revisão de Conteúdo - **PARCIALMENTE CONCLUÍDO**
**Objetivo**: Implementar geração e validação de conteúdo educacional

#### Tarefas
- [ ] Implementar Content Generator Agent
  - [ ] Integração com APIs de geração (Veo3, NotebookLM)
  - [ ] Pipeline de criação de vídeos/podcasts
  - [ ] Geração de roteiros e slides
- [x] Implementar Content Reviewer Agent ✅ **CONCLUÍDO**
  - [x] Estrutura base do agente implementada
  - [x] Revisão automática de conteúdos educacionais
  - [x] Fact-checking e validação de fontes
  - [x] Detecção de material desatualizado
  - [x] 18 módulos Python implementados
  - [x] Integração com CrewAI
- [ ] Implementar Award Methodology Agent
  - [ ] Criação de metodologias de premiação
  - [ ] Avaliação competitiva transparente
  - [ ] Rankings com justificativas

**Entregáveis**: ✅ Parcial
- [ ] Content Generator Agent produzindo materiais
- ✅ Content Reviewer Agent validando conteúdos **IMPLEMENTADO**
- Content Reviewer Agent validando conteúdos
- Award Methodology Agent para competições

**Critérios de Aceitação**:
- Vídeos educacionais gerados automaticamente
- Conteúdos revisados e validados
- Rankings de premiação explicáveis

---

### Sprint 6 (Semana 6): Dashboard, Gamificação e Integração
**Objetivo**: Unificar sistema e adicionar gamificação completa

#### Tarefas
- [ ] Implementar Dashboard Service
  - [ ] Agregação de dados de todos os agentes
  - [ ] Visualizações interativas (charts, graphs)
  - [ ] Relatórios personalizados
  - [ ] Exportação de dados (PDF, CSV)
- [ ] Expandir sistema de gamificação
  - [ ] Sistema de pontos e badges em todos os módulos
  - [ ] Desafios e missões
  - [ ] Leaderboards e competições
  - [ ] Recompensas e incentivos
- [ ] Integração completa entre agentes
  - [ ] Comunicação CrewAI entre agentes
  - [ ] Testes de integração end-to-end
  - [ ] Otimização de performance
  - [ ] Tratamento de erros e fallbacks

**Entregáveis**:
- Dashboard unificado e responsivo
- Sistema de gamificação completo
- Aplicação integrada e testada

**Critérios de Aceitação**:
- Dashboard agrega dados de todos os 13+ agentes
- Sistema de gamificação engaja usuários
- Aplicação suporta 100+ usuários simultâneos

---

### Sprint 7 (Semana 7): Testes, Documentação e Entrega
**Objetivo**: Finalizar, testar e preparar entrega GS

#### Tarefas
- [ ] Testes abrangentes
  - [ ] Testes unitários (cobertura 70%+) para todos os agentes
  - [ ] Testes de integração entre agentes
  - [ ] Testes de segurança (OWASP)
  - [ ] Testes de performance e carga
- [ ] Documentação completa
  - [ ] Documentação técnica (APIs, arquitetura)
  - [ ] Guias de uso e tutoriais
  - [ ] Comentários em código
  - [ ] Diagramas de arquitetura atualizados
- [ ] Preparar demonstração
  - [ ] Criar dados de demonstração realistas
  - [ ] Preparar cenários de uso com todos os agentes
  - [ ] Roteiro de demonstração em vídeo
- [ ] Preparar entregáveis GS
  - [ ] PDF com estrutura completa
  - [ ] Gravar vídeo de até 7 minutos
  - [ ] Postar vídeo no YouTube (não listado)
  - [ ] Revisar checklist de requisitos

**Entregáveis**:
- Suite completa de testes
- Documentação técnica e de usuário
- Vídeo de demonstração
- PDF formatado para entrega GS

**Critérios de Aceitação**:
- Todos os testes passando
- Documentação completa e clara
- Vídeo demonstra integração de todos os agentes
- PDF atende todos os requisitos GS

---

## 🏗️ Arquitetura Técnica Atualizada

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                     Frontend Flutter                             │
│  (Microfrontends: Auth, Dashboard, Wellbeing, Research,         │
│   Grading, CodeReview, GamifiedExams, Plagiarism, AI-Usage,     │
│   ContentGen, ContentReview, Awards, Approval)                  │
└────────────────────┬─────────────────────────────────────────────┘
                     │ HTTPS/REST/WebSocket
┌────────────────────┴─────────────────────────────────────────────┐
│                    API Gateway                                   │
└────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬────┘
     │      │      │      │      │      │      │      │      │
   Auth  Mental Research Grading Code  Gamified Plag  AI-Usage Content
  Service Health Mgmt   Agent Review  Exams  Detect   Detect   Gen
     │      │      │      │      │      │      │      │      │
     └──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┘
                           │
          ┌────────────────────────────────┐
          │    Serverless Database         │
          │  (DynamoDB / Aurora / Firebase)│
          └────────────────────────────────┘
```

### Stack Detalhado

**Frontend**
- Flutter 3.x (Dart)
- State Management: Riverpod
- UI: Material Design 3
- Charts: fl_chart
- Real-time: WebSocket / Firebase

**Backend Services**
- Python 3.11+ (FastAPI / Flask)
- Serverless Framework / SAM / Cloud Functions
- APIs RESTful + GraphQL
- Message Queue: AWS SQS / Google Pub/Sub

**Agentes IA (CrewAI)**
- 13+ agentes especializados
- LangChain para LLM integration
- OpenAI GPT / Anthropic Claude / Open source LLMs
- Vector DB: Pinecone / Chroma / FAISS

**Machine Learning**
- scikit-learn, TensorFlow, PyTorch
- Modelos: Random Forest, LSTM, BERT, CodeBERT
- MLOps: MLflow / Weights & Biases

**Analytics**
- Python: pandas, numpy, matplotlib, seaborn
- R: ggplot2, dplyr, tidyverse
- Notebooks: Jupyter / Google Colab

**Integrações Externas**
- GitHub API (code reviews, webhooks)
- Google APIs (Veo3, NotebookLM, Drive)
- YouTube API (upload de vídeos)
- Twilio (WhatsApp notifications)

---

## 🔒 Segurança e Privacidade

### Requisitos de Segurança (Cybersecurity)

- **Autenticação**: OAuth2 + JWT, MFA opcional
- **Autorização**: RBAC granular para professores/alunos
- **Criptografia**: 
  - Dados em trânsito: TLS 1.3
  - Dados em repouso: AES-256
  - Dados sensíveis de saúde: encryption at field level
- **Auditoria**: Logs de todas as ações críticas
- **GDPR/LGPD**: 
  - Consentimento explícito para monitoramento
  - Direito ao esquecimento
  - Portabilidade de dados
  - Anonimização quando possível
- **Proteção contra**: 
  - SQL Injection (ORMs)
  - XSS (sanitização)
  - CSRF (tokens)
  - DDoS (rate limiting)

### Testes de Segurança

- OWASP Top 10 compliance
- Vulnerability scanning (Snyk / Dependabot)
- Penetration testing
- Security code review

---

## 📊 Dados e Analytics

### Pipeline de Dados

1. **Coleta**: 
   - Eventos de usuários (clicks, tempo, ações)
   - Dados educacionais (notas, participação, progresso)
   - Indicadores de saúde mental (com consentimento)
   - Métricas de IA (uso, detecção de plágio)
   - Dados de gamificação (pontos, conquistas)

2. **Armazenamento**:
   - Raw data: S3 / Cloud Storage
   - Processed: DynamoDB / BigQuery
   - Cache: Redis para queries frequentes

3. **Processamento**:
   - ETL: Python scripts serverless
   - Transformações: pandas / PySpark
   - Agregações: SQL queries

4. **Análise**:
   - Descritiva: estatísticas básicas
   - Preditiva: modelos ML para bem-estar, performance
   - Prescritiva: agentes IA com recomendações

5. **Visualização**:
   - Dashboard real-time: Flutter + WebSocket
   - Relatórios: PDF / Excel exports
   - Notebooks: Jupyter para análises ad-hoc

### Machine Learning Models

| Modelo | Uso | Algoritmo | Métricas |
|--------|-----|-----------|----------|
| Mental Health Detection | Bem-estar | Random Forest / LSTM | Accuracy, Precision, Recall |
| Plagiarism Detection | Detecção de cópia | BERT + Cosine Similarity | F1-Score, Precision |
| AI Usage Detection | Detecção de IA | Transformer Classifier | AUC-ROC, F1-Score |
| Code Review Quality | Qualidade de código | CodeBERT | Accuracy |
| Student Performance | Previsão de notas | Gradient Boosting | RMSE, R² |
| Content Quality | Avaliação de conteúdo | BERT | Accuracy |

---

## 🎓 Integração Disciplinar Detalhada

Veja [docs/discipline-mapping.md](discipline-mapping.md) para mapeamento completo de como cada disciplina é integrada no projeto.

---

## 📦 Entregáveis Finais

### 1. Código-fonte
- ✅ Repositório GitHub completo
- ✅ README com instruções claras
- ✅ Código comentado e documentado
- ✅ Testes automatizados

### 2. PDF Único (estrutura)
```
1. Capa
   - Título do projeto: SymbioWork
   - Nomes completos dos integrantes (3-5)
   - Data
   
2. Introdução (2-3 páginas)
   - Contexto do desafio GS 2025.2
   - Problema identificado
   - Proposta de solução
   - Objetivos

3. Desenvolvimento (15-20 páginas)
   - Arquitetura dos 13+ agentes IA
   - Integração por disciplina (AICSS, Cyber, ML, etc)
   - Tecnologias utilizadas
   - Diagramas e fluxos atualizados
   - Códigos principais comentados
   - Decisões de design
   - Desafios enfrentados

4. Resultados Esperados (2-3 páginas)
   - Funcionalidades dos agentes implementadas
   - Demonstrações (screenshots, logs)
   - Análises de dados de ML
   - Insights dos agentes IA

5. Conclusões (2 páginas)
   - Aprendizados
   - Impacto na educação e trabalho
   - Trabalhos futuros
   - Contribuição para uso ético de IA

6. Referências
   - Bibliográficas
   - Tecnológicas
   
7. Anexos
   - Link do vídeo YouTube (não mascarado)
   - Link do repositório GitHub
   - Dados complementares
```

### 3. Vídeo (7 minutos)
```
Estrutura sugerida:
- 0:00-0:30: Introdução + "QUERO CONCORRER" + nome do grupo
- 0:30-2:00: Explicação do problema e solução com 13+ agentes
- 2:00-4:00: Demonstração técnica (dashboard, agentes em ação)
- 4:00-5:30: Integração disciplinas (ML, Cyber, Cloud, etc)
- 5:30-6:30: Agentes IA colaborando (CrewAI demo)
- 6:30-7:00: Conclusão e impacto ético de IA
```

---

## ✅ Checklist de Validação Final

### Requisitos Técnicos
- [ ] MVP funcional demonstrável
- [ ] 13+ agentes IA aplicados em contextos educacionais
- [ ] Machine Learning com modelos treinados
- [ ] Todas disciplinas integradas
- [ ] Coleta e análise de dados funcionando
- [ ] Código comentado e documentado
- [ ] Testes automatizados (unitários + integração)
- [ ] Deploy serverless configurado

### Requisitos de Entrega
- [ ] PDF único com estrutura completa
- [ ] Nomes completos na primeira página
- [ ] Códigos principais incluídos e comentados
- [ ] Vídeo gravado (máx 7 min)
- [ ] Vídeo postado no YouTube (não listado)
- [ ] Link do YouTube no PDF (não mascarado)
- [ ] Entrega dentro do prazo

### Qualidade e Diferenciação
- [ ] Solução criativa e inovadora
- [ ] Integração clara entre 13+ agentes
- [ ] Demonstração prática convincente
- [ ] Documentação clara e completa
- [ ] Apresentação visual organizada
- [ ] Originalidade (não plagiado)
- [ ] Uso consciente de IA (não copy-paste)

### Concorrendo ao Pódio
- [ ] Frase "QUERO CONCORRER" no início do vídeo
- [ ] Máxima integração de disciplinas
- [ ] Uso de dados/automações reais (se possível)
- [ ] Integração hardware/software (se aplicável)
- [ ] POC com alto grau de implementação
- [ ] Vídeo com explicação clara de integração

---

## 🚀 Próximos Passos

1. **Revisar e aprovar roadmap**: Ajustar sprints conforme necessário
2. **Montar equipe**: Definir papéis (frontend, backend, ML, design, docs)
3. **Configurar ambiente**: Criar contas cloud, repositórios, CI/CD
4. **Sprint 1**: Começar pela infraestrutura e autenticação
5. **Checkpoints semanais**: Revisar progresso e ajustar plano
6. **Demo contínua**: Manter versão demonstrável a cada sprint

---

**Dúvidas?** Consulte os roadmaps específicos de cada agente em `src/apps/<agent_name>/roadmap.md`
