# Atividade 6 — Integração SP + Trigger

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ12 — Bloco 6  
> Origem: conversão da Atividade 6 (questões 51 a 60) em itens de múltipla escolha.

> **Contexto compartilhado por várias questões.** O roteiro do Bloco 6 instrui o aluno a executar, na ordem, as três chamadas a seguir, depois das quais várias verificações são feitas:
>
> ```sql
> CALL sp_altera_livros(9786525223742, 44.44); -- #1
> CALL sp_altera_livros(8888888888888, 10.99); -- #2
> CALL sp_altera_livros(7777777777777, NULL);  -- #3
> ```

---

## Questão 1

Após executar as três chamadas obrigatórias do roteiro (#1, #2 e #3 acima), o aluno executa:

```sql
SELECT * FROM LIVROS;
```

Qual é o estado da tabela?

A) Os 4 ISBNs aparecem com seus preços originais do Bloco 3 inalterados, pois a Trigger `Audita_Livros` impede que `UPDATE`s alterem efetivamente os dados de `LIVROS`.

B) Os 4 ISBNs aparecem: `9786525223742` com `Precolivro = 44{,}44` (alterado pela #1); `8888888888888` com `Precolivro = 10{,}99` (alterado pela #2); `9999999999999` com `Precolivro = 34{,}50` (inalterado, não foi tocado por nenhuma chamada); e `7777777777777` com `Precolivro = 29{,}90` (inalterado — a chamada #3 falhou e foi desfeita pelo `ROLLBACK` interno da SP).

C) Apenas 2 ISBNs aparecem (`9786525223742` e `8888888888888`), pois as chamadas que falharam removem o registro original da tabela como medida de integridade.

D) 4 ISBNs com todos os preços convertidos para `NULL`, indicando que o erro da chamada #3 contaminou as anteriores e disparou um `ROLLBACK` em cadeia.

---

## Questão 2

Imediatamente após as três chamadas do roteiro, executa-se:

```sql
SELECT * FROM tab_audit;
```

Quantas linhas aparecem e qual é o conteúdo delas?

A) 3 linhas — uma para cada chamada, incluindo a chamada #3 (com `NULL`), que registra a tentativa mesmo tendo falhado.

B) 0 linhas — Triggers `AFTER UPDATE` não disparam dentro de transações iniciadas por SP.

C) 2 linhas. A primeira com `codigo_Produto = 9786525223742`, `preco_unitario_antigo = 74{,}9000` e `preco_unitario_novo = 44{,}4400`. A segunda com `codigo_Produto = 8888888888888`, `preco_unitario_antigo = 55{,}9000` e `preco_unitario_novo = 10{,}9900`. Apenas as duas chamadas bem-sucedidas deixaram rastro de auditoria; a chamada #3 falhou e foi descartada pelo `ROLLBACK`, junto com qualquer tentativa de auditoria.

D) 4 linhas — uma para cada livro existente em `LIVROS`, capturando o estado de cada um após as chamadas, mesmo os não alterados.

---

## Questão 3

Após as três chamadas do roteiro, o aluno executa uma **quarta chamada** com o mesmo ISBN da chamada #1, mas com um preço diferente:

```sql
CALL sp_altera_livros(9786525223742, 50.00);
SELECT * FROM tab_audit;
```

Qual é o novo conteúdo de `tab_audit`?

A) 3 linhas; a nova linha apresenta `preco_unitario_antigo = 74{,}9000`, repetindo o preço original do Bloco 3, pois a auditoria sempre rastreia o valor mais antigo já registrado para o livro.

B) 3 linhas; a nova linha apresenta `codigo_Produto = 9786525223742`, `preco_unitario_antigo = 44{,}4400` (o preço imediatamente anterior, definido pela chamada #1) e `preco_unitario_novo = 50{,}0000`. A Trigger captura o estado antes desta nova alteração, não o estado original — cada linha de `tab_audit` reflete o passo daquela alteração específica, não a história completa.

C) 2 linhas — a nova chamada sobrescreve o registro anterior do mesmo ISBN, mantendo apenas o estado mais recente para evitar redundância.

D) Erro de chave duplicada — `tab_audit` impede registros redundantes para o mesmo `codigo_Produto` em datas próximas.

---

## Questão 4

A Trigger `Audita_Livros` é disparada **dentro** ou **fora** da transação aberta pela SP `sp_altera_livros`?

A) Dentro. A Trigger é disparada pelo `UPDATE`, que está dentro do `START TRANSACTION` da SP. Logo, o `INSERT INTO tab_audit` executado pela Trigger faz parte da mesma transação. Se houver `ROLLBACK` na SP, o `INSERT` da Trigger também é desfeito automaticamente — atomicidade preservada.

B) Fora. Triggers MySQL sempre executam em uma transação implícita separada e autocommitada, para garantir que o registro de auditoria seja persistido mesmo quando a transação principal falhar.

C) Depende do tipo da Trigger: `BEFORE` executa fora da transação (autocommit), `AFTER` executa dentro.

D) Depende do isolamento da sessão: em `READ COMMITTED` a Trigger executa fora da transação, em `REPEATABLE READ` executa dentro.

---

## Questão 5

Por que a chamada #3 (`CALL sp_altera_livros(7777777777777, NULL);`) **não** deixou rastro em `tab_audit`? Existem **duas razões** — uma referente à Trigger e outra referente à SP. Qual alternativa cita ambas corretamente?

A) Apenas uma razão: a Trigger possui uma cláusula implícita `WHERE NEW.PRECOLIVRO IS NOT NULL` que filtra valores nulos antes do `INSERT` em `tab_audit`.

B) Duas razões cooperam: (1) Razão da Trigger — ela é `AFTER UPDATE`; como o `UPDATE` falha (NULL viola `NOT NULL`), nenhuma linha é modificada e a Trigger não é executada para nenhuma linha. (2) Razão da SP — mesmo se a Trigger tivesse executado e gravado em `tab_audit`, o `IF erro_sql = TRUE THEN ROLLBACK` desfaria essa gravação. Os dois mecanismos cooperam para garantir que falha não deixe rastro.

C) Apenas uma razão: o `CONTINUE HANDLER FOR SQLEXCEPTION` da SP captura o erro antes mesmo do `UPDATE` ser tentado, abortando toda a SP imediatamente.

D) Nenhuma das duas — `tab_audit` registra sim a chamada falha, mas com `preco_unitario_novo = NULL`, justamente para indicar a tentativa frustrada.

---

## Questão 6

Suponha que, em vez de `AFTER UPDATE`, a Trigger fosse `BEFORE UPDATE`. Como mudaria o comportamento das chamadas #1 (válida) e #3 (com `NULL`)?

A) Para ambas as chamadas, a Trigger não dispararia, pois `BEFORE` impede o acesso a `OLD.coluna`.

B) Apenas a chamada #1 mudaria: a Trigger `BEFORE` reverteria o `UPDATE` da chamada bem-sucedida.

C) Apenas a chamada #3 mudaria: a Trigger `BEFORE` deixaria rastro em `tab_audit` mesmo com `NULL`.

D) A Trigger executaria ANTES da modificação. Para a chamada #1 (válida), o comportamento final seria similar — a auditoria seria registrada antes do `UPDATE` ser confirmado, mas dentro da mesma transação. Para a chamada #3 (`NULL`), a Trigger executaria, mas o `UPDATE` falharia depois — ainda assim, o `ROLLBACK` da SP descartaria a gravação na auditoria. Conclusão: o resultado final visível seria o mesmo, mas com `BEFORE` a Trigger executaria sem necessidade — desperdício.

---

## Questão 7

Por que a mensagem de sucesso da `sp_altera_livros` retorna **3 colunas** (`RESULTADO`, `ISBN` e `'PREÇO NOVO'`), enquanto `sp_insere_livros` (Bloco 3) retorna apenas **1 coluna** (`RESULTADO`)?

A) Porque o MySQL exige que SPs com `UPDATE` retornem ao menos 3 colunas no `SELECT` final; SPs com `INSERT` podem retornar apenas 1.

B) Porque `sp_altera_livros` foi escrita por outro autor com estilo diferente — não há razão técnica que justifique a divergência.

C) Porque um `UPDATE` é uma operação destrutiva (sobrescreve um valor anterior); retornar o ISBN e o novo preço dá ao usuário evidência imediata e confiável de que o valor certo foi atualizado. Já um `INSERT` é uma operação construtiva — uma simples mensagem de sucesso é suficiente, pois não há valor anterior a confundir com o atual.

D) Porque a Trigger `Audita_Livros` exige que a SP retorne pelo menos 3 colunas para que ela seja disparada corretamente.

---

## Questão 8

Suponha que, em vez de chamar a SP, um usuário execute o comando direto:

```sql
UPDATE LIVROS SET Precolivro = 99.99 WHERE ISBN = 9786525223742;
```

A Trigger `Audita_Livros` dispararia? Por quê?

A) Não. A Trigger só dispara quando o `UPDATE` é executado pela SP `sp_altera_livros`, pois ela está vinculada à SP por contrato interno do MySQL.

B) Sim. A Trigger está vinculada à TABELA `LIVROS`, não à SP. Qualquer `UPDATE` em `LIVROS` — seja por SP, por usuário direto no Workbench ou por uma aplicação cliente externa — dispara `Audita_Livros`. Esse é justamente o ponto da Trigger: rastrear toda alteração, independentemente de quem a fez.

C) Sim, mas apenas se a sessão estiver com `autocommit = 0`; caso contrário, a Trigger é ignorada silenciosamente.

D) Não. Triggers `AFTER UPDATE` exigem que o `UPDATE` esteja dentro de um `START TRANSACTION` explícito para serem ativadas.

---

## Questão 9

Suponha que alguém tenha executado `DROP TABLE tab_audit;` antes de o aluno chamar `CALL sp_altera_livros(9786525223742, 60.00);`. Considerando que a Trigger `Audita_Livros` ainda existe e tenta inserir em `tab_audit`, o que acontece com o `UPDATE` em `LIVROS`?

A) O `UPDATE` é confirmado normalmente — a falha da Trigger é silenciosa e não afeta a transação principal da SP.

B) O MySQL detecta a inconsistência antes mesmo de iniciar a SP e aborta a chamada com erro, sem tocar em `LIVROS`.

C) O `INSERT INTO tab_audit` dentro da Trigger falha (porque a tabela não existe). Esse erro é capturado pelo `CONTINUE HANDLER FOR SQLEXCEPTION` da SP, que vira `erro_sql = TRUE` e segue para o `ROLLBACK`. Resultado: o `UPDATE` em `LIVROS` é desfeito. Conclusão importante: se a auditoria não pode ser registrada, a alteração não acontece — comportamento desejado em sistema crítico.

D) O `UPDATE` em `LIVROS` é confirmado, mas a Trigger gera um erro persistente no log do servidor que precisa ser tratado manualmente reiniciando o serviço MySQL.

---

## Questão 10

Comparando `sp_insere_livros` (Bloco 3) e `sp_altera_livros` (Bloco 6), qual é a diferença na **operação DML principal** de cada uma?

A) Ambas usam `INSERT` — a diferença está apenas no nome da SP e nos parâmetros recebidos.

B) Ambas usam `UPDATE` — a diferença está nos parâmetros recebidos e na mensagem retornada.

C) `sp_insere_livros` usa `INSERT INTO LIVROS (...) VALUES (...)`, executando uma operação construtiva (cria uma nova linha na tabela). `sp_altera_livros` usa `UPDATE LIVROS SET Precolivro = v_PRECOLIVRO WHERE ISBN = v_ISBN`, executando uma operação destrutiva (sobrescreve um valor existente em uma linha já presente).

D) `sp_insere_livros` usa o comando `MERGE`, enquanto `sp_altera_livros` usa `REPLACE`.

---

## Questão 11

Quantos parâmetros cada uma das SPs recebe, e por quê?

A) Ambas recebem 4 parâmetros (`v_ISBN`, `v_AUTOR`, `v_NOMELIVRO`, `v_PRECOLIVRO`), pois sempre é necessário fornecer todos os atributos do livro.

B) `sp_insere_livros` recebe 4 parâmetros — um para cada coluna de `LIVROS` (`v_ISBN`, `v_AUTOR`, `v_NOMELIVRO`, `v_PRECOLIVRO`) — porque um `INSERT` precisa dos valores de todos os atributos `NOT NULL`. `sp_altera_livros` recebe apenas 2 parâmetros (`v_ISBN` para identificar o livro e `v_PRECOLIVRO` para o novo preço), pois apenas o preço é alterado e os demais atributos permanecem inalterados.

C) `sp_insere_livros` recebe 2 e `sp_altera_livros` recebe 4 — exatamente o oposto, pois é o `UPDATE` que precisa de mais dados.

D) Ambas recebem 3 parâmetros, com a diferença apenas no tipo declarado para `Precolivro`.

---

## Questão 12

Qual das SPs tem **Trigger associada**, e qual é o motivo dessa associação?

A) Ambas têm `Audita_Livros` associada — toda alteração em `LIVROS` é auditada, independentemente de a operação ser `INSERT` ou `UPDATE`.

B) Nenhuma das duas tem Trigger associada — auditoria nesta aula é feita apenas por consultas externas a `tab_audit`.

C) Apenas `sp_insere_livros` tem Trigger associada (`Audita_Livros AFTER INSERT`) — auditar inserção é a prática mais comum em sistemas comerciais.

D) Apenas `sp_altera_livros` tem Trigger associada — `Audita_Livros` é definida como `AFTER UPDATE ON LIVROS`. `sp_insere_livros` não dispara nenhuma Trigger porque a Trigger criada no Bloco 5 atende apenas eventos de `UPDATE`, não de `INSERT`.

---

## Questão 13

Qual é a estrutura da **mensagem de sucesso** retornada por cada SP?

A) Ambas retornam 1 coluna (`RESULTADO`) com a mensagem padrão `'Transação efetivada com sucesso!!!'`.

B) `sp_insere_livros` retorna 1 coluna (`RESULTADO` com o texto `'Transação efetivada com sucesso!!!'`). `sp_altera_livros` retorna 3 colunas: `RESULTADO` com o texto `'Preço do Livro alterado com sucesso:'`, `ISBN` com o ISBN do livro alterado, e `'PREÇO NOVO'` com o novo preço — obtidos a partir de um `SELECT ... FROM LIVROS WHERE ISBN = v_ISBN`.

C) Ambas retornam 3 colunas com a mesma estrutura: `RESULTADO`, `ISBN` e `'PREÇO NOVO'`.

D) `sp_insere_livros` retorna 3 colunas e `sp_altera_livros` retorna 1 — pois um `INSERT` precisa exibir todos os atributos do registro recém-criado para confirmação.

---

## Questão 14

Quais tabelas são afetadas (direta ou indiretamente) por cada SP?

A) Ambas afetam apenas `LIVROS` diretamente; nenhuma tem efeito indireto, pois Triggers não modificam outras tabelas.

B) `sp_insere_livros` afeta apenas `LIVROS` diretamente — não há efeito indireto, pois nenhuma Trigger está associada ao evento `INSERT ON LIVROS`. `sp_altera_livros` afeta `LIVROS` diretamente (via `UPDATE`) e `tab_audit` indiretamente (via Trigger `Audita_Livros`, que insere uma linha de auditoria a cada `UPDATE` bem-sucedido).

C) Ambas afetam `LIVROS` e `tab_audit` — toda SP transacional do banco deve, por contrato, registrar uma linha de auditoria.

D) `sp_insere_livros` afeta `LIVROS` e `Produtos`; `sp_altera_livros` afeta `LIVROS` e `ItemPedido` — pois cada SP do bloco está conectada às tabelas do Bloco 4.
