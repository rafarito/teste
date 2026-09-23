# Implementation Context

Modernização da "Calculadora Corporativa" — um sistema legado em PHP procedural/OO artesanal (sem
framework, sem banco de dados relacional) que expõe um formulário web único para realizar operações
aritméticas básicas (soma, subtração, multiplicação, divisão) e manter um histórico dos últimos
cálculos realizados. O objetivo desta modernização é reimplementar as mesmas regras de negócio
(validação de operandos, cálculo, tratamento de divisão por zero, formatação pt-BR e histórico dos
últimos cálculos) numa stack nova: backend Spring Boot 3.x / Java 21 e frontend Angular 20, ambos
greenfield (`target_root` ainda vazio, sem boilerplate prévio).

---

# Stack Técnico

## Backend

| Item | Valor |
|------|-------|
| Linguagem | Java 21 |
| Framework | Spring Boot 3.x (Spring Framework 6.1+) |
| Build | Maven |
| Package base | `br.com.demomoderniza.calculadora` |
| Banco | Não há banco de dados relacional no legado — o legado persiste o histórico em arquivo texto (`data/historico.dat`) com registros serializados via `serialize()`/`unserialize()` do PHP, um por linha. Não há motor de banco de dados (Oracle/SQL Server/PostgreSQL/MySQL) a identificar porque nunca existiu — ver nota do sistema legado em `dao/FileOperationHistoryDAO.php`: "Predecessora do MySQL que nunca chegou a ser instalado no servidor de produção". A stack nova deve decidir com o time (fora do escopo desta análise) se mantém um armazenamento simples (arquivo/H2 embarcado) ou introduz um banco relacional de fato — não há schema legado a preservar. |
| Migrations | Não há ferramenta de migration/gestão de schema no legado (não existe banco relacional, logo não existe schema versionado). Se a stack nova introduzir um banco relacional para o histórico, cabe ao time decidir a ferramenta (ex: Flyway, conforme a skill `spring-21`) — isso não é uma restrição herdada do legado, é uma decisão nova. |
| Auditoria | Não utilizado — o legado não implementa Hibernate Envers nem tabelas de auditoria; apenas grava um log de aplicação (`logs/app.log`) com timestamp, nível e mensagem por linha. |
| Mensageria | Não utilizado |
| Cache | Não utilizado |
| Auth | Não há autenticação no legado. O sistema é público, sem login/senha/controle de acesso; `session_start()` em `config/bootstrap.php` é usado apenas para viabilizar o padrão PRG (Post/Redirect/Get) — guardar temporariamente `form_num1`, `form_num2`, `form_operacao`, `resultado` e `erro` na sessão entre o POST e o GET seguinte, evitando reenvio de formulário ao atualizar a página (F5). Não há integração com Keycloak/JWT/OAuth nem qualquer mecanismo de identidade. A modernização deve manter o sistema sem autenticação, salvo decisão explícita em contrário documentada em task. |
| Config principal | `src/main/resources/application.yml` (a criar) |
| Config local | `src/main/resources/application-local.yml` (a criar) |
| Diretório | `backend/` (a criar dentro de `target_root`, ainda vazio) |

### Estrutura de pacotes

Greenfield — nenhuma estrutura existe ainda em `target_root`. Estrutura proposta com base na
arquitetura em camadas obrigatória da skill `spring-21` (Controller → Service → Repository → Entity)
e espelhando os domínios já identificados no legado (operações aritméticas, histórico de cálculos):

```
br.com.demomoderniza.calculadora/
├── controller/         ← Endpoints REST (ex: CalculadoraController) — recebe request, delega ao Service
├── service/            ← Regras de negócio: validação de operandos, execução da operação, orquestração do histórico
├── repository/         ← Acesso a dados do histórico de cálculos (Spring Data JPA ou equivalente, a definir)
├── entity/             ← Mapeamento ORM do histórico de cálculos (se um banco relacional for adotado)
├── dto/                ← Records de entrada/saída da API (ex: CalculoRequestDTO, CalculoResponseDTO, HistoricoDTO)
├── mapper/             ← Interfaces MapStruct para conversão Entity <-> DTO
└── exception/          ← Exceções de negócio (ex: BusinessException para divisão por zero, operação inválida) e handler global (ProblemDetail)
```

### Comandos de build

```bash
# Compilar
mvn clean install

# Subir (profile local)
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Log esperado de startup: `Started CalculadoraApplication in`

---

## Frontend

| Item | Valor |
|------|-------|
| Framework | Angular 20 |
| Linguagem | TypeScript 5.8 |
| Build | Angular CLI 20.x |
| UI / Estilização | Angular Material (padrão da skill `angular-20`; a confirmar/ajustar com o time caso o projeto opte por outra biblioteca) |
| Estado Global | Signals (`signal()`/`computed()`) — não há necessidade de NgRx/Redux para o escopo funcional identificado (formulário simples + listagem de histórico) |
| API / Integração | `HttpClient` + `Observable`, tipado (`http.get<Tipo>(...)`) |
| Testes | A definir pelo time no `package.json` (Karma/Jasmine é o padrão do Angular CLI nesta versão; Jest é alternativa comum) — projeto greenfield, ainda sem `package.json` |
| Auth | Não utilizado — o legado não possui autenticação (ver seção Backend > Auth); a modernização deve manter o frontend público, sem tela de login, salvo decisão explícita em contrário |
| Diretório | `frontend/` (a criar dentro de `target_root`, ainda vazio) |

### Estrutura de módulos

Greenfield — nenhuma estrutura existe ainda em `target_root`. Estrutura proposta com base no padrão
standalone da skill `angular-20`, espelhando a única tela funcional do legado (formulário de
cálculo + histórico):

```
src/app/
├── app.config.ts                    ← providers globais (bootstrapApplication, HttpClient, rotas)
├── app.routes.ts                     ← rota raiz, lazy loading da feature de calculadora
├── shared/
│   └── shared-imports.ts             ← array de imports comuns (Angular Material, pipes) para spread nos componentes
└── features/
    └── calculadora/
        ├── calculadora.routes.ts      ← rota única da feature (equivalente à tela única do legado)
        ├── calculadora/
        │   ├── calculadora.component.ts    ← formulário (num1, num2, operação) + exibição de resultado/erro
        │   ├── calculadora.component.html
        │   └── calculadora.component.scss
        └── services/
            └── calculadora.service.ts       ← chamadas HTTP para calcular e listar histórico
```

### Comandos de build

```bash
# Instalar dependências
npm install

# Compilar
npx ng build

# Subir (profile local)
npm start
```

Log esperado de startup: `Application bundle generation complete` / `Local: http://localhost:4200/`

---

Toda implementação deve seguir:

* workflows definidos em `/workflows`
* padrões arquiteturais definidos em `/docs/architecture`
* regras de negócio definidas em `/docs/business`
* especializações dos agentes definidas em `/agents`

---

# Projeto

| Item | Valor |
|------|-------|
| Backend | Spring Boot 3.x / Java 21, arquitetura em camadas (Controller → Service → Repository → Entity), DTOs como `record`, MapStruct para conversão, `ProblemDetail` para erros — a construir do zero em `target_root` |
| Package base | `br.com.demomoderniza.calculadora` |
| Banco | Não há banco relacional no legado (histórico em arquivo `data/historico.dat` serializado); a stack nova deve decidir a forma de persistência do histórico junto ao time, sem schema legado a preservar |
| Frontend | Angular 20 / TypeScript 5.8, standalone components, Signals para estado, Reactive Forms tipados — a construir do zero em `target_root` |
| Auth | Não utilizado — legado não possui autenticação; sistema é público |

---

# Regra — Boilerplate do Projeto

Todo código novo deve seguir o padrão já estabelecido no projeto.

Antes de implementar qualquer coisa, o agente deve:
* localizar exemplos equivalentes já existentes no código
* replicar a mesma estrutura de classes, anotações e convenções
* não inventar padrões novos que não existam no projeto

Como `target_root` é greenfield (sem boilerplate ainda), os primeiros componentes implementados
devem seguir estritamente os padrões descritos nas skills `spring-21` (backend) e `angular-20`
(frontend) — a partir da segunda task em diante, o boilerplate já criado passa a ser a referência
prioritária, e as skills passam a valer apenas para o que o projeto ainda não decidiu.

---

# Regra — Compatibilidade com o Frontend

Os contratos expostos ao frontend são **imutáveis**. Nenhuma implementação pode alterá-los sem
necessidade explícita documentada na task.

Isso inclui:
* DTOs de request e response existentes
* Nomes de campos e tipos de dados em payloads JSON
* Endpoints e verbos HTTP já existentes

---

# Regra — Base de Dados

O legado não possui banco de dados relacional — o "histórico de cálculos" é persistido em um
arquivo texto (`data/historico.dat`) com registros serializados via `serialize()`/`unserialize()`
do PHP, sem schema formal a preservar. Diferente de um cenário de migração de banco existente,
aqui não há schema legado imutável a mapear.

Isso significa que:
* Não há restrição de "schema fixo do legado" a respeitar — a stack nova é livre para definir a
  forma de persistência do histórico (ex: tabela relacional simples, se o time optar por introduzir
  um banco de dados)
* Se um banco relacional for introduzido, toda alteração de schema a partir da primeira migration
  deve ser versionada (ex: Flyway, conforme a skill `spring-21`) — mas isso é uma decisão nova do
  projeto, não uma obrigação herdada do legado
* Entidades ORM (se houver) devem refletir o modelo de dados definido pelo time para esta
  modernização — não existe um schema legado a que precisem se conformar

---

# Princípios da Implementação

A implementação deve ser:

* incremental — uma task por domínio funcional
* orientada pelo boilerplate existente
* segura — sem quebrar contratos ou schemas existentes
* observável — com logs estruturados

Nunca implementar toda uma funcionalidade de uma única vez sem divisão em tasks.

---

# Modernização

| Item | Valor |
|------|-------|
| Fonte legada (source_root) | `C:\Users\rafael.pires\Documents\programas-teste-esteira\demo-moder` |
| Stack do legado | PHP procedural/OO customizado (sem framework) — MVC artesanal com front controller único (`index.php`), autoloader manual, "motor de template" próprio baseado em `extract()` + `include`, persistência do histórico em arquivo texto serializado (sem banco de dados relacional) |
| target_root tem boilerplate | não |
| Stack alvo (backend / frontend) | `spring-21` / `angular-20` |
| Banco de dados | Não há banco de dados relacional no legado — histórico persistido em arquivo (`data/historico.dat`, registros `serialize()`/`unserialize()` do PHP). Não há motor de banco a "manter": a stack nova define a persistência do histórico junto ao time. |
| Autenticação | Não há autenticação no legado — sistema público, sem login. `session_start()` existe apenas para o padrão PRG (Post/Redirect/Get), não para controle de acesso. A modernização deve manter o sistema sem autenticação, salvo decisão explícita em contrário. |

### Conexão com banco de dados

| Host | Porta | Banco/Schema | Driver/Motor | Variáveis de ambiente de credencial |
|------|-------|--------------|--------------|--------------------------------------|
| Não aplicável | Não aplicável | Não aplicável | Não há motor de banco de dados no legado — persistência via arquivo texto (`data/historico.dat`), sem driver JDBC/ODBC, sem connection string | Não aplicável — não há credenciais de banco no legado |

Essa seção existe para que o Analyst saiba, sem reler `.solutis.yaml`, que regras de negócio vêm
do legado e padrões de código vêm do target_root (ou das skills da stack escolhida, se ainda não
houver boilerplate).
