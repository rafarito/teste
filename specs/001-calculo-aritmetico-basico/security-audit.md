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

