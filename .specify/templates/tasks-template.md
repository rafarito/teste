---

description: "Template de lista de tasks para implementação de feature"
---

# Tasks: [FEATURE NAME]

**Entrada**: Documentos de design de `/specs/[###-feature-name]/`

**Pré-requisitos**: plan.md (obrigatório), spec.md (obrigatório para user stories), research.md, data-model.md, contracts/

**Testes**: Os exemplos abaixo incluem tasks de teste. Testes são OPCIONAIS - só inclua se explicitamente solicitado na especificação da feature.

**Organização**: Tasks são agrupadas por user story para permitir implementação e teste independentes de cada story.

## Formato: `[ID] [P?] [Story] Descrição`

- **[P]**: Pode rodar em paralelo (arquivos diferentes, sem dependências)
- **[Story]**: A qual user story esta task pertence (ex.: US1, US2, US3)
- Inclua caminhos de arquivo exatos nas descrições

## Convenções de Caminho

- **Projeto único**: `src/`, `tests/` na raiz do repositório
- **Aplicação web**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` ou `android/src/`
- Os caminhos abaixo assumem projeto único - ajuste conforme a estrutura do plan.md

<!--
  ============================================================================
  IMPORTANTE: As tasks abaixo são TASKS DE EXEMPLO apenas para ilustração.

  O comando /speckit-tasks DEVE substituí-las por tasks reais baseadas em:
  - User stories do spec.md (com suas prioridades P1, P2, P3...)
  - Requisitos da feature do plan.md
  - Entidades do data-model.md
  - Endpoints do contracts/

  As tasks DEVEM ser organizadas por user story para que cada story possa ser:
  - Implementada independentemente
  - Testada independentemente
  - Entregue como incremento de MVP

  NÃO mantenha essas tasks de exemplo no arquivo tasks.md gerado.
  ============================================================================
-->

## Fase 1: Setup (Infraestrutura Compartilhada)

**Propósito**: Inicialização do projeto e estrutura básica

- [ ] T001 Criar estrutura do projeto conforme o plano de implementação
- [ ] T002 Inicializar projeto [linguagem] com dependências [framework]
- [ ] T003 [P] Configurar ferramentas de lint e formatação

---

## Fase 2: Fundação (Pré-requisitos Bloqueantes)

**Propósito**: Infraestrutura central que DEVE estar completa antes de QUALQUER user story ser implementada

**⚠️ CRÍTICO**: Nenhum trabalho de user story pode começar até esta fase estar completa

Exemplos de tasks de fundação (ajuste conforme seu projeto):

- [ ] T004 Configurar schema do banco de dados e framework de migrations
- [ ] T005 [P] Implementar framework de autenticação/autorização
- [ ] T006 [P] Configurar roteamento de API e estrutura de middleware
- [ ] T007 Criar models/entidades base dos quais todas as stories dependem
- [ ] T008 Configurar infraestrutura de tratamento de erros e logging
- [ ] T009 Configurar gerenciamento de configuração de ambiente

**Checkpoint**: Fundação pronta - a implementação das user stories já pode começar em paralelo

---

## Fase 3: User Story 1 - [Título] (Prioridade: P1) 🎯 MVP

**Objetivo**: [Breve descrição do que esta story entrega]

**Teste Independente**: [Como verificar que esta story funciona sozinha]

### Testes para a User Story 1 (OPCIONAL - só se testes forem solicitados) ⚠️

> **NOTA: Escreva estes testes PRIMEIRO, garanta que FALHEM antes da implementação**

- [ ] T010 [P] [US1] Teste de contrato para [endpoint] em tests/contract/test_[name].py
- [ ] T011 [P] [US1] Teste de integração para [jornada de usuário] em tests/integration/test_[name].py

### Implementação da User Story 1

- [ ] T012 [P] [US1] Criar model [Entity1] em src/models/[entity1].py
- [ ] T013 [P] [US1] Criar model [Entity2] em src/models/[entity2].py
- [ ] T014 [US1] Implementar [Service] em src/services/[service].py (depende de T012, T013)
- [ ] T015 [US1] Implementar [endpoint/feature] em src/[location]/[file].py
- [ ] T016 [US1] Adicionar validação e tratamento de erros
- [ ] T017 [US1] Adicionar logging das operações da user story 1

**Checkpoint**: Neste ponto, a User Story 1 deve estar totalmente funcional e testável de forma independente

---

## Fase 4: User Story 2 - [Título] (Prioridade: P2)

**Objetivo**: [Breve descrição do que esta story entrega]

**Teste Independente**: [Como verificar que esta story funciona sozinha]

### Testes para a User Story 2 (OPCIONAL - só se testes forem solicitados) ⚠️

- [ ] T018 [P] [US2] Teste de contrato para [endpoint] em tests/contract/test_[name].py
- [ ] T019 [P] [US2] Teste de integração para [jornada de usuário] em tests/integration/test_[name].py

### Implementação da User Story 2

- [ ] T020 [P] [US2] Criar model [Entity] em src/models/[entity].py
- [ ] T021 [US2] Implementar [Service] em src/services/[service].py
- [ ] T022 [US2] Implementar [endpoint/feature] em src/[location]/[file].py
- [ ] T023 [US2] Integrar com componentes da User Story 1 (se necessário)

**Checkpoint**: Neste ponto, as User Stories 1 E 2 devem funcionar independentemente

---

## Fase 5: User Story 3 - [Título] (Prioridade: P3)

**Objetivo**: [Breve descrição do que esta story entrega]

**Teste Independente**: [Como verificar que esta story funciona sozinha]

### Testes para a User Story 3 (OPCIONAL - só se testes forem solicitados) ⚠️

- [ ] T024 [P] [US3] Teste de contrato para [endpoint] em tests/contract/test_[name].py
- [ ] T025 [P] [US3] Teste de integração para [jornada de usuário] em tests/integration/test_[name].py

### Implementação da User Story 3

- [ ] T026 [P] [US3] Criar model [Entity] em src/models/[entity].py
- [ ] T027 [US3] Implementar [Service] em src/services/[service].py
- [ ] T028 [US3] Implementar [endpoint/feature] em src/[location]/[file].py

**Checkpoint**: Todas as user stories devem estar funcionais de forma independente agora

---

[Adicione mais fases de user story conforme necessário, seguindo o mesmo padrão]

---

## Fase N: Polimento e Preocupações Transversais

**Propósito**: Melhorias que afetam múltiplas user stories

- [ ] TXXX [P] Atualizações de documentação em docs/
- [ ] TXXX Limpeza de código e refatoração
- [ ] TXXX Otimização de performance em todas as stories
- [ ] TXXX [P] Testes unitários adicionais (se solicitado) em tests/unit/
- [ ] TXXX Hardening de segurança
- [ ] TXXX Rodar validação do quickstart.md

---

## Dependências e Ordem de Execução

### Dependências entre Fases

- **Setup (Fase 1)**: Sem dependências - pode começar imediatamente
- **Fundação (Fase 2)**: Depende da conclusão do Setup - BLOQUEIA todas as user stories
- **User Stories (Fase 3+)**: Todas dependem da conclusão da fase de Fundação
  - As user stories podem então prosseguir em paralelo (se houver equipe)
  - Ou sequencialmente em ordem de prioridade (P1 → P2 → P3)
- **Polimento (Fase final)**: Depende de todas as user stories desejadas estarem completas

### Dependências entre User Stories

- **User Story 1 (P1)**: Pode começar após a Fundação (Fase 2) - Sem dependências de outras stories
- **User Story 2 (P2)**: Pode começar após a Fundação (Fase 2) - Pode integrar com a US1, mas deve ser testável independentemente
- **User Story 3 (P3)**: Pode começar após a Fundação (Fase 2) - Pode integrar com US1/US2, mas deve ser testável independentemente

### Dentro de Cada User Story

- Testes (se incluídos) DEVEM ser escritos e FALHAR antes da implementação
- Models antes de services
- Services antes de endpoints
- Implementação principal antes da integração
- Story completa antes de avançar para a próxima prioridade

### Oportunidades de Paralelismo

- Todas as tasks de Setup marcadas com [P] podem rodar em paralelo
- Todas as tasks de Fundação marcadas com [P] podem rodar em paralelo (dentro da Fase 2)
- Assim que a fase de Fundação terminar, todas as user stories podem começar em paralelo (se a capacidade da equipe permitir)
- Todos os testes de uma user story marcados com [P] podem rodar em paralelo
- Models dentro de uma story marcados com [P] podem rodar em paralelo
- Diferentes user stories podem ser trabalhadas em paralelo por diferentes membros da equipe

---

## Exemplo de Paralelismo: User Story 1

```bash
# Disparar todos os testes da User Story 1 juntos (se testes forem solicitados):
Task: "Teste de contrato para [endpoint] em tests/contract/test_[name].py"
Task: "Teste de integração para [jornada de usuário] em tests/integration/test_[name].py"

# Disparar todos os models da User Story 1 juntos:
Task: "Criar model [Entity1] em src/models/[entity1].py"
Task: "Criar model [Entity2] em src/models/[entity2].py"
```

---

## Estratégia de Implementação

### MVP Primeiro (Somente User Story 1)

1. Completar Fase 1: Setup
2. Completar Fase 2: Fundação (CRÍTICO - bloqueia todas as stories)
3. Completar Fase 3: User Story 1
4. **PARAR E VALIDAR**: Testar a User Story 1 de forma independente
5. Publicar/demonstrar se estiver pronta

### Entrega Incremental

1. Completar Setup + Fundação → Fundação pronta
2. Adicionar User Story 1 → Testar independentemente → Publicar/Demonstrar (MVP!)
3. Adicionar User Story 2 → Testar independentemente → Publicar/Demonstrar
4. Adicionar User Story 3 → Testar independentemente → Publicar/Demonstrar
5. Cada story agrega valor sem quebrar as stories anteriores

### Estratégia de Equipe em Paralelo

Com múltiplos desenvolvedores:

1. A equipe completa Setup + Fundação juntos
2. Assim que a Fundação estiver pronta:
   - Desenvolvedor A: User Story 1
   - Desenvolvedor B: User Story 2
   - Desenvolvedor C: User Story 3
3. As stories são completadas e integradas independentemente

---

## Notas

- Tasks [P] = arquivos diferentes, sem dependências
- O rótulo [Story] mapeia a task para uma user story específica, para rastreabilidade
- Cada user story deve ser completável e testável de forma independente
- Verifique que os testes falham antes de implementar
- Faça commit após cada task ou grupo lógico
- Pare em qualquer checkpoint para validar a story independentemente
- Evite: tasks vagas, conflitos no mesmo arquivo, dependências entre stories que quebrem a independência
