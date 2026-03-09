# 🟢 Bloco 2 — Comandos DDL de Consulta + DML (INSERT, SELECT, UPDATE, DELETE)

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual

---

## 🎯 O que você vai fazer neste bloco

- Consultar a estrutura do banco com comandos DDL: `SHOW DATABASES`, `SHOW TABLES`, `SHOW GRANTS`, `DESCRIBE`, `SHOW COLUMNS`
- Inserir dados na tabela `Cidade` usando `INSERT INTO` com campo ENUM
- Consultar dados com `SELECT` e `ORDER BY`
- Testar o comportamento do ENUM ao inserir um valor inválido
- Atualizar dados com `UPDATE`
- Excluir dados com `DELETE`
- Compreender o comportamento de `ROLLBACK`, `COMMIT` e `TRUNCATE`

---

## 💡 DDL de consulta vs. DML — Qual a diferença?

Até agora a disciplina focou em **DDL** (Data Definition Language) — comandos que definem a estrutura do banco: `CREATE`, `ALTER`, `DROP`.

Neste bloco, dois grupos de comandos aparecem:

```
DDL de consulta (estrutura):          DML (dados):
  SHOW DATABASES                       INSERT INTO
  SHOW TABLES                          SELECT
  DESCRIBE                             UPDATE
  SHOW COLUMNS                         DELETE
  SHOW GRANTS
```

Os comandos DDL de consulta **leem a estrutura** (tabelas, colunas, tipos). Os comandos DML **manipulam os dados** dentro das tabelas.

---

## 📋 Exercício

### [Exercício 07 — Praticando DML no Banco da Imobiliária](./Exercicio07/README.md)

Usando o banco criado no Exercício 06, você vai executar comandos para consultar a estrutura, inserir cidades com UF (ENUM), consultar os dados inseridos, testar validação do ENUM, e praticar UPDATE, DELETE, ROLLBACK, COMMIT e TRUNCATE.

---

> 💡 O gabarito com todos os comandos SQL está disponível em [`gabarito/DML_Imobiliaria.sql`](./gabarito/DML_Imobiliaria.sql).
