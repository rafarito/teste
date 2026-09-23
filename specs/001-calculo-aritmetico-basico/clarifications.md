# Dúvidas e Decisões — Cálculo Aritmético Básico

**Spec:** [spec.md](./spec.md)
**Origem:** `/discovery spec` (modo modernização) — clarify assíncrono, sem interação humana
**Status:** decisões adotadas pelo agente, pendentes de validação humana

> A engenharia reversa do legado deixou o ponto abaixo sem evidência conclusiva. Foi
> **decidido** pelo agente para não bloquear o lote, e o `spec.md` já reflete a decisão adotada.
> Alterar a decisão aqui exige atualizar o `spec.md` e, se já existirem, `plan.md` e `tasks.md`.

## Resumo

| # | Dúvida | Impacto | Decisão adotada | Confiança |
|---|--------|---------|-----------------|----------|
| Q1 | Limite de registros do histórico é fixo ou configurável? | Baixo | Configurável via propriedade de ambiente | Média |

---

## Q1 — Limite de registros exibidos no histórico: fixo ou configurável?

**Categoria:** Campo/validação

**O que não ficou claro:** O legado usa o valor `5` como quantidade máxima de registros exibidos no histórico, lido de um arquivo de configuração. Não está claro se, na stack de destino, esse valor deve ser fixo em código ou configurável via propriedade de ambiente/configuração da aplicação.

**Evidência encontrada:** O valor `5` está definido em arquivo de configuração do legado (seção `[historico]`, chave `max_registros_exibidos`), lido em tempo de execução pelo controlador. Isso indica intenção de parametrização, não valor hardcoded.

**Evidência ausente:** Não há documentação de negócio indicando se o valor `5` é uma regra de negócio imutável ou apenas um padrão operacional ajustável. Não há evidência de que o valor tenha sido alterado em algum momento.

**Opções consideradas:**

| Opção | Descrição | Consequência se estiver errada |
|---|---|---|
| A | Fixar o valor `5` em código na stack de destino | Se o time precisar ajustar o limite, exige alteração de código e novo deploy |
| B | Tornar o valor configurável via propriedade de ambiente/configuração da aplicação | Adiciona uma propriedade de configuração que pode nunca ser alterada — overhead mínimo |

**Decisão adotada:** Opção B — manter o valor configurável, com `5` como padrão. A evidência de que o legado o lê de configuração sugere intenção de parametrização, e o custo de torná-lo configurável na stack de destino é baixo.

**Confiança:** Média

**Reflexo no spec.md:** `## Premissas` — item na sublista "Inferidas (sem evidência direta)"

**Pergunta ao humano:** O limite de 5 registros exibidos no histórico deve ser fixo em código ou configurável via propriedade de ambiente na nova stack?
