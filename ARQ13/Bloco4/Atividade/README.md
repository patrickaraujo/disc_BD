# Atividade 4 — Sua Primeira SP Transacional Não Trivial

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 4  
> Origem: conversão da Atividade 4 (questões 31 a 42) em itens de múltipla escolha.

> **Saldos iniciais das contas em `Conta` (premissa para todas as questões):**  
> `1111` (Rubens, Corrente) = R\$ 10.000  ·  `2222` (Rubens, Poupança) = R\$ 0  
> `5555` (Oswaldo, Corrente) = R\$ 10.000  ·  `6666` (Oswaldo, Poupança) = R\$ 1.000

---

## Questão 1

Considere a primeira chamada do roteiro:

```sql
CALL sp_transf_bancaria(1111, 2222, 5000);
```

Qual mensagem é retornada e quais são os saldos finais das contas envolvidas?

A) Mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'` — saldos não alterados, pois a chamada não passa pelo IF de nível 1.

B) **Mensagem `'Contas alteradas com sucesso:'` + 3 colunas (`RESULTADO`, `NOVO SALDO ORIGEM = 5000`, `NOVO SALDO DESTINO = 5000`). Os 3 níveis de IF aprovam (parâmetros não-NULL → saldo `10000 >= 5000` → ambos UPDATEs sem erro), e o `COMMIT` consolida o débito de R\$ 5.000 da conta `1111` e o crédito equivalente na conta `2222`.** ✅

C) Mensagem `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — saldos não alterados, pois `10000 < 5000` retorna FALSE devido à comparação ser feita entre `FLOAT` e `INT`.

D) Mensagem `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'` — saldo de `1111` fica em 5000, mas saldo de `2222` permanece em 0 porque o segundo UPDATE falha por ausência de `COMMIT` intermediário.

---

## Questão 2

Considere a segunda chamada do roteiro (executada **logo após** a chamada da questão anterior):

```sql
CALL sp_transf_bancaria(5555, 6666, 1600);
```

Qual mensagem é retornada e quais são os saldos finais?

A) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — a SP confunde o saldo da conta `5555` com o saldo já reduzido da conta `1111`, resultando em validação incorreta.

B) Mensagem `'ATENÇÃO: Parâmetros inadequados...'` — o valor `1600` é interpretado como sub-múltiplo de saldo e cai no caminho de parâmetro inválido.

C) **Mensagem `'Contas alteradas com sucesso:'` — saldo final de `5555` = `8400` (`10000 - 1600`); saldo final de `6666` = `2600` (`1000 + 1600`). Caminho de sucesso da SP, sem qualquer interação com as contas alteradas pela chamada anterior, pois cada chamada captura `@saldo_origem` independentemente.** ✅

D) Mensagem `'ATENÇÃO: Erro na transação...'` — o servidor disparou `ROLLBACK` automaticamente porque há uma transação ativa da chamada anterior que precisa ser fechada antes.

---

## Questão 3

Considere a terceira chamada do roteiro (após as duas anteriores terem sido executadas):

```sql
CALL sp_transf_bancaria(1111, 2222, 7000);
```

Qual mensagem é retornada e quais são os saldos finais?

A) Mensagem `'Contas alteradas com sucesso:'` — o saldo de `1111` cai para `-2000` (negativo permitido em conta corrente).

B) **Mensagem `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — após a chamada #1, a conta `1111` tem apenas R\$ 5.000, e a comparação `@saldo_origem >= v_valor` (`5000 >= 7000`) retorna FALSE. A SP cai no `ELSE` do IF de nível 2 antes mesmo de abrir a transação, e nenhum UPDATE é executado. Saldos permanecem: `1111 = 5000`, `2222 = 5000`.** ✅

C) Mensagem `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'` — o UPDATE tenta reduzir abaixo de zero, dispara `SQLEXCEPTION`, o handler captura, `erro_sql = TRUE` e o `ROLLBACK` é executado.

D) Mensagem `'ATENÇÃO: Parâmetros inadequados...'` — valor `7000` maior que o saldo é tratado pela SP como parâmetro inválido.

---

## Questão 4

Considere a quarta chamada do roteiro:

```sql
CALL sp_transf_bancaria(1111, NULL, 2000);
```

Qual mensagem é retornada e qual o estado dos saldos?

A) Mensagem `'Contas alteradas com sucesso:'` — o `NULL` é tratado como conta padrão (`idCliente = 0`) por compatibilidade.

B) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — a conta `1111` tem `5000` e suporta o débito, mas o crédito ao `NULL` falha e a SP confunde com saldo insuficiente.

C) **Mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'` — o IF de nível 1 valida `v_origem IS NOT NULL AND v_destino IS NOT NULL`. Como `v_destino = NULL`, a expressão é UNKNOWN (que `IF` trata como FALSE) e a SP cai no `ELSE` externo, sem nem mesmo capturar `@saldo_origem`. Nenhum UPDATE é executado; saldos permanecem inalterados.** ✅

D) Erro de sintaxe na chamada — o MySQL exige um valor não-NULL para parâmetros declarados sem `DEFAULT NULL` na assinatura da SP.

---

## Questão 5

Após as 4 chamadas do roteiro (executadas em sequência), executa-se:

```sql
SELECT * FROM Conta;
```

Qual é o estado final esperado das 4 contas?

A) **`1111 = 5000` (debitada pela #1), `2222 = 5000` (creditada pela #1), `5555 = 8400` (debitada pela #2), `6666 = 2600` (creditada pela #2). As chamadas #3 e #4 falharam **antes** de qualquer UPDATE ser executado (foram interceptadas pelos IFs de validação), então não deixaram efeito em `Conta`.** ✅

B) Os saldos iniciais permanecem inalterados em todas as contas — todas as chamadas falharam por bugs latentes na SP.

C) Apenas `1111` e `2222` foram alteradas; `5555` e `6666` mantêm saldos iniciais — o servidor processa apenas a primeira transação por sessão.

D) `1111 = -2000`, `2222 = 7000`, `5555 = 8400`, `6666 = 2600` — efeito acumulado da chamada #3, que sobrescreveu os valores da #1 antes de ser revertida pelo `ROLLBACK`.

---

## Questão 6

Considerando a estrutura `IF` aninhada de 3 níveis em `sp_transf_bancaria`, qual alternativa lista corretamente as **4 mensagens distintas** que a SP pode retornar (uma por "caminho" de execução)?

A) Apenas 2 mensagens: `'sucesso'` e `'falha'` — cada IF apenas redireciona para uma das duas saídas finais.

B) **4 mensagens, cada uma associada a um caminho distinto: (1) `'Contas alteradas com sucesso:'` + 3 colunas (caminho do sucesso, com `COMMIT`); (2) `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'` (transação aberta mas erro de SQL → `ROLLBACK`); (3) `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` (saldo da origem insuficiente → nem abre transação); (4) `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'` (origem ou destino NULL → nem chega ao IF de saldo).** ✅

C) 3 mensagens — não há caminho separado para "parâmetros inadequados", pois o MySQL bloqueia automaticamente parâmetros NULL antes de a SP ser executada.

D) 5 mensagens — a SP também tem um caminho separado para cada tipo específico de erro (saldo negativo, valor zero, conta inexistente etc.).

---

## Questão 7

Por que a captura `SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem);` é feita **antes** do `START TRANSACTION`, e não **dentro** dele?

A) Porque dentro de uma transação não é possível usar variáveis de sessão (`@`); apenas variáveis locais (`DECLARE`).

B) Porque o `SELECT` precisa ser executado em modo `READ UNCOMMITTED` para conseguir ler o saldo, e `START TRANSACTION` ativa `READ COMMITTED` por padrão.

C) **Para evitar abrir transação desnecessariamente. Se o saldo fosse capturado dentro de uma transação aberta, mas a validação `@saldo_origem >= v_valor` falhasse depois, teríamos uma transação aberta sem nada para fazer — desperdício de locks/recursos e fonte de bugs (ex.: esquecer de fechar com `ROLLBACK` em algum caminho do `ELSE`). Capturar antes mantém o `START TRANSACTION` apenas onde realmente é necessário.** ✅

D) Porque o `SELECT` em variáveis de sessão é executado pelo servidor antes de qualquer transação, independentemente de onde for declarado no corpo da SP.

---

## Questão 8

Para cada uma das 4 chamadas do roteiro, qual é o estado de `@saldo_origem`, dos dois IFs externos e da decisão de iniciar transação?

A) **(1) `@saldo_origem = 10000`; IF nível 1 = TRUE; IF nível 2 = TRUE (`10000 >= 5000`); transação iniciada. (2) `@saldo_origem = 10000` (5555 não foi tocado); IF nível 1 = TRUE; IF nível 2 = TRUE (`10000 >= 1600`); transação iniciada. (3) `@saldo_origem = 5000` (1111 já foi debitada pela #1); IF nível 1 = TRUE; IF nível 2 = FALSE (`5000 < 7000`); transação NÃO iniciada. (4) A SP nem chega ao SELECT — o IF nível 1 já retorna FALSE devido a `v_destino = NULL`; transação NÃO iniciada.** ✅

B) Em todas as chamadas, `@saldo_origem = 10000` (saldo inicial), pois o `SELECT` sempre lê o estado pré-transação registrado em snapshot fixo.

C) Apenas as chamadas #1 e #2 capturam `@saldo_origem`; as #3 e #4 retornam erro **antes** da captura por validação interna do MySQL.

D) Todas as 4 chamadas iniciam transação; a diferença está apenas no resultado final (sucesso ou `ROLLBACK`).

---

## Questão 9

Por que a mensagem de sucesso da `sp_transf_bancaria` retorna **3 colunas** (`RESULTADO`, `NOVO SALDO ORIGEM`, `NOVO SALDO DESTINO`) — repetindo o padrão de "mensagem enriquecida" visto na `sp_altera_livros` (ARQ12, Bloco 6)?

A) Porque o MySQL exige sintaticamente que `SELECT` em SPs de UPDATE retorne pelo menos 3 colunas para que o resultado seja exibido no Workbench.

B) **Em uma SP de operação financeira, o usuário precisa de prova imediata do estado pós-operação. Mostrar `RESULTADO` + `NOVO SALDO ORIGEM` + `NOVO SALDO DESTINO` elimina a necessidade de fazer SELECT separado para confirmar a operação, e ainda permite que o app móvel/web exiba imediatamente "Você tinha R\$ X, agora tem R\$ Y" — UX mais clara e auditoria visual imediata.** ✅

C) Por consistência estrita com a `sp_altera_livros` da ARQ12; é apenas convenção pedagógica do professor sem ganho prático real.

D) Porque cada UPDATE da transação retorna 1 coluna automaticamente; como há 2 UPDATEs + a mensagem `RESULTADO`, o servidor consolida em 3 colunas no `SELECT` final.

---

## Questão 10

Suponha que, no segundo `UPDATE` da transação (o que credita o destino), ocorra um erro inesperado (por exemplo, falha de I/O do disco). O que acontece com o saldo da conta origem (que já foi debitada na linha anterior)?

A) Permanece debitada — apenas o segundo UPDATE foi desfeito; o primeiro UPDATE já foi auto-confirmado individualmente pelo servidor.

B) Não é afetada pelo erro — UPDATEs em SPs são autocommit-ados linha por linha em todas as engines do MySQL 8.

C) **É desfeita pelo `ROLLBACK`. Como ambos os UPDATEs estão dentro do `START TRANSACTION` e o `CONTINUE HANDLER FOR SQLEXCEPTION` está ativo, qualquer erro é capturado, `erro_sql` vira `TRUE`, e o `IF` final dispara `ROLLBACK`. O UPDATE da origem é desfeito junto com o tentado UPDATE do destino — atomicidade preservada. Esse é o ponto central de "transação".** ✅

D) Permanece debitada, e o sistema exibe um aviso ao usuário pedindo que execute manualmente um UPDATE compensatório para restaurar o saldo da origem.

---

## Questão 11

Por que `@saldo_destino` é inicializada com `0` no início da SP, e depois reatribuída via novo `SELECT` após o `COMMIT`?

A) Porque o MySQL exige inicialização explícita de qualquer variável de sessão antes do uso, sob pena de erro de sintaxe na criação da SP.

B) **A inicialização (`= 0`) garante que a variável **existe** desde o começo da SP, evitando referência a variável não inicializada caso algum caminho exótico chegue à mensagem de sucesso. A reatribuição **depois** do `COMMIT` é necessária porque os valores em `@saldo_origem` (capturado antes dos UPDATEs) e `@saldo_destino` (= `0`) **não refletem** mais o estado atual após os UPDATEs — é preciso reler do banco com novo `SELECT` para que a mensagem de sucesso exiba os saldos efetivamente atualizados.** ✅

C) Porque variáveis de sessão começam com `NULL` por padrão, e `NULL` em operações aritméticas resulta em `NULL` — a inicialização com `0` evita comportamento UNKNOWN nas comparações que vêm depois.

D) Porque a variável `@saldo_destino` é compartilhada entre todas as sessões do servidor; inicializá-la com `0` garante isolamento entre conexões concorrentes.

---

## Questão 12

Em qual situação a captura `SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem);` resulta em **`NULL`**? E o que acontece com a comparação `@saldo_origem >= v_valor` quando um dos lados é `NULL`?

A) **Quando `v_origem` aponta para uma conta inexistente (`NroConta` sem correspondência em `Conta`), o `SELECT` retorna 0 linhas e a variável recebe `NULL`. Comparações com `NULL` em SQL retornam UNKNOWN (não TRUE nem FALSE — **lógica de 3 valores**). Em um `IF`, UNKNOWN é tratado como falso. Então a comparação `NULL >= v_valor` cai no `ELSE` do IF de saldo, e a SP retorna `'Saldo Insuficiente'` — uma mensagem **enganosa**, já que o problema real é "conta não existe". Esse é o bug latente que o Bloco 5 vai explorar em detalhes.** ✅

B) Apenas quando o servidor MySQL está com `STRICT_TRANS_TABLES` desativado; com a flag ativa, o `SELECT` lança erro em vez de retornar `NULL`.

C) Nunca — o `SELECT` sempre retorna o saldo (mesmo que seja zero). `NULL` só aparece se o saldo da conta estiver explicitamente como `NULL` na própria coluna `saldo`.

D) Quando a comparação aritmética envolve um decimal de precisão diferente (`FLOAT` em saldo vs `INT` em `v_valor`), o servidor converte para `NULL` silenciosamente como medida de segurança.

---

## Questão 13

Considere a chamada `sp_transf_bancaria(9999, 2222, 100)`, sendo que a conta `9999` **não existe** em `Conta`. Qual mensagem é retornada e qual é o estado final dos saldos?

A) Mensagem `'ATENÇÃO: Parâmetros inadequados...'` — o servidor detecta automaticamente que `9999` não existe em `Conta` e classifica como parâmetro inválido. Saldos inalterados.

B) Mensagem `'ATENÇÃO: Conta de origem inexistente, transação cancelada!!!'` — a SP tem caminho específico para esse cenário, herdado da modelagem padrão de SPs financeiras. Saldos inalterados.

C) Mensagem `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'` — o `CONTINUE HANDLER` captura uma violação implícita de FK e dispara `ROLLBACK`. Saldos inalterados.

D) **Mensagem `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — **DIAGNÓSTICO ERRADO**. A conta `9999` não existe, mas a mensagem culpa o saldo. Isso ocorre porque `(SELECT saldo FROM Conta WHERE NroConta = 9999)` retorna 0 linhas → `@saldo_origem = NULL` → a comparação `NULL >= 100` é UNKNOWN, tratada como FALSE → cai no `ELSE` do IF de saldo. Saldos: inalterados (nada foi modificado), mas o usuário recebe uma informação **enganosa** sobre o motivo real da falha.** ✅

---

## Questão 14

Considere agora a chamada `sp_transf_bancaria(1111, 9999, 100)`, sendo que a conta `9999` **não existe** (mas a `1111` existe e tem saldo `5000`). Qual é o resultado?

A) Mensagem `'ATENÇÃO: Conta de destino inexistente...'` — a SP tem caminho específico para esse cenário, ativado pela validação de FK no segundo UPDATE. Saldos inalterados.

B) Mensagem `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'` — o segundo UPDATE falha por violação implícita de FK ou conta inexistente, o `CONTINUE HANDLER` captura, `erro_sql = TRUE` e o `ROLLBACK` desfaz o débito da origem. Saldos: inalterados.

C) Erro do MySQL impedindo a chamada antes da execução — `v_destino` precisa apontar para conta válida e o servidor valida o argumento na assinatura da SP. Saldos inalterados.

D) **A SP **retorna sucesso**! Saldo de `1111` antes: `5000`; saldo depois: `4900`. **A conta perdeu R\$ 100 — e o destino não recebeu nada (nem é uma conta que existe).** Em `SELECT * FROM Conta;`, aparecem ainda apenas 4 linhas, mas com `1111` debitada. Os R\$ 100 simplesmente **sumiram**. Isso ocorre porque o `UPDATE Conta SET saldo = saldo + 100 WHERE NroConta = 9999` afeta **0 linhas** — o que NÃO é considerado erro pelo `CONTINUE HANDLER FOR SQLEXCEPTION` (afetar 0 linhas é resultado válido, não exceção). O `erro_sql` permanece `FALSE`, o `COMMIT` é executado e a SP exibe mensagem de sucesso enganosa. **Bug CRÍTICO** que será corrigido no Bloco 6.** ✅
