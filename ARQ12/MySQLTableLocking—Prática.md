# MySQL Table Locking — Prática

> **Disciplina:** Banco de Dados — Prof. Me. Rubens Zampar Jr. (`rzampar@prof.unisa.br`)
>
> **Pré-requisito:** Aula anterior (Arquivo 13 — *Controle Transacional*). Esta aula coloca em prática os conceitos de **bloqueio compartilhado (READ)** e **bloqueio exclusivo (WRITE)** vistos na teoria, agora executados em duas sessões paralelas no MySQL Workbench.

---

## Visão geral

Esta aula tem dois objetivos:

1. Demonstrar, com sessões reais, como `LOCK TABLES` e `UNLOCK TABLES` controlam o acesso concorrente a uma tabela.
2. Mostrar um caso prático em que `LOCK TABLES` é usado para proteger uma *stored procedure* sem controle transacional próprio.

### Conceitos-chave

* **Sessão (*session*).** Cada conexão aberta no Workbench é uma sessão independente, com seu próprio `CONNECTION_ID()`. Bloqueios pertencem à sessão que os adquiriu — outra sessão não pode liberá-los.
* **Bloqueio explícito.** O `LOCK TABLES` é a forma de pedir manualmente um bloqueio. O InnoDB também faz bloqueios *implícitos* em transações; aqui trabalhamos só com os explícitos.
* **READ Lock.** Compartilhado — várias sessões podem ler ao mesmo tempo, mas ninguém escreve.
* **WRITE Lock.** Exclusivo — só a sessão dona acessa a tabela; as demais ficam em espera.

---

## 1. Preparação

### 1.1 Criar a tabela `messages` no schema `BLOQUEIOS`

```sql
CREATE TABLE messages (
    id INT NOT NULL AUTO_INCREMENT,
    message VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);
```

### 1.2 Configurar o Workbench para evitar timeout

Em **Edit → Preferences → SQL Editor**, atribua **`0`** aos três campos abaixo e **reinicie o Workbench**:

| Campo                                          | Valor |
| ---------------------------------------------- | :---: |
| DBMS connection keep-alive interval (in seconds) |  `0`  |
| DBMS connection read timeout interval (in seconds) |  `0`  |
| DBMS connection timeout interval (in seconds)  |  `0`  |

> ⚠️ Sem isso, ao executar comandos DML em sessões paralelas, a 2ª sessão pode cair com:
>
> ```
> Error Code: 2013. Lost connection to MySQL server during query
> ```
>
> Se isso ocorrer, basta reconectar o DBMS pelo ícone na barra de ferramentas.

---

## 2. Sintaxe — LOCK TABLES e UNLOCK TABLES

### Bloqueio explícito de uma tabela

```sql
LOCK TABLES table_name [READ | WRITE];
```

Você especifica o nome da tabela e o **tipo de bloqueio** — `READ` ou `WRITE`.

### Bloqueio de várias tabelas

```sql
LOCK TABLES
    table_name1 [READ | WRITE],
    table_name2 [READ | WRITE],
    ... ;
```

> ⚠️ **Adquira todos os bloqueios necessários em uma única instrução** `LOCK TABLES`. Enquanto eles estiverem ativos, a sessão só acessa as tabelas bloqueadas.

### Liberação de bloqueio

```sql
UNLOCK TABLES;
```

Libera **todos** os bloqueios da sessão. Se a sessão for encerrada (normal ou anormalmente), o MySQL libera os bloqueios implicitamente.

---

## 3. READ Lock — bloqueio compartilhado

### Características

* Várias sessões podem manter `READ` simultaneamente.
* Outras sessões podem **ler** sem precisar adquirir bloqueio.
* A sessão dona **não pode escrever** na tabela enquanto mantém o `READ`.
* Outras sessões que tentarem escrever ficam **em espera** até o bloqueio ser liberado.

### Demonstração em duas sessões

#### Sessão 1 — adquirir o READ lock

```sql
SELECT CONNECTION_ID();      -- ex.: 9
INSERT INTO messages(message) VALUES('Hello');
SELECT * FROM messages;
COMMIT;

LOCK TABLE messages READ;    -- adquire o bloqueio compartilhado

INSERT INTO messages(message) VALUES('Hi');
```

A última instrução falha imediatamente — a própria sessão não pode escrever enquanto mantém um READ:

```
Error Code: 1099. Table 'messages' was locked with a READ lock
and can't be updated.
```

> 🎯 **Conceito.** Isso reforça que o `READ` é compartilhado **para leitura**, mesmo para quem o adquiriu. Para escrever, é preciso `WRITE`.

#### Sessão 2 — abrir nova conexão (usuário `rzampar`, senha `12345@`)

```sql
SELECT CONNECTION_ID();              -- ex.: 11
SELECT * FROM messages;              -- funciona: leitura é livre
INSERT INTO messages(message) VALUES('Bye');
```

O `INSERT` da sessão 2 **fica pendente** (estado *Running...*) — está esperando o `READ` da sessão 1 ser liberado.

#### Sessão 1 — diagnosticar a espera

```sql
SHOW PROCESSLIST;
```

Saída relevante:

| Id  | User    | Command | Time | State                            | Info                                       |
| --- | ------- | ------- | ---- | -------------------------------- | ------------------------------------------ |
| 129 | rzampar | Query   | 548  | **Waiting for table metadata lock** | `INSERT INTO messages(message) VALUES('Bye')` |

#### Sessão 1 — liberar o bloqueio

```sql
UNLOCK TABLES;
```

Imediatamente, o `INSERT` pendente da sessão 2 é executado.

#### Verificação final

```sql
SELECT * FROM messages;
```

| id | message |
| -- | ------- |
| 1  | Hello   |
| 2  | Bye     |

> Faça `COMMIT` na sessão 2, feche-a, reconecte na sessão 1 e refaça o `SELECT` para confirmar.

---

## 4. WRITE Lock — bloqueio exclusivo

### Características

* Apenas a sessão dona pode **ler e escrever**.
* Todas as demais sessões ficam em espera, inclusive para `SELECT`.

### Demonstração em duas sessões

#### Sessão 1 — adquirir o WRITE lock e operar livremente

```sql
LOCK TABLE messages WRITE;

INSERT INTO messages(message) VALUES('Good Morning');   -- funciona
COMMIT;
SELECT * FROM messages;                                 -- funciona
```

| id | message       |
| -- | ------------- |
| 1  | Hello         |
| 2  | Bye           |
| 3  | Good Morning  |

#### Sessão 2 — abrir e tentar qualquer operação

```sql
INSERT INTO messages(message) VALUES('Bye Bye');    -- fica em espera
SELECT * FROM messages;                              -- fica em espera
```

> 🎯 **Diferença em relação ao READ.** No `WRITE`, mesmo `SELECT` da sessão 2 fica bloqueado. Isso é coerente com a teoria: `WRITE` é exclusivo.

#### Sessão 1 — diagnosticar e liberar

```sql
SHOW PROCESSLIST;
```

| Id  | User    | Command | State                            | Info                                          |
| --- | ------- | ------- | -------------------------------- | --------------------------------------------- |
| 216 | rzampar | Query   | **Waiting for table metadata lock** | `INSERT INTO messages(message) VALUES('Bye Bye')` |

```sql
UNLOCK TABLES;
```

Todas as operações pendentes da sessão 2 executam em sequência:

| id | message       |
| -- | ------------- |
| 1  | Hello         |
| 2  | Bye           |
| 3  | Good Morning  |
| 4  | Bye Bye       |

---

## 5. Resumindo: leitura *versus* gravação

| Situação                                           | READ Lock (compartilhado) | WRITE Lock (exclusivo) |
| -------------------------------------------------- | :-----------------------: | :--------------------: |
| Múltiplas sessões com o mesmo lock simultaneamente |             ✅            |           ❌           |
| Sessão dona pode ler                                |             ✅            |           ✅           |
| Sessão dona pode escrever                           |             ❌            |           ✅           |
| Outras sessões podem ler                            |             ✅            |           ❌           |
| Outras sessões podem escrever                       |             ❌            |           ❌           |
| Impede outro READ lock                              |             ❌            |           ✅           |
| Impede outro WRITE lock                             |             ✅            |           ✅           |

**Regra mnemônica:**

* **READ** → "compartilhado": permite leitura coletiva, bloqueia escrita.
* **WRITE** → "exclusivo": bloqueia tudo o que não seja a própria sessão.

---

## 6. Mais um exemplo — proteger uma procedure sem controle transacional

Na aula anterior, criamos a procedure `sp_insere_livros` com controle transacional embutido (`START TRANSACTION` + `COMMIT` / `ROLLBACK`):

```sql
DELIMITER //
CREATE PROCEDURE sp_insere_livros(
    v_ISBN BIGINT,
    v_AUTOR VARCHAR(50),
    v_NOMELIVRO VARCHAR(100),
    v_PRECOLIVRO FLOAT)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    START TRANSACTION;
        INSERT INTO LIVROS (ISBN, AUTOR, NOMELIVRO, PRECOLIVRO)
        VALUES (v_ISBN, v_AUTOR, v_NOMELIVRO, v_PRECOLIVRO);

        IF erro_sql = FALSE THEN
            COMMIT;
            SELECT 'Transação efetivada com sucesso!!!' AS RESULTADO;
        ELSE
            ROLLBACK;
            SELECT 'ATENÇÃO: Erro na transação!!!' AS RESULTADO;
        END IF;
END
//
```

### Tarefa

Criar uma versão alternativa **sem controle transacional**, e usar `LOCK TABLES` na chamada para garantir a integridade durante a operação.

### Resolução — `sp_insere_livros_02`

```sql
DELIMITER //
CREATE PROCEDURE sp_insere_livros_02(
    v_ISBN BIGINT,
    v_AUTOR VARCHAR(50),
    v_NOMELIVRO VARCHAR(100),
    v_PRECOLIVRO FLOAT)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    INSERT INTO LIVROS (ISBN, AUTOR, NOMELIVRO, PRECOLIVRO)
    VALUES (v_ISBN, v_AUTOR, v_NOMELIVRO, v_PRECOLIVRO);

    IF erro_sql = FALSE THEN
        COMMIT;
        SELECT 'Transação efetivada com sucesso!!!' AS RESULTADO;
    ELSE
        ROLLBACK;
        SELECT 'ATENÇÃO: Erro na transação!!!' AS RESULTADO;
    END IF;
END
//
```

### Chamada com `LOCK TABLES`

```sql
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(22222222222222, 'Golias Alencar', 'Pet - O livro', 29.99);
UNLOCK TABLES;
```

### Comparação entre as duas abordagens

| Aspecto                              | `sp_insere_livros` (com `START TRANSACTION`) | `sp_insere_livros_02` + `LOCK TABLES`         |
| ------------------------------------ | -------------------------------------------- | --------------------------------------------- |
| Controle de atomicidade              | Interno (transação)                          | Externo (bloqueio explícito)                  |
| Bloqueia outras sessões durante?     | Não (InnoDB usa bloqueio em nível de linha)  | Sim (tabela inteira fica exclusiva)           |
| Permite leitura concorrente?         | Sim                                          | Não — `WRITE` é exclusivo                     |
| Indicado para                        | Operações curtas em alta concorrência        | Operações em lote, manutenção, blocos críticos |

> 🎯 **Observação.** Na prática moderna com InnoDB, prefira o controle transacional embutido — é mais granular e mantém a concorrência. O `LOCK TABLES` é útil em manutenções, importações em lote ou quando o código herdado não tem transações.

---

## Considerações finais

* `LOCK TABLES` adquire bloqueios explícitos por **sessão**; `UNLOCK TABLES` os libera.
* `READ` é **compartilhado** — várias leitoras, nenhuma escritora.
* `WRITE` é **exclusivo** — uma sessão dona, todas as outras em espera.
* `SHOW PROCESSLIST` é a ferramenta padrão para diagnosticar quem está esperando por bloqueio.
* No InnoDB, `LOCK TABLES` deve ser usado com `SET autocommit = 0` (e nunca com `START TRANSACTION`), conforme visto no Arquivo 13.

---

## Referências

ELMASRI, R.; NAVATHE, S. B. **Sistemas de Banco de Dados.** 7. ed. São Paulo: Pearson, 2018.

MySQL 8.0 Reference Manual. **LOCK TABLES and UNLOCK TABLES Statements.** Disponível em: <https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html>.
