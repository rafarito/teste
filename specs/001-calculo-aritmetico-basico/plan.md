# Plano de Implementação: Cálculo Aritmético Básico

**Branch**: `001-calculo-aritmetico-basico` | **Data**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Entrada**: Especificação da feature em `specs/001-calculo-aritmetico-basico/spec.md`

---

## Resumo

Implementar a calculadora aritmética básica (soma, subtração, multiplicação, divisão) com validação de entrada, formatação de resultado no padrão brasileiro e histórico dos últimos 5 cálculos. O backend expõe uma API REST em Spring Boot 3.x / Java 21; o frontend é uma Single Page Application em Angular 20 que consome essa API.

A stack é greenfield — nenhum boilerplate existe ainda em `target_root`. Os primeiros componentes criados seguem estritamente as skills `spring-21` e `angular-20`.

---

## Contexto Técnico

| Item | Valor |
|------|-------|
| Linguagem backend | Java 21 |
| Framework backend | Spring Boot 3.x (Spring Framework 6.1+) |
| Build backend | Maven |
| Package base | `br.com.demomoderniza.calculadora` |
| Linguagem frontend | TypeScript 5.8 |
| Framework frontend | Angular 20 |
| Build frontend | Angular CLI 20.x |
| UI | Angular Material |
| Estado frontend | Signals (`signal()` / `computed()`) |
| Testes backend | JUnit 5 |
| Testes frontend | Jest |
| Testes API/E2E | Playwright |
| Persistência do histórico | H2 embarcado (decisão de projeto — sem banco relacional no legado; H2 elimina dependência externa para o escopo desta feature, com Flyway para versionamento de schema) |
| Auth | Não utilizado — sistema público |
| Diretório backend | `backend/` (a criar em `target_root`) |
| Diretório frontend | `frontend/` (a criar em `target_root`) |

---

## Verificação da Constituição

| Princípio | Status | Observação |
|-----------|--------|------------|
| Boilerplate-First | ✅ | Greenfield — primeiros componentes seguem as skills `spring-21` e `angular-20` |
| Implementação Incremental | ✅ | Tasks divididas por domínio funcional: setup → fundação → cálculo → histórico → frontend |
| Contratos Imutáveis | ✅ | Greenfield — contratos definidos aqui são a referência inicial |
| Banco via Migration | ✅ | Schema do histórico versionado via Flyway desde a primeira migration |

---

## Estrutura do Projeto

### Documentação (desta feature)

```text
specs/001-calculo-aritmetico-basico/
├── spec.md
├── plan.md              ← este arquivo
├── research.md
├── data-model.md
├── quickstart.md
├── clarifications.md
├── security-audit.md
├── checklists/
│   └── requirements.md
└── contracts/
    ├── calculo-api.md
    └── README.md
```

### Código-fonte (target_root)

```text
backend/
├── pom.xml
└── src/
    └── main/
        ├── java/br/com/demomoderniza/calculadora/
        │   ├── CalculadoraApplication.java
        │   ├── controller/
        │   │   └── CalculadoraController.java
        │   ├── service/
        │   │   └── CalculadoraService.java
        │   ├── repository/
        │   │   └── HistoricoRepository.java
        │   ├── entity/
        │   │   └── HistoricoCalculo.java
        │   ├── dto/
        │   │   ├── CalculoRequestDTO.java   (record)
        │   │   ├── CalculoResponseDTO.java  (record)
        │   │   └── HistoricoItemDTO.java    (record)
        │   ├── mapper/
        │   │   └── HistoricoMapper.java
        │   └── exception/
        │       ├── BusinessException.java
        │       └── GlobalExceptionHandler.java
        └── resources/
            ├── application.yml
            ├── application-local.yml
            └── db/migration/
                └── V1__cria_tabela_historico_calculo.sql

frontend/
├── package.json
├── angular.json
├── tsconfig.json
└── src/
    └── app/
        ├── app.config.ts
        ├── app.routes.ts
        ├── shared/
        │   └── shared-imports.ts
        └── features/
            └── calculadora/
                ├── calculadora.routes.ts
                ├── calculadora/
                │   ├── calculadora.component.ts
                │   ├── calculadora.component.html
                │   └── calculadora.component.scss
                └── services/
                    └── calculadora.service.ts
```

---

## Decisões de Implementação

### Backend

#### Persistência do histórico
O legado não possui banco de dados relacional. A stack de destino adota **H2 embarcado** para o histórico de cálculos: elimina dependência de infraestrutura externa, é suficiente para o escopo funcional identificado e pode ser substituído por um banco relacional externo sem alteração de código (apenas configuração). O schema é versionado via **Flyway** desde a primeira migration, conforme a skill `spring-21`.

#### Operações aritméticas
As quatro operações (soma, subtração, multiplicação, divisão) são implementadas no `CalculadoraService`. A validação de operação inválida é feita por enumeração de operações permitidas — nenhuma string arbitrária do cliente é aceita como operação.

#### Validação de entrada
- Campos vazios ou nulos: validados com `@NotBlank` no DTO de request.
- Valores não numéricos: o DTO recebe os operandos como `String` e o Service converte para `Double`; falha de conversão lança `BusinessException`.
- Divisão por zero: verificada no Service antes da operação; lança `BusinessException`.
- Operação inválida: validada por enum no DTO; `@NotNull` + `@Valid` garantem rejeição antes de chegar ao Service.

#### Formatação pt-BR
A formatação do resultado (vírgula decimal, ponto de milhar, máx. 4 casas, mín. 1 casa, sem zeros decorativos) é responsabilidade do **frontend** — o backend retorna o valor numérico bruto (`Double`) e o frontend aplica a formatação via pipe Angular ou utilitário TypeScript. Isso mantém a API agnóstica de locale.

#### Limite do histórico
O número máximo de registros exibidos (padrão: 5) é configurável via propriedade `calculadora.historico.max-registros-exibidos` em `application.yml`. O endpoint de histórico retorna sempre os N mais recentes, ordenados por data/hora decrescente.

#### Padrão de erro
Erros de negócio retornam `ProblemDetail` (RFC 7807) com HTTP 400. O handler global (`GlobalExceptionHandler`) trata `BusinessException` e erros de validação Bean Validation (`MethodArgumentNotValidException`).

### Frontend

#### Componente único
A feature tem uma única tela (formulário + resultado/erro + histórico), implementada como componente standalone `CalculadoraComponent`. Não há navegação interna.

#### Estado com Signals
- `num1`, `num2`, `operacao`: `signal<string>` — valores dos campos do formulário.
- `resultado`: `signal<string | null>` — resultado formatado ou `null`.
- `erro`: `signal<string | null>` — mensagem de erro ou `null`.
- `historico`: `signal<HistoricoItemDTO[]>` — lista do histórico.
- `carregando`: `signal<boolean>` — controle de estado de submissão.

#### Formulário
Reactive Forms tipados com `FormBuilder`. Campos: `num1` (texto), `num2` (texto), `operacao` (select). Após resposta da API (sucesso ou erro), os valores dos campos são mantidos (não resetados).

#### Formatação pt-BR no frontend
Pipe Angular `DecimalPipe` com locale `pt-BR` configurado globalmente em `app.config.ts`, ou utilitário TypeScript equivalente, aplicando as regras: vírgula decimal, ponto de milhar, máx. 4 casas, mín. 1 casa, sem zeros decorativos.

---

## Estratégia de Validação

| Camada | O que validar | Como |
|--------|--------------|------|
| Frontend | Campos não vazios antes de submeter | Reactive Forms — `Validators.required` |
| Backend (DTO) | Campos não nulos/vazios, operação válida | Bean Validation (`@NotBlank`, `@NotNull`) |
| Backend (Service) | Conversão numérica, divisão por zero | `BusinessException` com mensagem de negócio |
| Backend (Handler) | Tradução de exceções para `ProblemDetail` | `@RestControllerAdvice` global |
| Testes unitários | Service: todas as operações e condições de erro | JUnit 5 |
| Testes de API | Endpoints: sucesso, erros de validação, divisão por zero | Playwright |
| Testes E2E | Fluxo completo: preencher → calcular → ver resultado → ver histórico | Playwright |
