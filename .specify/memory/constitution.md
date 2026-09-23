# {{project_name}} Constitution

## Core Principles

### I. Boilerplate-First

Todo código novo deve seguir o padrão já estabelecido no projeto.
Antes de implementar, localizar exemplos equivalentes e replicar estrutura, anotações e convenções.
Não inventar padrões que não existam no projeto.

### II. Implementação Incremental (NÃO NEGOCIÁVEL)

Nunca implementar toda uma funcionalidade de uma vez.
Cada spec gera tasks independentes por domínio funcional — uma task por endpoint ou grupo coeso de funcionalidades.
Tasks ordenadas por dependência: criar antes de listar, listar antes de buscar.

### III. Contratos Imutáveis

DTOs de request/response existentes são imutáveis.
Nenhuma spec pode alterar nomes de campos, tipos de dados ou endpoints já existentes sem necessidade explícita documentada.

### IV. Banco via Migration (NÃO NEGOCIÁVEL)

Toda alteração de schema exige migration versionada.
Entidades mapeiam o schema — nunca o contrário.
Migrations já aplicadas são imutáveis.

## Stack

| Camada | Stack |
|--------|-------|
| Backend | (preencher) |
| Frontend | (preencher) |
| Banco | (preencher) |
| Auth | (preencher) |

## Governance

Esta constitution supersede todas as outras práticas.
Qualquer spec que viole estes princípios deve ser bloqueada antes de chegar ao Developer.
Consultar `context/system-context.md` para regras de runtime detalhadas.

**Version**: 1.0.0 | **Ratified**: (data)
