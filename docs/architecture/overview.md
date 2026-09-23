# demo-moderniza — Visão Geral da Arquitetura

Sistema de "Calculadora Corporativa": uma aplicação web simples que permite ao usuário informar dois
números e uma operação aritmética (soma, subtração, multiplicação ou divisão), obter o resultado
formatado em padrão pt-BR, e consultar um histórico dos últimos cálculos realizados. O sistema legado
é um PHP artesanal sem framework, sem banco de dados relacional e sem autenticação; esta
modernização reimplementa o mesmo escopo funcional numa stack nova (Spring Boot 3.x / Java 21 +
Angular 20), ambos construídos do zero (`target_root` greenfield).

---

## Estrutura do Repositório

```
demo-moderniza/
├── backend/          ← API REST (Java 21 + Spring Boot 3.x) — a construir
├── frontend/         ← SPA (Angular 20 + TypeScript 5.8) — a construir
└── docs/             ← Documentação de arquitetura e regras de negócio
```

O código legado (fonte das regras de negócio, somente leitura) vive em um repositório à parte:
`C:\Users\rafael.pires\Documents\programas-teste-esteira\demo-moder`, estruturado como:

```
demo-moder/                  (legado — PHP sem framework)
├── index.php                ← front controller único
├── config/                  ← bootstrap.php (autoloader manual) + config.ini
├── core/                    ← App (kernel), Router, Logger, TemplateEngine, Singleton
├── controllers/             ← CalculadoraController (único controller do sistema)
├── operations/              ← Strategy de operações aritméticas (Soma/Subtração/Multiplicação/Divisão) + Factory
├── dao/                     ← Persistência do histórico em arquivo texto serializado
├── helpers/                 ← ValidationHelper, NumberHelper (formatação pt-BR)
├── views/                   ← Templates PHP (extract()+include, sem engine real)
├── data/                    ← historico.dat (arquivo de dados, substitui banco relacional)
└── logs/                    ← app.log
```

---

## Stack Atual

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| **Backend — Linguagem** | Java | 21 |
| **Backend — Framework** | Spring Boot | 3.x (Spring Framework 6.1+) |
| **Backend — Build** | Maven | — |
| **Frontend — Linguagem** | TypeScript | 5.8 |
| **Frontend — Framework** | Angular | 20 |
| **Frontend — UI/Estilos** | Angular Material | conforme skill `angular-20` (a confirmar com o time) |
| **Banco de dados** | Não há banco relacional no legado — histórico em arquivo texto serializado (`data/historico.dat`). A stack nova define a forma de persistência do histórico (não há schema legado a migrar). | — |
| **Migrations** | Nenhuma ferramenta de migration/gestão de schema — o legado nunca teve banco relacional ("Predecessora do MySQL que nunca chegou a ser instalado em produção", conforme comentário do próprio código). Se um banco relacional for introduzido na modernização, cabe ao time decidir a ferramenta (ex: Flyway). | — |
| **Mensageria** | Não utilizado | — |
| **Cache** | Não utilizado | — |
| **Autenticação** | Não utilizado — sistema legado é público, sem login/senha; `session_start()` existe apenas para o padrão PRG (Post/Redirect/Get) | — |

---

## Backend

### Responsabilidade

Expor uma API REST que recebe dois operandos e uma operação aritmética, valida os dados de entrada,
executa o cálculo (incluindo tratamento de divisão por zero e operação desconhecida como erros de
negócio), registra o resultado num histórico persistente, e disponibiliza a consulta dos últimos
registros desse histórico — reimplementando fielmente o comportamento do `CalculadoraController`,
`OperationFactory`/`*Operation` e `FileOperationHistoryDAO` do sistema legado, porém como serviço
HTTP stateless (sem depender de sessão/PRG, que no legado existia apenas para lidar com reenvio de
formulário em uma aplicação server-side rendered).

### Arquitetura Interna

Greenfield — estrutura proposta com base na skill `spring-21` e no domínio identificado no legado:

```
br.com.demomoderniza.calculadora/
├── controller/       ← CalculadoraController: recebe requests REST (POST /calculos, GET /calculos/historico), delega ao Service
├── service/          ← CalculadoraService: valida operandos, seleciona a operação (equivalente ao OperationFactory/Strategy do legado), executa o cálculo, registra no histórico
├── repository/       ← Acesso a dados do histórico (equivalente ao FileOperationHistoryDAO do legado, porém via persistência a definir pelo time)
├── entity/           ← Modelo de persistência do histórico de cálculos, se um banco relacional for adotado
├── dto/              ← Records: CalculoRequestDTO (num1, num2, operacao), CalculoResponseDTO (resultado), HistoricoDTO (dataHora, n1, n2, simbolo, resultado)
└── exception/        ← Exceções de negócio (operação inválida, divisão por zero) + handler global com ProblemDetail
```

### API REST

- **Base path:** `/api/v1` (a confirmar/ajustar com o time na primeira implementação)
- **Autenticação:** Não utilizado — endpoints públicos, sem token/sessão, espelhando o legado
- **Documentação:** springdoc-openapi ainda não configurado (projeto greenfield); se adotado, seguirá
  o padrão da skill `spring-21` (`/v3/api-docs`, `/swagger-ui/index.html`)

### Banco de dados

- Não há motor de banco de dados relacional no legado, e portanto não há schema a ser "mantido" ou
  migrado. O histórico de cálculos hoje é um arquivo texto (`data/historico.dat`) com registros
  serializados via `serialize()` do PHP, um por linha, sem controle de schema.
- Não há ferramenta de migration/gestão de schema — nenhuma evidência de Flyway, Liquibase ou
  scripts DDL versionados no legado (que nunca chegou a ter banco relacional instalado em produção,
  conforme o próprio comentário de código em `FileOperationHistoryDAO.php`).
- Política adotada nesta modernização: como não há schema legado a preservar, a forma de persistência
  do histórico (arquivo, banco embarcado, banco relacional com migrations versionadas, etc.) é uma
  decisão nova do time de implementação, não uma restrição herdada — deve ser registrada explicitamente
  na primeira task que tratar de persistência.

### Infraestrutura local

Greenfield — nenhum `docker-compose.yml` existe ainda em `target_root`, e o legado não usa nenhum
serviço de infraestrutura local (sem banco, sem cache, sem mensageria — roda como aplicação PHP
pura servida por um servidor web comum). Nenhuma porta de serviço a mapear até o momento; a definir
conforme a decisão de persistência do histórico.

---

## Frontend

### Responsabilidade

Apresentar o formulário de cálculo (dois campos numéricos + seleção de operação), exibir o
resultado formatado em pt-BR ou a mensagem de erro correspondente, e listar os últimos cálculos
realizados — reimplementando a única tela do sistema legado (`views/calculadora.tpl.php`), porém
como SPA que consome a API REST do backend em vez de depender de reload de página via padrão PRG.

### Comunicação com Backend & Estado

- **Gerenciamento de Estado:** Signals (`signal()`/`computed()`) — estado local do formulário,
  resultado, erro e lista de histórico; sem necessidade de NgRx dado o escopo funcional simples
- **Integração / HTTP:** `HttpClient` + `Observable`, tipado, chamando os endpoints REST do backend
  para calcular e para listar o histórico

### Módulos

| Módulo | Caminho | Função |
|--------|---------|--------|
| `calculadora` | `/` (rota raiz) | Formulário de cálculo (num1, num2, operação), exibição de resultado/erro e listagem do histórico dos últimos cálculos — equivalente único à tela `calculadora.tpl.php` do legado |

---

## Segurança

O sistema legado não implementa autenticação nem autorização: a aplicação é pública, qualquer
usuário pode acessar o formulário e realizar cálculos sem login. O único uso de sessão HTTP
(`session_start()` em `config/bootstrap.php`) é para viabilizar o padrão PRG (Post/Redirect/Get),
guardando temporariamente os valores do formulário e o resultado/erro entre o POST e o GET
seguinte — não há relação com controle de acesso.

A modernização deve manter o sistema sem autenticação/autorização, já que não há mecanismo de
identidade a preservar do legado. Caso o negócio decida introduzir autenticação nesta modernização,
isso deve ser tratado como uma decisão nova, documentada explicitamente em task, e não como algo
herdado do sistema legado.

---

## Fluxo de Dados (visão geral)

```
[Usuário] → [Angular SPA: formulário de cálculo]
          → HTTP POST /api/v1/calculos { num1, num2, operacao }
          → [Spring Boot: CalculadoraController]
          → [CalculadoraService: valida operandos, seleciona operação, calcula]
          → [Repository: registra o cálculo no histórico]
          → HTTP 200 { resultado } ou erro de negócio via ProblemDetail (ex: divisão por zero)
          → [Angular SPA] atualiza signal de resultado/erro e re-renderiza

[Angular SPA] → HTTP GET /api/v1/calculos/historico
              → [Spring Boot: CalculadoraController] → [Repository: lista últimos registros]
              → HTTP 200 [ { dataHora, n1, n2, simbolo, resultado }, ... ]
              → [Angular SPA] popula tabela de histórico
```
