# Checklist de Requisitos — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23
**Spec**: [spec.md](../spec.md)

---

## Requisitos Funcionais

| ID | Descrição resumida | Comprovado no legado | User Story | Critério de aceite |
|----|--------------------|----------------------|------------|--------------------|
| FR-001 | Formulário com campos Numero 1, Numero 2 e Operacao | ✅ | US1, US2 | SC-001, SC-002 |
| FR-002 | Quatro operações disponíveis: soma, subtração, multiplicação, divisão | ✅ | US1 | SC-001 |
| FR-003 | Rejeitar campo vazio — mensagem `Preencha os dois numeros.` | ✅ | US2 | SC-002 |
| FR-004 | Rejeitar valor não numérico — mensagem `Operandos invalidos para operacao aritmetica.` | ✅ | US2 | SC-002 |
| FR-005 | Rejeitar divisão por zero — mensagem `Nao e possivel dividir por zero.` | ✅ | US2 | SC-002 |
| FR-006 | Formatar resultado em padrão pt-BR (vírgula decimal, ponto milhar, máx. 4 casas, mín. 1 casa) | ✅ | US1, US3 | SC-001, SC-004 |
| FR-007 | Preservar valores digitados no formulário após envio | ✅ | US1, US2 | SC-003 |
| FR-008 | Registrar cálculo bem-sucedido no histórico (data/hora, operandos, símbolo, resultado) | ✅ | US3 | SC-004 |
| FR-009 | Exibir últimos 5 cálculos em ordem decrescente (Data/Hora, Expressão, Resultado) | ✅ | US3 | SC-004 |
| FR-010 | Não exibir seção de histórico quando não há registros | ✅ | US3 | SC-004 |
| FR-011 | Sistema público — sem autenticação | ✅ | US1, US2, US3 | — |

---

## Cobertura por User Story

| User Story | Requisitos cobertos | Status |
|------------|--------------------|---------|
| US1 — Realizar cálculo aritmético (P1) | FR-001, FR-002, FR-006, FR-007 | ✅ Coberta |
| US2 — Receber mensagem de erro (P1) | FR-001, FR-003, FR-004, FR-005, FR-007 | ✅ Coberta |
| US3 — Consultar histórico (P2) | FR-006, FR-008, FR-009, FR-010 | ✅ Coberta |

---

## Premissas Inferidas (requerem validação)

| # | Premissa | Impacto se incorreta | Registrada em clarifications.md |
|---|----------|----------------------|----------------------------------|
| P1 | Limite de 5 registros no histórico é configurável no ambiente de destino | Baixo — o comportamento de exibir 5 é comprovado; apenas a parametrização é inferida | ✅ Q1 |

---

## Mensagens de Erro (literais — regra de negócio)

| Condição | Mensagem exata |
|----------|----------------|
| Campo de número vazio | `Preencha os dois numeros.` |
| Valor não numérico | `Operandos invalidos para operacao aritmetica.` |
| Divisão por zero | `Nao e possivel dividir por zero.` |

---

## Status Geral

- Total de requisitos funcionais: **11**
- Comprovados no legado: **11**
- Inferidos: **0** (premissa inferida registrada separadamente)
- Sem evidência / inventados: **0**

✅ **Checklist aprovado para planejamento.**
