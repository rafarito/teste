# Tasks: Cálculo Aritmético Básico

**Entrada**: Documentos de design em `specs/001-calculo-aritmetico-basico/`

**Pré-requisitos**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/calculo-api.md`

## Formato: `[ID] [P?] [Story] Descrição`

- **[P]**: Pode rodar em paralelo (arquivos diferentes, sem dependências)
- **[Story]**: User story relacionada (US1, US2, US3)
- Caminhos referem-se ao `target_root` (greenfield)

---

## Fase 1: Setup (Infraestrutura Compartilhada)

**Propósito**: Criar a estrutura inicial dos projetos backend e frontend do zero.

- [ ] **T001** Criar projeto Spring Boot 3.x / Java 21 com Maven em `backend/` — incluir dependências: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `spring-boot-starter-validation`, `h2`, `flyway-core`, `mapstruct`, `lombok`; configurar `pom.xml` com package base `br.com.demomoderniza.calculadora`
- [ ] **T002** [P] Criar `backend/src/main/resources/application.yml` com configurações: porta `8080`, datasource H2 em modo file, Flyway habilitado, propriedade `calculadora.historico.max-registros-exibidos: 5`, virtual threads habilitadas (`spring.threads.virtual.enabled: true`)
- [ ] **T003** [P] Criar `backend/src/main/resources/application-local.yml` com configurações de desenvolvimento local (console H2 habilitado, log SQL)
- [ ] **T004** [P] Criar projeto Angular 20 em `frontend/` com Angular CLI — configurar `package.json`, `angular.json`, `tsconfig.json`; instalar `@angular/material`
- [ ] **T005** [P] Configurar locale pt-BR globalmente em `frontend/src/app/app.config.ts` — `registerLocaleData(localePt)`, `{ provide: LOCALE_ID, useValue: 'pt-BR' }`, `provideHttpClient()`, `provideRouter(routes)`

**Checkpoint**: Projetos backend e frontend criados e compilando sem erros.

---

## Fase 2: Fundação (Pré-requisitos Bloqueantes)

**Propósito**: Infraestrutura central que DEVE estar completa antes de qualquer user story ser implementada.

⚠️ **CRÍTICO**: Nenhum trabalho de user story pode começar até esta fase estar completa.

- [ ] **T006** Criar classe principal `backend/src/main/java/br/com/demomoderniza/calculadora/CalculadoraApplication.java` com `@SpringBootApplication`
- [ ] **T007** [P] Criar enum `backend/src/main/java/br/com/demomoderniza/calculadora/dto/Operacao.java` com valores `SOMA`, `SUBTRACAO`, `MULTIPLICACAO`, `DIVISAO` — cada valor com método `getSimbolo()` retornando `+`, `-`, `*`, `/` respectivamente
- [ ] **T008** [P] Criar exception `backend/src/main/java/br/com/demomoderniza/calculadora/exception/BusinessException.java` estendendo `RuntimeException`
- [ ] **T009** Criar `backend/src/main/java/br/com/demomoderniza/calculadora/exception/GlobalExceptionHandler.java` com `@RestControllerAdvice` — tratar `BusinessException` e `MethodArgumentNotValidException` retornando `ProblemDetail` (HTTP 400) com o campo `detail` contendo a mensagem de negócio
- [ ] **T010** [P] Criar migration `backend/src/main/resources/db/migration/V1__cria_tabela_historico_calculo.sql` — tabela `historico_calculo` com colunas: `id` (PK auto-increment), `data_hora` (TIMESTAMP NOT NULL), `operando1` (VARCHAR(255) NOT NULL), `operando2` (VARCHAR(255) NOT NULL), `operacao` (VARCHAR(20) NOT NULL), `resultado` (DOUBLE NOT NULL)
- [ ] **T011** [P] Criar `frontend/src/app/shared/shared-imports.ts` com array `SHARED_IMPORTS` contendo imports comuns do Angular Material e pipes
- [ ] **T012** [P] Criar `frontend/src/app/app.routes.ts` com rota raiz redirecionando para `calculadora` via lazy loading de `calculadora.routes.ts`

**Checkpoint**: Backend compila e sobe com Flyway criando a tabela. Frontend compila sem erros.

---

## Fase 3: User Story 1 e 2 — Realizar Cálculo e Tratar Erros (Prioridade: P1) 🎯 MVP

**Objetivo**: Implementar o fluxo completo de cálculo aritmético com validação e exibição de resultado/erro.

**Teste Independente**: Submeter o formulário com valores válidos e inválidos e verificar resultado/erro exibido com campos preservados.

### Backend — US1 e US2

- [ ] **T013** [P] [US1] Criar record `backend/src/main/java/br/com/demomoderniza/calculadora/dto/CalculoRequestDTO.java` com campos: `@NotBlank String num1`, `@NotBlank String num2`, `@NotNull Operacao operacao`
- [ ] **T014** [P] [US1] Criar record `backend/src/main/java/br/com/demomoderniza/calculadora/dto/HistoricoItemDTO.java` com campos: `String dataHora`, `String operando1`, `String operando2`, `String simbolo`, `Double resultado`
- [ ] **T015** [P] [US1] Criar record `backend/src/main/java/br/com/demomoderniza/calculadora/dto/CalculoResponseDTO.java` com campos: `Double resultado`, `List<HistoricoItemDTO> historico`
- [ ] **T016** [P] [US1] Criar entity `backend/src/main/java/br/com/demomoderniza/calculadora/entity/HistoricoCalculo.java` com `@Entity`, campos mapeados para a tabela `historico_calculo` (id, dataHora, operando1, operando2, operacao, resultado)
- [ ] **T017** [P] [US1] Criar interface `backend/src/main/java/br/com/demomoderniza/calculadora/repository/HistoricoRepository.java` estendendo `JpaRepository<HistoricoCalculo, Long>` — adicionar método `findTopNByOrderByDataHoraDesc` usando `Pageable`
- [ ] **T018** [P] [US1] Criar interface `backend/src/main/java/br/com/demomoderniza/calculadora/mapper/HistoricoMapper.java` com `@Mapper(componentModel = "spring")` — métodos `toDTO(HistoricoCalculo entity)` e `toDTOList(List<HistoricoCalculo> entities)`
- [ ] **T019** [US1] [US2] Criar `backend/src/main/java/br/com/demomoderniza/calculadora/service/CalculadoraService.java` com `@Service` — implementar método `calcular(CalculoRequestDTO dto)` que: (1) tenta converter `num1` e `num2` para `Double` lançando `BusinessException("Operandos invalidos para operacao aritmetica.")` em caso de falha; (2) executa a operação conforme o enum `Operacao`; (3) para `DIVISAO`, verifica se `num2 == 0` e lança `BusinessException("Nao e possivel dividir por zero.")` antes de dividir; (4) persiste o resultado no histórico via `HistoricoRepository`; (5) retorna `CalculoResponseDTO` com resultado e histórico atualizado (últimos N registros, N lido de `@Value("${calculadora.historico.max-registros-exibidos:5}")`)
- [ ] **T020** [US1] [US2] Criar `backend/src/main/java/br/com/demomoderniza/calculadora/controller/CalculadoraController.java` com `@RestController`, `@RequestMapping("/api/calculos")` — endpoint `POST /api/calculos` recebendo `@Valid @RequestBody CalculoRequestDTO`, delegando ao `CalculadoraService` e retornando `ResponseEntity<CalculoResponseDTO>`; endpoint `GET /api/calculos/historico` retornando `ResponseEntity<List<HistoricoItemDTO>>`

### Testes backend — US1 e US2

- [ ] **T021** [P] [US1] [US2] Criar `backend/src/test/java/br/com/demomoderniza/calculadora/service/CalculadoraServiceTest.java` com JUnit 5 — cobrir: soma, subtração, multiplicação, divisão com valores válidos; divisão por zero; valor não numérico; campo vazio (validação Bean Validation)
- [ ] **T022** [P] [US1] [US2] Criar testes de API com Playwright em `backend/src/test/` — cobrir: POST com sucesso (HTTP 200 + resultado correto), POST com campo vazio (HTTP 400 + `detail` correto), POST com valor não numérico (HTTP 400), POST com divisão por zero (HTTP 400)

### Frontend — US1 e US2

- [ ] **T023** [P] [US1] Criar interface TypeScript `frontend/src/app/features/calculadora/models/calculo.model.ts` com `CalculoRequestDTO`, `CalculoResponseDTO`, `HistoricoItemDTO`
- [ ] **T024** [P] [US1] Criar `frontend/src/app/features/calculadora/services/calculadora.service.ts` com `@Injectable({ providedIn: 'root' })` — métodos `calcular(dto: CalculoRequestDTO): Observable<CalculoResponseDTO>` (POST `/api/calculos`) e `listarHistorico(): Observable<HistoricoItemDTO[]>` (GET `/api/calculos/historico`)
- [ ] **T025** [US1] [US2] Criar `frontend/src/app/features/calculadora/calculadora/calculadora.component.ts` com `ChangeDetectionStrategy.OnPush` — Reactive Form tipado com controles `num1` (string, `Validators.required`), `num2` (string, `Validators.required`), `operacao` (enum, `Validators.required`); signals: `resultado: signal<number | null>`, `erro: signal<string | null>`, `historico: signal<HistoricoItemDTO[]>`, `carregando: signal<boolean>`; método `calcular()` que submete o form, chama o service, atualiza os signals de resultado/erro/histórico e **não reseta os campos do formulário**; ao carregar o componente, chama `listarHistorico()` para popular o histórico inicial
- [ ] **T026** [US1] [US2] Criar `frontend/src/app/features/calculadora/calculadora/calculadora.component.html` — formulário com `[formGroup]`, campos `num1` e `num2` com `mat-form-field appearance="outline"` e `data-testid` estáveis; select de operação com as 4 opções; botão `Calcular` com `data-testid="calcular-button"`; exibição condicional de resultado (com pipe pt-BR customizado) ou mensagem de erro; seção de histórico condicional (`@if (historico().length > 0)`) com tabela Angular Material
- [ ] **T027** [P] [US1] Criar pipe Angular `frontend/src/app/shared/pipes/pt-br-number.pipe.ts` — formata número com vírgula decimal, ponto de milhar, máx. 4 casas decimais, sem zeros decorativos à direita, mínimo 1 casa decimal (ex: `3.3333` → `3,3333`; `7.0` → `7,0`; `3.5` → `3,5`)
- [ ] **T028** [P] [US1] Criar `frontend/src/app/features/calculadora/calculadora.routes.ts` com rota `''` carregando `CalculadoraComponent` via `loadComponent`

**Checkpoint**: Fluxo completo de cálculo funcional — resultado exibido, erros tratados, campos preservados.

---

## Fase 4: User Story 3 — Histórico dos Últimos Cálculos (Prioridade: P2)

**Objetivo**: Garantir que o histórico é exibido corretamente com os dados esperados (data/hora, expressão, resultado formatado) e que o limite de 5 registros é respeitado.

**Teste Independente**: Realizar 6 cálculos e verificar que apenas os 5 mais recentes aparecem no histórico, em ordem decrescente.

> **Nota**: A maior parte da implementação do histórico já foi feita na Fase 3 (T016, T017, T018, T019, T020, T025, T026). Esta fase cobre apenas os testes específicos do histórico e ajustes de exibição.

- [ ] **T029** [US3] Criar testes E2E com Playwright cobrindo: realizar 6 cálculos e verificar que apenas 5 aparecem no histórico; verificar ordem decrescente; verificar que histórico não é exibido quando vazio; verificar formatação pt-BR do resultado no histórico
- [ ] **T030** [P] [US3] Adicionar `data-testid` na tabela de histórico: `data-testid="historico-table"` na tabela, `data-testid="historico-row-{id}"` em cada linha

**Checkpoint**: Histórico exibido corretamente com limite, ordem e formatação validados por testes E2E.

---

## Fase 5: Polimento e Preocupações Transversais

**Propósito**: Melhorias que afetam múltiplas user stories.

- [ ] **T031** [P] Configurar CORS no backend para permitir requisições do frontend Angular em desenvolvimento (`http://localhost:4200`) — adicionar `@CrossOrigin` no controller ou configuração global via `WebMvcConfigurer`
- [ ] **T032** [P] Adicionar `springdoc-openapi-starter-webmvc-ui` ao `pom.xml` e anotar `CalculadoraController` com `@Tag`, `@Operation` e `@ApiResponses` conforme skill `spring-21` — verificar Swagger UI em `/swagger-ui/index.html`
- [ ] **T033** Rodar checklist completo do `quickstart.md` e confirmar todos os itens

---

## Dependências e Ordem de Execução

### Dependências entre Fases

- **Fase 1 (Setup)**: Sem dependências — pode começar imediatamente
- **Fase 2 (Fundação)**: Depende da conclusão da Fase 1 — BLOQUEIA todas as user stories
- **Fase 3 (US1 + US2)**: Depende da conclusão da Fase 2
- **Fase 4 (US3)**: Depende da conclusão da Fase 3 (histórico é implementado junto com o cálculo)
- **Fase 5 (Polimento)**: Depende da conclusão das Fases 3 e 4

### Dentro de Cada Fase

- Tasks marcadas com `[P]` podem rodar em paralelo
- T019 (Service) depende de T013, T014, T015, T016, T017, T018
- T020 (Controller) depende de T019
- T025 (Componente TS) depende de T023, T024
- T026 (Template HTML) depende de T025, T027

### Oportunidades de Paralelismo

- T001 (backend setup) e T004 (frontend setup) podem rodar em paralelo
- Dentro da Fase 2: T007, T008, T010, T011, T012 podem rodar em paralelo após T006
- Dentro da Fase 3 backend: T013–T018 podem rodar em paralelo entre si
- Dentro da Fase 3 frontend: T023, T024, T027, T028 podem rodar em paralelo entre si
