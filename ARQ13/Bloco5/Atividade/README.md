# Atividade 5 — Diagnosticando Bugs

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 5  
> Origem: conversão da Atividade 5 (questões 43 a 57) em itens de múltipla escolha.

> **Estado de partida (após o Bloco 4):**  
> `1111` (Rubens, Corrente) = R\$ 5.000  ·  `2222` (Rubens, Poupança) = R\$ 5.000  
> `5555` (Oswaldo, Corrente) = R\$ 8.400  ·  `6666` (Oswaldo, Poupança) = R\$ 2.600  
> Soma total = R\$ 21.000

---

## Questão 1

Considere a chamada do **Cenário 1 — origem inexistente**, com a conta `9999` **não existente** em `Conta`:

```sql
CALL sp_transf_bancaria(9999, 2222, 100);
```

Qual mensagem é retornada e ela é **honesta** com o usuário?

A) Mensagem `'ATENÇÃO: Conta inexistente, transação cancelada!!!'` — diagnóstico honesto que aponta o problema real ao usuário.

B) Mensagem `'ATENÇÃO: Erro na transação...'` — o `CONTINUE HANDLER` captura a violação implícita de FK e retorna erro genérico mas correto.

C) Mensagem `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — DIAGNÓSTICO ENGANOSO. O problema real é "conta `9999` não existe", mas a mensagem culpa o saldo. Isso porque `(SELECT saldo FROM Conta WHERE NroConta = 9999)` retorna 0 linhas, então `@saldo_origem = NULL`. A comparação `NULL >= 100` é UNKNOWN (tratada como FALSE no `IF`), caindo no `ELSE` da validação de saldo. A SP funciona, mas mente ao usuário sobre o motivo da falha.

D) Mensagem `'Contas alteradas com sucesso:'` — o servidor aceitou a chamada e debitou da conta `9999` mesmo ela não existindo, criando-a implicitamente em `Conta`.

---

## Questão 2

Após a chamada do Cenário 1 da questão anterior, executa-se:

```sql
SELECT SUM(saldo) AS soma_total FROM Conta;
```

Comparada com o valor anterior à chamada (R\$ 21.000), a soma mudou? Por quê?

A) Aumentou em R\$ 100 — a conta `2222` recebeu o crédito mesmo a origem `9999` não existindo (creditar para destino existente sempre funciona).

B) Diminuiu em R\$ 100 — a conta `9999` é "criada virtualmente" como negativa, e o débito conta na soma.

C) Não mudou. A soma permanece exatamente em R\$ 21.000. A SP caiu no `ELSE` da validação de saldo antes de qualquer `UPDATE` ser executado, então nenhuma alteração foi feita em `Conta`. O sistema conservou a integridade dos saldos — apesar da mensagem mentirosa retornada ao usuário.

D) Não mudou, mas isso é coincidência — o servidor MySQL bloqueou silenciosamente as duas operações por violação de FK não capturada pelo handler.

---

## Questão 3

Considere agora a chamada do **Cenário 2 — destino inexistente** (com a conta `1111` existente, saldo R\$ 5.000, e a conta `9999` **não existente**):

```sql
CALL sp_transf_bancaria(1111, 9999, 100);
```

Qual mensagem é retornada?

A) Mensagem `'ATENÇÃO: Conta de destino inexistente...'` — a SP detecta o problema na validação de FK durante o segundo UPDATE.

B) Mensagem `'ATENÇÃO: Erro na transação...'` — o segundo UPDATE falha, o handler captura, `ROLLBACK` é executado e o saldo da origem é restaurado.

C) Mensagem `'Contas alteradas com sucesso:'` + 3 colunas (`NOVO SALDO ORIGEM = 4900`, `NOVO SALDO DESTINO = NULL`). A SP afirma sucesso mesmo com a conta de destino não existindo. Os UPDATEs executam sem erro (afetar 0 linhas não é exceção SQL), o handler nunca dispara, o `COMMIT` é executado e a SP exibe mensagem otimista enganosa.

D) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — a SP confunde o cenário com saldo insuficiente, similar ao Cenário 1.

---

## Questão 4

Após a chamada da questão anterior, releia o saldo da conta `1111`. Para onde foram os R\$ 100 debitados?

A) Foram para a conta `2222` — a SP redirecionou automaticamente o crédito para a próxima conta válida do mesmo cliente.

B) Permanecem em uma "área de pendência" do MySQL, aguardando que a conta `9999` seja criada para receber o crédito posteriormente.

C) Os R\$ 100 simplesmente sumiram. Saldo de `1111` antes: R\$ 5.000; saldo depois: R\$ 4.900. Não foram para lugar algum. O `UPDATE Conta SET saldo = saldo + 100 WHERE NroConta = 9999` afetou 0 linhas — não houve crédito em parte alguma. Isso ocorre porque "afetar 0 linhas" não é considerado erro pelo `CONTINUE HANDLER FOR SQLEXCEPTION`, então o `ROLLBACK` nunca é disparado. O dinheiro deixou a origem mas nunca chegou a um destino.

D) Voltaram automaticamente para a conta `1111` após o `COMMIT` — o sistema detecta destino inválido e cancela apenas o crédito, mantendo o débito como "saldo retido" temporário.

---

## Questão 5

Após a chamada do Cenário 2, executa-se novamente `SELECT SUM(saldo) FROM Conta`. Comparada com o valor anterior (R\$ 21.000), a soma:

A) Aumentou para R\$ 21.100 — o servidor conta o débito da origem como receita do banco.

B) Diminuiu para R\$ 20.900 (R\$ 100 a menos). O dinheiro literalmente sumiu da contabilidade do banco — o débito na origem foi efetivado, mas o crédito nunca foi aplicado a nenhuma conta. A soma total dos saldos não conserva mais o invariante "soma constante" entre transferências internas.

C) Permaneceu igual em R\$ 21.000 — o sistema garante automaticamente conservação do dinheiro em qualquer cenário de operação.

D) Diminuiu em R\$ 200 (para R\$ 20.800) — a SP debitou da origem e cobrou uma "taxa de operação" de R\$ 100 não revertida em `ROLLBACK`.

---

## Questão 6

Por que esse bug é chamado de **"dinheiro que some"** e por que ele é **catastrófico** em sistema bancário real?

A) Porque o dinheiro vai literalmente para um endereço de memória inválido, expondo o servidor a ataques de buffer overflow.

B) Porque a soma total dos saldos do banco fica MENOR do que era antes — quebra o princípio sagrado de conservação do dinheiro em finanças. Em sistema bancário real, isso significa que o banco passa a ter na contabilidade interna um valor menor do que efetivamente possui em depósitos. Auditoria detecta a inconsistência, mas o dinheiro não é recuperável apenas via SQL — exige investigação manual de logs e correção via ajuste contábil. Sob escrutínio do regulador (Banco Central), bugs assim podem fechar a instituição.

C) Porque o dinheiro é desviado para uma conta-fantasma do MySQL que pode ser explorada por DBAs maliciosos para enriquecimento ilícito.

D) Porque o cliente pode acionar o banco judicialmente e exigir restituição em dobro — o que torna o erro caro, mas não catastrófico nem irrecuperável.

---

## Questão 7

No **Cenário 3 — valor inválido**, considere a chamada com **valor zero**:

```sql
CALL sp_transf_bancaria(1111, 2222, 0);
```

O que acontece?

A) Mensagem `'Contas alteradas com sucesso:'`. Os UPDATEs executam (`saldo = saldo - 0` e `saldo = saldo + 0`), os saldos não mudam, mas a SP exibe sucesso. Resultado: ruído desnecessário no log de auditoria — uma "transferência fantasma" registrada como operação real, sem efeito prático mas poluindo a trilha de auditoria.

B) Mensagem `'ATENÇÃO: Valor inválido, transação cancelada!!!'` — a SP tem caminho específico para valores zero ou negativos.

C) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — `5000 >= 0` retorna FALSE em algumas versões do MySQL devido a quirk de comparação inteira com `FLOAT`.

D) Erro de sintaxe — o MySQL rejeita o valor `0` como argumento para SP financeira, exigindo valor estritamente positivo.

---

## Questão 8

Considere a chamada com **valor negativo**:

```sql
CALL sp_transf_bancaria(1111, 2222, -500);
```

Qual é o comportamento?

A) Mensagem `'ATENÇÃO: Valor inválido...'` — a SP detecta que valor negativo não é uma transferência válida e cancela a operação.

B) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — `5000 >= -500` retorna FALSE devido a comparação numérica.

C) Mensagem `'Contas alteradas com sucesso:'`, mas o fluxo do dinheiro é INVERTIDO: a conta `1111` (origem) executou `saldo = saldo - (-500) = saldo + 500` (ganhou R\$ 500); a conta `2222` (destino) executou `saldo = saldo + (-500) = saldo - 500` (perdeu R\$ 500). O dono da conta `1111` recebeu dinheiro em vez de pagar. Bug grave: alguém pode "transferir" valores negativos para roubar dinheiro de outras contas.

D) Erro de execução — o MySQL bloqueia operações aritméticas com valores negativos em colunas declaradas como `FLOAT`.

---

## Questão 9

Considere a chamada com **origem == destino**:

```sql
CALL sp_transf_bancaria(1111, 1111, 100);
```

O que acontece?

A) Mensagem `'ATENÇÃO: Origem e destino iguais, transação cancelada!!!'` — a SP detecta automaticamente o auto-empréstimo.

B) Mensagem `'ATENÇÃO: Saldo Insuficiente...'` — após o débito, a comparação interna detecta inconsistência.

C) Mensagem `'Contas alteradas com sucesso:'`. A conta `1111` executa primeiro `saldo = saldo - 100` (debita R\$ 100), depois `saldo = saldo + 100` (credita R\$ 100). O saldo final é o mesmo, mas a SP exibe sucesso. Resultado: operação sem sentido econômico passa por bem-sucedida e fica registrada na auditoria como transferência legítima. Não é "dinheiro que some" — é "operação inútil registrada como real".

D) Erro de FK auto-referente — o MySQL bloqueia UPDATEs sucessivos na mesma linha dentro de uma transação.

---

## Questão 10

Para a chamada com valor `-500` (Q8), qual conta **ganhou** dinheiro e qual **perdeu**? E por quê?

A) Conta `1111` perdeu R\$ 500; conta `2222` ganhou R\$ 500 — comportamento normal de transferência; valor negativo é apenas convenção contábil interna.

B) Ambas as contas perderam R\$ 500 — a SP não diferencia origem de destino quando o valor é negativo.

C) A conta `1111` (origem) ganhou R\$ 500; a conta `2222` (destino) perdeu R\$ 500. Isso porque os UPDATEs aplicam: `saldo_origem = saldo_origem - (-500) = saldo_origem + 500` e `saldo_destino = saldo_destino + (-500) = saldo_destino - 500`. A SP usa o sinal aritmético do parâmetro literalmente, sem validar se ele é positivo. O fluxo do dinheiro fica invertido — a conta que deveria pagar recebe, e a que deveria receber paga.

D) Conta `2222` ganhou R\$ 500; conta `1111` perdeu R\$ 500 — o MySQL inverte automaticamente o sinal em SPs financeiras como medida de segurança.

---

## Questão 11

Para cada expressão abaixo, qual é o retorno do MySQL? (Convenção: `1` = TRUE, `0` = FALSE, `NULL` = UNKNOWN.)

```sql
SELECT 5 >= 100;
SELECT NULL >= 100;
SELECT NULL = NULL;
SELECT NULL IS NULL;
SELECT (NULL >= 100) IS NULL;
```

A) Todas retornam `0` (FALSE), pois nenhuma das comparações é verdadeira no sentido aritmético padrão.

B) Todas retornam `NULL` (UNKNOWN), pois qualquer comparação envolvendo `NULL` é UNKNOWN, sem exceção.

C) `5 >= 100` → `0` (FALSE); `NULL >= 100` → `NULL` (UNKNOWN); `NULL = NULL` → `NULL` (UNKNOWN); `NULL IS NULL` → `1` (TRUE); `(NULL >= 100) IS NULL` → `1` (TRUE — confirma que a expressão `NULL >= 100` é UNKNOWN). Esse exercício mostra que o SQL implementa lógica de 3 valores (TRUE, FALSE, UNKNOWN), e que o operador `IS NULL` é a única forma confiável de testar nulidade.

D) `5 >= 100` → `1`; `NULL >= 100` → `0`; `NULL = NULL` → `1`; `NULL IS NULL` → `1`; `(NULL >= 100) IS NULL` → `0` — comportamento padrão de comparação em álgebra booleana clássica.

---

## Questão 12

Por que `SELECT NULL = NULL;` retorna `NULL` (UNKNOWN) em vez de `TRUE` (`1`) no MySQL?

A) Porque o MySQL trata `NULL` como uma string vazia (`''`) em comparações de igualdade, e duas strings vazias podem diferir em codificação interna.

B) Porque `NULL` significa "valor desconhecido" — não é um valor concreto, é "ausência de informação". Comparar dois valores desconhecidos resulta em "não sabemos se são iguais" — daí o UNKNOWN. Conceitualmente: se você sabe que João tem alguma idade desconhecida e Maria também tem alguma idade desconhecida, você não pode afirmar "João e Maria têm a mesma idade" — pode ser que sim, pode ser que não. Logo, a comparação correta é UNKNOWN.

C) Porque `NULL` é uma constante reservada do MySQL que sempre retorna `NULL` em qualquer expressão, por questões de performance interna do otimizador.

D) Porque o operador `=` foi sobrescrito no MySQL 8 para retornar `NULL` quando ambos os lados são `NULL`, evitando comportamento ambíguo em joins.

---

## Questão 13

Em SQL, qual operador deve-se usar para verificar se um valor é `NULL`? E por que `WHERE coluna = NULL` **não** funciona como o esperado?

A) Use `WHERE coluna == NULL` — `==` é o operador de comparação estrita do MySQL para nulos, equivalente ao do JavaScript.

B) Use `WHERE NULL(coluna)` — função built-in do MySQL que retorna TRUE se a coluna é nula.

C) Use `IS NULL` (e `IS NOT NULL` para o oposto). `WHERE coluna = NULL` retorna sempre UNKNOWN, e em `WHERE`, UNKNOWN é tratado como FALSE — então nenhuma linha é retornada, mesmo as que de fato têm `NULL` na coluna. Isso confunde iniciantes que esperam `=` funcionar de forma análoga aos demais valores. O operador `IS NULL` foi criado justamente para escapar da lógica de 3 valores e retornar TRUE/FALSE concretamente.

D) Use `WHERE coluna != NOT_NULL` — sintaxe alternativa do MySQL 8 que inverte o comportamento e retorna apenas linhas nulas.

---

## Questão 14

Para corrigir os 3 modos de falha identificados (origem inexistente, destino inexistente, valor zero/negativo), quais validações a v2 da `sp_transf_bancaria` precisa implementar?

A) Adicionar tratamento de erro com `BEGIN ... EXCEPTION ... END` no estilo PostgreSQL/Oracle e migrar a SP para essa estrutura.

B) Adicionar `LOCK TABLES Conta WRITE` antes da transação para evitar concorrência e descartar o handler genérico de SQLEXCEPTION.

C) Três correções aplicadas em uma única validação combinada no `IF` de nível 1: (1) Para origem inexistente: capturar `@conta_origem = (SELECT NroConta FROM Conta WHERE NroConta = v_origem)` e validar `IS NOT NULL` antes da transação. (2) Para destino inexistente: capturar `@conta_destino` analogamente e validar `IS NOT NULL`. (3) Para valor zero ou negativo: adicionar `AND v_valor > 0` à mesma validação. As três correções juntas substituem o `IF` da v1.

D) Substituir o `CONTINUE HANDLER FOR SQLEXCEPTION` por um `EXIT HANDLER` que aborta a SP imediatamente sem `ROLLBACK` — qualquer erro deixa de ser silencioso e força o usuário a investigar.

---

## Questão 15

Qual pseudocódigo abaixo representa **corretamente** a validação combinada que a v2 deve usar para cobrir os 3 cenários de falha em uma única estrutura `IF`?

A) `IF v_origem != NULL AND v_destino != NULL THEN ... ELSE ...` — basta substituir `IS NOT NULL` por `!= NULL` para ganhar legibilidade e evitar a confusão de UNKNOWN.

B) `IF v_valor > 0 AND EXISTS (SELECT 1 FROM Conta WHERE NroConta IN (v_origem, v_destino)) THEN ... ELSE ...` — usar `EXISTS` é a forma SQL canônica de testar presença de linhas.

C) 
```sql
SET @conta_origem  = (SELECT NroConta FROM Conta WHERE NroConta = v_origem);
SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = v_destino);

IF @conta_origem IS NOT NULL
   AND @conta_destino IS NOT NULL
   AND v_valor > 0
THEN
   -- prossegue com validação de saldo e transação
ELSE
   SELECT 'Parâmetros inadequados, transação cancelada!!!' AS RESULTADO;
END IF;
```
Essa única validação substitui o `IF v_origem IS NOT NULL AND v_destino IS NOT NULL` da v1 e cobre todos os 3 problemas. O truque está em capturar `NroConta` em vez de assumir que `v_origem`/`v_destino` representam contas válidas: se a conta não existe, o `SELECT` retorna 0 linhas, `@conta_*` recebe `NULL`, e o `IS NOT NULL` filtra corretamente.

D) `IF v_valor BETWEEN 1 AND 999999 THEN ... ELSE ...` — limita o valor a um intervalo razoável e rejeita `NULL`s implicitamente em uma única expressão concisa.
