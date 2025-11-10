# Mapeamento por Disciplinas FIAP - SymbioWork

## 📚 Visão Geral

Este documento mapeia como cada disciplina do curso é integrada no projeto **SymbioWork**, demonstrando aplicação prática dos conhecimentos adquiridos.

---

## 🤖 AICSS (AI, Cognitive and Semantic Systems)

### Aplicação no Projeto

**Contexto**: Como pensar criticamente sobre IA no futuro do trabalho?

#### Implementações

1. **Assistentes Críticos e Sociais**
   - Agentes IA que consideram impacto humano antes de automatizar
   - Sistema de "perguntas críticas" antes de decisões automatizadas
   - Transparência sobre quando e como IA está sendo usada

2. **Políticas de Uso Responsável**
   - Governança de IA: quando usar e quando não usar automação
   - Explicabilidade obrigatória em decisões críticas (ex: recrutamento)
   - Auditoria de viés e fairness em todos os modelos

3. **Design Centrado no Humano**
   - IA como assistente, não substituto
   - Agentes que empoderam usuários, não os controlam
   - Interface que permite override de recomendações de IA

#### Arquivos Relacionados
- `src/apps/agents_orchestrator/` - Implementação de agentes com ética
- `docs/ai-governance-policy.md` - Políticas de uso de IA (a criar)

#### Entregável para GS
- **PDF**: Seção sobre governança e ética da IA
- **Vídeo**: Demonstrar explicabilidade e transparência dos agentes

---

## 🔒 Cybersecurity

### Aplicação no Projeto

**Contexto**: Como proteger dados sensíveis de trabalhadores no futuro?

#### Implementações

1. **Autenticação e Autorização Robusta**
   - OAuth2 + JWT para autenticação stateless
   - MFA (Multi-Factor Authentication) opcional
   - RBAC (Role-Based Access Control) granular
   - Session management seguro

2. **Proteção de Dados Sensíveis**
   - Criptografia end-to-end para dados de saúde/bem-estar
   - Encryption at rest (AES-256) no banco de dados
   - TLS 1.3 para dados em trânsito
   - Tokenização de dados pessoais identificáveis

3. **Conformidade LGPD/GDPR**
   - Consentimento explícito para coleta de dados
   - Direito ao esquecimento implementado
   - Portabilidade de dados
   - Anonimização quando possível
   - Privacy by design em todos os serviços

4. **Segurança Defensiva**
   - Rate limiting para prevenir DDoS
   - Input validation e sanitização (anti-XSS, SQLi)
   - CSRF tokens em formulários
   - Security headers (HSTS, CSP, etc)
   - Secrets management (AWS Secrets Manager / Vault)

5. **Auditoria e Monitoramento**
   - Logging de todas ações críticas
   - Detecção de anomalias em acessos
   - Alertas automáticos para tentativas suspeitas
   - Audit trail completo para compliance

#### Arquivos Relacionados
- `src/apps/auth_service/` - Autenticação segura
- `src/security/` - Utilitários de segurança (a criar)
- `docs/security-architecture.md` - Arquitetura de segurança (a criar)

#### Entregável para GS
- **PDF**: Diagrama de segurança, explicação de proteções
- **Vídeo**: Demonstrar autenticação e proteção de dados
- **Testes**: OWASP Top 10 compliance checklist

---

## 🧠 Machine Learning

### Aplicação no Projeto

**Contexto**: Como ML pode melhorar o trabalho de forma humana?

#### Implementações

1. **Detecção de Padrões de Bem-Estar**
   - **Modelo**: Random Forest / LSTM
   - **Input**: Eventos de atividade, pausas, horários, auto-relatos
   - **Output**: Score de risco de burnout, recomendações
   - **Métricas**: Accuracy, Precision, Recall, F1-Score

2. **Sistema de Recomendação de Tarefas**
   - **Modelo**: Collaborative Filtering / Matrix Factorization
   - **Input**: Histórico de tarefas, skills, preferências
   - **Output**: Tarefas recomendadas, melhor momento para execução
   - **Métricas**: RMSE, MAP@K, NDCG

3. **Previsão de Engajamento**
   - **Modelo**: Gradient Boosting (XGBoost/LightGBM)
   - **Input**: Participação, gamificação, interações
   - **Output**: Probabilidade de churn, ações preventivas
   - **Métricas**: AUC-ROC, Precision-Recall curve

4. **Clustering de Perfis de Trabalho**
   - **Modelo**: K-Means / DBSCAN
   - **Input**: Padrões de trabalho, preferências, produtividade
   - **Output**: Segmentos de usuários, personas
   - **Métricas**: Silhouette Score, Davies-Bouldin Index

5. **Análise de Sentimentos**
   - **Modelo**: BERT / DistilBERT fine-tuned
   - **Input**: Feedbacks, comentários, mensagens
   - **Output**: Sentimento (positivo/negativo/neutro), tópicos
   - **Métricas**: F1-Score, Confusion Matrix

#### Pipeline ML

```
Data Collection → Feature Engineering → Training → Validation → Deployment → Monitoring
     ↓                    ↓                 ↓           ↓            ↓            ↓
  Raw events      Transformações      Split      Hyperparameter  Serverless   A/B Testing
  Simulados       Normalization     Train/Test    Tuning        Lambda/CF    Drift Detection
```

#### Arquivos Relacionados
- `src/apps/analytics_service/ml/` - Modelos ML
- `src/apps/wellbeing_service/models/` - Modelo de stress
- `notebooks/` - Jupyter notebooks para experimentação (a criar)

#### Entregável para GS
- **PDF**: Explicação de modelos, métricas, resultados
- **Vídeo**: Demonstrar predição em tempo real
- **Código**: Scripts de treinamento comentados

---

## 🕸️ Redes Neurais

### Aplicação no Projeto

**Contexto**: Como redes neurais podem captar padrões complexos no trabalho?

#### Implementações

1. **LSTM para Séries Temporais de Bem-Estar**
   - **Arquitetura**: 2-3 camadas LSTM + Dense layers
   - **Input**: Sequência temporal de eventos de stress/energia
   - **Output**: Previsão de estado futuro (próximas horas/dias)
   - **Framework**: TensorFlow / PyTorch
   
   ```python
   # Arquitetura simplificada
   Input(timesteps=24, features=10)
   → LSTM(units=64, return_sequences=True)
   → Dropout(0.2)
   → LSTM(units=32)
   → Dense(16, activation='relu')
   → Dense(1, activation='sigmoid')  # Risco de burnout
   ```

2. **Transformer para Análise de Reuniões**
   - **Modelo**: BERT fine-tuned / DistilBERT
   - **Input**: Transcrições de reuniões (simuladas via ASR)
   - **Output**: Resumo, action items, sentimento geral
   - **Uso**: Agente de produtividade resume reuniões automaticamente

3. **CNN para Análise de Interfaces**
   - **Arquitetura**: CNN + Transfer Learning (ResNet/EfficientNet)
   - **Input**: Screenshots de ambientes de trabalho
   - **Output**: Classificação de tipo de atividade, detecção de distrações
   - **Uso**: Análise de produtividade visual (opcional)

4. **Autoencoders para Detecção de Anomalias**
   - **Arquitetura**: Encoder-Decoder simétrico
   - **Input**: Padrões normais de trabalho
   - **Output**: Reconstruction error para detectar comportamentos anômalos
   - **Uso**: Alerta precoce de problemas de saúde mental

5. **GANs para Geração de Dados Sintéticos (Opcional)**
   - **Arquitetura**: Conditional GAN
   - **Input**: Amostras pequenas de dados reais
   - **Output**: Dados sintéticos para treinar modelos (privacy-preserving)
   - **Uso**: Aumentar dataset sem comprometer privacidade

#### Treinamento e Otimização

- **Regularização**: Dropout, L2, Early Stopping
- **Otimizadores**: Adam, AdamW
- **Learning Rate**: Scheduler com warm-up
- **Batch Size**: 32-128 dependendo do modelo
- **Hardware**: Google Colab GPU / AWS SageMaker

#### Arquivos Relacionados
- `src/apps/analytics_service/neural_networks/` - Implementações
- `src/apps/wellbeing_service/lstm_model.py` - LSTM para bem-estar
- `notebooks/neural_networks_experiments.ipynb` - Experimentos (a criar)

#### Entregável para GS
- **PDF**: Arquiteturas, resultados de treino, análise de erro
- **Vídeo**: Demonstrar previsão LSTM em tempo real
- **Código**: Model definition e training scripts

---

## 📊 Linguagem R

### Aplicação no Projeto

**Contexto**: Como usar R para análises estatísticas profundas?

#### Implementações

1. **Análise Exploratória de Dados (EDA)**
   - Estatísticas descritivas de bem-estar
   - Distribuições de produtividade por perfil
   - Correlações entre variáveis (stress vs tarefas)
   - Testes de hipóteses (t-test, ANOVA, chi-squared)

   ```r
   # Exemplo de análise
   library(tidyverse)
   library(ggplot2)
   
   wellbeing_data %>%
     group_by(user_profile) %>%
     summarise(
       avg_stress = mean(stress_score),
       sd_stress = sd(stress_score)
     ) %>%
     ggplot(aes(x=user_profile, y=avg_stress)) +
     geom_bar(stat="identity") +
     theme_minimal()
   ```

2. **Visualizações Avançadas**
   - Dashboards interativos com Shiny (opcional)
   - Plots estatísticos: boxplots, violin plots, heatmaps
   - Séries temporais com forecast
   - Redes de correlação entre variáveis

3. **Modelagem Estatística**
   - Regressões lineares e logísticas
   - Modelos mistos para dados hierárquicos
   - Time series analysis (ARIMA, Prophet)
   - Survival analysis para churn

4. **Relatórios Automatizados**
   - R Markdown para relatórios reproduzíveis
   - Geração automática de PDFs com análises
   - Integração com pipeline Python (reticulate)

#### Scripts R no Projeto

- `src/apps/analytics_service/r_scripts/eda.R` - Análise exploratória
- `src/apps/analytics_service/r_scripts/statistical_tests.R` - Testes
- `src/apps/analytics_service/r_scripts/visualizations.R` - Plots
- `reports/wellbeing_analysis.Rmd` - Relatório R Markdown (a criar)

#### Arquivos Relacionados
- `src/apps/analytics_service/r_scripts/` - Scripts R
- `reports/` - Relatórios gerados (a criar)

#### Entregável para GS
- **PDF**: Incluir plots e análises estatísticas do R
- **Vídeo**: Mostrar dashboard R ou relatório gerado
- **Código**: Scripts R comentados

---

## 🐍 Python

### Aplicação no Projeto

**Contexto**: Python como linguagem principal do backend e analytics

#### Implementações

1. **Backend Microservices**
   - FastAPI / Flask para APIs RESTful
   - Pydantic para validação de dados
   - SQLAlchemy / DynamoDB SDK para persistência
   - Celery para tarefas assíncronas (opcional)

2. **Pipeline de Dados**
   - pandas para transformações
   - numpy para cálculos numéricos
   - Apache Airflow / Prefect para orquestração (opcional)
   - boto3 para integração AWS

3. **Machine Learning**
   - scikit-learn para modelos clássicos
   - TensorFlow / PyTorch para deep learning
   - MLflow para tracking de experimentos
   - joblib / pickle para serialização de modelos

4. **Integração CrewAI**
   - crewai SDK para orquestração de agentes
   - langchain para LLM integration
   - Prompt engineering para agentes especializados
   - Memory e context management

5. **Automações**
   - Scripts serverless (Lambda handlers)
   - Web scraping para coleta de dados (se necessário)
   - ETL pipelines
   - Scheduled jobs (CloudWatch Events / Cloud Scheduler)

#### Padrões de Código Python

- **Style**: PEP 8, formatado com black, imports com isort
- **Type Hints**: Usar typing em todas as funções
- **Docstrings**: Google style ou NumPy style
- **Testing**: pytest com cobertura 70%+
- **Logging**: structlog / python-json-logger

#### Arquivos Relacionados
- Todo `src/apps/*/` - Todos os microservices em Python
- `src/shared/` - Utilitários compartilhados (a criar)
- `requirements.txt` / `pyproject.toml` - Dependências

#### Entregável para GS
- **PDF**: Código Python comentado (trechos principais)
- **Vídeo**: Mostrar execução de scripts e APIs
- **Código**: Repositório completo em Python

---

## ☁️ Computação em Nuvem

### Aplicação no Projeto

**Contexto**: Arquitetura serverless escalável e econômica

#### Implementações

1. **Arquitetura Serverless**
   - **Compute**: AWS Lambda / Google Cloud Functions / Azure Functions
   - **Storage**: S3 / Cloud Storage / Azure Blob
   - **Database**: DynamoDB / Firestore / CosmosDB
   - **API Gateway**: AWS API Gateway / Cloud Endpoints
   - **Messaging**: SQS / Pub/Sub / Service Bus

2. **Infrastructure as Code (IaC)**
   - Terraform / Serverless Framework / SAM
   - Versionamento de infraestrutura
   - Ambientes (dev, staging, prod)
   - Rollback automático em caso de falhas

3. **CI/CD Pipeline**
   - GitHub Actions para build e deploy
   - Testes automatizados antes de deploy
   - Deploy gradual (canary / blue-green)
   - Rollback automático se métricas degradarem

4. **Monitoramento e Observabilidade**
   - CloudWatch / Cloud Monitoring / Azure Monitor
   - Métricas customizadas (latência, erros, uso)
   - Logs centralizados
   - Alertas em tempo real (SNS / PagerDuty)
   - Distributed tracing (X-Ray / Cloud Trace)

5. **Otimização de Custos**
   - Pay-per-use: só paga quando usa
   - Reserved capacity onde faz sentido
   - Auto-scaling baseado em demanda
   - Cold start optimization

6. **Segurança Cloud-Native**
   - IAM roles com princípio de least privilege
   - VPC / Security Groups quando necessário
   - Secrets Manager para credenciais
   - Encryption padrão em todos os serviços

#### Diagrama de Deploy

```
GitHub → GitHub Actions (CI/CD)
           ↓
    Build & Test
           ↓
    Package Lambdas/Functions
           ↓
    Deploy to Cloud (Terraform/Serverless)
           ↓
    Run Integration Tests
           ↓
    Production (with monitoring)
```

#### Arquivos Relacionados
- `.github/workflows/` - GitHub Actions workflows (a criar)
- `infrastructure/` - IaC configs (a criar)
- `serverless.yml` ou `terraform/` - Definição de infra

#### Entregável para GS
- **PDF**: Diagrama de arquitetura cloud, custos estimados
- **Vídeo**: Demonstrar escalabilidade e serverless em ação
- **Código**: IaC scripts e configs de deploy

---

## 💾 Banco de Dados

### Aplicação no Projeto

**Contexto**: Modelagem híbrida para diferentes tipos de dados

#### Implementações

1. **NoSQL - Eventos e Logs (DynamoDB / Firestore)**
   - **Tabela**: `wellbeing_events`
     - PK: `user_id#timestamp`
     - Attributes: event_type, value, metadata
   - **Tabela**: `collaboration_sessions`
     - PK: `session_id`
     - GSI: user_id para queries por usuário
   - **Vantagens**: Escalabilidade, baixa latência, schema-less

2. **SQL Serverless - Dados Relacionais (Aurora Serverless / Cloud SQL)**
   - **Tabela**: `users`
     - id, email, name, profile_type, created_at
   - **Tabela**: `tasks`
     - id, user_id, title, status, priority, due_date
   - **Tabela**: `recruitment_candidates`
     - id, name, skills[], experience[], diversity_tags[]
   - **Relacionamentos**: Foreign keys, joins para queries complexas
   - **Vantagens**: ACID, queries complexas, integridade referencial

3. **Vector Database - Embeddings para IA (Pinecone / Chroma)**
   - Embeddings de documentos e conhecimento
   - Similarity search para recomendações
   - RAG (Retrieval Augmented Generation) para agentes

4. **Cache - Redis / Memcached**
   - Cache de queries frequentes
   - Session storage
   - Rate limiting counters
   - Pub/sub para real-time features

5. **Object Storage - S3 / Cloud Storage**
   - Arquivos de usuários
   - Datasets para ML
   - Backups e archives
   - Static assets

#### Modelagem de Dados

**Exemplo: Wellbeing Service**

```sql
-- SQL (Aurora Serverless)
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wellbeing_summary (
    user_id UUID REFERENCES users(id),
    date DATE,
    avg_stress_score FLOAT,
    total_breaks INT,
    risk_level VARCHAR(20),
    PRIMARY KEY (user_id, date)
);
```

```json
// NoSQL (DynamoDB)
{
  "PK": "USER#user-123",
  "SK": "EVENT#2025-11-10T14:30:00Z",
  "event_type": "stress_measurement",
  "value": 7.5,
  "metadata": {
    "source": "manual_input",
    "context": "after_meeting"
  },
  "ttl": 1762214400  // Expira após 1 ano
}
```

#### Estratégias

- **CQRS**: Separar reads e writes para performance
- **Event Sourcing**: Histórico completo de eventos (wellbeing)
- **Data Partitioning**: Por usuário ou time range
- **Backups**: Snapshots diários, point-in-time recovery
- **Data Retention**: Políticas de TTL e archiving

#### Arquivos Relacionados
- `src/apps/*/models.py` - Modelos de dados
- `src/apps/*/schemas/` - Schemas de validação
- `infrastructure/database/` - Scripts de setup (a criar)
- `migrations/` - Database migrations (a criar)

#### Entregável para GS
- **PDF**: Diagramas ER, explicação de escolhas de DB
- **Vídeo**: Mostrar queries e persistência de dados
- **Código**: Models, migrations, queries

---

## 🌍 Formação Social

### Aplicação no Projeto

**Contexto**: Análise do impacto social, inclusão e ética

#### Implementações

1. **Inclusão no Recrutamento**
   - **Problema**: Viés inconsciente em seleções tradicionais
   - **Solução**: IA que detecta e corrige viés em processos seletivos
   - **Impacto**: Aumentar diversidade e equidade nas contratações
   - **Métricas**: Disparate impact, equal opportunity
   - **Explicabilidade**: SHAP values para entender decisões

2. **Bem-Estar e Saúde Mental**
   - **Problema**: Burnout crescente no trabalho moderno
   - **Solução**: Monitoramento proativo e intervenções preventivas
   - **Impacto**: Reduzir afastamentos, melhorar qualidade de vida
   - **Ética**: Consentimento, privacidade, não discriminação

3. **Sustentabilidade e Trabalho Verde**
   - **Problema**: Impacto ambiental do trabalho (deslocamento, energia)
   - **Solução**: Medição e otimização de carbon footprint
   - **Impacto**: Conscientização e redução de emissões
   - **Social**: Trabalho remoto como ferramenta de inclusão geográfica

4. **Democratização do Conhecimento**
   - **Problema**: Acesso desigual a oportunidades de aprendizado
   - **Solução**: Gamificação e agentes IA para aprendizado personalizado
   - **Impacto**: Upskilling e reskilling acessíveis
   - **Social**: Reduzir gap de habilidades digitais

5. **Trabalho Híbrido Inclusivo**
   - **Problema**: Exclusão de trabalhadores remotos em decisões
   - **Solução**: Ambientes colaborativos que equalizam presencial e remoto
   - **Impacto**: Inclusão de pessoas com deficiência, cuidadores, etc
   - **Social**: Flexibilidade como direito, não privilégio

#### Análise de Impacto Social

**Dimensões Analisadas**:
1. **Equidade**: Todos têm acesso igual às ferramentas?
2. **Privacidade**: Dados pessoais são protegidos?
3. **Autonomia**: Usuários têm controle sobre a tecnologia?
4. **Transparência**: Decisões de IA são explicáveis?
5. **Sustentabilidade**: Solução é ambientalmente responsável?

#### Estudos de Caso (para PDF)

1. **Caso 1**: Como agente IA reduziu viés de gênero em 30% no recrutamento
2. **Caso 2**: Impacto do monitoramento de bem-estar na retenção de talentos
3. **Caso 3**: Redução de 15% no carbon footprint com recomendações sustentáveis

#### Arquivos Relacionados
- `docs/social-impact-analysis.md` - Análise completa (a criar)
- `docs/ethics-guidelines.md` - Diretrizes éticas (a criar)

#### Entregável para GS
- **PDF**: Seção dedicada a análise social e ética
- **Vídeo**: Explicar impacto social esperado
- **Relatório**: Métricas de inclusão e equidade

---

## 🎬 AI Challenge

### Aplicação no Projeto

**Contexto**: Vídeo integrador explicando todas as disciplinas

#### Estrutura do Vídeo (7 minutos)

**Roteiro Sugerido**:

```
[0:00 - 0:30] ABERTURA
- "Olá, somos o grupo [NOME]"
- "QUERO CONCORRER ao pódio da GS 2025.2"
- Apresentação rápida dos membros
- Tema: SymbioWork - O Futuro do Trabalho

[0:30 - 1:30] PROBLEMA E SOLUÇÃO
- Desafio: Tornar trabalho mais humano, inclusivo e sustentável
- Problemas atuais: burnout, viés em RH, impacto ambiental
- Nossa solução: Ecossistema de agentes IA + ambientes adaptativos
- Diferenciais: CrewAI, serverless, multi-disciplinar

[1:30 - 3:00] DEMONSTRAÇÃO TÉCNICA
- Login no sistema (Cybersecurity)
- Dashboard de bem-estar (Machine Learning + Redes Neurais)
- Agentes IA em ação (AICSS + Python + CrewAI)
- Recrutamento inclusivo (Formação Social + ML)
- Sustentabilidade (Green Work + Analytics)

[3:00 - 5:00] INTEGRAÇÃO DISCIPLINAR
- AICSS: Governança de IA, agentes éticos
- Cybersecurity: Criptografia, LGPD compliance
- Machine Learning: 5 modelos implementados
- Redes Neurais: LSTM para previsão de bem-estar
- Linguagem R: Análises estatísticas, visualizações
- Python: Backend serverless, pipelines
- Computação em Nuvem: Arquitetura AWS/GCP, escalabilidade
- Banco de Dados: Modelagem híbrida NoSQL+SQL
- Formação Social: Análise de impacto, inclusão, ética

[5:00 - 6:30] AGENTES IA E RESULTADOS
- Agente de Produtividade: otimização de tarefas
- Agente de Bem-Estar: alertas preventivos
- Agente de Aprendizado: recomendações de cursos
- Resultados: métricas, gráficos, insights
- Código em produção: mostrar serverless funcionando

[6:30 - 7:00] CONCLUSÃO
- Aprendizados do projeto
- Impacto esperado no futuro do trabalho
- Próximos passos e escalabilidade
- Agradecimentos
- "Obrigado! Vamos construir um futuro de trabalho mais humano!"
```

#### Checklist de Gravação

- [ ] Equipamento: câmera/celular de boa qualidade
- [ ] Iluminação adequada
- [ ] Áudio limpo (microfone externo recomendado)
- [ ] Ambiente organizado ao fundo
- [ ] Roteiro ensaiado
- [ ] Demos testadas antes de gravar
- [ ] Edição: cortes, transições, legendas (opcional)
- [ ] Duração: máximo 7 minutos
- [ ] Formato: MP4, 1080p recomendado

#### Pós-Produção

1. **Edição**:
   - Cortar erros e silêncios longos
   - Adicionar legendas (acessibilidade)
   - Inserir screen recordings das demos
   - Música de fundo suave (opcional)
   
2. **Upload YouTube**:
   - Configurar como "Não listado"
   - Título: "SymbioWork - GS 2025.2 FIAP - Grupo [NOME]"
   - Descrição: Breve resumo do projeto
   - Tags: FIAP, GS2025, IA, Futuro do Trabalho
   
3. **Link no PDF**:
   - Copiar URL completa (não mascarar)
   - Exemplo: `https://www.youtube.com/watch?v=XXXXXXXXXXX`
   - Inserir ao final do PDF, seção "Anexos"

#### Arquivos Relacionados
- `assets/video/` - Recursos para vídeo (a criar)
- `docs/video-script.md` - Roteiro detalhado (a criar)

#### Entregável para GS
- **Vídeo**: Postado no YouTube (não listado)
- **PDF**: Link completo do YouTube sem mascaramento
- **Qualidade**: Áudio e vídeo claros, demonstração convincente

---

## ✅ Checklist de Integração Disciplinar

Use esta checklist para garantir que todas as disciplinas estão adequadamente representadas:

### AICSS
- [ ] Agentes IA implementados com considerações éticas
- [ ] Explicabilidade em decisões críticas
- [ ] Políticas de governança documentadas

### Cybersecurity
- [ ] Autenticação OAuth2 + JWT
- [ ] Criptografia de dados sensíveis
- [ ] Compliance LGPD/GDPR
- [ ] Auditoria e logging

### Machine Learning
- [ ] Pelo menos 3 modelos treinados
- [ ] Métricas de avaliação documentadas
- [ ] Pipeline de dados implementado

### Redes Neurais
- [ ] Pelo menos 1 arquitetura neural implementada (LSTM/CNN/Transformer)
- [ ] Treinamento documentado com gráficos
- [ ] Modelo deployado em produção

### Linguagem R
- [ ] Scripts R para análises estatísticas
- [ ] Visualizações criadas com ggplot2
- [ ] Relatório ou dashboard em R (opcional)

### Python
- [ ] Backend em Python (FastAPI/Flask)
- [ ] Scripts de automação e ETL
- [ ] Testes unitários com pytest

### Computação em Nuvem
- [ ] Arquitetura serverless implementada
- [ ] IaC (Terraform/Serverless Framework)
- [ ] CI/CD com GitHub Actions
- [ ] Monitoramento configurado

### Banco de Dados
- [ ] Modelagem de dados (ER diagram)
- [ ] Implementação NoSQL e/ou SQL
- [ ] Queries complexas documentadas
- [ ] Estratégia de backup

### Formação Social
- [ ] Análise de impacto social no PDF
- [ ] Métricas de inclusão e equidade
- [ ] Considerações éticas documentadas

### AI Challenge
- [ ] Vídeo gravado (máx 7 min)
- [ ] "QUERO CONCORRER" mencionado
- [ ] Integração de disciplinas explicada
- [ ] Postado no YouTube (não listado)
- [ ] Link no PDF

---

## 📊 Tabela Resumo: Disciplina × Componente

| Disciplina | Componente Principal | Artefato Chave | Demonstração no Vídeo |
|------------|---------------------|----------------|------------------------|
| AICSS | Agents Orchestrator | Agentes éticos com explicabilidade | Agentes tomando decisões transparentes |
| Cybersecurity | Auth Service | Sistema de autenticação + criptografia | Login seguro, dados protegidos |
| Machine Learning | Analytics Service | 5 modelos ML treinados | Predições em tempo real |
| Redes Neurais | Wellbeing Service | LSTM para previsão de bem-estar | Gráfico de previsão |
| Linguagem R | Analytics R Scripts | Análises estatísticas e plots | Dashboard ou relatório R |
| Python | Todos os microservices | Backend serverless completo | APIs respondendo |
| Computação em Nuvem | Infra (AWS/GCP) | Deploy serverless funcionando | Escalabilidade, logs cloud |
| Banco de Dados | Database layer | Modelagem híbrida NoSQL+SQL | Queries e persistência |
| Formação Social | Recruitment + Green | Análise de impacto social | Métricas de inclusão |
| AI Challenge | Vídeo 7min | Vídeo integrador | O próprio vídeo |

---

## 🎓 Conclusão

Este projeto demonstra aplicação prática e integrada de **todas as disciplinas** do curso, criando uma solução inovadora, ética e sustentável para o futuro do trabalho.

**Próximos passos**: Consultar os roadmaps individuais de cada app para começar a implementação!
