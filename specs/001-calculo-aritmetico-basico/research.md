# Pesquisa Técnica — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23
**Plan**: [plan.md](./plan.md)

---

## Decisões Técnicas

### 1. Persistência do histórico de cálculos

**Problema**: O legado não possui banco de dados relacional. A stack de destino precisa definir como persistir o histórico de cálculos.

**Opções avaliadas**:

| Opção | Prós | Contras |
|-------|------|---------|
| H2 embarcado (modo file) | Sem dependência de infraestrutura externa; Spring Data JPA funciona normalmente; Flyway gerencia o schema; substituível por banco externo apenas com configuração | Não recomendado para produção com alta concorrência; dados ficam em arquivo local do servidor |
| PostgreSQL/MySQL externo | Robusto para produção; suporte a concorrência | Requer infraestrutura adicional; fora do escopo mínimo desta feature |
| Arquivo texto (como o legado) | Sem dependência | Sem query, sem transação, sem tipagem; não se integra com Spring Data JPA |

**Decisão**: **H2 embarcado em modo file** para esta feature. Justificativa: o escopo funcional é simples (gravar e listar registros de histórico), o ambiente é greenfield sem banco relacional definido, e H2 permite usar Spring Data JPA + Flyway sem infraestrutura adicional. A migração para banco externo, se necessária, exige apenas alteração de `application.yml` e nenhuma mudança de código.

---

### 2. Formatação numérica pt-BR

**Problema**: O resultado deve ser exibido com vírgula decimal, ponto de milhar, máximo 4 casas decimais, sem zeros decorativos à direita, com mínimo de 1 casa decimal.

**Decisão**: A formatação é responsabilidade do **frontend**. O backend retorna o valor numérico como `Double` no JSON. O frontend aplica a formatação via `DecimalPipe` do Angular com locale `pt-BR` registrado globalmente em `app.config.ts` (`registerLocaleData(localePt)`). Para o controle de zeros decorativos (comportamento específico: remover zeros mas manter ao menos 1 casa), será implementado um pipe Angular customizado `PtBrNumberPipe` que encapsula a lógica.

**Justificativa**: Manter a API agnóstica de locale facilita reuso e testes. A lógica de formatação fica centralizada em um único pipe reutilizável no frontend.

---

### 3. Representação das operações na API

**Problema**: Como representar as quatro operações no contrato da API (request/response).

**Decisão**: Usar um enum Java `Operacao` com os valores `SOMA`, `SUBTRACAO`, `MULTIPLICACAO`, `DIVISAO`. O DTO de request recebe o valor como string e o Jackson deserializa para o enum. Operação inválida resulta em HTTP 400 automaticamente via `HttpMessageNotReadableException` (tratado pelo handler global).

**Justificativa**: Enum garante whitelist de operações válidas sem lógica adicional de validação no Service. Alinhado com a abordagem do legado (whitelist fixa de operações).

---

### 4. Tratamento de erros de negócio

**Problema**: Como comunicar ao frontend os erros de negócio (campo vazio, valor não numérico, divisão por zero) de forma padronizada.

**Decisão**: `BusinessException` lançada no Service, capturada pelo `GlobalExceptionHandler` (`@RestControllerAdvice`), que retorna `ProblemDetail` (RFC 7807) com HTTP 400 e o campo `detail` contendo a mensagem de negócio. O frontend lê o campo `detail` do corpo de erro e exibe ao usuário.

**Justificativa**: `ProblemDetail` é o padrão nativo do Spring 6 / Spring Boot 3.x (skill `spring-21`). Evita criar estrutura de erro customizada.

---

### 5. Preservação de valores no formulário após envio

**Problema**: O legado usa sessão do servidor (padrão PRG) para preservar os valores digitados. Na stack de destino com API REST + SPA Angular, não há sessão de servidor.

**Decisão**: A preservação dos valores é feita inteiramente no **frontend**. O `CalculadoraComponent` mantém os valores dos campos em `signal<string>` e não os reseta após a resposta da API (seja sucesso ou erro). O Reactive Form mantém os valores nos controles. Não há estado de sessão no servidor.

**Justificativa**: Em uma SPA, o estado do formulário vive no componente Angular. Não há necessidade de sessão de servidor para esse propósito — o que elimina a vulnerabilidade SEC-001 identificada no audit de segurança.

---

### 6. Limite configurável do histórico

**Problema**: O número máximo de registros exibidos no histórico (5 no legado) deve ser fixo ou configurável?

**Decisão**: Configurável via propriedade `calculadora.historico.max-registros-exibidos` em `application.yml`, com valor padrão `5`. O endpoint de histórico lê essa propriedade via `@Value` no Service.

**Justificativa**: O legado lê o valor de configuração, sugerindo intenção de parametrização. O custo de torná-lo configurável na stack de destino é mínimo. Ver Q1 em `clarifications.md`.

---

### 7. Estrutura do endpoint de cálculo

**Problema**: O cálculo e o registro no histórico devem ser operações separadas ou unificadas em um único endpoint?

**Decisão**: **Endpoint único** `POST /api/calculos` que realiza o cálculo, persiste no histórico e retorna o resultado + os últimos N registros do histórico em uma única resposta. Isso evita que o frontend precise fazer duas chamadas sequenciais após cada cálculo.

**Justificativa**: O legado realiza as duas operações atomicamente no mesmo fluxo de request. Manter esse comportamento simplifica o frontend e reduz latência percebida.

---

## Bibliotecas e Dependências (backend)

| Dependência | Uso | Versão |
|-------------|-----|--------|
| `spring-boot-starter-web` | API REST | gerenciada pelo Spring Boot BOM |
| `spring-boot-starter-data-jpa` | Repositório JPA para histórico | gerenciada pelo Spring Boot BOM |
| `spring-boot-starter-validation` | Bean Validation nos DTOs | gerenciada pelo Spring Boot BOM |
| `com.h2database:h2` | Banco embarcado para histórico | gerenciada pelo Spring Boot BOM |
| `org.flywaydb:flyway-core` | Versionamento de schema | gerenciada pelo Spring Boot BOM |
| `org.mapstruct:mapstruct` | Conversão Entity ↔ DTO | 1.5.x |
| `org.projectlombok:lombok` | Redução de boilerplate em classes | gerenciada pelo Spring Boot BOM |

---

## Bibliotecas e Dependências (frontend)

| Dependência | Uso |
|-------------|-----|
| `@angular/material` | Componentes de UI (form fields, select, button, table) |
| `@angular/common/http` | `HttpClient` para chamadas à API |
| `@angular/forms` | Reactive Forms tipados |
| `@angular/common` | `DecimalPipe`, `DatePipe` |

---

## Configuração de Locale pt-BR (frontend)

```typescript
// app.config.ts
import { registerLocaleData } from '@angular/common';
import localePt from '@angular/common/locales/pt';
import { LOCALE_ID } from '@angular/core';

registerLocaleData(localePt);

export const appConfig: ApplicationConfig = {
  providers: [
    // ...
    { provide: LOCALE_ID, useValue: 'pt-BR' },
  ]
};
```
