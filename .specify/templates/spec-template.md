# Especificação de Feature: [FEATURE NAME]

**Branch da feature**: `[###-feature-name]`

**Criado em**: [DATE]

**Status**: Rascunho

**Data**: [DATE]

---

## 📋 Artefatos Relacionados

**Audit de Segurança**: [security-audit.md](./security-audit.md)  
Vulnerabilidades encontradas no código legado e remediações sugeridas (para análise do ANALISTA).

**Análise Técnica**: [functional-spec.md](./functional-spec.md)  
Análise cross-artifact: cobertura, inconsistências, gaps de segurança e status de aprovação.

**Dúvidas e Decisões**: [clarifications.md](./clarifications.md)  
Dúvidas sem evidência conclusiva no legado, opções consideradas e a decisão adotada em cada uma. Existe apenas quando restou dúvida material — ausente, a spec saiu inteiramente comprovada no código.

---

## Cenários de Usuário e Testes *(obrigatório)*

<!--
  IMPORTANTE: As user stories devem ser PRIORIZADAS como jornadas de usuário ordenadas por importância.
  Cada user story/jornada deve ser TESTÁVEL DE FORMA INDEPENDENTE — ou seja, se você implementar
  apenas UMA delas, ainda assim deve haver um MVP (Minimum Viable Product) viável que entregue valor.

  Atribua prioridades (P1, P2, P3, etc.) a cada story, sendo P1 a mais crítica.
  Pense em cada story como uma fatia autônoma de funcionalidade que pode ser:
  - Desenvolvida independentemente
  - Testada independentemente
  - Publicada (deploy) independentemente
  - Demonstrada a usuários independentemente
-->

### User Story 1 - [Título breve] (Prioridade: P1)

[Descreva esta jornada de usuário em linguagem simples]

**Por que esta prioridade**: [Explique o valor e por que tem este nível de prioridade]

**Teste Independente**: [Descreva como isso pode ser testado de forma independente — ex.: "Pode ser totalmente testado ao [ação específica] e entrega [valor específico]"]

**Cenários de Aceite**:

1. **Dado** [estado inicial], **Quando** [ação], **Então** [resultado esperado]
2. **Dado** [estado inicial], **Quando** [ação], **Então** [resultado esperado]

---

### User Story 2 - [Título breve] (Prioridade: P2)

[Descreva esta jornada de usuário em linguagem simples]

**Por que esta prioridade**: [Explique o valor e por que tem este nível de prioridade]

**Teste Independente**: [Descreva como isso pode ser testado de forma independente]

**Cenários de Aceite**:

1. **Dado** [estado inicial], **Quando** [ação], **Então** [resultado esperado]

---

### User Story 3 - [Título breve] (Prioridade: P3)

[Descreva esta jornada de usuário em linguagem simples]

**Por que esta prioridade**: [Explique o valor e por que tem este nível de prioridade]

**Teste Independente**: [Descreva como isso pode ser testado de forma independente]

**Cenários de Aceite**:

1. **Dado** [estado inicial], **Quando** [ação], **Então** [resultado esperado]

---

[Adicione mais user stories conforme necessário, cada uma com uma prioridade atribuída]

### Casos de Borda

<!--
  AÇÃO NECESSÁRIA: O conteúdo desta seção representa placeholders.
  Preencha com os casos de borda corretos.
-->

- O que acontece quando [condição limite]?
- Como o sistema trata [cenário de erro]?

## Requisitos *(obrigatório)*

<!--
  AÇÃO NECESSÁRIA: O conteúdo desta seção representa placeholders.
  Preencha com os requisitos funcionais corretos.
-->

### Requisitos Funcionais

- **FR-001**: O sistema DEVE [capacidade específica, ex.: "permitir que usuários criem contas"]
- **FR-002**: O sistema DEVE [capacidade específica, ex.: "validar endereços de e-mail"]
- **FR-003**: Os usuários DEVEM conseguir [interação-chave, ex.: "redefinir sua senha"]
- **FR-004**: O sistema DEVE [requisito de dado, ex.: "persistir preferências do usuário"]
- **FR-005**: O sistema DEVE [comportamento, ex.: "registrar todos os eventos de segurança"]

*Exemplo de como marcar requisitos não esclarecidos:*

- **FR-006**: O sistema DEVE autenticar usuários via [NEEDS CLARIFICATION: método de autenticação não especificado - e-mail/senha, SSO, OAuth?]
- **FR-007**: O sistema DEVE reter dados do usuário por [NEEDS CLARIFICATION: período de retenção não especificado]

### Entidades Principais *(incluir se a feature envolver dados)*

- **[Entidade 1]**: [O que representa, atributos-chave sem detalhes de implementação]
- **[Entidade 2]**: [O que representa, relacionamentos com outras entidades]

## Critérios de Sucesso *(obrigatório)*

<!--
  AÇÃO NECESSÁRIA: Defina critérios de sucesso mensuráveis.
  Devem ser tecnologicamente agnósticos e mensuráveis.
-->

### Resultados Mensuráveis

- **SC-001**: [Métrica mensurável, ex.: "Usuários conseguem concluir a criação de conta em menos de 2 minutos"]
- **SC-002**: [Métrica mensurável, ex.: "Sistema suporta 1000 usuários simultâneos sem degradação"]
- **SC-003**: [Métrica de satisfação do usuário, ex.: "90% dos usuários concluem a tarefa principal com sucesso na primeira tentativa"]
- **SC-004**: [Métrica de negócio, ex.: "Reduzir chamados de suporte relacionados a [X] em 50%"]

## Premissas

<!--
  AÇÃO NECESSÁRIA: O conteúdo desta seção representa placeholders.
  Preencha com as premissas corretas, baseadas em padrões razoáveis
  escolhidos quando a descrição da feature não especificou determinados detalhes.
-->

- [Premissa sobre usuários-alvo, ex.: "Usuários têm conectividade de internet estável"]
- [Premissa sobre limites de escopo, ex.: "Suporte mobile está fora de escopo para v1"]
- [Premissa sobre dados/ambiente, ex.: "O sistema de autenticação existente será reutilizado"]
- [Dependência de sistema/serviço existente, ex.: "Requer acesso à API de perfil de usuário já existente"]
