# Modelo de Dados: Histórico de Cálculos

**Feature**: 002-historico-de-calculos
**Data**: 2026-09-23

## Entidade: HistoricoCalculo

Representa um cálculo aritmético concluído com sucesso, registrado de forma persistente e imutável.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | Identificador numérico (chave primária, gerado pelo banco) | Sim | Identificador técnico único do registro. |
| dataHora | Data/Hora | Sim | Momento em que o cálculo foi concluído com sucesso (FR-001). |
| operando1 | Número decimal | Sim | Primeiro operando informado pelo usuário (FR-001). |
| operando2 | Número decimal | Sim | Segundo operando informado pelo usuário (FR-001). |
| simboloOperacao | Texto curto | Sim | Símbolo da operação aplicada (ex.: soma, subtração, multiplicação, divisão), usado para compor a expressão exibida (FR-001, FR-005). |
| resultado | Número decimal | Sim | Resultado obtido pelo cálculo (FR-001). |

**Regras de negócio associadas**:

- Um registro só é criado quando o cálculo é concluído com sucesso (FR-001); nunca para cálculos que falham por validação de operandos ou por divisão por zero (FR-002).
- Um registro, uma vez criado, é imutável — não há operação de edição ou exclusão identificada no comportamento da feature (ver `## Entidades Principais` do `spec.md`).
- Todos os registros bem-sucedidos são mantidos permanentemente no armazenamento; a limitação de quantidade (padrão 5, configurável) aplica-se apenas à consulta/exibição, nunca à retenção dos dados (FR-009).
- Um registro que não possa ser lido corretamente do armazenamento (dado corrompido) é ignorado ao montar a lista de exibição, sem impedir a exibição dos demais registros válidos (FR-007).

## Relacionamentos

Não há relacionamento com outras entidades — o histórico de cálculos é uma entidade autônoma e compartilhada por todos os usuários da aplicação (não há entidade de Usuário nesta feature, pois a aplicação não possui autenticação, conforme `system-context.md`).

## Consulta de listagem

A operação de listagem (US2) recupera os registros ordenados por `dataHora` de forma decrescente (mais recente primeiro), limitados a uma quantidade máxima configurável (padrão 5, ver `research.md`, Decisão 2). Essa é uma operação de leitura que não altera o estado dos registros.
