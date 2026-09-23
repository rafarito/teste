# Especificação de Feature: Histórico de Cálculos

**Branch da feature**: `002-historico-de-calculos`

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

## Cenários de Usuário e Testes *(obrigatório)*

### User Story 1 - Registro automático de cálculo bem-sucedido no histórico (Prioridade: P1)

Sempre que um usuário realiza um cálculo aritmético com sucesso (operandos válidos e operação executável), o sistema registra esse cálculo de forma persistente, guardando data/hora, a expressão utilizada (operandos e operação) e o resultado obtido. Cálculos que falham por validação ou por erro de execução (como divisão por zero) não geram registro.

**Por que esta prioridade**: sem o registro persistente, não há dado algum para compor o histórico exibido na User Story 2 — é a base de toda a feature.

**Teste Independente**: pode ser validado realizando um cálculo válido e conferindo, de forma isolada (ex.: inspecionando o armazenamento ou reconsultando o histórico), que um novo registro com os dados corretos foi adicionado; e realizando um cálculo inválido, conferindo que nenhum registro novo foi criado.

**Cenários de Aceite**:

1. **Dado** que um usuário informa dois operandos válidos e uma operação suportada, **Quando** o cálculo é concluído com sucesso, **Então** o sistema registra de forma persistente a data/hora do cálculo, os operandos e a operação utilizada, e o resultado obtido.
2. **Dado** que um usuário submete o formulário sem preencher um ou ambos os operandos, **Quando** a validação falha, **Então** nenhum registro é adicionado ao histórico.
3. **Dado** que um usuário solicita uma divisão em que o segundo operando é zero, **Quando** o cálculo é submetido, **Então** a operação é rejeitada com mensagem de erro e nenhum registro é adicionado ao histórico.
4. **Dado** que ocorre uma falha ao gravar o registro no armazenamento persistente, **Quando** um cálculo é concluído com sucesso, **Então** o resultado do cálculo é exibido normalmente ao usuário, independentemente do sucesso da gravação do registro.

---

### User Story 2 - Exibição dos cálculos mais recentes (Prioridade: P2)

O usuário visualiza, na mesma tela onde realiza os cálculos, uma lista com os cálculos mais recentes já registrados, ordenados do mais novo para o mais antigo, limitada a uma quantidade máxima configurável (padrão: 5 registros).

**Por que esta prioridade**: depende do registro (User Story 1) já existir; é o valor percebido pelo usuário — poder consultar o que foi calculado anteriormente.

**Teste Independente**: pode ser validado populando o histórico com mais registros do que o limite configurado e conferindo que apenas a quantidade configurada é exibida, na ordem correta (mais recente primeiro).

**Cenários de Aceite**:

1. **Dado** que existem cálculos previamente registrados, **Quando** o usuário acessa a tela, **Então** o sistema exibe a lista dos cálculos mais recentes, ordenada do mais novo para o mais antigo.
2. **Dado** que a quantidade de registros existentes no histórico é maior que o limite máximo configurado de exibição, **Quando** a lista é exibida, **Então** apenas a quantidade máxima configurada de registros mais recentes é exibida (valor padrão: 5, quando não configurado de outra forma).
3. **Dado** que não existe nenhum cálculo registrado, **Quando** o usuário acessa a tela, **Então** a seção de histórico não é exibida.
4. **Dado** que um registro do histórico está corrompido ou ilegível no armazenamento, **Quando** a lista é montada, **Então** esse registro é ignorado, e os demais registros válidos continuam sendo exibidos normalmente.
5. **Dado** que um cálculo foi registrado com sucesso, **Quando** a lista de histórico é exibida, **Então** cada registro mostra a data/hora do cálculo, a expressão (operandos e operação) e o resultado formatado no padrão numérico brasileiro (vírgula como separador decimal).

---

### Casos de Borda

- Quando não existe nenhum cálculo registrado, a seção de histórico inteira não é exibida ao usuário.
- Quando um registro do histórico está corrompido ou não pode ser interpretado, ele é descartado silenciosamente da lista, sem impedir a exibição dos demais registros válidos nem gerar erro visível ao usuário.
- Quando a gravação de um novo registro falha (ex.: armazenamento persistente indisponível ou inacessível), o cálculo em si não é afetado: o resultado continua sendo exibido normalmente ao usuário, apenas o registro no histórico não é adicionado.
- Cálculos que falham por validação de operandos ou por divisão por zero nunca geram registro no histórico, mesmo que o usuário tenha preenchido parcialmente o formulário.

## Requisitos *(obrigatório)*

### Requisitos Funcionais

- **FR-001**: O sistema DEVE registrar de forma persistente cada cálculo aritmético concluído com sucesso, contendo: data e hora do cálculo, os dois operandos utilizados, a operação aplicada e o resultado obtido.
- **FR-002**: O sistema NÃO DEVE registrar no histórico cálculos que falharem por validação de operandos (campos não preenchidos ou valores não numéricos) ou por tentativa de divisão por zero.
- **FR-003**: O sistema DEVE exibir ao usuário a lista dos cálculos mais recentes, ordenada do mais novo para o mais antigo (por data/hora de realização).
- **FR-004**: O sistema DEVE limitar a quantidade de registros exibidos na lista de histórico a um número máximo configurável, com valor padrão de 5 registros quando não configurado de outra forma.
- **FR-005**: O sistema DEVE exibir, para cada registro do histórico, a data/hora do cálculo, a expressão realizada (operandos e operação) e o resultado, formatado no padrão numérico brasileiro (vírgula como separador decimal).
- **FR-006**: O sistema NÃO DEVE exibir a seção de histórico quando não houver nenhum cálculo registrado.
- **FR-007**: O sistema DEVE ignorar, ao montar a lista de histórico, qualquer registro armazenado que esteja corrompido ou ilegível, sem impedir a exibição dos demais registros válidos.
- **FR-008**: Uma falha ao persistir um novo registro de histórico NÃO DEVE impedir a exibição do resultado do cálculo ao usuário — a gravação do histórico é um efeito colateral do cálculo bem-sucedido, não uma condição para exibir o resultado.
- **FR-009**: Todos os cálculos bem-sucedidos DEVEM permanecer armazenados no histórico persistente, independentemente de quantos sejam realizados; a limitação de quantidade (FR-004) aplica-se apenas à exibição, não ao armazenamento.

### Entidades Principais

- **Registro de Cálculo**: representa um cálculo aritmético concluído com sucesso. Atributos: Data/Hora do cálculo (Data), Primeiro Operando (Número), Segundo Operando (Número), Operação/Símbolo utilizado (Texto), Resultado (Número). Cada registro é imutável após criado — não há operação de edição ou exclusão de registros identificada no comportamento da feature.

## Critérios de Sucesso *(obrigatório)*

### Resultados Mensuráveis

- **SC-001**: **Dado** um cálculo realizado com sucesso pelo usuário, **Quando** a lista de histórico é consultada em seguida, **Então** esse cálculo aparece na lista com data/hora, expressão e resultado corretos.
- **SC-002**: **Dado** um histórico com mais registros do que a quantidade máxima configurada, **Quando** a lista é exibida, **Então** o número de registros exibidos nunca ultrapassa a quantidade máxima configurada.
- **SC-003**: **Dado** dois ou mais cálculos registrados em momentos diferentes, **Quando** a lista de histórico é exibida, **Então** os registros aparecem ordenados do mais recente para o mais antigo.
- **SC-004**: **Dado** um cálculo que falhou por validação de operandos ou por divisão por zero, **Quando** a lista de histórico é consultada em seguida, **Então** nenhum registro correspondente a esse cálculo aparece na lista.

## Premissas

**Comprovadas no código:**

- O histórico de cálculos é compartilhado por todos os usuários da aplicação — não há segmentação de registros por usuário ou por sessão individual, já que a feature não possui identificação de usuário nem controle de acesso.
- A quantidade máxima de registros exibidos é definida por configuração do sistema (não é um parâmetro escolhido pelo usuário na tela).
- Todos os cálculos bem-sucedidos são armazenados permanentemente no histórico persistente; a limitação de quantidade máxima aplica-se somente à exibição, nunca ao armazenamento em si — não existe rotina de expurgo, limpeza ou exclusão de registros antigos no comportamento observado.
- A exibição do histórico ocorre na mesma tela onde o usuário realiza os cálculos; não existe uma tela ou consulta dedicada apenas ao histórico completo.
- Um registro que não possa ser interpretado corretamente ao ser lido do armazenamento é descartado silenciosamente, sem gerar mensagem de erro ao usuário e sem impedir a exibição dos demais registros.

**Inferidas (sem evidência direta):** nenhuma. Todo o comportamento descrito nesta especificação foi comprovado diretamente na leitura do código da feature; não houve necessidade de premissas inferidas.
