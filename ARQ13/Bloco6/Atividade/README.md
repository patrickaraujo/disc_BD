# Atividade 6 — Validação Robusta

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 6  
> Origem: conversão da Atividade 6 (questões 58 a 68) em itens de múltipla escolha.

> **Estado de partida (saldos restaurados ao estado do Bloco 2):**  
> `1111` = R\$ 10.000  ·  `2222` = R\$ 0  ·  `5555` = R\$ 10.000  ·  `6666` = R\$ 1.000  
> Soma total = R\$ 21.000

---

## Questão 1

Considere o **teste #1** do roteiro (cenário positivo, com os saldos no estado de partida acima):

```sql
CALL sp_transf_bancaria02(1111, 2222, 7000);
```

Qual mensagem é retornada e a soma total dos saldos é preservada?

A) Mensagem `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — a v2 herda o bug da v1 e culpa o saldo erroneamente. Soma total: preservada.

B) Mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'` — a v2 rejeita transferências acima de R\$ 5.000 por segurança. Soma total: preservada.

C) **Mensagem `'Contas alteradas com sucesso:'` + 3 colunas (`NOVO SALDO ORIGEM = 3000`, `NOVO SALDO DESTINO = 7000`). A conta `1111` tem saldo `10000 >= 7000`, então passa pela validação combinada (parâmetros válidos) e pela validação de saldo. Soma total: **preservada** (transferência interna entre duas contas existentes — R\$ 21.000 antes e depois).** ✅

D) Mensagem `'Erro na transação...'` — a v2 detecta automaticamente que valores acima de R\$ 5.000 violam regras de segurança e dispara `ROLLBACK`. Soma total: preservada.

---

## Questão 2

Considere os **5 testes de falha** aplicados à `sp_transf_bancaria02`:

| Teste | Chamada | Cenário |
|-------|---------|---------|
| #2 | `(9999, 2222, 100)` | origem inexistente |
| #3 | `(1111, 9999, 100)` | destino inexistente |
| #4 | `(1111, 2222, -500)` | valor negativo |
| #5 | `(1111, 2222, 0)` | valor zero |
| #6 | `(1111, NULL, 2000)` | destino `NULL` |

Qual mensagem é retornada para cada um deles, e qual é o estado dos saldos após cada um?

A) Cada teste retorna uma mensagem específica para a sua falha: `'Conta origem inexistente'`, `'Conta destino inexistente'`, `'Valor negativo inválido'`, `'Valor zero inválido'`, `'Parâmetro NULL'`.

B) **Todos retornam a **mesma mensagem**: `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`. A v2 implementa uma **única validação combinada** no IF de nível 1: `@conta_origem IS NOT NULL AND @conta_destino IS NOT NULL AND v_valor > 0`. Qualquer um dos 5 cenários viola pelo menos uma das três condições e cai no mesmo `ELSE`. Em todos os 5, a soma total é preservada (R\$ 21.000), pois nenhum `UPDATE` é executado.** ✅

C) Os testes #2 e #3 retornam `'Conta inexistente'`; os testes #4 e #5 retornam `'Valor inválido'`; o #6 retorna `'NULL não permitido'`. A v2 distribui as validações em 3 `IF`s sequenciais.

D) Apenas os testes #2, #3 e #6 retornam erro; os testes #4 e #5 retornam sucesso, pois os UPDATEs com valor zero ou negativo passam pelo handler sem disparar exceção.

---

## Questão 3

A v2 retorna a **mesma mensagem** (`'Parâmetros inadequados, transação cancelada!!!'`) para os 5 cenários de falha distintos. Qual é a análise correta dos trade-offs dessa decisão?

A) É um defeito puro — não há vantagem em retornar a mesma mensagem para cenários distintos; o usuário sempre prefere mensagens específicas.

B) **Vantagem: simplicidade do código (uma só validação combinada). Desvantagem: o usuário **não sabe qual** dos parâmetros está errado — precisa adivinhar entre origem inexistente, destino inexistente, valor zero/negativo ou destino `NULL`. Em sistemas críticos (financeiros, médicos), mensagens específicas costumam ser preferíveis para guiar a correção, ao custo de mais código de validação. A escolha depende do contexto.** ✅

C) É uma vantagem pura — a mesma mensagem garante que atacantes não consigam mapear quais contas existem por análise diferencial das respostas. É boa prática de segurança em **todos** os contextos.

D) É indiferente — usuários finais raramente leem mensagens de erro, então o nível de detalhe não importa em UX.

---

## Questão 4

Considere a chamada catastrófica do Bloco 5, executada primeiro com v1 e depois com v2 (com saldos restaurados entre as chamadas, conta `1111` com saldo R\$ 5.000):

```sql
CALL sp_transf_bancaria(1111, 9999, 100);    -- v1
CALL sp_transf_bancaria02(1111, 9999, 100);  -- v2
```

Qual é o impacto comparado de cada versão?

A) Ambas apresentam o mesmo comportamento: saldo de `1111` cai para R\$ 4.900 e soma total diminui em R\$ 100. A v2 não corrige o bug.

B) **A v1 debita R\$ 100 da conta `1111` (saldo final: R\$ 4.900) e a soma total diminui em R\$ 100 — DINHEIRO SUMIU. A v2, ao contrário, captura `@conta_destino = NULL` (porque `9999` não existe), a validação combinada falha, retorna `'Parâmetros inadequados...'`, **nenhum UPDATE é executado**, saldo de `1111` permanece em R\$ 5.000 e a soma total é preservada. **Conservação do dinheiro garantida.**** ✅

C) A v1 debita R\$ 100 da conta `1111`, mas a v2 cria uma conta-fantasma `9999` com saldo R\$ 100 — ambas preservam a soma total via mecanismos diferentes.

D) A v2 também sofre do mesmo bug, mas em menor intensidade: debita apenas R\$ 50 da conta `1111` (metade do valor), evitando perda total mas ainda violando a conservação.

---

## Questão 5

Considere o comando abaixo, executado em uma sessão MySQL:

```sql
SELECT NroConta FROM Conta WHERE NroConta = NULL;
```

Quantas linhas retornam, e por quê?

A) Retorna todas as linhas onde `NroConta IS NULL` — o operador `=` é tratado como `IS` quando o operando é a constante `NULL`.

B) **Retorna **0 linhas**. `WHERE NroConta = NULL` produz UNKNOWN para qualquer linha (mesmo que `NroConta` seja `NULL`), e em `WHERE`, UNKNOWN é tratado como FALSE — então nenhuma linha casa. Esse é o comportamento da lógica de 3 valores em SQL: comparações com `NULL` via `=` nunca retornam TRUE.** ✅

C) Retorna erro de sintaxe — o MySQL exige uso explícito de `IS NULL` em qualquer comparação envolvendo nulos.

D) Retorna todas as linhas da tabela — `= NULL` é interpretado como "qualquer valor", funcionando como um curinga universal.

---

## Questão 6

Agora considere:

```sql
SELECT NroConta FROM Conta WHERE NroConta IS NULL;
```

Quantas linhas retornam? Há diferença prática entre `= NULL` e `IS NULL`?

A) Retorna o mesmo número de linhas que `WHERE NroConta = NULL` (0 linhas) — `IS NULL` é apenas sintaxe equivalente a `= NULL`.

B) **Retorna **0 linhas** neste caso específico, porque a coluna `NroConta` foi declarada como `NOT NULL` na criação de `Conta`, então **nenhuma linha** tem valor `NULL` lá. Mas a diferença prática é fundamental: em uma coluna que **aceitasse** `NULL`, `IS NULL` retornaria as linhas com `NULL`, enquanto `= NULL` continuaria retornando 0. `IS NULL` é a única forma confiável de testar nulidade no SQL.** ✅

C) Retorna 1 linha (a "linha-NULL" que o MySQL mantém internamente como sentinela de tabela vazia).

D) Retorna erro — `IS NULL` só é válido para colunas declaradas explicitamente como `NULL DEFAULT NULL`.

---

## Questão 7

Considere a atribuição abaixo, executada quando `v_destino` chega como `NULL`:

```sql
SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = NULL);
```

Por que `@conta_destino` recebe `NULL`, e como esse comportamento é aproveitado pela v2 para tratar parâmetros nulos sem precisar de validação separada?

A) O resultado é erro de sintaxe — o MySQL bloqueia comparações com `NULL` em `SELECT` que alimenta variáveis de sessão. A v2 deve usar `IS NULL` explicitamente.

B) O resultado é UNKNOWN — a variável recebe um valor especial UNKNOWN. A v2 usa `COALESCE` para converter UNKNOWN em FALSE antes da validação.

C) **Quando `v_destino` chega como `NULL`, o `SELECT` recebe `WHERE NroConta = NULL`, que é UNKNOWN para todas as linhas → 0 linhas retornadas → atribuição em variável de sessão recebe `NULL` (em vez de erro). A validação `@conta_destino IS NOT NULL` então captura **simultaneamente** dois casos distintos: (a) parâmetro era `NULL`; e (b) parâmetro era um valor que não existe na tabela. **Uma única condição cobre dois problemas** — elegante e sem código duplicado. Esse é o "truque" central da v2.** ✅

D) O resultado é `0` (zero) — variáveis de sessão recém-atribuídas com `SELECT` vazio recebem `0` por padrão. A v2 usa `@conta_destino > 0` para validar.

---

## Questão 8

Por que a v2 captura `@conta_origem` e `@conta_destino` (com `SELECT NroConta`) em vez de só capturar `@saldo_origem` e `@saldo_destino` e checar `IS NOT NULL`?

A) Porque o MySQL bloqueia atribuição de variáveis de sessão com colunas `FLOAT` — apenas tipos inteiros podem ser usados em variáveis prefixadas com `@`.

B) **Porque o saldo pode ser **zero legítimo** (uma conta recém-criada, por exemplo) — `@saldo_origem = 0` é um valor válido, **não** indica conta inexistente. Pior: se a coluna `saldo` permitisse `NULL` no futuro, `@saldo_origem IS NOT NULL` confundiria "conta com saldo `NULL`" com "conta inexistente". `SELECT NroConta WHERE NroConta = v_origem` é o **teste inequívoco de existência** — só retorna não-`NULL` se a linha realmente existe na tabela.** ✅

C) Por questões de performance: `SELECT NroConta` é mais rápido que `SELECT saldo` porque `NroConta` é a chave primária e tem acesso direto via índice clusterizado.

D) Por convenção pedagógica do professor — não há diferença técnica; ambos os padrões funcionam igualmente bem em sistemas reais.

---

## Questão 9

A v2 não trata explicitamente o caso "origem == destino". Imagine que um cliente faz:

```sql
CALL sp_transf_bancaria02(1111, 1111, 100);
```

Descreva o que acontece — e se isso é problema de integridade.

A) Erro de FK auto-referente — o MySQL bloqueia UPDATEs sucessivos na mesma linha dentro de uma única transação por questão de integridade.

B) **Passos: `@conta_origem = 1111` (existe) → `@conta_destino = 1111` (existe) → `v_valor = 100 > 0` → IF nível 1 passa → IF nível 2 (saldo): `@saldo_origem` capturado, suficiente → `START TRANSACTION` → `UPDATE` debita 100 de `1111` → `UPDATE` credita 100 em `1111` (mesma linha) → saldo final inalterado → `COMMIT` → mensagem de sucesso. **Não é problema de integridade** (saldo correto, conservação preservada). Mas é **operação inútil** — gasta recurso do banco e gera registro de auditoria sem motivo. Em uma SP idealmente robusta, deveria ser bloqueada com mensagem específica.** ✅

C) A v2 retorna `'Parâmetros inadequados...'` — a validação combinada inclui implicitamente o teste `v_origem != v_destino` por consistência semântica.

D) O segundo `UPDATE` falha por deadlock interno — o MySQL detecta que a mesma linha está sendo modificada duas vezes em uma única transação e dispara `ROLLBACK` automático.

---

## Questão 10

Em produção, depois de validar a v2, é comum apagar a v1 com `DROP PROCEDURE sp_transf_bancaria;`. **Antes** de fazer esse drop, qual conjunto de verificações operacionais é mais apropriado?

A) Nenhuma verificação é necessária — após a criação da v2, a v1 fica obsoleta automaticamente, e o servidor MySQL redireciona chamadas para a v2 transparentemente.

B) Apenas executar `SHOW PROCEDURE STATUS` para confirmar que a v1 ainda existe; o `DROP` em si é seguro e não tem efeitos colaterais sobre dados.

C) **Conjunto de 4 verificações: (1) procurar referências em **código de aplicação** (`grep "sp_transf_bancaria"` no codebase, excluindo a v2); (2) examinar **logs do banco** para identificar se há `CALL sp_transf_bancaria` recente (de jobs agendados, scripts manuais, integrações externas); (3) verificar **permissões `EXECUTE`** concedidas para a v1 — esses usuários precisam ser realocados para a v2; (4) comunicar a equipe e fazer **deprecation period** (algumas semanas mostrando aviso antes de apagar), permitindo rollback caso surja problema imprevisto.** ✅

D) Apenas verificar se a v1 e a v2 produzem o mesmo resultado para os 6 testes do roteiro; se sim, é seguro apagar a v1 imediatamente em qualquer ambiente.

---

## Questão 11

Suponha que se queira adicionar **mensagens específicas** para cada tipo de falha (`'Conta origem inexistente'`, `'Conta destino inexistente'`, `'Valor inválido'`). Qual estrutura `IF`/`ELSEIF`/`ELSE` é mais adequada?

A) Uma cadeia de `IF`s **independentes**, cada um retornando uma mensagem diferente — todos executados em sequência, mesmo se uma validação anterior falhar.

B) Um único `IF` com `OR` lógico em todas as condições, retornando a mesma mensagem genérica — exatamente o que a v2 atual faz, sem necessidade de mudança.

C) **Cadeia ordenada com `ELSEIF`/`ELSE`:
```sql
IF @conta_origem IS NULL THEN
   SELECT 'Conta origem inexistente' AS RESULTADO;
ELSEIF @conta_destino IS NULL THEN
   SELECT 'Conta destino inexistente' AS RESULTADO;
ELSEIF v_valor IS NULL OR v_valor <= 0 THEN
   SELECT 'Valor inválido' AS RESULTADO;
ELSE
   -- prossegue com validação de saldo e transação
   IF @saldo_origem >= v_valor THEN ... ELSE ... END IF;
END IF;
```
A ordem das cláusulas importa: a primeira condição verdadeira "captura" o erro, e as subsequentes são ignoradas. Bom design: testar o defeito mais grave (ou mais provável) primeiro.** ✅

D) Um `CASE WHEN` aninhado dentro do bloco `BEGIN ... END`, listando todas as condições com `WHEN ... THEN`; mais legível que `IF`/`ELSEIF`.

---

## Questão 12

Sobre a decisão da v2 de usar a **mesma mensagem** para todos os erros de validação, qual análise é mais correta?

A) Concordância plena — usar a mesma mensagem é a única abordagem profissional aceita; mensagens específicas são amadorismo.

B) **Análise discutível: **prós:** código simples (uma só validação combinada), facilidade de manutenção, e proteção contra mapeamento de contas existentes por análise diferencial. **Contras:** o usuário não sabe o que corrigir — precisa adivinhar entre vários defeitos possíveis. Em sistemas reais críticos, mensagens específicas costumam ser preferíveis (ver Q11), ao custo de mais código de validação. A escolha depende do contexto.** ✅

C) Discordância plena — em qualquer sistema profissional, sempre é preferível mensagens específicas, pois o ganho em UX supera o custo de código adicional em todos os cenários conhecidos.

D) A questão é apenas de estilo; tecnicamente, ambas as abordagens são equivalentes e produzem os mesmos efeitos colaterais.

---

## Questão 13

Sobre a decisão de manter a v1 e a v2 **coexistindo** (em vez de substituir uma pela outra imediatamente), qual análise é mais apropriada?

A) Discordância — manter duas versões de SP é prática ruim; gera confusão entre desenvolvedores e poluição no schema.

B) **Concordância — a coexistência permite **migração gradual** (aplicações migram da v1 para v2 quando o risco de regressão estiver mitigado), **comparação direta** durante validação, e **rollback rápido** caso a v2 apresente problema imprevisto em produção. Especialmente importante em sistemas críticos onde a transição abrupta é arriscada. Após período de validação, a v1 pode ser removida com segurança (ver Q10).** ✅

C) Concordância apenas em ambientes de desenvolvimento — em produção, sempre é preferível substituir imediatamente para evitar custos de manutenção dupla.

D) A questão não tem trade-off relevante — coexistir ou substituir é decisão puramente arbitrária, sem impacto operacional real.

---

## Questão 14

Sobre a decisão da v2 de **não testar** explicitamente o caso "origem == destino", qual análise é mais correta?

A) Concordância plena — o cenário é raro e não causa erro de integridade; testá-lo seria sobre-engenharia desnecessária.

B) Discordância plena — sem o teste, a v2 está incompleta e não pode ser considerada robusta para produção em hipótese alguma.

C) **Análise discutível: o cenário **não causa erro de integridade** (saldo final correto, conservação preservada), mas é uma **operação inútil** — gasta recursos do banco (locks, escrita, audit log) e gera ruído na trilha de auditoria. Boa prática profissional seria bloquear com mensagem específica (`'Origem e destino iguais'`), embora o impacto técnico imediato seja zero. Em SPs com volume alto de chamadas, vale o teste extra; em SPs de uso esporádico, a omissão é aceitável.** ✅

D) A v2 testa implicitamente o caso via `@conta_origem != @conta_destino` no IF de nível 1; a questão é redundante.

---

## Questão 15

Sobre a decisão de manter o `CONTINUE HANDLER FOR SQLEXCEPTION` na v2 mesmo com validações robustas no IF, qual análise é mais apropriada?

A) Discordância — com validações robustas (que filtram conta inexistente e valor inválido), o handler torna-se redundante e pode ser removido para simplificar o código.

B) **Concordância — **defesa em profundidade**. Mesmo com validações robustas no IF de nível 1, **erros inesperados** podem ocorrer DURANTE a transação: falha de I/O em disco, deadlock entre transações concorrentes, esgotamento de espaço em log, indisponibilidade temporária da tabela `Conta` em replicação master-slave. O handler permanece relevante para garantir que qualquer falha intra-transação seja capturada e dispare `ROLLBACK`, preservando atomicidade. **Validação preventiva e tratamento reativo são camadas complementares, não substitutas.**** ✅

C) Concordância apenas em ambientes com replicação ativa — em servidores standalone, o handler nunca dispara após validações robustas e pode ser omitido sem prejuízo.

D) Discordância — o `CONTINUE HANDLER` é incompatível com `IF`/`ELSE` aninhado e deve ser substituído por `EXIT HANDLER` em SPs com validação de parâmetros.
