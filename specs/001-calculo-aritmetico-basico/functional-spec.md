# Análise Funcional — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23
**Gerado por**: `/speckit-analyze` (Passo 5 do `/discovery spec`)

---

## Resumo Executivo

| Métrica | Valor |
|---------|-------|
| Requisitos funcionais | 11 |
| Tasks geradas | 33 |
| User stories | 3 (P1 × 2, P2 × 1) |
| Issues CRITICAL | 0 |
| Issues HIGH | 0 |
| Issues MEDIUM | 2 |
| Issues LOW | 1 |
| Achados de segurança (legado) | 3 (todos MEDIUM) |
| Status de aprovação de segurança | ⏸️ Aguarda analista |

---

## Cobertura de Requisitos × Tasks

| Requisito | Descrição resumida | Tasks associadas | Coberto? |
|-----------|-------------------|-----------------|----------|
| FR-001 | Formulário com 3 campos | T025, T026 | ✅ |
| FR-002 | 4 operações disponíveis | T007, T026 | ✅ |
| FR-003 | Rejeitar campo vazio | T013, T019, T009, T025 | ✅ |
| FR-004 | Rejeitar valor não numérico | T019, T009 | ✅ |
| FR-005 | Rejeitar divisão por zero | T019, T009 | ✅ |
| FR-006 | Formatação pt-BR | T027, T025 | ✅ |
| FR-007 | Preservar valores no formulário | T025, T026 | ✅ |
| FR-008 | Registrar cálculo no histórico | T016, T017, T019 | ✅ |
| FR-009 | Exibir últimos 5 cálculos | T019, T025, T026 | ✅ |
| FR-010 | Não exibir histórico vazio | T026 | ✅ |
| FR-011 | Sistema público sem autenticação | — (ausência de task é o correto) | ✅ |

**Cobertura**: 11/11 requisitos cobertos por ao menos uma task. ✅

---

## Análise de Inconsistências

### ⚠️ MEDIUM — INC-001: Validação de campo vazio duplicada entre Bean Validation e Service

**Descrição**: O `CalculoRequestDTO` usa `@NotBlank` para `num1` e `num2`, o que já rejeita campos vazios com HTTP 400. Porém, a mensagem de negócio esperada é `Preencha os dois numeros.` — que é diferente da mensagem padrão do Bean Validation. O `GlobalExceptionHandler` precisa interceptar `MethodArgumentNotValidException` e retornar a mensagem de negócio correta, não a mensagem padrão do framework.

**Impacto**: Se o handler não for implementado corretamente, o frontend receberá uma mensagem de erro diferente da especificada, quebrando o requisito FR-003.

**Recomendação**: Garantir que o `GlobalExceptionHandler` (T009) trate `MethodArgumentNotValidException` retornando `ProblemDetail` com `detail = "Preencha os dois numeros."` — independentemente de qual campo específico está vazio.

**Status**: ⚠️ Requer atenção na implementação de T009.

---

### ⚠️ MEDIUM — INC-002: Pipe pt-BR customizado não está em `SHARED_IMPORTS`

**Descrição**: O `PtBrNumberPipe` (T027) é criado em `shared/pipes/` mas não há task explícita para adicioná-lo ao array `SHARED_IMPORTS` (T011). Se não for incluído, o `CalculadoraComponent` precisará importá-lo manualmente.

**Impacto**: Baixo — não quebra funcionalidade, mas pode causar inconsistência de padrão se outros componentes precisarem do pipe futuramente.

**Recomendação**: Incluir `PtBrNumberPipe` em `SHARED_IMPORTS` durante a implementação de T011 ou T027.

**Status**: ⚠️ Observação para o Developer.

---

### 💡 LOW — INC-003: Endpoint GET /api/calculos/historico marcado como opcional

**Descrição**: O contrato (`contracts/calculo-api.md`) marca o `GET /api/calculos/historico` como opcional para o MVP. Porém, o `CalculadoraComponent` (T025) chama `listarHistorico()` ao carregar para popular o histórico inicial. Se o endpoint não for implementado, o histórico inicial ficará vazio até o primeiro cálculo.

**Impacto**: Baixo — o histórico aparece após o primeiro cálculo de qualquer forma. Mas a experiência do usuário ao recarregar a página perde o histórico anterior até realizar um novo cálculo.

**Recomendação**: Implementar o `GET /api/calculos/historico` junto com o `POST /api/calculos` (ambos estão em T020). Não é opcional do ponto de vista da experiência do usuário.

**Status**: 💡 Sugestão de refinamento.

---

## Gaps de Segurança (legado → destino)

Achados do `security-audit.md` e seu status de remediação nos artefatos de destino:

| Achado | Severidade | Remediado nos artefatos? | Observação |
|--------|-----------|--------------------------|------------|
| SEC-001: Sessão sem parâmetros de segurança | MEDIUM | ✅ Sim — eliminado | A stack de destino não usa sessão de servidor para preservar valores do formulário (resolvido no frontend via Signals, conforme `research.md` decisão 5) |
| SEC-002: Arquivo de histórico acessível via HTTP | MEDIUM | ✅ Sim — eliminado | A stack de destino persiste o histórico em banco H2 embarcado, não em arquivo no webroot |
| SEC-003: Supressão de erros de I/O com `@` | MEDIUM | ✅ Sim — eliminado | A stack de destino usa Spring Data JPA com tratamento explícito de exceções e logging estruturado |

**Todos os achados de segurança do legado são remediados pela própria mudança de arquitetura.** Nenhuma task adicional de remediação é necessária.

**Status de aprovação de segurança**: ✅ AUTOMÁTICO — os 3 achados MEDIUM são eliminados pela mudança de stack, sem necessidade de remediação explícita adicional.

---

## Alinhamento com a Constituição

| Princípio | Status | Observação |
|-----------|--------|------------|
| Boilerplate-First | ✅ | Greenfield — primeiros componentes seguem skills `spring-21` e `angular-20` |
| Implementação Incremental | ✅ | 5 fases, 33 tasks, ordenadas por dependência |
| Contratos Imutáveis | ✅ | Greenfield — contratos definidos aqui são a referência inicial |
| Banco via Migration | ✅ | V1__cria_tabela_historico_calculo.sql definida em T010 |

---

## Dúvidas Pendentes de Validação Humana

| # | Dúvida | Impacto | Decisão adotada |
|---|--------|---------|------------------|
| Q1 | Limite de 5 registros: fixo ou configurável? | Baixo | Configurável via propriedade de ambiente (padrão: 5) |

Detalhes em [clarifications.md](./clarifications.md).

---

## Recomendações para o Developer

1. **Prioridade máxima**: Implementar o `GlobalExceptionHandler` (T009) com cuidado especial para que `MethodArgumentNotValidException` retorne a mensagem `Preencha os dois numeros.` — não a mensagem padrão do Bean Validation.
2. **Incluir `PtBrNumberPipe` em `SHARED_IMPORTS`** durante a implementação de T011 ou T027 para facilitar reuso futuro.
3. **Implementar `GET /api/calculos/historico`** junto com o `POST` (ambos em T020) — não tratar como opcional.

---

## Status para Próxima Fase

```
Pronto para: ✅ /speckit-implement
Bloqueadores: nenhum (Issues CRITICAL: 0, Issues HIGH: 0)
Melhorias sugeridas:
  ⚠️ INC-001 — Garantir mensagem correta no GlobalExceptionHandler para campos vazios
  ⚠️ INC-002 — Incluir PtBrNumberPipe em SHARED_IMPORTS
  💡 INC-003 — Não tratar GET /historico como opcional
```
