# Atividade 8 — Resolução Documentada do Exercício Integrador

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ12 — Bloco 8 (Exercício Integrador)  
> Origem: conversão da Atividade 8 (questões 72 a 80) em itens de múltipla escolha.

> ⚠️ **Atividade avaliativa.** As questões assumem que o aluno já implementou a resolução do exercício integrador do Bloco 8 (recriação da `tab_audit`, da Trigger `Audita_Livros`, da SP `sp_altera_livros` e bateria de testes).

---

## Questão 1

Considere os requisitos do Bloco 8 para a tabela `tab_audit`. Qual `CREATE TABLE` está estruturalmente correto e respeita todos os cuidados pedidos?

A) `tab_audit` com `codigo_Produto INT NOT NULL` — pois `INT` cabe a maioria dos códigos de produto comuns em sistemas de pequeno porte.

B) `tab_audit` com `codigo INT AUTO_INCREMENT PRIMARY KEY`, `usuario CHAR(30) NOT NULL`, `estacao CHAR(30) NOT NULL`, `dataautitoria DATETIME NOT NULL`, `codigo_Produto BIGINT NOT NULL`, `preco_unitario_novo DECIMAL(10,4) NOT NULL` e `preco_unitario_antigo DECIMAL(10,4) NOT NULL`. O cuidado central é declarar `codigo_Produto` como `BIGINT` (não `INT`), pois a tabela auditará o `ISBN` da tabela `LIVROS` (`BIGINT UNSIGNED`, 13 dígitos) — `INT UNSIGNED` não comportaria.

C) `tab_audit` com `codigo_Produto VARCHAR(20)` e `dataauditoria DATETIME` (com correção ortográfica) — `VARCHAR` para flexibilidade futura e correção do nome da coluna.

D) `tab_audit` com `codigo_Produto DECIMAL(13,0)` e `preco_unitario_novo FLOAT` — `DECIMAL` para o ISBN (caber 13 dígitos) e `FLOAT` para preço (mais leve em armazenamento).

---

## Questão 2

Por que o nome da coluna `dataautitoria` é mantido com essa grafia exata no Bloco 8, mesmo parecendo ser uma digitação?

A) Porque o MySQL não permite renomear colunas em tabelas que serão usadas por Triggers — só seria possível recriar a tabela.

B) Porque o nome aparece exatamente assim no roteiro original do professor (e em qualquer código previamente registrado, como a Trigger criada no Bloco 5). Preservar a grafia garante compatibilidade com o gabarito e com toda referência por nome — "corrigir" para `dataauditoria` quebraria o `INSERT INTO TAB_AUDIT (..., dataautitoria, ...)` da Trigger.

C) Porque "dataautitoria" é um termo técnico do português brasileiro, derivado de "auditoria" e "data", padronizado pela LGPD para colunas de log.

D) Porque o MySQL faz comparação case-insensitive em nomes de colunas; `dataautitoria` e `dataauditoria` são tratados como sinônimos pelo servidor.

---

## Questão 3

Por que é recomendado executar `DROP TRIGGER IF EXISTS Audita_Livros;` **antes** do `CREATE TRIGGER Audita_Livros ...` no Bloco 8?

A) Para forçar o servidor a recompilar todas as Triggers do banco e melhorar o desempenho geral.

B) Porque a Trigger `Audita_Livros` foi criada no Bloco 5 e ainda está registrada no banco. Sem o `DROP`, o `CREATE TRIGGER` falharia com erro "Trigger already exists". Como o exercício recriou também a tabela `tab_audit`, é boa prática recriar a Trigger para garantir o vínculo lógico atualizado, mesmo que tecnicamente a referência seja por nome.

C) Porque uma Trigger `AFTER UPDATE` precisa ser apagada e recriada toda vez que `tab_audit` recebe novas linhas, para liberar espaço em cache.

D) Porque o MySQL exige `DROP` explícito antes de qualquer `CREATE` em ambiente de produção, por questão de auditoria de DDL.

---

## Questão 4

No corpo da Trigger `Audita_Livros AFTER UPDATE ON LIVROS FOR EACH ROW`, quais pseudo-registros são usados e em quais variáveis de sessão seus valores são capturados?

A) `NEW.ISBN`, `NEW.PRECOLIVRO_OLD` e `NEW.PRECOLIVRO_NEW`, capturados em variáveis locais declaradas com `DECLARE` no início do bloco.

B) Apenas `OLD.*` para todas as colunas, pois `NEW.*` só está disponível em Triggers `BEFORE`.

C) `OLD.ISBN` (capturado em `@ISBN`), `NEW.PRECOLIVRO` (capturado em `@PRECONOVO`) e `OLD.PRECOLIVRO` (capturado em `@PRECOANTIGO`). As variáveis de sessão (prefixo `@`) tornam o código mais legível e são depois usadas no `INSERT INTO TAB_AUDIT (...) VALUES (CURRENT_USER, USER(), CURRENT_DATE, @ISBN, @PRECONOVO, @PRECOANTIGO);`.

D) `OLD` e `NEW` para todas as colunas, capturados em uma única variável `@AUDITORIA` do tipo array associativo.

---

## Questão 5

Considere a estrutura interna correta da SP `sp_altera_livros` no Bloco 8. Em que ordem aparecem os elementos `DECLARE erro_sql`, `DECLARE CONTINUE HANDLER`, `START TRANSACTION`, `UPDATE` e `IF erro_sql = FALSE THEN COMMIT ... ELSE ROLLBACK ... END IF`?

A) `START TRANSACTION` primeiro, seguido pelos `DECLARE`s, e o `IF ... END IF` aparece como bloco fora do `BEGIN ... END`.

B) A ordem correta é: (1) `DECLARE erro_sql boolean DEFAULT FALSE;`, (2) `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;`, (3) `START TRANSACTION;`, (4) o `UPDATE LIVROS SET Precolivro = v_PRECOLIVRO WHERE ISBN = v_ISBN;`, e por último (5) o `IF erro_sql = FALSE THEN COMMIT; SELECT '...sucesso...' AS RESULTADO, ISBN, PRECOLIVRO AS 'PREÇO NOVO' FROM LIVROS WHERE ISBN = v_ISBN; ELSE ROLLBACK; SELECT '...falha...' AS RESULTADO; END IF;`.

C) `DECLARE erro_sql`, `START TRANSACTION`, `DECLARE CONTINUE HANDLER`, `UPDATE`, `COMMIT`. O handler vem depois do `START TRANSACTION` para conseguir capturar erros do `UPDATE`.

D) Os elementos podem aparecer em qualquer ordem, desde que estejam dentro do `BEGIN ... END`. O MySQL reorganiza internamente no momento da execução.

---

## Questão 6

Por que os `DECLARE`s **precisam** vir antes do `START TRANSACTION` no corpo da SP?

A) Porque `START TRANSACTION` zera o escopo de variáveis locais — qualquer `DECLARE` posterior seria descartado pelo servidor antes da execução.

B) Porque o MySQL impõe uma regra sintática: todas as declarações `DECLARE` devem aparecer no início do `BEGIN ... END`, antes de qualquer instrução executável (inclusive antes do `START TRANSACTION`). Se essa ordem for invertida, o servidor retorna erro de sintaxe na criação da SP — a SP nem chega a ser registrada no banco.

C) Porque `DECLARE CONTINUE HANDLER` precisa ser registrado pelo servidor antes de qualquer transação ser aberta, ou ele captura apenas erros pós-`COMMIT`.

D) Não precisa — é apenas convenção estilística adotada pelo professor; tecnicamente a ordem pode variar livremente sem efeito.

---

## Questão 7

Considere a bateria de testes do Bloco 8 com as três chamadas a seguir, **executadas em sequência**:

```sql
CALL sp_altera_livros(9786525223742, 49.90);
CALL sp_altera_livros(8888888888888, 65.00);
CALL sp_altera_livros(9999999999999, NULL);
```

Quais são os resultados esperados?

A) As três chamadas retornam mensagem de sucesso, pois a SP é resiliente a qualquer erro e completa todas as transações abertas.

B) As três falham, pois `NULL` na chamada #3 contamina a sessão e força `ROLLBACK` em todas as transações abertas (mesmo nas anteriores).

C) As chamadas #1 e #2 retornam mensagem de sucesso (3 colunas: `RESULTADO`, `ISBN`, `'PREÇO NOVO'`), confirmando os preços alterados. A chamada #3 falha (1 coluna: `RESULTADO` com texto `'ATENÇÃO: Erro na transação, preço do livro não alterado!!!'`) — o `NULL` viola `NOT NULL` em `LIVROS.Precolivro`, o handler captura, a flag `erro_sql` vira `TRUE` e a SP executa `ROLLBACK`.

D) Apenas a chamada #1 é bem-sucedida; a #2 falha por falta de `COMMIT` explícito após a #1 e a #3 falha por `NULL`.

---

## Questão 8

Após executar a bateria de testes da questão anterior, executa-se:

```sql
SELECT * FROM tab_audit;
```

Quantas linhas aparecem e qual é o conteúdo correto?

A) 3 linhas — uma para cada chamada, sendo a da #3 com `preco_unitario_novo = NULL` para indicar a tentativa frustrada.

B) 2 linhas: uma com `codigo_Produto = 9786525223742` (com `preco_unitario_antigo` e `preco_unitario_novo` correspondendo à alteração da #1), e outra com `codigo_Produto = 8888888888888` (correspondendo à #2). A chamada #3 não deixa rastro porque o `UPDATE` falhou (Trigger `AFTER UPDATE` não dispara) e, mesmo se tivesse disparado, o `ROLLBACK` da SP descartaria a inserção de auditoria.

C) 0 linhas — `tab_audit` é zerada automaticamente quando qualquer chamada à SP falha na mesma sessão.

D) 1 linha — apenas a última chamada bem-sucedida deixa rastro; as anteriores são sobrescritas em `tab_audit`.

---

## Questão 9

Após a bateria, executa-se `SELECT * FROM LIVROS;`. Como deve estar o estado da tabela?

A) Apenas 2 livros aparecem (os ISBNs alterados) — os demais foram removidos como efeito colateral das chamadas anteriores nos blocos.

B) Os 4 livros aparecem, mas todos com `Precolivro = NULL` por contaminação da chamada #3.

C) Erro — `LIVROS` foi truncada automaticamente quando a chamada #3 falhou.

D) Os 4 livros aparecem: `9786525223742` com `Precolivro = 49{,}90` (alterado pela #1); `8888888888888` com `Precolivro = 65{,}00` (alterado pela #2); `9999999999999` inalterado (a chamada #3 falhou e foi desfeita por `ROLLBACK`); `7777777777777` inalterado (não foi tocado por nenhuma chamada). Apenas as chamadas bem-sucedidas refletem em `LIVROS`; as falhas não deixam rastro.

---

## Questão 10

Identifique corretamente **três padrões/conceitos** vindos dos blocos anteriores que foram reusados na resolução do Bloco 8:

A) Padrões CRUD-RESTful do Bloco 1, normalização Boyce-Codd do Bloco 4 e índices secundários do Bloco 7.

B) (1) O trio `DECLARE erro_sql / DECLARE CONTINUE HANDLER FOR SQLEXCEPTION / START TRANSACTION` (vindo do Bloco 3) — usado no início da `sp_altera_livros`. (2) O cabeçalho `FOR EACH ROW BEGIN` em Trigger `AFTER UPDATE` (vindo do Bloco 5) — recriado para `Audita_Livros`. (3) A mensagem de sucesso enriquecida com 3 colunas, incluindo `ISBN` e `'PREÇO NOVO'` via `SELECT ... FROM LIVROS WHERE ISBN = v_ISBN` (vindo do Bloco 6).

C) Apenas o `IF ... THEN ... ELSE ... END IF` do Bloco 2 — os demais elementos foram introduzidos pela primeira vez no Bloco 8 e são autênticos da resolução integradora.

D) Padrões de criptografia AES, autenticação OAuth2 e replicação master-slave — vindos respectivamente dos blocos 5, 6 e 7.

---

## Questão 11

Em uma turma reflexiva, qual frase descreve melhor o que efetivamente permite ao aluno resolver o exercício integrador do Bloco 8 **sem código guia**?

A) A leitura cuidadosa do enunciado do Bloco 8, sem necessidade de envolvimento prático com os blocos anteriores.

B) A consulta direta ao gabarito (`COMANDOS-BD-03-bloco8.sql`) antes de tentar — afinal, o objetivo é entregar a solução correta no menor tempo possível.

C) A prática repetida dos Blocos 1 a 7, que construíram, por reaplicação, os padrões necessários (trio transacional, Trigger `AFTER UPDATE`, mensagem enriquecida etc.). A mera leitura teórica seria insuficiente — é a repetição prática que internaliza o padrão a ponto de o aluno poder reaplicá-lo em um cenário novo, sem rede de proteção.

D) A memorização da sintaxe SQL do MySQL 8 antes de iniciar a aula — o conhecimento prévio dispensa qualquer prática ou repetição.

---

## Questão 12

Imagine que a próxima tarefa seja adicionar uma Trigger **`BEFORE INSERT ON LIVROS`** que valide `Precolivro` (rejeitando valores negativos). Como você adaptaria o que aprendeu nos Blocos 5 e 6?

A) Manteria `AFTER UPDATE` e adicionaria um `IF Precolivro < 0 THEN ROLLBACK` no corpo — Triggers `INSERT` não conseguem validar valores antes da gravação.

B) Criaria uma SP nova `sp_valida_preco` que faz o `INSERT` apenas após verificar manualmente o sinal do preço — sem usar Trigger nenhuma.

C) Mudaria o tipo da Trigger para `BEFORE INSERT ON LIVROS` (em vez de `AFTER UPDATE`), validaria `NEW.Precolivro` (não há `OLD` em `INSERT`), e se `NEW.Precolivro < 0` sinalizaria erro com `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Preço inválido';`. Esse `SIGNAL` é capturado pelo `CONTINUE HANDLER FOR SQLEXCEPTION` da SP de inserção — abortando o `INSERT`. O padrão da SP transacional permanece o mesmo do Bloco 3; apenas a Trigger muda, passando a impor uma regra de negócio antes da gravação.

D) Criaria a Trigger como `AFTER INSERT ON LIVROS` e usaria `OLD.Precolivro` para rejeitar valores negativos — `OLD` em `INSERT` retorna o valor padrão (`0`), comparável ao `NEW`.
