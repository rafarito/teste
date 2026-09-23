# Plano de Implementação: Histórico de Cálculos

**Branch**: `002-historico-de-calculos` | **Data**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Entrada**: Especificação da feature em `specs/002-historico-de-calculos/spec.md`

## Resumo

A feature registra de forma persistente cada cálculo aritmético concluído com sucesso (data/hora, operandos, operação, resultado) e expõe ao usuário a lista dos cálculos mais recentes, ordenada do mais novo para o mais antigo, limitada a uma quantidade máxima configurável (padrão: 5). Como o `target_root` é greenfield e o legado não possui banco de dados relacional (histórico persistido em arquivo texto serializado), esta modernização introduz uma persistência relacional simples para o histórico, com schema definido do zero (sem schema legado a preservar), seguindo os padrões obrigatórios da stack `spring-21` (camadas, DTOs `record`, MapStruct, migrations versionadas) no backend e `angular-20` (standalone components, Signals, Reactive Forms tipados) no frontend.

## Contexto Técnico

**Linguagem/Versão**: Java 21 (backend) / TypeScript 5.8 (frontend)

**Dependências Principais**: Spring Boot 3.x, Spring Data JPA, Flyway, MapStruct, Lombok (backend); Angular 20, Angular Material, RxJS (frontend)

**Armazenamento**: Banco relacional embarcado/simples a ser definido pelo time de infraestrutura do projeto (ex.: H2 ou PostgreSQL) — decisão nova desta modernização, já que o legado não usa banco relacional. Uma tabela única armazena os registros de histórico de cálculo.

**Testes**: JUnit (backend, conforme `.solutis.yaml`), Jest (frontend, conforme `.solutis.yaml`)

**Plataforma Alvo**: Aplicação web (backend REST + frontend SPA)

**Tipo de Projeto**: Aplicação web (backend + frontend)

**Metas de Performance**: Não especificadas na spec — sem evidência de metas de performance no legado; não inventadas aqui.

**Restrições**: A gravação do histórico é um efeito colateral do cálculo bem-sucedido e não pode impedir a resposta do cálculo ao usuário mesmo se falhar (FR-008) — implica que a chamada de persistência do histórico não deve propagar exceção que interrompa a resposta do endpoint de cálculo.

**Escala/Escopo**: Uma única tela funcional (formulário de cálculo + histórico); volume de uso não especificado no legado.

## Verificação da Constitution

- **Boilerplate-First**: `target_root` é greenfield; não há boilerplate a seguir ainda. Os padrões adotados seguem estritamente as skills `spring-21` e `angular-20`, conforme instruído em `system-context.md`. ✅ Conforme.
- **Implementação Incremental**: as tasks (`tasks.md`) são organizadas por user story (US1 - registro; US2 - exibição), permitindo entrega incremental. ✅ Conforme.
- **Contratos Imutáveis**: não há contrato pré-existente nesta feature (greenfield); os contratos definidos em `contracts/` nascem desta modernização e passam a ser a referência imutável daqui em diante. ✅ Conforme (não há violação, pois não existe contrato anterior a quebrar).
- **Banco via Migration (NÃO NEGOCIÁVEL)**: a tabela de histórico será criada via migration Flyway versionada (`V1__criar_historico_calculo.sql`), com a entidade JPA mapeando o schema definido pela migration. ✅ Conforme.

Nenhuma violação identificada. Não é necessária a seção de Rastreamento de Complexidade.

## Estrutura do Projeto

### Documentação (desta feature)

```text
specs/002-historico-de-calculos/
├── plan.md              # Este arquivo
├── research.md          # Decisões técnicas desta feature
├── data-model.md        # Entidades da nova solução
├── quickstart.md        # Guia de validação manual/local
├── contracts/           # Contrato da API REST desta feature
└── tasks.md             # Tarefas de implementação
```

### Código-fonte (target_root)

```text
backend/
├── src/main/java/br/com/demomoderniza/calculadora/
│   ├── controller/
│   │   └── CalculoController.java
│   ├── service/
│   │   ├── CalculoService.java
│   │   └── HistoricoCalculoService.java
│   ├── repository/
│   │   └── HistoricoCalculoRepository.java
│   ├── entity/
│   │   └── HistoricoCalculo.java
│   ├── dto/
│   │   ├── CalculoRequestDTO.java
│   │   ├── CalculoResponseDTO.java
│   │   └── HistoricoCalculoDTO.java
│   ├── mapper/
│   │   └── HistoricoCalculoMapper.java
│   └── exception/
│       ├── OperacaoInvalidaException.java
│       ├── DivisaoPorZeroException.java
│       └── BaseExceptionHandler.java
└── src/main/resources/
    └── db/migration/
        └── V1__criar_historico_calculo.sql

frontend/
└── src/app/features/calculadora/
    ├── calculadora.routes.ts
    ├── calculadora/
    │   ├── calculadora.component.ts
    │   ├── calculadora.component.html
    │   └── calculadora.component.scss
    └── services/
        └── calculadora.service.ts
```

**Decisão de Estrutura**: aplicação web com `backend/` (Spring Boot, camadas Controller → Service → Repository → Entity) e `frontend/` (Angular standalone, feature `calculadora` com componente único de formulário + histórico), ambos ainda a criar dentro do `target_root`, seguindo a estrutura de pacotes já proposta em `system-context.md`.

## Rastreamento de Complexidade

Não aplicável — nenhuma violação da constitution foi identificada nesta feature.
