# Audit de Segurança — Análise do Código Legado

**Feature**: Cálculo Aritmético Básico
**Data do Audit**: 2026-09-23
**Analisado em**: Passo 0 (leitura integral dos arquivos da feature + expansão priorizada de `core/App.php`, `core/Router.php`, `core/TemplateEngine.php`, `core/Singleton.php`, `core/Logger.php`, `config/bootstrap.php`, `config/config.ini`, `dao/FileOperationHistoryDAO.php`, `dao/OperationHistoryDAOInterface.php`)

---

## Vulnerabilidades Identificadas

### 🟡 MEDIUM — Segurança Baixa

#### SEC-001: Sessão iniciada sem parâmetros de segurança explícitos no cookie
- **Localização**: `config/bootstrap.php:52-54`
- **Evidência (trecho exato do código)**:
  ```php
  if (session_status() !== PHP_SESSION_ACTIVE) {
      session_start();
  }
  ```
- **Risco**: `session_start()` é chamado sem configurar no código os atributos de cookie de sessão (`httponly`, `secure`, `samesite`), deixando a segurança do cookie dependente inteiramente de configuração externa (`php.ini`).
- **Impacto**: Impacto concreto é baixo nesta feature: a sessão guarda apenas os valores digitados no formulário (`form_num1`, `form_num2`, `form_operacao`) e o resultado/erro do último cálculo, usados exclusivamente para o padrão Post/Redirect/Get — não há credenciais, dados pessoais ou identificação de usuário na sessão.
- **Remediação sugerida**: Se a stack de destino mantiver algum mecanismo equivalente de preservação de estado entre requisições, garantir que não dependa de cookie de sessão sem `HttpOnly`/`Secure`/`SameSite` explícitos; alternativamente, resolver a preservação dos valores digitados inteiramente no lado do cliente, sem necessidade de estado de sessão no servidor.
- **Status de remediação**: ⏸️ Aguarda aprovação do analista

#### SEC-002: Arquivo de histórico sem controle de acesso no sistema de arquivos
- **Localização**: `dao/FileOperationHistoryDAO.php:18-34`
- **Evidência (trecho exato do código)**:
  ```php
  $handle = @fopen($this->caminhoArquivo, 'a');
  if ($handle) {
      @flock($handle, LOCK_EX);
      fwrite($handle, $linha);
      @flock($handle, LOCK_UN);
      fclose($handle);
  }
  ```
- **Risco**: O arquivo `data/historico.dat` é gravado e lido sem verificação de permissões de sistema de arquivos no código. Dependendo da configuração do servidor web, o arquivo pode ser acessível diretamente via HTTP se o diretório `data/` não estiver protegido por `.htaccess` ou configuração equivalente.
- **Impacto**: Exposição do histórico de cálculos (operandos, operação, resultado, data/hora) a qualquer usuário que conheça o caminho do arquivo.
- **Remediação sugerida**: Na stack de destino, persistir o histórico em mecanismo não acessível diretamente via HTTP (banco de dados, armazenamento fora do webroot). Não há schema legado a preservar — a decisão de persistência é livre.
- **Status de remediação**: ⏸️ Aguarda aprovação do analista

#### SEC-003: Supressão de erros com `@` oculta falhas de I/O silenciosamente
- **Localização**: `dao/FileOperationHistoryDAO.php:18`, `dao/FileOperationHistoryDAO.php:20`, `dao/FileOperationHistoryDAO.php:22`
- **Evidência (trecho exato do código)**:
  ```php
  $handle = @fopen($this->caminhoArquivo, 'a');
  ...
  @flock($handle, LOCK_EX);
  ...
  @flock($handle, LOCK_UN);
  ```
- **Risco**: O operador `@` suprime erros de I/O. Falhas de gravação no histórico (disco cheio, permissão negada) passam silenciosamente sem log nem alerta.
- **Impacto**: Perda silenciosa de registros de histórico sem qualquer rastreabilidade.
- **Remediação sugerida**: Na stack de destino, usar mecanismo de persistência com tratamento explícito de exceções e logging estruturado de falhas.
- **Status de remediação**: ⏸️ Aguarda aprovação do analista

---

## Resumo para Analista Funcional

| Severidade | Contagem | Deve remedir? |
|---|---|---|
| 🔴 CRITICAL | 0 | — |
| 🟠 HIGH | 0 | — |
| 🟡 MEDIUM | 3 | Sugerido |
| 🔍 INFERIDO | 0 | — |
| **Total** | **3** | — |

**Próximas ações:**
1. Analista revisa este documento
2. Aprova quais remediações serão implementadas
3. Evidence Validator valida as citações arquivo:linha
4. Developer implementa as remediações aprovadas
