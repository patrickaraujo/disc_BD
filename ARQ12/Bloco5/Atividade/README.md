# Atividade 5 — Auditoria + Trigger AFTER UPDATE

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ12 — Bloco 5  
> Origem: conversão da Atividade 5 (questões 40 a 50) em itens de múltipla escolha.

---

## Questão 1

Após executar o comando abaixo no MySQL Workbench:

```sql
SHOW TRIGGERS;
```

Quais colunas relevantes aparecem no resultado para que se possa identificar e descrever uma Trigger `AFTER UPDATE`?

A) Apenas `Trigger` e `Statement`, pois são os únicos campos que descrevem o comportamento da Trigger.

B) `Trigger` (nome), `Event` (`UPDATE`/`INSERT`/`DELETE`), `Table` (tabela vigiada) e `Timing` (`AFTER` ou `BEFORE`), além de `Statement` (corpo), `Definer`, `sql_mode`, `character_set_client` e `collation_connection`. ✅

C) Apenas `Name`, `Type` e `Schema` — os mesmos campos retornados por `SHOW PROCEDURE STATUS`.

D) `Trigger`, `Database` e `Lines`, pois o MySQL retorna o número de linhas afetadas pela Trigger no momento da inspeção.

---

## Questão 2

Ao executar o comando abaixo:

```sql
SHOW CREATE TRIGGER Audita_Livros;
```

Quais elementos a saída do MySQL exibe sobre a Trigger?

A) Apenas o corpo `BEGIN ... END`, sem informações sobre o evento monitorado ou o usuário criador.

B) O `DEFINER` (usuário dono — ex.: `'root'@'localhost'`), a cláusula `AFTER UPDATE ON livros FOR EACH ROW` e o bloco `BEGIN ... END` com o corpo reconstituído da Trigger. ✅

C) Apenas as colunas `Trigger` e `sql_mode`, exigindo um segundo `SHOW TRIGGERS` para complementar com o evento monitorado.

D) O plano de execução estimado da Trigger, incluindo custo de processamento por linha afetada.

---

## Questão 3

Imediatamente após criar a Trigger `Audita_Livros` (sem executar nenhum `UPDATE` em `LIVROS`), executa-se:

```sql
SELECT * FROM tab_audit;
```

Qual é o resultado e a explicação para esse valor?

A) **0 linhas.** A Trigger só dispara quando ocorre um `UPDATE` em `LIVROS`. Como nenhum evento de atualização aconteceu desde a criação da Trigger, `tab_audit` permanece vazia. Criar uma Trigger não a executa — apenas a registra. ✅

B) 4 linhas — uma para cada livro existente, pois a Trigger inspeciona o estado inicial de `LIVROS` no momento da criação.

C) 1 linha contendo `CURRENT_USER`, `USER()` e `CURRENT_DATE`, registrando o evento de criação da Trigger como auditoria inicial.

D) Erro de execução — a Trigger não pode coexistir com `tab_audit` vazia, pois isso violaria a integridade referencial entre as tabelas.

---

## Questão 4

Em uma Trigger declarada como `AFTER UPDATE ON LIVROS FOR EACH ROW`, quais pseudo-registros estão disponíveis dentro do corpo `BEGIN ... END`?

A) Apenas `NEW`, pois `AFTER` significa "depois da modificação" e o estado anterior já foi descartado da memória.

B) Apenas `OLD`, pois o `UPDATE` ainda não foi efetivado fisicamente quando a Trigger executa.

C) **Ambos `OLD` e `NEW`** — em um `UPDATE`, há um valor "antes" (acessível por `OLD.coluna`) e um valor "depois" (acessível por `NEW.coluna`) para cada coluna. Os dois pseudo-registros coexistem porque a operação `UPDATE` envolve, naturalmente, um par "antes/depois". ✅

D) Nenhum dos dois — em Triggers `AFTER`, deve-se reler a tabela com um `SELECT` para obter os valores das colunas modificadas.

---

## Questão 5

Em uma Trigger declarada como `BEFORE INSERT ON LIVROS FOR EACH ROW`, quais pseudo-registros estão disponíveis e qual é a justificativa?

A) **Apenas `NEW`** — em um `INSERT`, não existe valor "antes": a linha está sendo criada, portanto `OLD` não faz sentido nem está disponível. `NEW` representa a linha que será inserida e pode inclusive ser modificada antes da gravação. ✅

B) Apenas `OLD`, pois `BEFORE` significa "antes da modificação" e o registro novo só passa a existir após o `INSERT` ser concluído.

C) Ambos `OLD` e `NEW`, mas `OLD` retorna `NULL` em todas as colunas, pois não há linha anterior.

D) Nenhum dos dois — `BEFORE INSERT` não pode acessar dados; serve apenas para validações com `SIGNAL`.

---

## Questão 6

Em uma Trigger declarada como `AFTER DELETE ON LIVROS FOR EACH ROW`, quais pseudo-registros estão disponíveis?

A) Apenas `NEW`, contendo a linha que substituirá a removida.

B) Ambos `OLD` e `NEW`, pois o MySQL preserva uma cópia da linha removida em `NEW` para fins de auditoria.

C) **Apenas `OLD`** — em um `DELETE`, há um valor "antes" (a linha que será removida, acessível por `OLD.coluna`), mas não há "valor depois", pois nenhuma linha substitui a removida. Logo, `NEW` não existe nesse contexto. ✅

D) Nenhum dos dois — em `AFTER DELETE`, a linha já foi removida e nenhum acesso direto aos dados anteriores é possível.

---

## Questão 7

Considere o comando abaixo, aplicado a uma tabela `LIVROS` com 4 livros, e com a Trigger `Audita_Livros` (`AFTER UPDATE` com cabeçalho `FOR EACH ROW BEGIN`) ativa:

```sql
UPDATE LIVROS SET Precolivro = Precolivro * 1.10;
```

Quantas linhas serão inseridas em `tab_audit` por este único comando?

A) 1 linha — o `UPDATE` é uma única instrução SQL, e a Trigger registra a execução do comando inteiro como evento atômico.

B) **4 linhas** — o `UPDATE` afeta as 4 linhas de `LIVROS`; o cabeçalho `FOR EACH ROW` faz a Trigger executar **uma vez por linha afetada**, e cada execução insere 1 linha em `tab_audit`. Total: 4 inserções de auditoria. ✅

C) 0 linhas — Triggers `AFTER UPDATE` ignoram comandos executados sem cláusula `WHERE`, por considerarem a operação "em massa".

D) 16 linhas — a Trigger executa uma vez por coluna alterada (4 colunas × 4 linhas = 16 inserções).

---

## Questão 8

Por que o autor escolheu `DECIMAL(10,4)` para `preco_unitario_novo` e `preco_unitario_antigo` em `tab_audit`, em vez de `FLOAT`?

A) Porque `DECIMAL(10,4)` ocupa menos espaço em disco que `FLOAT`, otimizando o armazenamento da tabela de auditoria.

B) Porque `FLOAT` não aceita valores negativos, e preços de auditoria podem precisar ser ajustados para baixo.

C) Porque o MySQL não permite usar `FLOAT` em Triggers de auditoria, apenas em colunas de tabelas DDL convencionais.

D) **Por precisão** — `FLOAT` é um tipo de ponto flutuante binário (IEEE 754) e sofre arredondamentos de natureza não-decimal (por exemplo, `0{,}1 + 0{,}2 = 0{,}30000000000000004`), enquanto `DECIMAL(10,4)` é ponto fixo e preserva exatamente 4 casas decimais. Em sistemas que registram valores monetários, `DECIMAL` é a escolha correta para evitar erros acumulados de arredondamento. ✅

---

## Questão 9

Qual afirmação descreve corretamente as diferenças entre `CURRENT_USER`, `USER()` e `SESSION_USER()` no MySQL?

A) Os três sempre retornam o mesmo valor; são apenas sinônimos sintáticos sem qualquer diferença semântica.

B) **`CURRENT_USER` retorna o usuário sob cujo contexto de segurança o código está executando (relevante quando há `DEFINER` em SP/Trigger); `USER()` retorna o usuário que originalmente conectou na sessão (formato `usuário@host`); e `SESSION_USER()` é sinônimo de `USER()`. Em uma Trigger criada com `DEFINER='admin'@'localhost' SQL SECURITY DEFINER` e executada por outro usuário `joao`, `CURRENT_USER` retorna `'admin'@'localhost'` (o definer) e `USER()` retorna `'joao'@'host'` (quem conectou).** ✅

C) `CURRENT_USER` retorna sempre o usuário que conectou na sessão; `USER()` retorna o `DEFINER` da SP em execução; e `SESSION_USER()` retorna o usuário da última transação confirmada.

D) `CURRENT_USER` é uma variável de sessão (prefixo `@`), enquanto `USER()` e `SESSION_USER()` são variáveis globais (prefixo `@@`).

---

## Questão 10

Considere o comando abaixo, executado quando `tab_audit` está vazia:

```sql
UPDATE LIVROS SET Precolivro = 99.99 WHERE ISBN = 9786525223742;
```

Qual valor a coluna `codigo` da nova linha em `tab_audit` apresentará?

A) `9786525223742`, repetindo o valor do ISBN auditado para facilitar a busca.

B) **`1`** — a coluna `codigo` foi declarada como `INT AUTO_INCREMENT PRIMARY KEY`, e como esta é a primeira linha inserida em `tab_audit` (que estava vazia), o valor inicial gerado automaticamente é `1`. ✅

C) `NULL`, pois a Trigger não atribui valor explícito para essa coluna no `INSERT`.

D) O timestamp atual em formato Unix, conforme o padrão `AUTO_INCREMENT` do InnoDB para tabelas de auditoria.

---

## Questão 11

Para o mesmo `UPDATE` da questão anterior, quais valores serão gravados nas colunas `usuario` e `estacao` da nova linha de `tab_audit`?

A) `usuario` recebe o nome literal do livro alterado e `estacao` recebe a string fixa `'WORKBENCH'`.

B) Ambos os campos serão preenchidos com `NULL`, pois `CURRENT_USER` e `USER()` só funcionam dentro de Stored Procedures, não dentro de Triggers.

C) **`usuario` recebe o valor de `CURRENT_USER` (ex.: `'root@localhost'`) e `estacao` recebe o valor de `USER()` (também no formato `usuário@host` da conexão real). Em uma sessão comum como `root` na máquina local, ambos retornam valores semelhantes; em cenários com `DEFINER`/`SQL SECURITY DEFINER`, os valores podem divergir, sendo justamente esse o motivo de gravar os dois.** ✅

D) Ambos os campos recebem o nome do banco corrente (`procs_armazenados`), pois auditoria identifica sempre o banco e não o usuário responsável.

---

## Questão 12

Considerando que a coluna `dataautitoria` é do tipo `DATETIME` e a Trigger grava `CURRENT_DATE` nela, qual será o formato/valor armazenado para o `UPDATE` da questão 10?

A) Apenas a parte de hora corrente (ex.: `14:32:05`), sem a data, pois `CURRENT_DATE` retorna apenas o componente temporal ao gravar em `DATETIME`.

B) **A data corrente do servidor com a parte de hora preenchida como `00:00:00`** (ex.: `2025-04-28 00:00:00`). `CURRENT_DATE` retorna apenas a data (sem hora), mas como o tipo da coluna é `DATETIME`, o MySQL completa a parte de hora com zeros automaticamente. ✅

C) Erro de conversão — `DATETIME` exige um valor com hora explícita, e `CURRENT_DATE` é incompatível com esse tipo.

D) O timestamp Unix correspondente ao instante da gravação, em segundos desde 1970, convertido implicitamente para `DATETIME`.

---

## Questão 13

Para o `UPDATE` da questão 10, qual será o valor da coluna `codigo_Produto` na linha registrada em `tab_audit`?

A) `1`, pois corresponde à chave primária `codigo` da própria tabela de auditoria.

B) **`9786525223742`** — capturado da variável de sessão `@ISBN` (que recebe `OLD.ISBN` no corpo da Trigger). É exatamente por isso que `codigo_Produto` foi declarada como `BIGINT` (e não `INT`): para acomodar ISBN-13 sem risco de estouro de capacidade. ✅

C) `99.9900`, pois a coluna registra o novo preço aplicado pela alteração.

D) `NULL`, pois `OLD.ISBN` não pode ser referenciado em uma Trigger `AFTER UPDATE` — apenas em `BEFORE UPDATE`.

---

## Questão 14

Para o mesmo `UPDATE` da questão 10, qual valor será gravado em `preco_unitario_novo`?

A) **`99{,}9900`** — o valor de `NEW.PRECOLIVRO` (capturado em `@PRECONOVO`), formatado com 4 casas decimais conforme o tipo `DECIMAL(10,4)` da coluna. ✅

B) `74{,}9000`, que é o valor original inserido no Bloco 3 (preço antes da alteração).

C) `25{,}0900`, correspondendo à diferença `99{,}99 - 74{,}90` (variação de preço).

D) `NULL`, pois `NEW.PRECOLIVRO` só está disponível em Triggers `BEFORE`, não em `AFTER`.

---

## Questão 15

Considerando que o ISBN `9786525223742` foi inserido no Bloco 3 com `Precolivro = 74.90`, qual valor será gravado em `preco_unitario_antigo` quando o `UPDATE` para `99.99` for executado?

A) `99{,}9900` — o mesmo valor de `preco_unitario_novo`, pois o histórico registra apenas o estado pós-alteração.

B) `0{,}0000` — valor padrão para o primeiro registro auditado de qualquer livro.

C) **`74{,}9000`** — capturado a partir de `OLD.PRECOLIVRO` (atribuído a `@PRECOANTIGO` no corpo da Trigger). Corresponde ao preço imediatamente anterior à alteração; o tipo `DECIMAL(10,4)` exibe o valor com 4 casas decimais. ✅

D) `25{,}0900` — diferença entre o preço novo e o antigo, registrando o delta da alteração.

---

## Questão 16

Suponha que, após criar a Trigger `Audita_Livros`, sejam executados, na ordem:

```sql
DROP TRIGGER Audita_Livros;
UPDATE LIVROS SET Precolivro = 99.99 WHERE ISBN = 9786525223742;
```

Qual é o resultado nas tabelas `LIVROS` e `tab_audit`?

A) Erro — sem a Trigger ativa, o `UPDATE` em `LIVROS` é bloqueado pelo MySQL por razões de integridade referencial entre as tabelas.

B) **O `UPDATE` em `LIVROS` é aplicado normalmente: o preço do livro passa a ser `99{,}99`. No entanto, `tab_audit` permanece inalterada — sem a Trigger, não há quem faça a inserção automática de auditoria. A alteração acontece sem deixar rastro, demonstrando concretamente o papel da Trigger como rastreabilidade automática que sobrevive ao esquecimento humano.** ✅

C) Tanto o `UPDATE` quanto a inserção em `tab_audit` são desfeitos por `ROLLBACK` automático, pois a transação fica inconsistente quando a Trigger esperada está ausente.

D) O `UPDATE` falha silenciosamente (`0 rows affected`), e `tab_audit` recebe um registro com valores `NULL` para indicar a falha de auditoria.
