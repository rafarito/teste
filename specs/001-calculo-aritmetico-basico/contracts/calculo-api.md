# Contrato da API — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23
**Base URL**: `/api`

---

## Endpoints

### POST /api/calculos

Realiza um cálculo aritmético, persiste o resultado no histórico e retorna o resultado junto com os últimos N registros do histórico.

#### Request

**Content-Type**: `application/json`

```json
{
  "num1": "10",
  "num2": "3",
  "operacao": "DIVISAO"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `num1` | `string` | Sim | Primeiro operando. Deve ser um valor numérico válido. |
| `num2` | `string` | Sim | Segundo operando. Deve ser um valor numérico válido. Para operação `DIVISAO`, não pode ser `"0"`. |
| `operacao` | `string` (enum) | Sim | Uma das quatro operações: `SOMA`, `SUBTRACAO`, `MULTIPLICACAO`, `DIVISAO`. |

#### Response — Sucesso (HTTP 200)

**Content-Type**: `application/json`

```json
{
  "resultado": 3.3333333333333335,
  "historico": [
    {
      "dataHora": "2026-09-23T14:30:00",
      "operando1": "10",
      "operando2": "3",
      "simbolo": "/",
      "resultado": 3.3333333333333335
    },
    {
      "dataHora": "2026-09-23T14:25:00",
      "operando1": "5",
      "operando2": "2",
      "simbolo": "+",
      "resultado": 7.0
    }
  ]
}
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `resultado` | `number` | Resultado numérico bruto do cálculo. A formatação pt-BR é aplicada pelo frontend. |
| `historico` | `array` | Lista dos últimos N cálculos realizados (padrão: 5), do mais recente ao mais antigo. |
| `historico[].dataHora` | `string` | Data e hora do cálculo no formato ISO 8601 (`yyyy-MM-dd'T'HH:mm:ss`). |
| `historico[].operando1` | `string` | Primeiro operando exatamente como informado pelo usuário. |
| `historico[].operando2` | `string` | Segundo operando exatamente como informado pelo usuário. |
| `historico[].simbolo` | `string` | Símbolo matemático da operação: `+`, `-`, `*` ou `/`. |
| `historico[].resultado` | `number` | Resultado numérico bruto do cálculo histórico. |

#### Response — Erro de validação de campo (HTTP 400)

Ocorre quando `num1` ou `num2` está vazio/nulo, ou quando `operacao` é inválida.

**Content-Type**: `application/problem+json`

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Preencha os dois numeros.",
  "instance": "/api/calculos"
}
```

#### Response — Erro de negócio: valor não numérico (HTTP 400)

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Operandos invalidos para operacao aritmetica.",
  "instance": "/api/calculos"
}
```

#### Response — Erro de negócio: divisão por zero (HTTP 400)

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Nao e possivel dividir por zero.",
  "instance": "/api/calculos"
}
```

---

### GET /api/calculos/historico

Retorna os últimos N cálculos realizados com sucesso, do mais recente ao mais antigo.

> **Nota**: Este endpoint é opcional para o MVP — o `POST /api/calculos` já retorna o histórico atualizado na resposta. O `GET /api/historico` é útil para carregar o histórico inicial ao abrir a tela, sem precisar realizar um cálculo.

#### Request

Sem parâmetros.

#### Response — Sucesso (HTTP 200)

**Content-Type**: `application/json`

```json
[
  {
    "dataHora": "2026-09-23T14:30:00",
    "operando1": "10",
    "operando2": "3",
    "simbolo": "/",
    "resultado": 3.3333333333333335
  }
]
```

Retorna array vazio `[]` quando não há histórico.

---

## Mapeamento de Mensagens de Erro

| Condição | Campo `detail` no ProblemDetail |
|----------|----------------------------------|
| Campo `num1` ou `num2` vazio | `Preencha os dois numeros.` |
| Valor não numérico em `num1` ou `num2` | `Operandos invalidos para operacao aritmetica.` |
| Divisão por zero (`num2 = "0"` com `operacao = "DIVISAO"`) | `Nao e possivel dividir por zero.` |
| Valor de `operacao` não reconhecido | HTTP 400 (deserialização do enum falha automaticamente) |

---

## Notas de Implementação

- O backend retorna o resultado como `number` (ponto flutuante). A formatação pt-BR (vírgula decimal, ponto de milhar, máx. 4 casas, mín. 1 casa, sem zeros decorativos) é responsabilidade exclusiva do frontend.
- O campo `detail` do `ProblemDetail` contém a mensagem de negócio exata que deve ser exibida ao usuário — o frontend não deve traduzir nem reescrever essas mensagens.
- O histórico retornado no `POST /api/calculos` já inclui o cálculo recém-realizado.
