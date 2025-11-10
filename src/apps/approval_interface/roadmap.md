# Approval Interface - Roadmap

## ✅ Visão Geral

Interface unificada para professores e coordenadores aprovarem, editarem e conversarem com todas as ações geradas por agentes de IA.

### Responsabilidades
- Dashboard unificado de aprovações
- Edição inline de conteúdos gerados
- Chat com agentes para ajustes
- Histórico de aprovações
- Notificações e alerts

---

## 🎯 Funcionalidades

### 1. Dashboard Unificado
- Visão de todas ações pendentes de aprovação:
  - Code reviews
  - Correções automatizadas
  - Rankings de premiação
  - Conteúdos gerados (vídeos, podcasts)
  - Issues de revisão de conteúdo
- Filtros (tipo, disciplina, data, prioridade)
- Contador de pendências

### 2. Preview e Edição
- Visualização do que foi gerado
- Edição inline com autosave
- Comparação antes/depois
- Cancelar alterações

### 3. Chat com Agentes
- Conversa contextual com agente responsável
- Comandos de ajuste:
  - "Mude o tom para mais encorajador"
  - "Reduza a nota de 8 para 7"
  - "Adicione mais exemplos práticos"
  - "Regenere esta seção"
- Histórico de conversas

### 4. Aprovação com 1 Clique
- Botão de aprovação rápida
- Confirmação se mudanças críticas
- Ação automática após aprovação:
  - Postar comment no GitHub
  - Publicar nota no sistema
  - Upload de vídeo para YouTube
  - Enviar notificação para alunos

### 5. Aprovação em Massa
- Selecionar múltiplos items
- Aprovar todos de uma vez
- Filtros para seleção (ex: todos code reviews com score > 90)

### 6. Histórico e Auditoria
- Log de todas aprovações
- Quem aprovou o quê e quando
- Edições feitas
- Conversas com agentes
- Reversão (se necessário)

---

## 📋 Tarefas de Implementação

### Fase 1: Dashboard Frontend (Flutter Web)
- [ ] Página inicial com resumo:
  ```
  Pendente de Aprovação:
  - 12 Code Reviews
  - 8 Correções
  - 2 Rankings de Premiação
  - 3 Vídeos Gerados
  - 15 Issues de Revisão
  
  Total: 40 items
  ```
- [ ] Lista de items com cards
- [ ] Filtros:
  - Tipo
  - Disciplina
  - Prioridade (crítico, importante, normal)
  - Data (hoje, esta semana, este mês)
  - Status (pending, in_review, approved, rejected)

### Fase 2: Preview e Edição

#### Code Reviews
- [ ] Diff view do código
- [ ] Comentários gerados destacados
- [ ] Editor de Markdown para editar feedback
- [ ] Preview de como aparecerá no GitHub

#### Correções
- [ ] Tabela de critérios com notas
- [ ] Feedback completo
- [ ] Edição de notas inline (slider ou input)
- [ ] Editor de texto para feedback

#### Rankings
- [ ] Tabela com ranking
- [ ] Justificativas expandíveis
- [ ] Edição de pontuações
- [ ] Reordenação manual (drag and drop)

#### Conteúdos Gerados
- [ ] Player de vídeo/áudio
- [ ] Transcrição/roteiro
- [ ] Edição de metadados (título, descrição, tags)
- [ ] Botão de re-geração

#### Issues de Revisão
- [ ] Localização do erro (highlight)
- [ ] Sugestão de correção
- [ ] Botões: Aceitar / Ignorar / Editar

### Fase 3: Chat com Agentes
- [ ] Interface de chat (sidebar ou modal)
- [ ] Contexto do item em discussão carregado automaticamente
- [ ] Sugestões de comandos comuns:
  - "Regenerar com mais exemplos"
  - "Simplificar linguagem"
  - "Aumentar nota para X"
  - "Adicionar comentário sobre Y"
- [ ] Respostas do agente em tempo real
- [ ] Aplicação automática de mudanças sugeridas
- [ ] Opção de "aplicar e aprovar" em 1 clique

Exemplo de UI:
```
┌─────────────────────────────────────────────┐
│ Chat com Grading Agent                      │
├─────────────────────────────────────────────┤
│ Você: A nota de documentação está muito    │
│       alta. Reduza para 7.                  │
│                                             │
│ Agente: ✓ Nota de documentação atualizada  │
│         de 9 para 7. A nota final passa de │
│         8.5 para 8.2. Deseja aplicar?       │
│                                             │
│         [Aplicar] [Cancelar]                │
│                                             │
│ Você: [input field...]              [Send] │
└─────────────────────────────────────────────┘
```

### Fase 4: Aprovação
- [ ] Botão "Aprovar" proeminente
- [ ] Confirmação se crítico:
  - "Tem certeza? Esta ação publicará a nota de 10 alunos."
  - [Cancelar] [Sim, aprovar]
- [ ] Loading state durante processamento
- [ ] Mensagem de sucesso:
  - "✓ Code review aprovado e postado no GitHub"
  - "✓ Notas publicadas no sistema FIAP"
  - "✓ Vídeo enviado para YouTube"
- [ ] Toast notifications

### Fase 5: Aprovação em Massa
- [ ] Checkboxes em cada card
- [ ] "Selecionar todos" (com filtros aplicados)
- [ ] Botão "Aprovar Selecionados (N items)"
- [ ] Preview de ações a serem executadas
- [ ] Confirmação obrigatória
- [ ] Progress bar durante execução
- [ ] Resumo ao final:
  ```
  Aprovados: 10/10
  ✓ 8 code reviews postados
  ✓ 2 notas publicadas
  
  Erros: 0
  ```

### Fase 6: Rejeição e Feedback
- [ ] Botão "Rejeitar" com motivo obrigatório
- [ ] Feedback volta para o agente
- [ ] Agente aprende com rejeições (opcional: reinforcement learning)
- [ ] Re-geração automática com ajustes

### Fase 7: Histórico e Auditoria
- [ ] Página de histórico
- [ ] Filtros (por professor, tipo, data)
- [ ] Detalhes de cada aprovação:
  - O que foi aprovado
  - Edições feitas
  - Conversas com agente
  - Timestamp
- [ ] Exportação de logs (CSV, JSON)
- [ ] Compliance e auditoria (LGPD)

### Fase 8: Notificações
- [ ] Push notifications (Web Push API)
- [ ] Email digest diário:
  ```
  Olá Prof. João,
  
  Você tem 5 items pendentes de aprovação:
  - 3 code reviews urgentes
  - 2 correções de trabalhos
  
  [Ir para Dashboard]
  ```
- [ ] Badge counter no ícone do app
- [ ] Configurações de notificações (frequência, tipos)

### Fase 9: Mobile (Flutter)
- [ ] Versão mobile responsiva
- [ ] Navegação otimizada para mobile
- [ ] Aprovação rápida com swipe gestures
- [ ] Push notifications nativas

### Fase 10: Testes e Deploy
- [ ] Testes de usabilidade com professores
- [ ] A/B testing de fluxos de aprovação
- [ ] Performance testing (muitos items)
- [ ] Deploy

---

## 🔌 Endpoints (Backend)

- `GET /api/v1/approvals/pending` - Lista items pendentes
- `GET /api/v1/approvals/{id}` - Detalhes do item
- `PUT /api/v1/approvals/{id}/edit` - Editar antes de aprovar
- `POST /api/v1/approvals/{id}/chat` - Enviar mensagem ao agente
- `POST /api/v1/approvals/{id}/approve` - Aprovar
- `POST /api/v1/approvals/{id}/reject` - Rejeitar
- `POST /api/v1/approvals/bulk-approve` - Aprovação em massa
- `GET /api/v1/approvals/history` - Histórico
- `GET /api/v1/approvals/stats` - Estatísticas

---

## 🎨 UI/UX Design

### Princípios
1. **Eficiência**: Aprovação rápida (< 30s por item)
2. **Clareza**: Preview claro do que está sendo aprovado
3. **Controle**: Sempre possível editar antes de aprovar
4. **Confiança**: Confirmações para ações críticas
5. **Transparência**: Histórico completo e auditável

### Tema Claro/Escuro
- [ ] Light mode (padrão)
- [ ] Dark mode
- [ ] Auto (seguir sistema)
- [ ] Salvar preferência por usuário

### Cores
- **Pendente**: Amarelo/Laranja
- **Aprovado**: Verde
- **Rejeitado**: Vermelho
- **Em Revisão**: Azul
- **Crítico**: Vermelho escuro

---

## 📊 Database Schema

### Table: approval_items
```
PK: approval_id
Attributes:
  - type (code_review, grading, award, content, issue)
  - related_id (ex: review_id, grading_id)
  - title
  - description
  - generated_content (JSON)
  - priority (critical, high, normal, low)
  - status (pending, in_review, approved, rejected)
  - assigned_to (professor_id)
  - created_at
  - reviewed_at
  - approved_at
```

### Table: approval_edits
```
PK: edit_id
Attributes:
  - approval_id
  - field_changed
  - old_value
  - new_value
  - changed_by
  - timestamp
```

### Table: approval_chats
```
PK: message_id
Attributes:
  - approval_id
  - sender (user, agent)
  - message
  - timestamp
```

---

## 📈 Métricas

- **Time to Approval**: Tempo médio para aprovar (alvo: < 2 minutos)
- **Approval Rate**: % de items aprovados vs rejeitados (alvo: > 85%)
- **Edit Rate**: % de items editados antes de aprovar
- **Bulk Approval Usage**: % de aprovações em massa
- **User Satisfaction**: Pesquisa com professores (alvo: 4+/5)

---

## ✅ Critérios de Aceitação

- [ ] Dashboard unificado funcional
- [ ] Preview e edição de todos tipos de items
- [ ] Chat com agentes funcionando
- [ ] Aprovação com 1 clique
- [ ] Aprovação em massa
- [ ] Histórico e auditoria
- [ ] Notificações (push + email)
- [ ] Tema claro/escuro
- [ ] Versão mobile responsiva
- [ ] Tempo médio de aprovação < 2 min
- [ ] Satisfação de usuários > 4/5
- [ ] Deploy

---

## 📚 Referências

- [Admin Dashboard Best Practices](https://uxdesign.cc/)
- [Approval Workflows](https://www.process.st/)
- [Chat UI Design](https://sendbird.com/developer/tutorials/chat-ui-kit)
- [Material Design 3](https://m3.material.io/)
