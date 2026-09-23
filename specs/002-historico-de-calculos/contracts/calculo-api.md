# Contrato de API: Cálculo e Histórico de Cálculos

**Feature**: 002-historico-de-calculos
**Data**: 2026-09-23

Este contrato descreve a interface REST exposta pelo backend ao frontend para esta feature. Os nomes de campos e endpoints são definidos exclusivamente para a stack de destino — não há contrato equivalente no legado (o legado expõe apenas um formulário HTML server-side, sem API).

## Endpoint 1: Realizar cálculo

**Requisição**: `POST /calculos`

**Corpo da requisição**:

```json
{
  "operando1": 10,
  "operando2": 2,
  "operacao": "divisao"
}
```

| Campo | Tipo | Obrigatório | Regra |
|---|---|---|---|
| operando1 | número | Sim | Deve ser um valor numérico válido (FR relacionado à validação, ver spec.md - User Story 1, Cenário 2). |
| operando2 | número | Sim | Deve ser um valor numérico válido; se `operacao` for divisão, não pode ser zero (spec.md - Cenário 3). |
| operacao | texto | Sim | Um dos valores suportados: `soma`, `subtracao`, `multiplicacao`, `divisao`. |

**Resposta de sucesso** (`200 OK`):

```json
{
  "operando1": 10,
  "operando2": 2,
  "operacao": "divisao",
  "resultado": 5
}
```

**Resposta de erro** (`400 Bad Request`, formato `ProblemDetail`):

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Não é possível dividir por zero."
}
```

Outras mensagens de erro possíveis, refletindo o comportamento comprovado no legado:
- "Preencha os dois números." (operandos não preenchidos)
- "Operandos inválidos para operação aritmética." (operandos não numéricos)
- "Operação desconhecida: {valor}" (operação fora da whitelist suportada)

**Efeito colateral**: em caso de sucesso, o sistema registra o cálculo no histórico persistente (FR-001). Uma falha nesse registro não altera a resposta deste endpoint (FR-008).

## Endpoint 2: Consultar histórico de cálculos recentes

**Requisição**: `GET /calculos/historico`

**Resposta de sucesso** (`200 OK`):

```json
[
  {
    "dataHora": "2026-09-23T14:32:10",
    "operando1": 10,
    "operando2": 2,
    "operacao": "divisao",
    "resultado": 5
  },
  {
    "dataHora": "2026-09-23T14:30:02",
    "operando1": 4,
    "operando2": 6,
    "operacao": "soma",
    "resultado": 10
  }
]
```

- A lista é ordenada do mais recente para o mais antigo (FR-003).
- A quantidade de itens retornados nunca ultrapassa o limite máximo configurado no servidor (padrão 5, FR-004) — não é um parâmetro de query da requisição (ver `research.md`, Decisão 2).
- Se não houver nenhum registro, a resposta é uma lista vazia (`[]`); o frontend decide, com base nisso, não exibir a seção de histórico (FR-006).
- A formatação do resultado no padrão numérico brasileiro (FR-005) é responsabilidade do frontend ao exibir o valor numérico recebido — o contrato entrega o valor numérico puro (ver `research.md`, Decisão 4).
