# Features Descobertas

**Fonte de origem:** `C:\Users\rafael.pires\Documents\programas-teste-esteira\demo-moder` (código-fonte)  
**Data da análise:** `2026-09-23`  
**Total de features identificadas:** `2`

> Observação: aplicação PHP monolítica ("Calculadora Corporativa"), com uma única rota registrada (`calculadora`) atendida por `CalculadoraController` e renderizada via templates PHP em `views/`. Não há frontend separado. A pasta `novo/` está vazia. Logging (`core/Logger.php`), roteamento, template engine e bootstrap são infraestrutura e não foram catalogados como features.

---

## Cálculos

### 1. Cálculo Aritmético Básico

**Descrição:** Permite ao usuário informar dois números, escolher uma operação (soma, subtração, multiplicação ou divisão) e obter o resultado formatado no padrão brasileiro. O sistema rejeita campos vazios, valores não numéricos e divisão por zero, exibindo uma mensagem de erro. Os valores digitados permanecem no formulário após o envio.

**Prioridade:** Alta

**Classificação:** Core

**Features Relacionadas:** Histórico de Cálculos

**Componentes Relacionados:** operations (estratégias de operação e fábrica com whitelist), helpers (validação e formatação numérica pt-BR)

**Origem da Descoberta:** Rota `calculadora` (`index.php`) → `CalculadoraController::tratarRequisicao` (fluxo POST/Redirect/GET) e tela `views/calculadora.tpl.php`

**Arquivos relacionados:** `index.php`, `controllers/CalculadoraController.php`, `operations/OperationFactory.php`, `operations/OperationInterface.php`, `operations/AbstractOperation.php`, `operations/SomaOperation.php`, `operations/SubtracaoOperation.php`, `operations/MultiplicacaoOperation.php`, `operations/DivisaoOperation.php`, `helpers/ValidationHelper.php`, `helpers/NumberHelper.php`, `views/calculadora.tpl.php`, `views/layout.tpl.php`

**Spec gerada:** `Não`

---

## Histórico

### 2. Histórico de Cálculos

**Descrição:** Registra de forma persistente cada cálculo bem-sucedido, com data/hora, expressão e resultado. Exibe ao usuário a lista dos cálculos mais recentes, do mais novo para o mais antigo, com quantidade máxima configurável (padrão: 5).

**Prioridade:** Média

**Classificação:** Edge

**Features Relacionadas:** Cálculo Aritmético Básico

**Dependências:** Cálculo Aritmético Básico

**Componentes Relacionados:** dao (persistência do histórico em arquivo `data/historico.dat`)

**Origem da Descoberta:** `FileOperationHistoryDAO` (métodos `registrar` / `listarUltimos`), seção "Ultimos calculos" em `views/calculadora.tpl.php` e chave `[historico] max_registros_exibidos` em `config/config.ini`

**Arquivos relacionados:** `dao/OperationHistoryDAOInterface.php`, `dao/FileOperationHistoryDAO.php`, `controllers/CalculadoraController.php`, `views/calculadora.tpl.php`, `config/config.ini`

**Spec gerada:** `Sim` (`specs/002-historico-de-calculos/spec.md`)

---
