# Research Management - Roadmap

## 🔬 Visão Geral

Sistema integrado de gestão de iniciação científica que garante que nenhum aluno seja esquecido ou deixado para trás.

### Responsabilidades
- Gerenciar grupos de IC
- Acompanhar progresso de projetos
- Notificações e alertas automáticos
- Relatórios para coordenadores
- Interface para alunos e orientadores

---

## 🎯 Funcionalidades

### 1. Gestão de Grupos
- Cadastro de projetos de IC
- Formação de grupos (alunos + orientador)
- Distribuição equilibrada de orientandos
- Histórico de participação

### 2. Acompanhamento de Progresso
- Milestones e deadlines
- Check-ins regulares
- Entregáveis esperados
- Status de cada projeto (on track, at risk, delayed)

### 3. Sistema de Alertas
- Alunos sem orientador há > 2 semanas
- Projetos sem atualização há > 1 mês
- Deadlines próximos
- Reuniões agendadas

### 4. Relatórios para Coordenadores
- Dashboard com visão geral
- Grupos ativos vs inativos
- Taxa de conclusão
- Alunos em risco de abandono

### 5. Interface para Alunos
- Ver status do projeto
- Submeter atualizações
- Comunicar com orientador
- Acessar recursos e templates

---

## 📋 Tarefas de Implementação

### Fase 1: CRUD de Projetos e Grupos
- [ ] Endpoints:
  - `POST /api/v1/research/projects` - Criar projeto
  - `GET /api/v1/research/projects` - Listar projetos
  - `GET /api/v1/research/projects/{id}` - Detalhes
  - `PUT /api/v1/research/projects/{id}` - Atualizar
  - `DELETE /api/v1/research/projects/{id}` - Arquivar
- [ ] Cadastro de membros (alunos, orientadores)
- [ ] Definição de milestones
- [ ] Upload de documentos

### Fase 2: Sistema de Acompanhamento
- [ ] Timeline de projeto
- [ ] Check-in semanal/mensal
- [ ] Registro de reuniões
- [ ] Log de atualizações
- [ ] Indicadores de saúde do projeto:
  ```
  🟢 On Track: Tudo OK
  🟡 At Risk: Atrasos leves ou falta de comunicação
  🔴 Critical: Atrasos significativos ou abandono iminente
  ```

### Fase 3: Sistema de Alertas
- [ ] Agente de monitoramento (scheduled job)
- [ ] Regras de alerta:
  - Aluno sem orientador > 14 dias → notificar coordenador
  - Projeto sem update > 30 dias → notificar todos
  - Deadline em 7 dias → notificar grupo
  - Reunião em 24h → lembrete
- [ ] Notificações:
  - Email
  - Push notification (app Flutter)
  - WhatsApp (Twilio API, opcional)

### Fase 4: Dashboard para Coordenadores
- [ ] Visão geral de todos os projetos
- [ ] Filtros (status, área, orientador)
- [ ] Métricas:
  - Total de projetos ativos
  - Taxa de conclusão
  - Média de alunos por orientador
  - Projetos em risco
- [ ] Lista de alunos sem orientador
- [ ] Ações rápidas (atribuir orientador, arquivar projeto)

### Fase 5: Interface para Alunos e Orientadores
- [ ] Dashboard do projeto
- [ ] Formulário de atualização de progresso
- [ ] Chat/comentários
- [ ] Calendário de reuniões
- [ ] Biblioteca de recursos (templates, guias)

### Fase 6: Integração com Sistema FIAP
- [ ] API ou RPA para sincronizar dados
- [ ] Importar alunos e orientadores
- [ ] Exportar relatórios
- [ ] Single Sign-On (SSO)

### Fase 7: Testes e Deploy
- [ ] Testes com dados reais (anonimizados)
- [ ] Validação com coordenadores
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `POST /api/v1/research/projects` - Criar projeto
- `GET /api/v1/research/projects` - Listar (com filtros)
- `GET /api/v1/research/projects/{id}` - Detalhes
- `PUT /api/v1/research/projects/{id}` - Atualizar
- `POST /api/v1/research/projects/{id}/members` - Adicionar membro
- `POST /api/v1/research/projects/{id}/updates` - Submeter atualização
- `GET /api/v1/research/projects/{id}/timeline` - Linha do tempo
- `GET /api/v1/research/dashboard/coordinator` - Dashboard coordenador
- `GET /api/v1/research/alerts` - Alertas ativos
- `POST /api/v1/research/alerts/{id}/resolve` - Resolver alerta

---

## 📊 Database Schema

### Table: research_projects
```
PK: project_id
Attributes:
  - title
  - description
  - area (CS, ML, Networks, etc)
  - status (proposal, active, paused, completed, archived)
  - health_status (on_track, at_risk, critical)
  - start_date
  - expected_end_date
  - actual_end_date
  - created_at
```

### Table: project_members
```
PK: project_id#user_id
Attributes:
  - project_id
  - user_id
  - role (student, advisor, co-advisor, coordinator)
  - joined_at
  - left_at
```

### Table: project_updates
```
PK: update_id
Attributes:
  - project_id
  - submitted_by (user_id)
  - content (Markdown)
  - milestone_completed
  - files_attached (URLs)
  - timestamp
```

### Table: alerts
```
PK: alert_id
Attributes:
  - type (no_advisor, no_update, deadline_soon, meeting_reminder)
  - project_id
  - user_id
  - message
  - severity (info, warning, critical)
  - status (active, resolved, dismissed)
  - created_at
  - resolved_at
```

---

## 📈 Dashboard Metrics

### Para Coordenadores
- Total de projetos: 45 (38 ativos, 7 arquivados)
- Taxa de conclusão: 78%
- Média alunos/orientador: 3.2
- Projetos em risco: 5 (11%)
- Alunos sem orientador: 2 ⚠️

### Para Orientadores
- Meus orientandos: 4
- Projetos ativos: 4
- Reuniões esta semana: 2
- Updates pendentes: 1

### Para Alunos
- Meu projeto: "ML for Image Classification"
- Status: 🟢 On Track
- Próximo milestone: "Completar treinamento de modelo" (em 10 dias)
- Última reunião: há 5 dias
- Próxima reunião: em 2 dias

---

## 🔔 Exemplos de Alertas

```
🔴 CRITICAL: Aluno João Silva está sem orientador há 18 dias
   Ação: Atribuir orientador imediatamente

🟡 WARNING: Projeto "Deep Learning for NLP" sem updates há 35 dias
   Ação: Contatar grupo para atualização

🟢 INFO: Deadline do projeto "IoT Healthcare" em 7 dias
   Ação: Lembrete enviado ao grupo

📅 REMINDER: Reunião com Prof. Ana às 14h hoje
   Ação: Confirmar presença
```

---

## ✅ Critérios de Aceitação

- [ ] CRUD de projetos e membros funcionando
- [ ] Sistema de acompanhamento com timeline
- [ ] Alertas automáticos configurados
- [ ] Dashboard para coordenadores funcional
- [ ] Interface para alunos e orientadores
- [ ] Notificações (email + app)
- [ ] Integração com sistema FIAP (se viável)
- [ ] Nenhum aluno fica sem orientador > 14 dias
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [Project Management Best Practices](https://www.pmi.org/)
- [Student Success Tracking](https://www.educause.edu/)
- [Academic Research Management Systems](https://en.wikipedia.org/wiki/Research_information_system)
