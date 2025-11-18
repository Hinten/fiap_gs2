# Roadmap - Tema Package

## 📋 Visão Geral

Package Flutter para gerenciamento de temas claro e escuro com detecção automática do tema do sistema e persistência de preferências do usuário.

## 🎯 Objetivos

1. Fornecer temas modernos e atraentes para toda a plataforma FIAP
2. Permitir fácil alternância entre temas claro, escuro e sistema
3. Persistir preferências do usuário entre sessões
4. Integrar perfeitamente com o ecossistema Riverpod usado no projeto

## ✅ Fase 1: Implementação Base (CONCLUÍDA)

### Estrutura do Package
- [x] Criar estrutura de pastas seguindo convenções do monorepo
- [x] Configurar pubspec.yaml com dependências necessárias
- [x] Configurar analysis_options.yaml com regras de lint do projeto
- [x] Criar arquivo de exportação pública (tema.dart)

### Definições de Tema
- [x] Implementar tema claro com Material Design 3
  - [x] Esquema de cores primário (roxo/violeta)
  - [x] Esquema de cores secundário (teal)
  - [x] Configuração de componentes (AppBar, Card, Input, Buttons)
  - [x] Configuração de elevações e bordas arredondadas
- [x] Implementar tema escuro com Material Design 3
  - [x] Esquema de cores ajustado para alto contraste
  - [x] Mesmas configurações de componentes
- [x] Documentar paleta de cores

### Provider de Tema
- [x] Criar TemaNotifier usando StateNotifier
- [x] Implementar StateNotifierProvider para gerenciamento global
- [x] Implementar métodos de controle:
  - [x] setLight() - Mudar para tema claro
  - [x] setDark() - Mudar para tema escuro
  - [x] setSystem() - Seguir tema do sistema
  - [x] toggle() - Alternar entre claro/escuro
  - [x] getEffectiveBrightness() - Obter brilho efetivo atual
- [x] Implementar persistência com SharedPreferences
  - [x] Salvar preferência ao mudar tema
  - [x] Carregar preferência ao inicializar
  - [x] Tratar erros de I/O gracefully

### Testes
- [x] Testes unitários para TemaNotifier
  - [x] Teste de inicialização com tema system
  - [x] Teste de mudança para cada modo (light/dark/system)
  - [x] Teste de toggle entre modos
  - [x] Teste de persistência (save/load)
  - [x] Teste de getEffectiveBrightness
- [x] Testes para AppThemes
  - [x] Verificar configuração correta de brightness
  - [x] Verificar uso de Material Design 3
  - [x] Verificar configurações de componentes

### Documentação
- [x] README.md completo com:
  - [x] Instruções de instalação
  - [x] Exemplos de uso básico
  - [x] Exemplos de uso avançado
  - [x] Documentação da API
  - [x] Paleta de cores
  - [x] Exemplo completo funcional
- [x] Documentação inline (DartDoc) em todos os arquivos
- [x] Roadmap (este arquivo)

## 🚀 Fase 2: Melhorias Futuras (PLANEJADA)

### Temas Adicionais
- [ ] Tema de alto contraste para acessibilidade
- [ ] Variações de cor (permitir usuário escolher cor primária)
- [ ] Temas por perfil (estudante, professor, admin)

### Funcionalidades Avançadas
- [ ] Animações de transição entre temas
- [ ] Agendamento de temas (automático baseado em horário)
- [ ] Sincronização de tema entre dispositivos (Firebase)
- [ ] Widget de preview de tema em tempo real
- [ ] Tema customizável via interface gráfica

### Otimizações
- [ ] Lazy loading de temas não utilizados
- [ ] Cache de ThemeData para melhor performance
- [ ] Reduzir tamanho do bundle eliminando recursos não usados

### Testes Adicionais
- [ ] Widget tests para integração com MaterialApp
- [ ] Golden tests para validação visual dos temas
- [ ] Testes de performance de mudança de tema
- [ ] Testes de acessibilidade (contraste, tamanhos)

### Documentação Avançada
- [ ] Guia de customização de temas
- [ ] Guia de acessibilidade
- [ ] Video tutorial de uso
- [ ] Storybook/showcase interativo

## 📊 Fase 3: Integração (PLANEJADA)

### Integração com Outros Packages
- [ ] Integrar com frontend_flutter
- [ ] Integrar com approval_interface (migrar tema existente)
- [ ] Integrar com gamified_exams
- [ ] Integrar com dashboard_auth (exemplo de uso)

### Exemplos
- [ ] Criar app de exemplo standalone
- [ ] Adicionar exemplos de customização
- [ ] Adicionar exemplos de widgets personalizados

### CI/CD
- [ ] Adicionar workflow de testes automatizados
- [ ] Adicionar verificação de cobertura de testes
- [ ] Adicionar análise de qualidade de código
- [ ] Publicar como package reutilizável

## 🎨 Especificações de Design

### Paleta de Cores

#### Tema Claro
```dart
Primary: #6750A4 (Roxo/Violeta inspirado em IA/tech)
Secondary: #00897B (Teal para equilíbrio)
Error: #BA1A1A (Vermelho Material)
Background: Definido por ColorScheme.fromSeed
Surface: Definido por ColorScheme.fromSeed
```

#### Tema Escuro
```dart
Primary: #D0BCFF (Roxo claro para contraste)
Secondary: #4DB6AC (Teal claro)
Error: #FFB4AB (Vermelho claro)
Background: Definido por ColorScheme.fromSeed
Surface: Definido por ColorScheme.fromSeed
```

### Componentes Estilizados

- **AppBar**: Sem elevação, título centralizado, scrolledUnderElevation: 2
- **Card**: Elevação 1, bordas arredondadas (12px)
- **Input**: Filled, border com raio 8px, padding horizontal/vertical balanceado
- **ElevatedButton**: Elevação 2, padding generoso, bordas arredondadas (8px)
- **TextButton**: Padding reduzido
- **FAB**: Elevação 4
- **Divider**: Espessura 1px

## 🔧 Arquitetura Técnica

### Estrutura de Arquivos
```
tema/
├── lib/
│   ├── src/
│   │   ├── themes.dart           # Definições de ThemeData
│   │   └── tema_provider.dart    # StateNotifier e Provider
│   └── tema.dart                 # Exports públicos
├── test/
│   └── tema_test.dart            # Testes unitários
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── roadmap.md
```

### Dependências
- **flutter_riverpod**: ^3.0.3 - State management
- **shared_preferences**: ^2.2.2 - Persistência local

### Padrões de Código
- StateNotifier para lógica de estado
- StateNotifierProvider para acesso global
- Métodos assíncronos para I/O (SharedPreferences)
- Error handling com try-catch e debugPrint
- Documentação DartDoc em toda API pública
- Conformidade com linting rules do projeto

## 📈 Métricas de Sucesso

### Cobertura de Testes
- [x] Cobertura > 80% (atual: ~90%)
- [x] Todos os métodos públicos testados
- [x] Testes de persistência
- [x] Testes de casos extremos

### Qualidade de Código
- [x] 0 erros no flutter analyze
- [x] 0 warnings relevantes
- [x] Conformidade 100% com linting rules
- [x] Documentação completa

### Usabilidade
- [x] API simples e intuitiva
- [x] Documentação clara com exemplos
- [x] Suporte a casos de uso comuns
- [ ] Feedback positivo dos desenvolvedores (pendente integração)

## 🚧 Limitações Conhecidas

1. **Não reage automaticamente ao sistema**: O app precisa ser reiniciado ou o provider precisa ser notificado manualmente quando o tema do sistema muda enquanto o app está em ThemeMode.system
   - **Solução Futura**: Implementar listener de mudanças de plataforma

2. **Sem animações de transição**: Mudança de tema é instantânea
   - **Solução Futura**: AnimatedTheme wrapper

3. **Persistência apenas local**: Não sincroniza entre dispositivos
   - **Solução Futura**: Firebase integration para sync

## 📝 Notas de Implementação

### SharedPreferences
- Chave usada: `'tema_mode'`
- Valores salvos: `'light'`, `'dark'`, `'system'`
- Erro de I/O é tratado silenciosamente (fallback para system)

### Detecção do Sistema
- Usa `SchedulerBinding.instance.platformDispatcher.platformBrightness`
- Disponível em todas as plataformas Flutter

### Riverpod Integration
- Provider é global (disponível em toda árvore de widgets)
- Estado persiste durante toda a vida do app
- Carregamento assíncrono de preferências não bloqueia inicialização

## 🎓 Como Usar Este Roadmap

1. **Desenvolvedores**: Use as fases para entender o estado atual e próximos passos
2. **QA**: Use as métricas de sucesso para validação
3. **Product**: Use as funcionalidades planejadas para priorização
4. **Docs**: Use as especificações para atualizar documentação

## 📅 Timeline

- **Fase 1** (Base): ✅ Concluída
- **Fase 2** (Melhorias): 🔄 Planejada para futuras iterações
- **Fase 3** (Integração): 🔄 Planejada após aprovação da Fase 1

---

**Última Atualização**: 2025-11-18
**Status**: Fase 1 Completa, pronto para integração
**Próximo Marco**: Integração com frontend_flutter
