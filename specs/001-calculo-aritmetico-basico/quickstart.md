# Quickstart — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23

Guia para subir o ambiente local e validar manualmente os fluxos da feature após a implementação.

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|------------|---------------|
| Java | 21 |
| Maven | 3.9+ |
| Node.js | 20+ |
| Angular CLI | 20.x |
| Navegador | Qualquer moderno (Chrome, Firefox, Edge) |

---

## 1. Subir o backend

```bash
# A partir do diretório backend/
mvn clean install
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

**Sinal de sucesso**: log exibe `Started CalculadoraApplication in`

O backend sobe em `http://localhost:8080` por padrão.

---

## 2. Subir o frontend

```bash
# A partir do diretório frontend/
npm install
npm start
```

**Sinal de sucesso**: log exibe `Application bundle generation complete` e `Local: http://localhost:4200/`

---

## 3. Validação manual — Fluxos principais

### 3.1 Cálculo com sucesso

1. Acesse `http://localhost:4200`
2. Preencha `Numero 1` com `10`
3. Preencha `Numero 2` com `3`
4. Selecione a operação `Divisao (/)`
5. Clique em `Calcular`

**Resultado esperado**:
- O resultado exibido é `3,3333` (formatado em pt-BR, 4 casas decimais, sem zeros decorativos)
- Os campos `Numero 1`, `Numero 2` e a operação selecionada mantêm os valores informados
- O cálculo aparece na seção de histórico com data/hora, expressão `10 / 3` e resultado `3,3333`

### 3.2 Resultado inteiro

1. Preencha `Numero 1` com `6`, `Numero 2` com `2`, operação `Divisao (/)`
2. Clique em `Calcular`

**Resultado esperado**: `3,0` (ao menos uma casa decimal obrigatória)

### 3.3 Erro — campo vazio

1. Deixe `Numero 1` em branco
2. Preencha `Numero 2` com `5`, operação `Soma (+)`
3. Clique em `Calcular`

**Resultado esperado**:
- Mensagem de erro: `Preencha os dois numeros.`
- Nenhum resultado exibido
- Os valores digitados permanecem nos campos

### 3.4 Erro — valor não numérico

1. Preencha `Numero 1` com `abc`, `Numero 2` com `5`, operação `Soma (+)`
2. Clique em `Calcular`

**Resultado esperado**:
- Mensagem de erro: `Operandos invalidos para operacao aritmetica.`
- Nenhum resultado exibido

### 3.5 Erro — divisão por zero

1. Preencha `Numero 1` com `10`, `Numero 2` com `0`, operação `Divisao (/)`
2. Clique em `Calcular`

**Resultado esperado**:
- Mensagem de erro: `Nao e possivel dividir por zero.`
- Nenhum resultado exibido

### 3.6 Histórico com limite de 5 registros

1. Realize 6 cálculos válidos consecutivos
2. Observe a seção de histórico

**Resultado esperado**: Apenas os 5 cálculos mais recentes são exibidos, do mais recente ao mais antigo.

### 3.7 Histórico vazio

1. Reinicie o backend (banco H2 em memória é reiniciado junto, se configurado em modo memória)
2. Acesse a tela sem realizar nenhum cálculo

**Resultado esperado**: A seção de histórico não é exibida.

---

## 4. Validação via API (Playwright ou curl)

### Cálculo com sucesso

```bash
curl -X POST http://localhost:8080/api/calculos \
  -H "Content-Type: application/json" \
  -d '{"num1": "10", "num2": "3", "operacao": "DIVISAO"}'
```

**Resposta esperada** (HTTP 200):
```json
{
  "resultado": 3.3333333333333335,
  "historico": [ ... ]
}
```

### Erro — campo vazio

```bash
curl -X POST http://localhost:8080/api/calculos \
  -H "Content-Type: application/json" \
  -d '{"num1": "", "num2": "5", "operacao": "SOMA"}'
```

**Resposta esperada** (HTTP 400):
```json
{
  "status": 400,
  "detail": "Preencha os dois numeros."
}
```

### Erro — divisão por zero

```bash
curl -X POST http://localhost:8080/api/calculos \
  -H "Content-Type: application/json" \
  -d '{"num1": "10", "num2": "0", "operacao": "DIVISAO"}'
```

**Resposta esperada** (HTTP 400):
```json
{
  "status": 400,
  "detail": "Nao e possivel dividir por zero."
}
```

### Histórico inicial

```bash
curl http://localhost:8080/api/calculos/historico
```

**Resposta esperada** (HTTP 200): array com os últimos cálculos ou `[]` se vazio.

---

## 5. Checklist de validação

- [ ] Backend sobe sem erros
- [ ] Frontend sobe e exibe o formulário
- [ ] Soma, subtração, multiplicação e divisão retornam resultado correto
- [ ] Resultado formatado em pt-BR (vírgula decimal, ponto de milhar)
- [ ] Resultado inteiro exibe ao menos uma casa decimal (ex: `3,0`)
- [ ] Resultado com casas decimais não exibe zeros decorativos (ex: `3,5` e não `3,5000`)
- [ ] Campo vazio exibe `Preencha os dois numeros.`
- [ ] Valor não numérico exibe `Operandos invalidos para operacao aritmetica.`
- [ ] Divisão por zero exibe `Nao e possivel dividir por zero.`
- [ ] Valores digitados permanecem no formulário após erro
- [ ] Valores digitados permanecem no formulário após sucesso
- [ ] Histórico exibe os últimos 5 cálculos em ordem decrescente
- [ ] Histórico não é exibido quando não há registros
