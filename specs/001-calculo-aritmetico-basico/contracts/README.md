# Contratos — Cálculo Aritmético Básico

**Feature**: `001-calculo-aritmetico-basico`
**Data**: 2026-09-23

---

## Contratos disponíveis

| Arquivo | Descrição |
|---------|-----------|
| [calculo-api.md](./calculo-api.md) | Contrato REST da API de cálculo e histórico: endpoints, payloads de request/response, códigos HTTP e mapeamento de mensagens de erro. |

---

## Resumo dos endpoints

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/calculos` | Realiza o cálculo, persiste no histórico e retorna resultado + histórico atualizado |
| `GET` | `/api/calculos/historico` | Retorna os últimos N cálculos (usado para carga inicial da tela) |

---

## Contratos externos

Esta feature não possui integração com sistemas externos. Toda a comunicação é entre o frontend Angular e o backend Spring Boot desta própria modernização.
