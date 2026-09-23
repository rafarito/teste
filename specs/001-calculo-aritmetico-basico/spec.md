# Especificação de Feature: Cálculo Aritmético Básico

**Branch da feature**: `001-calculo-aritmetico-basico`

**Criado em**: 2026-09-23

**Status**: Rascunho

**Data**: 2026-09-23

---

## 📋 Artefatos Relacionados

**Audit de Segurança**: [security-audit.md](./security-audit.md)  
Vulnerabilidades encontradas no código legado e remediações sugeridas (para análise do ANALISTA).

**Análise Técnica**: [functional-spec.md](./functional-spec.md)  
Análise cross-artifact: cobertura, inconsistências, gaps de segurança e status de aprovação.

**Dúvidas e Decisões**: [clarifications.md](./clarifications.md)  
Dúvidas sem evidência conclusiva no legado, opções consideradas e a decisão adotada em cada uma. Existe apenas quando restou dúvida material — ausente, a spec saiu inteiramente comprovada no código.

---

## ⚠️ Dúvidas e Decisões Pendentes de Validação

Esta especificação contém **1 ponto decidido sem evidência conclusiva** no código legado.
As dúvidas, as opções consideradas e a decisão adotada em cada caso estão em
[clarifications.md](./clarifications.md). Revise antes de planejar ou implementar.

---

## Cenários de Usuário e Testes

### User Story 1 — Realizar um cálculo aritmético (Prioridade: P1)

O usuário acessa a calculadora, informa dois números, escolhe uma operação entre soma, subtração, multiplicação e divisão, e obtém o resultado formatado no padrão brasileiro. Os valores digitados permanecem visíveis no formulário após o envio.

**Por que esta prioridade**: É a funcionalidade central e única da feature. Sem ela, nada mais faz sentido.

**Teste Independente**: Pode ser testado de forma completa ao preencher o formulário com dois números válidos, selecionar uma operação e submeter — o resultado deve aparecer formatado e os campos devem manter os valores informados.

**Cenários de Aceite**:

1. **Dado** que o usuário informou dois números válidos e selecionou a operação de soma, **Quando** submete o formulário, **Então** o sistema exibe o resultado da soma formatado no padrão brasileiro (vírgula como separador decimal, ponto como separador de milhar) e os campos `Numero 1`, `Numero 2` e `Operacao` mantêm os valores informados.
2. **Dado** que o usuário informou dois números válidos e selecionou a operação de subtração, **Quando** submete o formulário, **Então** o sistema exibe o resultado da subtração formatado no padrão brasileiro.
3. **Dado** que o usuário informou dois números válidos e selecionou a operação de multiplicação, **Quando** submete o formulário, **Então** o sistema exibe o resultado da multiplicação formatado no padrão brasileiro.
4. **Dado** que o usuário informou dois números válidos e selecionou a operação de divisão com divisor diferente de zero, **Quando** submete o formulário, **Então** o sistema exibe o resultado da divisão formatado no padrão brasileiro.
5. **Dado** que um cálculo foi realizado com sucesso, **Quando** o resultado é exibido, **Então** o valor numérico usa vírgula como separador decimal, ponto como separador de milhar, no máximo 4 casas decimais, sem zeros decorativos à direita (exceto ao menos uma casa decimal obrigatória).

---

### User Story 2 — Receber mensagem de erro em entradas inválidas (Prioridade: P1)

O usuário tenta realizar um cálculo com campos vazios, valores não numéricos ou divisão por zero. O sistema rejeita a operação, exibe uma mensagem de erro descritiva e mantém os valores digitados no formulário.

**Por que esta prioridade**: Validação é parte inseparável do fluxo principal — sem ela, a feature não está completa.

**Teste Independente**: Pode ser testado submetendo o formulário com cada condição de erro separadamente e verificando a mensagem exibida e a preservação dos campos.

**Cenários de Aceite**:

1. **Dado** que o usuário deixou um ou ambos os campos de número em branco, **Quando** submete o formulário, **Então** o sistema exibe a mensagem `Preencha os dois numeros.` e nenhum resultado é exibido.
2. **Dado** que o usuário informou um valor não numérico em qualquer um dos campos de número, **Quando** submete o formulário, **Então** o sistema exibe a mensagem `Operandos invalidos para operacao aritmetica.` e nenhum resultado é exibido.
3. **Dado** que o usuário selecionou a operação de divisão e informou zero como segundo número, **Quando** submete o formulário, **Então** o sistema exibe a mensagem `Nao e possivel dividir por zero.` e nenhum resultado é exibido.
4. **Dado** que qualquer erro ocorreu, **Quando** a mensagem de erro é exibida, **Então** os valores que o usuário digitou nos campos `Numero 1`, `Numero 2` e a operação selecionada permanecem visíveis no formulário.

---

### User Story 3 — Consultar histórico dos últimos cálculos (Prioridade: P2)

Após realizar cálculos, o usuário visualiza na mesma tela uma listagem dos últimos cálculos realizados, com data/hora, expressão e resultado de cada um.

**Por que esta prioridade**: Agrega valor informacional mas não bloqueia o uso da calculadora. Pode ser entregue após o fluxo principal estar funcional.

**Teste Independente**: Pode ser testado realizando ao menos um cálculo com sucesso e verificando que ele aparece na listagem de histórico abaixo do formulário.

**Cenários de Aceite**:

1. **Dado** que ao menos um cálculo foi realizado com sucesso, **Quando** o usuário visualiza a tela da calculadora, **Então** uma seção de histórico é exibida abaixo do formulário, listando os últimos cálculos em ordem do mais recente para o mais antigo.
2. **Dado** que a seção de histórico é exibida, **Quando** o usuário a observa, **Então** cada registro mostra: data e hora do cálculo, a expressão (número 1, símbolo da operação, número 2) e o resultado formatado no padrão brasileiro.
3. **Dado** que existem mais de 5 cálculos registrados, **Quando** o histórico é exibido, **Então** apenas os 5 mais recentes são listados.
4. **Dado** que nenhum cálculo foi realizado ainda, **Quando** o usuário visualiza a tela, **Então** a seção de histórico não é exibida.

---

### Casos de Borda

- O que acontece quando o campo de número contém apenas espaços em branco? → É tratado como campo vazio: exibe `Preencha os dois numeros.`
- O que acontece quando o valor informado é uma string não numérica (ex: letras)? → Exibe `Operandos invalidos para operacao aritmetica.`
- O que acontece quando o segundo operando da divisão é exatamente zero? → Exibe `Nao e possivel dividir por zero.`
- O que acontece quando o resultado tem mais de 4 casas decimais significativas? → O resultado é arredondado para 4 casas decimais, com zeros decorativos à direita removidos.
- O que acontece quando o resultado é um número inteiro? → É exibido com ao menos uma casa decimal (ex: `10,0`).

## Requisitos

### Requisitos Funcionais

- **FR-001**: O sistema DEVE apresentar um formulário com os campos `Numero 1` (texto livre), `Numero 2` (texto livre) e `Operacao` (seleção entre as quatro operações disponíveis: soma, subtração, multiplicação e divisão).
- **FR-002**: O sistema DEVE disponibilizar exatamente quatro operações: soma (símbolo `+`), subtração (símbolo `-`), multiplicação (símbolo `*`) e divisão (símbolo `/`).
- **FR-003**: O sistema DEVE rejeitar o envio quando qualquer um dos campos de número estiver vazio ou contiver apenas espaços em branco, exibindo a mensagem `Preencha os dois numeros.`
- **FR-004**: O sistema DEVE rejeitar o envio quando qualquer um dos campos de número contiver um valor não numérico, exibindo a mensagem `Operandos invalidos para operacao aritmetica.`
- **FR-005**: O sistema DEVE rejeitar a operação de divisão quando o segundo número for zero, exibindo a mensagem `Nao e possivel dividir por zero.`
- **FR-006**: O sistema DEVE formatar o resultado numérico no padrão brasileiro: vírgula como separador decimal, ponto como separador de milhar, no máximo 4 casas decimais, sem zeros decorativos à direita, com ao menos uma casa decimal sempre presente.
- **FR-007**: O sistema DEVE preservar os valores digitados nos campos `Numero 1`, `Numero 2` e a operação selecionada após o envio do formulário, independentemente de sucesso ou erro.
- **FR-008**: O sistema DEVE registrar cada cálculo realizado com sucesso no histórico, armazenando: data e hora, primeiro operando, segundo operando, símbolo da operação e resultado.
- **FR-009**: O sistema DEVE exibir, abaixo do formulário, os últimos 5 cálculos realizados com sucesso, em ordem do mais recente para o mais antigo, com as colunas: Data/Hora, Expressão e Resultado.
- **FR-010**: O sistema NÃO DEVE exibir a seção de histórico quando não houver nenhum cálculo registrado.
- **FR-011**: O sistema NÃO DEVE exigir autenticação — a calculadora é pública e acessível sem login.

### Entidades Principais

- **Cálculo**: representa uma operação aritmética realizada com sucesso. Atributos: data e hora da realização, primeiro operando (valor numérico informado pelo usuário), segundo operando (valor numérico informado pelo usuário), símbolo da operação (`+`, `-`, `*`, `/`), resultado numérico.
- **Operação**: uma das quatro operações aritméticas disponíveis. Atributos: identificador interno (soma, subtracao, multiplicacao, divisao), rótulo de exibição (Soma, Subtracao, Multiplicacao, Divisao), símbolo matemático (`+`, `-`, `*`, `/`).

## Critérios de Sucesso

- **SC-001**: **Dado** que o usuário informa dois números válidos e seleciona qualquer operação disponível, **Quando** submete o formulário, **Então** o resultado correto é exibido formatado no padrão brasileiro.
- **SC-002**: **Dado** que o usuário submete o formulário com campo vazio, valor não numérico ou divisão por zero, **Quando** o sistema processa a requisição, **Então** a mensagem de erro correspondente é exibida e nenhum resultado é mostrado.
- **SC-003**: **Dado** que o formulário foi submetido (com sucesso ou com erro), **Quando** a tela é exibida novamente, **Então** os valores digitados pelo usuário permanecem nos campos do formulário.
- **SC-004**: **Dado** que ao menos um cálculo foi realizado com sucesso, **Quando** o usuário visualiza a tela, **Então** o histórico dos últimos cálculos (máximo 5) é exibido com data/hora, expressão e resultado formatado.

## Premissas

### Comprovadas no código

- O sistema não possui autenticação; é público e acessível sem login.
- O limite de registros exibidos no histórico é 5.
- A formatação numérica usa vírgula decimal, ponto de milhar, máximo 4 casas decimais, sem zeros decorativos à direita, com mínimo de 1 casa decimal.
- As quatro operações disponíveis são fixas: soma, subtração, multiplicação e divisão.
- Os valores dos campos são preservados entre o envio e a exibição da resposta.
- O histórico é exibido apenas quando há ao menos um registro.
- O histórico é ordenado do mais recente para o mais antigo.

### Inferidas (sem evidência direta)

- O número máximo de registros exibidos no histórico (5) é configurável no ambiente de destino, não um valor fixo em código. (inferido) — o valor `5` aparece em arquivo de configuração do legado, sugerindo que é parametrizável, mas a stack de destino não tem configuração equivalente ainda definida.
