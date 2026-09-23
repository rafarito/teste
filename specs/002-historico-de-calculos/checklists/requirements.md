# Checklist de Qualidade de Requisitos: Histórico de Cálculos

**Propósito**: Validar a completude, clareza e consistência dos requisitos antes do planejamento técnico.

**Criado em**: 2026-09-23

**Escopo**: FR-001 a FR-009, entidades e critérios de sucesso do `spec.md`.

---

## Completude dos Requisitos

- [x] CHK001 - Existe requisito cobrindo o registro persistente de cada cálculo bem-sucedido? (FR-001)
- [x] CHK002 - Existe requisito cobrindo os casos em que um cálculo NÃO deve ser registrado? (FR-002)
- [x] CHK003 - Existe requisito cobrindo a exibição da lista de cálculos mais recentes? (FR-003)
- [x] CHK004 - Existe requisito cobrindo o limite máximo (e seu valor padrão) de registros exibidos? (FR-004)
- [x] CHK005 - Existe requisito cobrindo os campos exibidos por registro e sua formatação? (FR-005)
- [x] CHK006 - Existe requisito cobrindo o comportamento quando não há nenhum registro no histórico? (FR-006)
- [x] CHK007 - Existe requisito cobrindo o tratamento de registros corrompidos/ilegíveis? (FR-007)
- [x] CHK008 - Existe requisito cobrindo a independência entre sucesso do cálculo e sucesso da gravação do histórico? (FR-008)
- [x] CHK009 - Existe requisito distinguindo limite de exibição de limite de armazenamento? (FR-009)

## Clareza e Ambiguidade

- [x] CHK010 - O critério de ordenação da lista ("mais novo para o mais antigo") está definido de forma verificável? (FR-003)
- [x] CHK011 - O valor padrão da quantidade máxima exibida está explícito e não ambíguo? (FR-004 - padrão 5)
- [x] CHK012 - A formatação numérica esperada no resultado está definida sem ambiguidade? (FR-005 - padrão pt-BR)
- [x] CHK013 - Não há marcadores `[NEEDS CLARIFICATION]` pendentes no `spec.md`.

## Consistência

- [x] CHK014 - Os cenários de aceite das User Stories 1 e 2 são consistentes entre si quanto ao que gera ou não um registro no histórico.
- [x] CHK015 - Os Critérios de Sucesso (SC-001 a SC-004) são rastreáveis a requisitos funcionais específicos (FR-001, FR-004, FR-003, FR-002).
- [x] CHK016 - Nenhuma premissa inferida (sufixo `(inferido)`) aparece sem evidência correspondente — não há premissas inferidas nesta feature.

## Cobertura de Casos de Borda

- [x] CHK017 - O caso de histórico vazio está coberto por um requisito e por um cenário de aceite. (FR-006)
- [x] CHK018 - O caso de falha na gravação do registro está coberto sem impactar o retorno do cálculo ao usuário. (FR-008)
- [x] CHK019 - O caso de registro corrompido no armazenamento está coberto sem interromper a exibição dos demais. (FR-007)

## Alinhamento com Escopo

- [x] CHK020 - Nenhum requisito de edição ou exclusão de registros do histórico foi incluído (não há evidência dessas operações no comportamento observado).
- [x] CHK021 - Nenhum requisito de segmentação de histórico por usuário/perfil foi incluído (não há autenticação nem identificação de usuário na feature).
- [x] CHK022 - Nenhuma métrica de negócio não verificável (ex.: percentuais de redução de chamados) foi incluída nos Critérios de Sucesso.

---

## Resultado

Todos os itens desta checklist foram validados como atendidos com base no comportamento comprovado no código-fonte lido. Nenhum item pendente.
