---
description: "Lista de tasks para implementação da feature Histórico de Cálculos"
---

# Tasks: Histórico de Cálculos

**Entrada**: Documentos de design de `specs/002-historico-de-calculos/`

**Pré-requisitos**: plan.md, spec.md, research.md, data-model.md, contracts/calculo-api.md

**Testes**: Incluídos, pois `.solutis.yaml` define frameworks de teste (JUnit backend, Jest frontend) para o projeto.

**Organização**: Tasks agrupadas por user story (US1 - registro; US2 - exibição), com fundação compartilhada antes.

## Formato: `[ID] [P?] [Story] Descrição`

- **[P]**: Pode rodar em paralelo (arquivos diferentes, sem dependências)
- **[Story]**: User story associada (US1, US2)

---

## Fase 1: Setup

- [ ] **T001** Criar estrutura inicial do backend Spring Boot (Maven, package base `br.com.demomoderniza.calculadora`) em `backend/`, conforme `system-context.md`
- [ ] **T002** Criar estrutura inicial do frontend Angular 20 standalone em `frontend/`, conforme `system-context.md`
- [ ] **T003** [P] Configurar `application.yml` e `application-local.yml` do backend em `backend/src/main/resources/`, incluindo a propriedade de configuração do limite máximo de registros exibidos no histórico (padrão: 5), conforme FR-004
- [ ] **T004** [P] Configurar `EnvService`/base de URL da API no frontend em `frontend/src/app/` para apontar ao backend local

---

## Fase 2: Fundação (bloqueante para as user stories)

- [ ] **T005** Criar migration Flyway `V1__criar_historico_calculo.sql` em `backend/src/main/resources/db/migration/`, definindo a tabela de histórico com os campos descritos em `data-model.md` (id, data/hora, operando1, operando2, símbolo da operação, resultado)
- [ ] **T006** Criar entidade JPA `HistoricoCalculo` em `backend/src/main/java/br/com/demomoderniza/calculadora/entity/HistoricoCalculo.java`, mapeando o schema da migration T005
- [ ] **T007** Criar exceções de negócio `OperacaoInvalidaException` e `DivisaoPorZeroException` em `backend/src/main/java/br/com/demomoderniza/calculadora/exception/`, e o handler global `BaseExceptionHandler` (retornando `ProblemDetail`), conforme mensagens comprovadas no `spec.md` ("Preencha os dois números.", "Não é possível dividir por zero.", "Operandos inválidos para operação aritmética.", "Operação desconhecida: {valor}")
- [ ] **T008** [P] Criar array de imports compartilhados do frontend (`SHARED_IMPORTS`) em `frontend/src/app/shared/shared-imports.ts`, incluindo os módulos Angular Material necessários ao formulário e à tabela de histórico

**Checkpoint**: Fundação pronta — as user stories podem ser implementadas a partir daqui.

---

## Fase 3: User Story 1 - Registro automático de cálculo bem-sucedido no histórico (Prioridade: P1) 🎯 MVP

**Objetivo**: Registrar de forma persistente cada cálculo aritmético concluído com sucesso, sem registrar cálculos que falharam por validação ou por divisão por zero.

**Teste Independente**: realizar um cálculo válido e confirmar (via teste de integração ou consulta direta ao repositório) que um novo registro foi criado; realizar um cálculo inválido e confirmar que nenhum registro foi criado.

### Testes para User Story 1

- [ ] **T009** [P] [US1] Teste unitário do serviço de cálculo (`CalculoServiceTest`) cobrindo as quatro operações e os erros de validação/divisão por zero, em `backend/src/test/java/br/com/demomoderniza/calculadora/service/CalculoServiceTest.java`
- [ ] **T010** [P] [US1] Teste unitário do serviço de histórico (`HistoricoCalculoServiceTest`) cobrindo o registro de um cálculo bem-sucedido e a tolerância a falha de gravação (FR-008), em `backend/src/test/java/br/com/demomoderniza/calculadora/service/HistoricoCalculoServiceTest.java`
- [ ] **T011** [P] [US1] Teste de contrato do endpoint `POST /calculos` (casos de sucesso e de cada mensagem de erro), em `backend/src/test/java/br/com/demomoderniza/calculadora/controller/CalculoControllerTest.java`

### Implementação da User Story 1

- [ ] **T012** [US1] Criar DTOs `record` `CalculoRequestDTO` e `CalculoResponseDTO` em `backend/src/main/java/br/com/demomoderniza/calculadora/dto/`, conforme `contracts/calculo-api.md`
- [ ] **T013** [US1] Criar DTO `record` `HistoricoCalculoDTO` em `backend/src/main/java/br/com/demomoderniza/calculadora/dto/HistoricoCalculoDTO.java`, conforme `contracts/calculo-api.md`
- [ ] **T014** [US1] Implementar `HistoricoCalculoRepository` (Spring Data JPA) em `backend/src/main/java/br/com/demomoderniza/calculadora/repository/HistoricoCalculoRepository.java`, com método de busca ordenada por data/hora decrescente com limite (para uso futuro na US2)
- [ ] **T015** [US1] Implementar `HistoricoCalculoMapper` (MapStruct) em `backend/src/main/java/br/com/demomoderniza/calculadora/mapper/HistoricoCalculoMapper.java`, convertendo `HistoricoCalculo` (entidade) para `HistoricoCalculoDTO`
- [ ] **T016** [US1] Implementar `HistoricoCalculoService` em `backend/src/main/java/br/com/demomoderniza/calculadora/service/HistoricoCalculoService.java`, com método de registro que captura e loga qualquer falha de persistência sem propagar exceção (FR-008), e método de listagem que descarta registros ilegíveis (FR-007) (depende de T014, T015)
- [ ] **T017** [US1] Implementar `CalculoService` em `backend/src/main/java/br/com/demomoderniza/calculadora/service/CalculoService.java`, com a lógica de validação de operandos, execução das quatro operações (soma, subtração, multiplicação, divisão) e chamada ao `HistoricoCalculoService` após sucesso (depende de T016)
- [ ] **T018** [US1] Implementar `CalculoController` com endpoint `POST /calculos` em `backend/src/main/java/br/com/demomoderniza/calculadora/controller/CalculoController.java`, com `@Valid`, documentação OpenAPI (`@Tag`, `@Operation`, `@ApiResponses`) conforme skill `spring-21` (depende de T012, T017)
- [ ] **T019** [US1] Adicionar logging estruturado do cálculo realizado com sucesso (operandos, operação, resultado) no `CalculoService`, refletindo o comportamento comprovado no legado

**Checkpoint**: User Story 1 completa e testável de forma independente — cálculos são registrados corretamente.

---

## Fase 4: User Story 2 - Exibição dos cálculos mais recentes (Prioridade: P2)

**Objetivo**: Exibir ao usuário a lista dos cálculos mais recentes, do mais novo para o mais antigo, limitada à quantidade máxima configurada (padrão 5).

**Teste Independente**: popular o histórico com mais registros do que o limite configurado e confirmar que apenas a quantidade configurada é exibida, na ordem correta.

### Testes para User Story 2

- [ ] **T020** [P] [US2] Teste de contrato do endpoint `GET /calculos/historico` (histórico vazio, histórico com menos itens que o limite, histórico excedendo o limite), em `backend/src/test/java/br/com/demomoderniza/calculadora/controller/CalculoControllerTest.java`
- [ ] **T021** [P] [US2] Teste unitário do componente Angular de calculadora (`calculadora.component.spec.ts`), cobrindo exibição condicional da seção de histórico (com e sem registros) e ordenação exibida, em `frontend/src/app/features/calculadora/calculadora/calculadora.component.spec.ts`

### Implementação da User Story 2

- [ ] **T022** [US2] Adicionar ao `CalculoController` o endpoint `GET /calculos/historico`, retornando a lista de `HistoricoCalculoDTO` conforme `contracts/calculo-api.md`, com documentação OpenAPI (depende de T016, T018)
- [ ] **T023** [US2] Criar `CalculadoraService` (Angular) em `frontend/src/app/features/calculadora/services/calculadora.service.ts`, com métodos `calcular()` (POST) e `listarHistorico()` (GET), tipados conforme `contracts/calculo-api.md`
- [ ] **T024** [US2] Criar modelos TypeScript `CalculoRequestDTO`, `CalculoResponseDTO` e `HistoricoCalculoDTO` (interfaces) em `frontend/src/app/features/calculadora/models/calculadora.model.ts`, espelhando `contracts/calculo-api.md`
- [ ] **T025** [US2] Implementar `CalculadoraComponent` (formulário reativo tipado para operandos e operação, exibição de resultado/erro via `MatSnackBar` ou mensagem inline, seção de histórico com `signal()` para os itens) em `frontend/src/app/features/calculadora/calculadora/calculadora.component.ts`, `.html` e `.scss` (depende de T023, T024)
- [ ] **T026** [US2] Implementar a tabela/lista de histórico no template, ordenada do mais recente ao mais antigo, oculta quando vazia (FR-006), com formatação pt-BR do resultado via pipe (depende de T025)
- [ ] **T027** [US2] Adicionar `data-testid` estáveis aos elementos de interação e asserção do formulário e da lista de histórico (campos de operando, seletor de operação, botão calcular, linhas da lista de histórico por identificador estável), conforme skill `angular-20`
- [ ] **T028** [US2] Configurar a rota da feature `calculadora.routes.ts` em `frontend/src/app/features/calculadora/` e registrá-la em `app.routes.ts` (depende de T025)

**Checkpoint**: User Story 1 e User Story 2 completas e testáveis de forma independente.

---

## Fase 5: Polimento

- [ ] **T029** [P] Revisar mensagens de erro exibidas ao usuário (frontend) para garantir que reproduzem exatamente as mensagens comprovadas no `spec.md` ("Preencha os dois números.", "Não é possível dividir por zero.")
- [ ] **T030** Rodar o roteiro de validação descrito em `quickstart.md` de ponta a ponta em ambiente local

---

## Dependências e Ordem de Execução

- **Setup (Fase 1)** → **Fundação (Fase 2)** → **User Story 1 (Fase 3)** → **User Story 2 (Fase 4)** → **Polimento (Fase 5)**
- User Story 2 depende do `HistoricoCalculoService`/`HistoricoCalculoRepository` criados na User Story 1 (T014, T016), pois reutiliza a mesma listagem — não é totalmente independente na implementação, mas é testável de forma independente uma vez que a Fundação e a US1 estejam completas.
- Dentro de cada Fase, tasks marcadas [P] podem ser executadas em paralelo (arquivos distintos, sem dependência direta).

## Estratégia de Implementação

### MVP Primeiro (User Story 1)

1. Completar Fase 1 (Setup) e Fase 2 (Fundação)
2. Completar Fase 3 (User Story 1) — cálculos passam a ser registrados corretamente
3. Validar de forma independente antes de avançar

### Entrega Incremental

1. Setup + Fundação
2. User Story 1 → validar → (MVP: cálculo funcional com registro em histórico, ainda sem exibição)
3. User Story 2 → validar → feature completa (registro + exibição do histórico)
4. Polimento
