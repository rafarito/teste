# Plano de Implementação: [FEATURE]

**Branch**: `[###-feature-name]` | **Data**: [DATE] | **Spec**: [link]

**Entrada**: Especificação da feature em `/specs/[###-feature-name]/spec.md`

**Nota**: Este template é preenchido pelo comando `/speckit-plan`. Ver `.specify/templates/plan-template.md` para o fluxo de execução.

## Resumo

[Extraia da spec da feature: requisito principal + abordagem técnica a partir da pesquisa]

## Contexto Técnico

<!--
  AÇÃO NECESSÁRIA: Substitua o conteúdo desta seção pelos detalhes técnicos
  do projeto. A estrutura aqui é apresentada em caráter consultivo para
  orientar o processo de iteração.
-->

**Linguagem/Versão**: [ex.: Python 3.11, Swift 5.9, Rust 1.75 ou NEEDS CLARIFICATION]

**Dependências Principais**: [ex.: FastAPI, UIKit, LLVM ou NEEDS CLARIFICATION]

**Armazenamento**: [se aplicável, ex.: PostgreSQL, CoreData, arquivos ou N/A]

**Testes**: [ex.: pytest, XCTest, cargo test ou NEEDS CLARIFICATION]

**Plataforma Alvo**: [ex.: Linux server, iOS 15+, WASM ou NEEDS CLARIFICATION]

**Tipo de Projeto**: [ex.: library/cli/web-service/mobile-app/compiler/desktop-app ou NEEDS CLARIFICATION]

**Metas de Performance**: [específico do domínio, ex.: 1000 req/s, 10k linhas/seg, 60 fps ou NEEDS CLARIFICATION]

**Restrições**: [específico do domínio, ex.: <200ms p95, <100MB memória, funciona offline ou NEEDS CLARIFICATION]

**Escala/Escopo**: [específico do domínio, ex.: 10k usuários, 1M LOC, 50 telas ou NEEDS CLARIFICATION]

## Verificação da Constitution

*GATE: Deve passar antes da Fase 0 (pesquisa). Reverificar após o design da Fase 1.*

[Gates determinados com base no arquivo constitution]

## Estrutura do Projeto

### Documentação (desta feature)

```text
specs/[###-feature]/
├── plan.md              # Este arquivo (saída do comando /speckit-plan)
├── research.md          # Saída da Fase 0 (comando /speckit-plan)
├── data-model.md        # Saída da Fase 1 (comando /speckit-plan)
├── quickstart.md        # Saída da Fase 1 (comando /speckit-plan)
├── contracts/           # Saída da Fase 1 (comando /speckit-plan)
└── tasks.md             # Saída da Fase 2 (comando /speckit-tasks - NÃO criado pelo /speckit-plan)
```

### Código-fonte (raiz do repositório)
<!--
  AÇÃO NECESSÁRIA: Substitua a árvore de placeholder abaixo pelo layout
  concreto desta feature. Remova as opções não usadas e expanda a estrutura
  escolhida com caminhos reais (ex.: apps/admin, packages/algo). O plano
  entregue não deve incluir os rótulos de Opção.
-->

```text
# [REMOVER SE NÃO USADO] Opção 1: Projeto único (PADRÃO)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVER SE NÃO USADO] Opção 2: Aplicação web (quando "frontend" + "backend" detectados)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVER SE NÃO USADO] Opção 3: Mobile + API (quando "iOS/Android" detectado)
api/
└── [mesmo que backend acima]

ios/ ou android/
└── [estrutura específica da plataforma: módulos de feature, fluxos de UI, testes de plataforma]
```

**Decisão de Estrutura**: [Documente a estrutura escolhida e referencie os
diretórios reais capturados acima]

## Rastreamento de Complexidade

> **Preencher SOMENTE se a Verificação da Constitution tiver violações que precisam ser justificadas**

| Violação | Por que é Necessária | Alternativa Mais Simples Rejeitada Porque |
|-----------|------------|-------------------------------------|
| [ex.: 4º projeto] | [necessidade atual] | [por que 3 projetos são insuficientes] |
| [ex.: Padrão Repository] | [problema específico] | [por que acesso direto ao BD é insuficiente] |
