# Guia Rápido de Validação: Histórico de Cálculos

**Feature**: 002-historico-de-calculos
**Data**: 2026-09-23

Este guia descreve como validar manualmente, em ambiente local, o comportamento funcional desta feature após a implementação no `target_root`.

## Pré-requisitos

1. Backend rodando localmente (perfil `local`), com a migration `V1__criar_historico_calculo.sql` aplicada.
2. Frontend rodando localmente, apontando para o backend local.

## Roteiro de validação — User Story 1 (Registro de cálculo)

1. Acesse a tela da calculadora.
2. Informe dois operandos válidos (ex.: `10` e `2`) e selecione a operação `Divisão`.
3. Submeta o cálculo e confirme que o resultado `5,0` é exibido, formatado no padrão brasileiro.
4. Consulte a lista de histórico (recarregando a tela ou observando a atualização automática) e confirme que o cálculo aparece como o primeiro item, com data/hora, expressão (`10 / 2`) e resultado corretos.
5. Repita o cálculo com o operando 2 igual a `0` na operação `Divisão` e confirme que:
   - A mensagem de erro "Não é possível dividir por zero." é exibida.
   - Nenhum novo item aparece no histórico.
6. Submeta o formulário deixando um dos operandos em branco e confirme que:
   - A mensagem de erro "Preencha os dois números." é exibida.
   - Nenhum novo item aparece no histórico.

## Roteiro de validação — User Story 2 (Exibição do histórico)

1. Com o histórico vazio (ambiente limpo), acesse a tela e confirme que a seção de histórico não é exibida.
2. Realize seis cálculos válidos, cada um com operandos diferentes, aguardando um intervalo mínimo entre eles para garantir data/hora distintas.
3. Confirme que a lista de histórico exibe exatamente 5 itens (valor padrão configurado), correspondendo aos 5 cálculos mais recentes.
4. Confirme que a ordem exibida é do mais recente (primeiro) para o mais antigo (último) entre os 5 exibidos.
5. Confirme que o cálculo mais antigo dos seis realizados não aparece na lista (por exceder o limite de exibição), mas isso não impede que ele continue armazenado (validação indireta: ajustar a configuração de limite para um valor maior e confirmar que ele reaparece).

## Critério de conclusão

O roteiro é considerado bem-sucedido quando todos os passos acima produzem exatamente o comportamento descrito, sem necessidade de intervenção manual adicional no banco de dados ou nos arquivos de configuração além do already previsto.
