# Pesquisa Técnica: Histórico de Cálculos

**Feature**: 002-historico-de-calculos
**Data**: 2026-09-23

Este documento registra as decisões técnicas tomadas para implementar a feature na stack de destino (`spring-21` / `angular-20`), com base nas skills injetadas no contexto e no `system-context.md`. Nenhuma decisão aqui deriva de tecnologia do legado — o legado (arquivo texto serializado) serve apenas como evidência do comportamento de negócio já documentado no `spec.md`.

## Decisão 1: Persistência do histórico

**Decisão**: Introduzir uma tabela relacional (`historico_calculo`) via migration Flyway, mapeada por uma entidade JPA, para armazenar cada registro de cálculo bem-sucedido.

**Justificativa**: O legado não possui banco de dados relacional (persistência em arquivo texto serializado); a stack de destino (`spring-21`) exige, pela skill obrigatória, "Banco via Migration (NÃO NEGOCIÁVEL)" — toda alteração de schema exige migration versionada. Como não há schema legado a preservar (`system-context.md`, seção Base de Dados), a modernização é livre para definir o modelo relacional do zero.

**Alternativas consideradas**:
- Manter persistência em arquivo (equivalente ao legado): rejeitada, pois contraria o princípio "Banco via Migration" da constitution do projeto e não se alinha à arquitetura em camadas (Repository → Entity) exigida pela skill `spring-21`.
- Cache em memória sem persistência: rejeitada, pois a spec (FR-001, FR-009) exige persistência e retenção de todos os cálculos bem-sucedidos, não apenas os exibidos.

## Decisão 2: Limite de exibição configurável

**Decisão**: O valor máximo de registros exibidos (padrão 5) é uma propriedade de configuração da aplicação (`application.yml`), lida pelo Service ao montar a resposta do histórico — não um parâmetro exposto na API pública nem escolhido pelo usuário na tela, refletindo o comportamento comprovado no legado, onde esse limite é definido em arquivo de configuração da aplicação e lido a cada requisição para montar a lista exibida.

**Justificativa**: FR-004 exige um valor máximo configurável com padrão 5; a Premissa comprovada do `spec.md` confirma que esse valor é definido por configuração do sistema, não pelo usuário — comportamento já observado no legado, onde esse limite é definido em arquivo de configuração da aplicação, e não escolhido pelo usuário na tela.

**Alternativas consideradas**:
- Parâmetro de query string na API (`?limite=N`): rejeitada por falta de evidência no legado de que o usuário pudesse escolher a quantidade exibida.
- Valor fixo no código sem possibilidade de configuração: rejeitada, pois contraria FR-004 ("quantidade máxima configurável").

## Decisão 3: Independência entre cálculo e gravação do histórico

**Decisão**: A gravação do registro de histórico é encapsulada em um Service dedicado (`HistoricoCalculoService`), chamado pelo Service de cálculo (`CalculoService`) após a operação aritmética ser concluída com sucesso. Uma falha na gravação é tratada (capturada e logada) sem propagar exceção que impeça a resposta do cálculo ao cliente.

**Justificativa**: FR-008 exige que uma falha na gravação do histórico não impeça a exibição do resultado do cálculo ao usuário — comportamento comprovado no legado, onde a gravação do registro de histórico ocorre após o cálculo, sem que uma falha de gravação (armazenamento indisponível) interrompa o fluxo de resposta.

**Alternativas consideradas**:
- Gravação síncrona sem tratamento de exceção, deixando propagar erro de persistência: rejeitada, pois violaria diretamente FR-008.
- Gravação assíncrona (fila/evento): não há evidência no legado de mensageria ou processamento assíncrono; rejeitada por ausência de evidência (ver `system-context.md`, Mensageria: Não utilizado).

## Decisão 4: Formatação numérica pt-BR

**Decisão**: A formatação do resultado no padrão numérico brasileiro (vírgula decimal) é responsabilidade da camada de apresentação (frontend), usando pipes/formatação nativa do Angular, mantendo o valor numérico puro no contrato da API (JSON não deve carregar strings pré-formatadas com vírgula, para preservar interoperabilidade).

**Justificativa**: FR-005 exige exibição no padrão pt-BR; no legado essa formatação ocorre na camada de visualização, não na camada de persistência ou de cálculo — a separação de responsabilidades da stack de destino (DTO como contrato, sem lógica de apresentação) leva a manter esse comportamento equivalente na camada de frontend.

**Alternativas consideradas**:
- Formatar a string com vírgula já no backend e devolver como texto: rejeitada, pois acopla apresentação regional ao contrato da API, dificultando reuso por outros clientes e contrariando a convenção de DTOs como contrato de dados puro (skill `spring-21`, seção 2).

## Decisão 5: Endpoint(s) da API

**Decisão**: Um único endpoint REST (`POST /calculos`) recebe os operandos e a operação, executa o cálculo, registra o histórico em caso de sucesso e retorna o resultado; um segundo endpoint (`GET /calculos/historico`) retorna a lista dos cálculos mais recentes conforme o limite configurado. Ambos substituem o fluxo único de tela do legado (que combinava POST + redirecionamento + GET via padrão PRG) por uma API REST stateless, sem uso de sessão — consistente com `system-context.md` ("Auth: Não há autenticação... sistema deve manter-se sem autenticação") e com o fato de o padrão PRG do legado existir apenas para evitar reenvio de formulário (F5), uma preocupação de camada de apresentação que o frontend Angular resolve de outra forma (SPA sem reload de página).

**Justificativa**: a arquitetura REST desacopla o cálculo da exibição, permitindo que o frontend Angular consuma cada operação de forma independente e idiomática, sem necessidade de replicar o padrão PRG do legado (mecanismo específico de aplicações com reload de página completo).

**Alternativas consideradas**:
- Um único endpoint que sempre retorna cálculo + histórico atualizado juntos: considerada, mas rejeitada em favor de dois endpoints separados, pois a spec descreve dois comportamentos distintos e independentemente testáveis (US1 - registrar; US2 - exibir), e a skill `angular-20` recomenda services com métodos de responsabilidade única.
