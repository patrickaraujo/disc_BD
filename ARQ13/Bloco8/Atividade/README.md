# Atividade 8 — Resolução Documentada do Exercício Integrador

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 8 (Exercício Integrador)  
> Origem: conversão da Atividade 8 (questões 81 a 91) em itens de múltipla escolha.

> ⚠️ **Atividade avaliativa.** As questões assumem que o aluno já implementou as SPs `sp_saque` e `sp_deposito` do Bloco 8 (com a estrutura de validação herdada da v2 da transferência), e executou a bateria de testes contra a `AuditFin` ativa.

---

## Questão 1

Considere a estrutura interna da `sp_saque` no Bloco 8. Quantos níveis de IF aninhado a SP deve ter, e por quê?

A) 1 nível — apenas a validação combinada de parâmetros (`@conta IS NOT NULL AND v_valor > 0`); a validação de saldo é dispensável em saques porque o sistema permite saldo negativo (cheque especial implícito).

B) **2 níveis. Nível 1: validação combinada de parâmetros (`@conta IS NOT NULL AND v_valor > 0`). Nível 2: validação de saldo suficiente (`@saldo >= v_valor`). A estrutura é análoga à v2 da transferência (`sp_transf_bancaria02`), mas **sem** o IF do destino — saque tem só uma conta envolvida. Mensagens distintas: `'Parâmetros inadequados...'` (nível 1 falha), `'Saldo Insuficiente...'` (nível 2 falha) ou `'Saque efetuado com sucesso:'` (sucesso).** ✅

C) 3 níveis — params + saldo + validação obrigatória de identidade do correntista via `CURRENT_USER`, exigida em qualquer SP de saque por regulação bancária.

D) 4 níveis — params + saldo + limite diário de saque + autenticação multifator, todos exigidos pelo MySQL 8 em SPs financeiras.

---

## Questão 2

Comparando estruturalmente `sp_saque` e `sp_deposito`, quais elementos são **idênticos** e quais são **diferentes**?

A) São completamente idênticas — depósito é apenas um saque com sinal invertido; ambas devem ter a mesma estrutura para garantir consistência.

B) **Idênticos: trio `DECLARE erro_sql` + `CONTINUE HANDLER` + `START TRANSACTION`; captura `@conta = (SELECT NroConta WHERE NroConta = v_param)`; validação combinada de parâmetros no IF de nível 1; `IF erro_sql = FALSE THEN COMMIT ... ELSE ROLLBACK`. Diferentes: `sp_deposito` **não tem** validação de saldo (depósito não exige saldo prévio — recebe dinheiro), então tem apenas **1 nível de IF aninhado** (vs. 2 níveis na `sp_saque`). Outra diferença: o UPDATE em `sp_deposito` é `saldo = saldo + v_valor` (crédito), enquanto em `sp_saque` é `saldo = saldo - v_valor` (débito).** ✅

C) São completamente diferentes — depósito usa estrutura de `LOOP/REPEAT` para distribuir o valor em várias transações pequenas; saque usa estrutura linear.

D) Diferem apenas no nome — internamente, `sp_deposito` invoca `sp_saque` com valor negativo, evitando duplicação de código.

---

## Questão 3

Considere a chamada `sp_saque(1111, 3000)`, com a conta `1111` tendo saldo `R\$ 10.000`. Qual é o resultado?

A) **Mensagem `'Saque efetuado com sucesso:'` + colunas com novo saldo. A SP passa pela validação combinada (`@conta = 1111` válida, `v_valor = 3000 > 0`), pela validação de saldo (`10000 >= 3000`), executa o UPDATE (saldo de `1111` cai de `10000` para `7000`), e o `CONTINUE HANDLER` não dispara → `COMMIT` é executado.** ✅

B) Mensagem `'ATENÇÃO: Saldo Insuficiente, saque cancelado!!!'` — o saque exige reserva técnica de 50% do saldo, então só seriam permitidos saques até `R\$ 5.000`.

C) Mensagem `'ATENÇÃO: Parâmetros inadequados, saque cancelado!!!'` — o valor `3000` ultrapassa o limite diário de saque programado por padrão na SP.

D) Erro de execução — saques só podem ser efetuados em horário comercial; o servidor bloqueia chamadas fora do expediente bancário.

---

## Questão 4

Considere as chamadas abaixo a `sp_saque`, com a conta `1111` tendo saldo `R\$ 10.000`:

```sql
CALL sp_saque(1111, 100000);   -- saldo insuficiente
CALL sp_saque(9999, 100);      -- conta inexistente
CALL sp_saque(1111, -500);     -- valor negativo
CALL sp_saque(1111, 0);        -- valor zero
```

Quais mensagens cada chamada retorna?

A) Todas retornam a mesma mensagem `'ATENÇÃO: Parâmetros inadequados, saque cancelado!!!'` — assim como em `sp_transf_bancaria02`, a SP usa validação combinada única para todos os erros.

B) **A primeira retorna `'ATENÇÃO: Saldo Insuficiente, saque cancelado!!!'` (passa pelo IF nível 1 — `@conta = 1111` existe e `v_valor = 100000 > 0` — mas falha no IF nível 2: `10000 < 100000`). As outras três retornam `'ATENÇÃO: Parâmetros inadequados, saque cancelado!!!'`: na segunda, `@conta = NULL` (conta `9999` inexistente); na terceira e quarta, `v_valor <= 0`. Em todos os 4 casos, nenhum UPDATE é executado e o saldo permanece em `R\$ 10.000`.** ✅

C) Todas retornam `'ATENÇÃO: Saldo Insuficiente...'` — a SP herda o bug da v1 da transferência e culpa o saldo erroneamente em todos os erros.

D) A primeira retorna sucesso (com saldo negativo `-90000`), pois saques não validam o saldo. As outras três retornam erro genérico.

---

## Questão 5

Considere as chamadas abaixo a `sp_deposito`, com a conta `2222` tendo saldo `R\$ 0`:

```sql
CALL sp_deposito(2222, 5000);  -- sucesso
CALL sp_deposito(9999, 100);   -- conta inexistente
CALL sp_deposito(2222, -200);  -- valor negativo
CALL sp_deposito(2222, 0);     -- valor zero
```

Quais resultados são esperados?

A) Todas retornam sucesso, pois depósitos sempre são bem-sucedidos — a SP só valida que `v_valor` é numérico, não seu sinal nem a existência da conta.

B) **A primeira retorna `'Depósito efetuado com sucesso:'`, a conta `2222` passa de `0` para `5000`. As outras três retornam `'ATENÇÃO: Parâmetros inadequados, depósito cancelado!!!'`: na segunda, `@conta = NULL` (conta `9999` inexistente); na terceira e quarta, `v_valor <= 0`. Em todos os 3 casos de falha, nenhum UPDATE é executado e o saldo da conta `2222` permanece em `5000` (após o sucesso da primeira chamada).** ✅

C) Todas as 4 chamadas retornam `'ATENÇÃO: Conta inexistente'` — a SP exige que a conta tenha histórico de operações para aceitar depósitos.

D) Apenas a primeira é sucesso; as outras três geram erro de transação capturado pelo `CONTINUE HANDLER` e disparam `ROLLBACK`.

---

## Questão 6

Após executar **todas as 9 chamadas** do roteiro (5 chamadas a `sp_saque` + 4 chamadas a `sp_deposito`), executa-se:

```sql
SELECT * FROM AuditFin ORDER BY idAuditoria;
```

Quantas linhas aparecem em `AuditFin` e por quê?

A) 9 linhas — uma para cada chamada, independente de sucesso ou falha; a Trigger registra todas as tentativas.

B) 18 linhas — cada chamada bem-sucedida gera 2 linhas (uma para a conta + uma para auditoria simétrica), mantendo o padrão da transferência da Atividade 7.

C) **2 linhas — uma do saque bem-sucedido em `1111` (`valor_transacao = -3000{,}00`) e uma do depósito bem-sucedido em `2222` (`valor_transacao = +5000{,}00`). As outras 7 chamadas falharam **antes** do UPDATE (interceptadas pelos IFs de validação), então nada foi auditado. Insight central: como saque e depósito envolvem **uma única conta** cada, geram **1 linha por chamada bem-sucedida** (não 2 como na transferência).** ✅

D) 4 linhas — a Trigger gera 2 registros por chamada bem-sucedida (uma com `OLD.SALDO`, outra com `NEW.SALDO`), totalizando 4 linhas.

---

## Questão 7

Para cada linha de `AuditFin` registrada na bateria, como identificar se é um **saque** ou um **depósito** apenas pela coluna `valor_transacao`?

A) Não é possível — `valor_transacao` registra apenas o módulo do valor; é necessário cruzar com a coluna `tipo_operacao` (que não existe no schema atual).

B) Pelo nome da SP que gerou — a Trigger `tg_Audita_Fin` armazena automaticamente em `valor_transacao` a string `'SAQUE'` ou `'DEPOSITO'` antes do número.

C) **Pelo **sinal** de `valor_transacao`. Como a Trigger calcula `NEW.SALDO - OLD.SALDO`: se o saldo **diminuiu** (saque), o valor é **negativo**; se **aumentou** (depósito), é **positivo**. Exemplo: `idAuditoria = 1`, conta `1111`, `valor_transacao = -3000{,}00` → SAQUE; `idAuditoria = 2`, conta `2222`, `valor_transacao = +5000{,}00` → DEPÓSITO. A coluna `valor_transacao` é semanticamente rica — sinal + magnitude — graças à fórmula `NEW - OLD`.** ✅

D) Pela coluna `dataautitoria` — saques são registrados durante o dia (data atual), depósitos são lançados na data do dia útil seguinte por convenção bancária.

---

## Questão 8

Após a bateria, executa-se:

```sql
SELECT SUM(valor_transacao) FROM AuditFin;
```

O resultado é zero, e como isso compara com o invariante observado no Bloco 7?

A) Sim, é zero — toda movimentação financeira em sistema bancário é matematicamente simétrica, independente de ser transferência, saque ou depósito.

B) **Não, é `+2000{,}00` (= `5000 - 3000`). **Diferente do Bloco 7**, onde transferências sempre geravam pares simétricos (soma = 0). Saques e depósitos **alteram a soma total** do banco — o saque **tira** dinheiro do sistema (vai para o "exterior", o caixa físico ou outro banco), o depósito **injeta** dinheiro do exterior. **`SUM(valor_transacao)` em `AuditFin` é, na verdade, o resultado líquido das movimentações externas** (depósitos − saques). Positivo: o banco recebeu mais do que pagou; negativo: o oposto.** ✅

C) Sim, é zero — porque o saque debitou `R\$ 3.000` da conta `1111` e a Trigger automaticamente registrou um crédito de `R\$ 3.000` em uma conta-fantasma do sistema, mantendo a simetria global.

D) Não, é `R\$ 8.000` (= `5000 + 3000`) — o sistema soma os valores absolutos para fins de relatório, ignorando sinais.

---

## Questão 9

Identifique corretamente **três técnicas/padrões** vindos dos blocos anteriores que foram reusados no exercício do Bloco 8:

A) Apenas o `START TRANSACTION` do Bloco 4 — `sp_saque` e `sp_deposito` são SPs simples que não precisaram dos padrões mais elaborados dos blocos 5, 6 e 7.

B) **(1) **Trio `DECLARE erro_sql / DECLARE CONTINUE HANDLER FOR SQLEXCEPTION / START TRANSACTION`** (vindo do Bloco 4) — usado no início de cada SP. (2) **Captura `@conta = (SELECT NroConta FROM Conta WHERE NroConta = v_param)`** (vindo do Bloco 6) — teste inequívoco de existência da conta. (3) **Validação combinada `@conta IS NOT NULL AND v_valor > 0`** (vindo do Bloco 6) — IF de nível 1 das duas SPs. Bônus: a Trigger `tg_Audita_Fin` (Bloco 7) é reaproveitada **automaticamente** — qualquer UPDATE em `CONTA`, seja por SP de transferência, saque ou depósito, é auditado sem necessidade de modificação na Trigger.** ✅

C) Apenas o padrão `IF erro_sql = TRUE THEN ROLLBACK` do Bloco 3 — os demais elementos foram introduzidos pela primeira vez no Bloco 8.

D) Padrões de criptografia, autenticação 2FA e replicação master-slave — vindos respectivamente dos Blocos 5, 6 e 7.

---

## Questão 10

Em uma turma reflexiva, qual frase descreve melhor o que efetivamente permite ao aluno resolver o exercício integrador do Bloco 8 **sem código guia**?

A) A leitura cuidadosa do enunciado do Bloco 8, sem necessidade de envolvimento prático com os blocos anteriores.

B) A consulta direta ao gabarito (`COMANDOS-BD-03-bloco8.sql`) antes de tentar — afinal, o objetivo é entregar a solução correta no menor tempo possível.

C) **A **comparação v1 × v2 dos Blocos 5 e 6** foi crucial. Sem ela, o aluno tenderia a copiar a estrutura "errada" da v1 (sem captura de `@conta`, sem validação combinada robusta), repetindo os bugs catastróficos ("dinheiro some", diagnóstico errado). Foi por **ver de perto o que dá errado** que o aluno internalizou o que **deve fazer certo** — a v2 é o **modelo concreto** de SP transacional resiliente que se reaplica em saque/depósito com pequenas adaptações.** ✅

D) A memorização da sintaxe SQL do MySQL 8 antes de iniciar a aula — o conhecimento prévio dispensa qualquer prática ou repetição.

---

## Questão 11

Qual das duas SPs (`sp_saque` ou `sp_deposito`) tem a `sp_transf_bancaria02` como **referência estrutural mais próxima**, e por quê?

A) `sp_deposito` — porque tanto a v2 da transferência quanto o depósito injetam dinheiro em uma conta de destino, sem necessidade de validação de saldo na origem.

B) **`sp_saque` — porque `sp_transf_bancaria02` tem **2 níveis de IF aninhado** (validação combinada de parâmetros + validação de saldo da origem), exatamente a mesma estrutura que `sp_saque` precisa. Para `sp_deposito`, a referência foi mais útil como ponto de partida para **simplificação** — remover o IF de saldo, pois depósito não exige saldo prévio. Ambas as referências valem; a v2 é a base mais próxima, e cada SP a adapta conforme seu próprio domínio.** ✅

C) Nenhuma das duas — a v2 da transferência tem 3 UPDATEs e taxa cambial, enquanto saque/depósito têm apenas 1 UPDATE; são domínios totalmente distintos.

D) Ambas igualmente — saque e depósito são estruturalmente idênticos, então qualquer comparação com a v2 vale para ambos.

---

## Questão 12

Imagine a tarefa de criar uma terceira SP, `sp_transferencia_internacional`, que transfere entre duas contas aplicando uma **taxa cambial** (parâmetro `v_taxa FLOAT`) e gera **3 UPDATEs**: debita origem, credita destino com valor convertido (`v_valor * v_taxa`) e credita uma "conta-banco" `(NroConta=1, idCliente=1, idTipoConta=1)` com o valor da taxa retida. Quantas linhas em `AuditFin` cada chamada bem-sucedida geraria?

A) 1 linha — apenas o resultado líquido da operação é auditado, com `valor_transacao = 0` no caso simétrico ou `> 0` no caso com taxa.

B) 2 linhas — apenas as linhas da origem e do destino; a conta-banco é considerada "interna" pela Trigger e não é auditada.

C) **3 linhas — uma por UPDATE em `Conta`. A Trigger `tg_Audita_Fin` é `AFTER UPDATE FOR EACH ROW` e dispara uma vez por linha afetada, independentemente de qual SP fez o UPDATE. Os 3 UPDATEs (origem, destino e conta-banco) gerariam 3 linhas em `AuditFin`, com `valor_transacao` distinto em cada uma: `-v_valor` (origem), `+v_valor * v_taxa` (destino) e `+(v_valor - v_valor*v_taxa)` (conta-banco), por exemplo.** ✅

D) 0 linhas — Triggers `AFTER UPDATE` não disparam dentro de transações que envolvem múltiplos UPDATEs sequenciais; apenas o último é registrado, e como o último é a conta-banco (interna), o registro é descartado.

---

## Questão 13

Para a `sp_transferencia_internacional` da questão anterior, o invariante `SUM(valor_transacao) = 0` por chamada bem-sucedida ainda se mantém? Por quê?

A) Sim, sempre — qualquer operação em sistema bancário preserva o invariante de conservação por design do MySQL.

B) **Depende: se a taxa cambial implicar conversão real (`v_valor * v_taxa ≠ v_valor`), então **não** — o que sai da origem (`-v_valor`) **diferirá** do que entra no destino (`+v_valor * v_taxa`), e mesmo somando o valor que entra na conta-banco, o resultado **só será zero se o cálculo for matematicamente fechado**: `-v_valor + (v_valor * v_taxa) + (v_valor - v_valor * v_taxa) = 0` ✅ (neste caso particular, sim, soma zero, pois a conta-banco recebe exatamente o "resíduo"). Mas se a "taxa" fosse uma comissão bruta sem ser absorvida internamente (saída para o "exterior"), a soma seria diferente de zero. **Lição:** o invariante depende da modelagem — não é uma garantia automática.** ✅

C) Não, nunca — qualquer operação envolvendo `FLOAT` (como `v_taxa`) introduz erro de arredondamento que quebra o invariante mesmo em cenários idealmente fechados.

D) Sim, sempre — porque a Trigger arredonda automaticamente o saldo final para preservar a soma zero, garantindo conservação contábil em qualquer cenário.

---

## Questão 14

Para a `sp_transferencia_internacional`, quais validações da v2 (`sp_transf_bancaria02`) você reusaria, e quais novas precisariam ser adicionadas?

A) Reusaria todas as validações da v2 sem adicionar nenhuma — taxa cambial é apenas um multiplicador aritmético sem necessidade de validação.

B) **Reusaria: existência da conta de origem (`@conta_origem IS NOT NULL`); existência da conta de destino (`@conta_destino IS NOT NULL`); valor positivo (`v_valor > 0`); saldo suficiente da origem (`@saldo_origem >= v_valor`). Novas validações necessárias: (1) **`v_taxa > 0`** — taxa não pode ser zero ou negativa (inverteria o fluxo do dinheiro como no bug do valor negativo do Bloco 5). (2) Verificação de **existência da conta-banco** `(1, 1, 1)` no schema — se ela for apagada/renomeada, o terceiro UPDATE afetaria 0 linhas e o "dinheiro da taxa" sumiria silenciosamente (mesmo bug "dinheiro some" que a v2 corrigiu na transferência comum). (3) Possivelmente, validar limites máximos de taxa (ex.: `v_taxa BETWEEN 0.5 AND 2.0`) para evitar cenários absurdos.** ✅

C) Reusaria apenas a captura de `@saldo_origem`; as demais validações são específicas da transferência interna e não se aplicam à internacional.

D) Não reusaria nenhuma — `sp_transferencia_internacional` exige validação por API externa de câmbio (Banco Central) e não pode usar a estrutura da v2 da transferência interna.
