# Agent System — demo-moderniza

Este projeto implementa incrementalmente funcionalidades de **demo-moderniza** usando uma pipeline de agentes especializados do [solutis-ai-kit](https://github.com/solutis/solutis-ai-kit).

---

## Leitura obrigatória antes de qualquer ação

Leia `context/system-context.md` antes de executar qualquer tarefa.
Ele contém as regras não negociáveis que se aplicam a todos os agentes.

---

## Como usar

Para implementar uma funcionalidade, invoque o **Orchestrator Agent** com uma descrição da task.

**Pipeline:**
```
Analyst → Developer → Builder → Reviewer → Unit Tester → Entrega
```

O contexto de cada feature está em `specs/<feature>/` (spec.md, plan.md, tasks.md).

---

## Agentes

| Agente | Papel | Invocação |
|--------|-------|-----------|
| Orchestrator | Coordena a pipeline, sequencia agentes, trata bloqueios | Automático |
| Analyst | Mapeia escopo, regras de negócio, contratos e boilerplate de referência | Via Orchestrator |
| Developer | Implementa o código no escopo da task | Via Orchestrator ou `/develop` |
| Reviewer | Valida qualidade, arquitetura e consistência com o boilerplate | Via Orchestrator |
| Builder | Compila e sobe o backend localmente | Via Orchestrator |
| Unit Tester | Cria/atualiza testes unitários cobrindo a feature implementada | Via Orchestrator ou `/test-unit` |
| Push | Cria branch da feature (git-flow), commita e dá push | `/push` ou automático via Orchestrator (Fase 8), exige feature ativa |
| MR | Cria Pull Request/Merge Request no host remoto listando commits e mudanças | `/mr` ou automático via Orchestrator (Fase 9), exige feature ativa |
| Sonar | Sobe SonarQube e executa análise de código via containers Docker separados | Somente `/sonar` |
| Dependency Audit | Audita dependências do projeto (desatualizadas, deprecated, sem manutenção, vulneráveis e supply chain) e recomenda atualizações compatíveis | Somente `/dependency-audit` |
| Documentador | Gera e mantém diagramas C4 da arquitetura do sistema | Manual |

---

## Context e estado

| Arquivo | Papel |
|---------|-------|
| `context/system-context.md` | Regras globais — injetado em todos os agentes |
| `specs/<feature>/` | Contexto por feature — spec.md, plan.md, tasks.md |
| `.specify/memory/constitution.md` | Princípios e regras do projeto |

---

## Documentação de referência

| Arquivo | Conteúdo | Quem usa |
|---------|---------|---------|
| `docs/architecture/overview.md` | Arquitetura atual do projeto | Todos os agentes |
| `docs/business/` | Regras de negócio por domínio | Todos os agentes |
| `docs/system/` | Documentos originais do sistema | Todos os agentes |
| `docs/images/` | Screenshots de layout por funcionalidade | Todos os agentes |
