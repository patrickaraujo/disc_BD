# Atividade 2 — Tabelas-Catálogo

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 2  
> Origem: conversão da Atividade 2 (questões 11 a 20) em itens de múltipla escolha.

---

## Questão 1

Após executar o comando abaixo, com a tabela `Cliente` já populada com os 2 clientes do roteiro:

```sql
SHOW CREATE TABLE Cliente;
```

Que valor aparece na cláusula `AUTO_INCREMENT=` no retorno?

A) `AUTO_INCREMENT=2` — corresponde ao valor do `idCliente` da última linha inserida (`OSWALDO MARTINS DE SOUZA`).

B) `AUTO_INCREMENT=1` — o contador `AUTO_INCREMENT` é resetado após cada `COMMIT` em tabelas InnoDB.

C) **`AUTO_INCREMENT=3` — é o **próximo valor** que será atribuído ao próximo `INSERT`. Como já há 2 linhas com ids `1` e `2`, o próximo registro receberá `3`.** ✅

D) A cláusula `AUTO_INCREMENT=` não aparece em `SHOW CREATE TABLE` — aparece apenas em `SHOW TABLE STATUS`, e nunca dentro do comando `CREATE TABLE` reconstituído.

---

## Questão 2

Após executar os `INSERT`s do roteiro e o `COMMIT`, executa-se:

```sql
SELECT * FROM Cliente;
SELECT * FROM TipoConta;
```

Qual é o resultado esperado?

A) Cada tabela tem 1 linha, ambas com `id = 1` — o `COMMIT` só persiste o último `INSERT` de cada lote em sessões com `autocommit = 0`.

B) **Cada tabela tem 2 linhas, com ids `1` e `2`. Em `Cliente`: `RUBENS ZAMPAR JUNIOR` (`idCliente = 1`) e `OSWALDO MARTINS DE SOUZA` (`idCliente = 2`). Em `TipoConta`: `Conta Corrente` (`idTipoConta = 1`) e `Conta Poupança` (`idTipoConta = 2`).** ✅

C) `Cliente` tem 2 linhas, mas `TipoConta` está vazia — `TipoConta` exige FK para ser populada, e o Bloco 2 ainda não criou a tabela `Conta`.

D) Cada tabela tem 2 linhas, mas com ids `0` e `1`, pois `AUTO_INCREMENT` começa em `0` no MySQL 8 (alteração desde a versão 5.7).

---

## Questão 3

Considere a consulta abaixo:

```sql
SELECT TABLE_NAME, ENGINE, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Financeiro';
```

Qual é o significado da coluna `AUTO_INCREMENT` no retorno e quais valores são esperados ao final do Bloco 2?

A) Mostra o número total de linhas já inseridas com `AUTO_INCREMENT` em cada tabela. Tipicamente: `2` para `Cliente` e `2` para `TipoConta`.

B) Mostra o último valor de `id` efetivamente atribuído. Tipicamente: `2` em ambas as tabelas (id da segunda linha inserida).

C) **Mostra o **próximo valor** de id a ser usado pelo próximo `INSERT`. Tipicamente: `Cliente.AUTO_INCREMENT = 3` e `TipoConta.AUTO_INCREMENT = 3`. Para `Conta` (que será criada no Bloco 3 sem `AUTO_INCREMENT`), o valor seria `NULL`.** ✅

D) Sempre mostra `1`, indicando que o contador interno não é exposto via `information_schema` por questões de segurança.

---

## Questão 4

Considere o experimento abaixo, executado após a tabela `Cliente` já conter 2 linhas (ids `1` e `2`):

```sql
START TRANSACTION;
INSERT INTO Cliente (NomeCli) VALUES ('JOÃO TESTE');
ROLLBACK;
INSERT INTO Cliente (NomeCli) VALUES ('MARIA TESTE');
SELECT idCliente, NomeCli FROM Cliente WHERE NomeCli LIKE '%TESTE%';
```

Que valor de `idCliente` `MARIA TESTE` recebe — e por quê?

A) **`idCliente = 3`** — o `ROLLBACK` reverteu o `INSERT` de João por completo, então o contador `AUTO_INCREMENT` também retrocedeu. Maria recebe o próximo valor disponível na sequência reaberta.

B) **`idCliente = 4` — o `AUTO_INCREMENT` no MySQL/InnoDB **consome a sequência mesmo em `ROLLBACK`**. O `INSERT` de João incrementou o contador interno para `3`, mas o `ROLLBACK` removeu apenas a linha — o contador não retrocede. O próximo `INSERT` (Maria) recebe `4`. Esse comportamento garante unicidade absoluta de identificadores em ambientes concorrentes (várias sessões inserindo simultaneamente sem risco de colisão).** ✅

C) `idCliente = NULL` — após um `ROLLBACK`, qualquer `INSERT` subsequente na mesma sessão recebe `NULL` como `AUTO_INCREMENT` até o próximo `COMMIT` "destravar" o contador.

D) Erro de **duplicate key** — o `ROLLBACK` de João libera o id `3`, mas Maria tenta inserir simultaneamente com `3` e o servidor detecta uma corrida silenciosa contra o `INSERT` revertido.

---

## Questão 5

Continuando o experimento da questão anterior (em que `MARIA TESTE` recebeu `idCliente = 4`), executa-se:

```sql
DELETE FROM Cliente WHERE NomeCli LIKE '%TESTE%';
COMMIT;
```

Os ids `3` (atribuído ao `JOÃO TESTE` revertido) e `4` (atribuído à `MARIA TESTE` deletada) foram **liberados** ou **consumidos permanentemente**?

A) Foram **liberados** automaticamente — o MySQL detecta lacunas na sequência e reutiliza os menores ids disponíveis nos próximos `INSERT`s para manter compactação.

B) **Foram consumidos permanentemente — nunca serão reutilizados. Esse é um comportamento intencional do MySQL para garantir unicidade absoluta de identificadores em ambientes concorrentes. Várias conexões podem inserir simultaneamente sem risco de colisão; em troca, "lacunas" na sequência são aceitáveis.** ✅

C) Foram liberados e ficam disponíveis para reuso **até a próxima reinicialização do servidor** — após o reboot, voltam a estar consumidos por consolidação interna do contador.

D) Apenas o id `4` (atribuído à Maria deletada) foi liberado; o id `3` (revertido) foi consumido — o MySQL diferencia exclusão por `DELETE` de exclusão por `ROLLBACK`.

---

## Questão 6

Por que **não devemos** especificar valor para uma coluna `AUTO_INCREMENT` em um `INSERT` típico? Considere especificamente o que acontece com o comando abaixo, supondo que a tabela `Cliente` já tenha ids `1` e `2`:

```sql
INSERT INTO Cliente (idCliente, NomeCli) VALUES (10, 'Z');
```

A) O MySQL **rejeita com erro** — colunas `AUTO_INCREMENT` são protegidas e não podem receber valor explícito em nenhuma circunstância.

B) **O MySQL aceita o `INSERT` (já que `10` não está em uso), e o próximo `AUTO_INCREMENT` salta para `11` — você efetivamente "consumiu" os ids `3` a `10` sem usá-los, criando lacunas inesperadas. Em geral, devemos deixar o sistema atribuir os valores: intervir manualmente abre risco de conflitos (dois registros com mesmo id, em sessões concorrentes) ou de lacunas indesejadas na sequência.** ✅

C) O MySQL aceita, mas o valor `10` é silenciosamente substituído por `3` (próximo valor real da sequência), pois colunas `AUTO_INCREMENT` ignoram valores explícitos passados via `VALUES`.

D) O MySQL aceita e **mantém** o contador `AUTO_INCREMENT` em `3` — o id `10` é tratado como uma exceção isolada que não afeta a sequência subsequente, e o próximo `INSERT` ainda receberia `3`.

---

## Questão 7

Imagine que você precisa adicionar uma coluna `email` na tabela `Cliente`, do tipo `VARCHAR(80)`, com restrição de **unicidade**. Qual comando SQL é apropriado?

A) `INSERT INTO Cliente.email VARCHAR(80) UNIQUE;` — `INSERT` é o comando para adicionar colunas no MySQL 8.

B) `CREATE COLUMN email IN Cliente AS VARCHAR(80) UNIQUE;` — sintaxe declarativa moderna recomendada pelo padrão SQL:2016.

C) **`ALTER TABLE Cliente ADD COLUMN email VARCHAR(80) UNIQUE;` — ou, equivalentemente, com a restrição de unicidade declarada à parte: `ALTER TABLE Cliente ADD COLUMN email VARCHAR(80), ADD CONSTRAINT uk_email UNIQUE (email);`.** ✅

D) `MODIFY TABLE Cliente WITH email VARCHAR(80) UNIQUE;` — comando específico para tabelas que já contêm dados.

---

## Questão 8

As tabelas `Cliente` e `TipoConta` têm estrutura idêntica em **forma** (id `AUTO_INCREMENT` + um campo descritivo `VARCHAR`). Em quais aspectos elas diferem **conceitualmente** (não estruturalmente)?

A) Não diferem conceitualmente — são tabelas isomorfas que cumprem o mesmo papel no schema, e poderiam ser unificadas em uma única tabela `Entidade` com uma coluna `tipo` discriminadora.

B) Diferem apenas em **performance interna** do MySQL: `Cliente` é otimizada para `INSERT`, `TipoConta` para `SELECT` — a estrutura interna de índices é distinta apesar da DDL aparente ser similar.

C) **`Cliente` representa **pessoas reais** — cresce com o negócio, recebe novos registros constantemente, é uma tabela **transacional**. `TipoConta` representa **categorias estáticas** (tipos definidos pelo banco/sistema) — quase nunca muda, é controlada por administradores, é uma tabela **referencial / de metadados / catálogo**. A diferença é de **natureza**, não de forma.** ✅

D) `Cliente` é, na verdade, uma tabela "filha" de `TipoConta` — a estrutura idêntica revela uma relação `1:1` implícita entre elas que o diagrama ER não tornou explícita.

---

## Questão 9

A tabela `TipoConta` provavelmente nunca terá milhões de linhas — apenas algumas dezenas. Já a tabela `Cliente` pode crescer indefinidamente. Considerando essa diferença, em qual delas o tipo `INT` é "exagero" e poderia ser substituído por `TINYINT` (ou `SMALLINT`)?

A) Em **`Cliente`** — clientes têm rotatividade alta, e o `TINYINT` (até `127`) seria suficiente para o "estoque ativo" de um determinado momento, com reciclagem natural dos ids antigos pelo MySQL.

B) **Em `TipoConta` — pode usar `TINYINT` (até `127` valores positivos) ou `SMALLINT`, mais que suficiente para os poucos tipos de conta existentes. Em `Cliente`, manter `INT` é prudente (cobre até ~`2{,}1 × 10⁹`; até `BIGINT` para sistemas globais). A otimização tem ganho prático mínimo em uma tabela com poucas linhas, mas em desenhos com **centenas** de tabelas referenciais, escolher o tipo certo economiza espaço de armazenamento e melhora performance de índices.** ✅

C) Em **ambas** — o MySQL 8 implementa `INT` como sinônimo de `TINYINT` em tabelas com PK simples, então a escolha é apenas estilística e não afeta o armazenamento físico.

D) Em **nenhuma** — o tipo `TINYINT` está depreciado desde o MySQL 5.7 e deve ser evitado em favor de `INT` ou `BIGINT` em qualquer tabela nova.
