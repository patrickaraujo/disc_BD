# Aula ARQ12 — Transações e Controle Transacional na Prática

Bem-vindo à **Aula ARQ12** da disciplina de **Banco de Dados**. Esta é uma aula **100% prática**, na qual você vai aplicar — em laboratório — todos os conceitos de **transações**, **Stored Procedures**, **Triggers** e **gestão de usuários** que já estudou. O objetivo não é reapresentar a teoria, e sim **construir, com suas próprias mãos**, um conjunto de transações controladas, com auditoria automática e tratamento de erro.

> 🧑‍🏫 **Importante:** os blocos desta aula são **guias de implementação** — eles indicam *o que* construir, *o que* observar e *como validar*, mas **não entregam o código pronto**. Você é convidado a escrever o SQL a partir do que já sabe. Apenas alguns comandos específicos (handler de erro de SQL, sintaxe de Trigger e gestão de usuários) são apresentados explicitamente, por se tratar de comandos que normalmente recebem pouca atenção em aulas teóricas.

---

## 🎯 Objetivos da Aula

* Aplicar `START TRANSACTION`, `COMMIT` e `ROLLBACK` para controlar transações manuais.
* Encapsular transações dentro de Stored Procedures, com tratamento de erro via `DECLARE CONTINUE HANDLER`.
* Construir uma tabela de auditoria e uma Trigger `AFTER UPDATE` que registra automaticamente alterações de preço.
* Combinar Trigger e Stored Procedure transacional em um mesmo cenário.
* Criar, conceder privilégios, listar e excluir usuários no MySQL.
* Resolver, ao final, um exercício integrador que reúne os 6 elementos: BD → tabela → Trigger → tabela de auditoria → Stored Procedure transacional → testes.

---

## 📂 Organização dos Blocos

A aula está dividida em **oito blocos práticos**. Cada bloco é independente do ponto de vista didático, mas o **estado do banco de dados é cumulativo** — execute na ordem.

### [Bloco 01 — Preparação do Ambiente: Autocommit e Banco de Trabalho](./Bloco1/README.md)
* **Foco:** verificar e desativar o `autocommit`; (re)criar o banco `procs_armazenados`; criar a tabela `LIVROS`.
* **Destaque:** `SELECT @@autocommit`, `SET autocommit = 0`, `CREATE DATABASE`, `CREATE TABLE … ENGINE = InnoDB`.

### [Bloco 02 — Transações Manuais: ROLLBACK e COMMIT](./Bloco2/README.md)
* **Foco:** abrir transações com `START TRANSACTION`, observar o efeito de `ROLLBACK` e de `COMMIT`.
* **Destaque:** comportamento de `INSERT` antes e depois do `COMMIT`; uso de `TRUNCATE` para zerar a tabela entre experimentos.

### [Bloco 03 — Encapsulando Transações em Stored Procedures](./Bloco3/README.md)
* **Foco:** criar `sp_insere_livros` — uma SP que insere um livro com tratamento de erro automático.
* **Destaque:** `DECLARE erro_sql boolean DEFAULT FALSE`, `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION`, fluxo `IF erro_sql = FALSE THEN COMMIT ELSE ROLLBACK`.

### [Bloco 04 — Aplicando em Cenário Real: ItemPedido × Produtos](./Bloco4/README.md)
* **Foco:** recriar as tabelas `ItemPedido` e `Produtos`, e construir `sp_insere_itempedido`.
* **Destaque:** consolidação do padrão de SP transacional em um cenário diferente (pedido + estoque).

### [Bloco 05 — Auditoria Automática: tab_audit + Trigger Audita_Livros](./Bloco5/README.md)
* **Foco:** criar a tabela `tab_audit` e a Trigger `Audita_Livros` (`AFTER UPDATE ON LIVROS`).
* **Destaque:** sintaxe `FOR EACH ROW BEGIN … END`, uso de `OLD.coluna` e `NEW.coluna`, função `CURRENT_USER` e `USER()`.

### [Bloco 06 — Integrando Trigger + Transação em SP](./Bloco6/README.md)
* **Foco:** construir `sp_altera_livros` — SP transacional que atualiza o preço do livro e dispara, automaticamente, a Trigger de auditoria.
* **Destaque:** integração `Trigger ↔ SP`, validação dos registros gerados em `tab_audit`.

### [Bloco 07 — Gestão de Usuários e Privilégios](./Bloco7/README.md)
* **Foco:** criar, listar, conceder privilégios e remover usuários no MySQL.
* **Destaque:** `CREATE USER`, `GRANT ALL PRIVILEGES`, `SHOW GRANTS`, `FLUSH PRIVILEGES`, `DROP USER`.

### [Bloco 08 — Exercício Integrador: Auditoria de Alteração de Preço](./Bloco8/README.md)
* **Foco:** resolver o exercício que reúne tudo: recriar `tab_audit` (com `codigo_Produto BIGINT`), Trigger, Stored Procedure transacional e bateria de testes.
* **Destaque:** entrega final da aula — sem código guia, apenas requisitos e critérios de validação.

---

## 🚀 Como estudar este conteúdo

1. Abra o **Bloco 1** e **execute os passos no MySQL Workbench** — não pule a verificação do `autocommit`.
2. Avance para o **Bloco 2** e observe (de fato, com `SELECT * FROM LIVROS` antes e depois) o efeito do `ROLLBACK` e do `COMMIT`.
3. No **Bloco 3**, escreva sua primeira SP transacional. Releia os três comandos exibidos no guia e entenda **por que eles aparecem juntos**.
4. Reaplique o padrão no **Bloco 4** com `ItemPedido` e `Produtos`.
5. Construa, no **Bloco 5**, a tabela de auditoria e a Trigger.
6. Faça a integração no **Bloco 6** — este é o coração da aula.
7. Aprenda a controlar usuários no **Bloco 7**.
8. Resolva o **Bloco 8** sem consultar o código-fonte dos blocos anteriores até esgotar suas tentativas.

> ⚠️ **Importante:** o **estado do banco de dados é cumulativo** entre os blocos. Cada bloco pressupõe que o anterior foi executado com sucesso. Se algo der errado, recomece do Bloco 1 (basta `DROP DATABASE procs_armazenados;` e seguir).

---

## 🛠️ Pré-requisitos

* **MySQL** e **MySQL Workbench** instalados e funcionando.
* Conhecimento prévio de:
  * DDL (`CREATE`, `ALTER`, `DROP`, constraints) — visto em ARQ04 a ARQ08.
  * DML (`INSERT`, `UPDATE`, `DELETE`, `SELECT`) — visto em ARQ09 e ARQ10.
  * Stored Procedures, Triggers, Functions e Views — vistos em ARQ11.
* O banco `procs_armazenados` (criado em ARQ11) será **recriado** no Bloco 1, então **faça backup do que precisar manter** antes de começar.

---

## 📌 Importante

* Esta aula é **100% prática** — todo o conteúdo é construído diretamente no MySQL Workbench.
* O guia **não entrega código pronto**, exceto para os comandos abaixo, que merecem destaque e explicação dirigida:
  * `FOR EACH ROW BEGIN` — cabeçalho do corpo de uma Trigger.
  * `DECLARE erro_sql boolean DEFAULT FALSE;` — variável de controle de erro.
  * `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;` — handler que captura qualquer exceção SQL.
  * `START TRANSACTION;` — abre uma transação dentro de uma SP.
  * `CREATE USER`, `GRANT ALL PRIVILEGES`, `SHOW GRANTS`, `FLUSH PRIVILEGES`, `DROP USER` — comandos de DCL menos rotineiros em sala.
* **Cada bloco contém atividade obrigatória** (`Atividade/README.md`).
* **Cada bloco mantém um arquivo `codigo-fonte/COMANDOS-BD-03-bloco{N}.sql`** — esse arquivo serve como **gabarito de referência**, a ser consultado **apenas após a tentativa do aluno**.

---

## 🎯 Ao Final desta Aula

Você será capaz de:

✅ Controlar transações manualmente com `START TRANSACTION`, `COMMIT` e `ROLLBACK`.
✅ Construir Stored Procedures transacionais robustas, com tratamento de erro.
✅ Implementar auditoria automática com Triggers `AFTER UPDATE`.
✅ Combinar Trigger e Stored Procedure em um cenário real.
✅ Gerenciar usuários e privilégios no MySQL.
✅ Resolver, de forma autônoma, um exercício integrador que mescla todos os elementos acima.

---

## 📊 Mapa de Comandos Trabalhados na Aula

| Categoria | Comandos / Construções |
|-----------|------------------------|
| **Sessão** | `SELECT @@autocommit`, `SET autocommit = 0` |
| **DDL** | `CREATE DATABASE`, `CREATE TABLE … ENGINE = InnoDB`, `DROP DATABASE`, `TRUNCATE TABLE` |
| **DML** | `INSERT INTO`, `UPDATE`, `DELETE FROM`, `SELECT * FROM` |
| **TCL** | `START TRANSACTION`, `COMMIT`, `ROLLBACK` |
| **Stored Procedure** | `CREATE PROCEDURE`, `CALL`, `DELIMITER //`, `BEGIN … END`, parâmetros `IN` |
| **Tratamento de erro** | `DECLARE … boolean DEFAULT FALSE`, `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION` |
| **Trigger** | `CREATE TRIGGER … AFTER UPDATE ON …`, `FOR EACH ROW`, `OLD.coluna`, `NEW.coluna`, `DROP TRIGGER` |
| **DCL** | `CREATE USER`, `GRANT ALL PRIVILEGES`, `SHOW GRANTS`, `FLUSH PRIVILEGES`, `DROP USER` |

---

### Estrutura de pastas da Aula `ARQ12`:

```
ARQ12/
├── Bloco1/ (Autocommit + Banco + Tabela LIVROS)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco1.sql
├── Bloco2/ (Transações Manuais — ROLLBACK e COMMIT)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco2.sql
├── Bloco3/ (sp_insere_livros — SP Transacional)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco3.sql
├── Bloco4/ (sp_insere_itempedido — Cenário Real)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco4.sql
├── Bloco5/ (tab_audit + Trigger Audita_Livros)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco5.sql
├── Bloco6/ (sp_altera_livros — Trigger + SP)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco6.sql
├── Bloco7/ (Gestão de Usuários e Privilégios)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco7.sql
├── Bloco8/ (Exercício Integrador)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco8.sql
└── README.md (este arquivo)
```

---

> 💭 *"Transação não é sintaxe — é compromisso. Ou tudo ou nada."*
