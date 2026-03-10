# 📘 Bloco 1 — Álgebra Relacional + Linguagem SQL (DDL e DCL)

> **Duração estimada:** 50 minutos  
> **Formato:** Exposição teórica + prática guiada

---

## 🎯 O que você vai aprender neste bloco

- Compreender o conceito de Álgebra Relacional e suas operações
- Situar a SQL dentro do contexto da Álgebra Relacional
- Conhecer os subconjuntos da SQL: DDL, DML, DCL e DTL
- Revisar os comandos DDL já praticados (CREATE, DROP, ALTER TABLE)
- Compreender o tratamento de constraints ao apagar tabelas
- Praticar os comandos DCL para gerenciamento de usuários e permissões

---

## 💡 Álgebra Relacional

A **Álgebra Relacional (AR)** é um conjunto de operações matemáticas usadas para manipular relações (tabelas) em um banco de dados relacional. Toda operação da AR recebe uma ou mais relações como entrada e produz uma nova relação como resultado — ou seja, o resultado de uma consulta é sempre apresentado na forma de uma tabela.

Na prática, os programadores não utilizam a AR diretamente. Ela serve como **fundamentação teórica** para a linguagem SQL. Compreender a AR ajuda a entender a lógica por trás dos comandos SQL, especialmente o `SELECT`.

### Operações da Álgebra Relacional

As operações são divididas em dois grupos:

**Operações Específicas:**

- **Seleção (σ):** Filtra linhas de uma relação com base em uma condição. Equivale à cláusula `WHERE` do SQL.
- **Projeção (π):** Seleciona colunas específicas de uma relação. Equivale a listar colunas no `SELECT`.
- **Junção (⋈):** Combina tuplas de duas relações com base em uma condição de correspondência. Equivale ao `JOIN` do SQL.

**Operações de Conjuntos:**

- **União (∪):** Combina todas as tuplas de duas relações, eliminando duplicatas. Equivale ao `UNION`.
- **Interseção (∩):** Retorna apenas as tuplas presentes em ambas as relações. Equivale ao `INTERSECT`.
- **Diferença (−):** Retorna as tuplas da primeira relação que não estão na segunda. Equivale ao `EXCEPT`.
- **Produto Cartesiano (×):** Combina cada tupla de uma relação com todas as tuplas de outra. Equivale ao `CROSS JOIN`.

---

## 💡 Linguagem SQL — Organização

A **SQL (Structured Query Language)** é a linguagem padrão para bancos de dados relacionais. Ela pode ser utilizada de duas formas: embutida em linguagens de programação (Java, Python, etc.) ou diretamente no SGBD via Query Editor.

A SQL é organizada em subconjuntos conforme a finalidade dos comandos:

```
┌──────────────────────────────────────────────────────────────┐
│                     LINGUAGEM SQL                            │
├────────────┬────────────┬────────────┬───────────────────────┤
│    DDL     │    DML     │    DCL     │     DTL / TCL         │
│ Definition │ Manipulat. │  Control   │   Transaction         │
├────────────┼────────────┼────────────┼───────────────────────┤
│ CREATE     │ INSERT     │ CREATE USER│ BEGIN TRANSACTION     │
│ ALTER      │ SELECT     │ GRANT      │ COMMIT                │
│ DROP       │ UPDATE     │ REVOKE     │ ROLLBACK              │
│ TRUNCATE   │ DELETE     │ DROP USER  │ SAVEPOINT             │
│ RENAME     │            │ SHOW GRANTS│                       │
└────────────┴────────────┴────────────┴───────────────────────┘
```

Diferentes profissionais utilizam diferentes partes da SQL:
- O **programador** usa principalmente DDL e DML para criar estruturas e manipular dados.
- O **DBA** (Administrador de BD) usa DCL para gerenciar acesso, e DTL para controlar transações.

---

## 💡 Revisão DDL — Tratamento de Constraints

Ao apagar uma tabela que fornece sua PK como FK para outra tabela, o MySQL retorna um erro de integridade referencial. Para resolver, é necessário **apagar a constraint** antes de apagar a tabela:

```sql
-- Erro: não é possível apagar a tabela diretamente
DROP TABLE nome_tabela;   -- ❌ Error: foreign key constraint fails

-- Solução: apagar a constraint primeiro, depois a tabela
ALTER TABLE tabela_dependente DROP CONSTRAINT nome_constraint;
DROP TABLE nome_tabela;   -- ✅ Agora funciona
```

---

## 💡 DCL — Data Control Language

Os comandos DCL gerenciam **quem** pode acessar o banco e **o que** cada usuário pode fazer. Os principais comandos são:

| Comando | Função |
|---------|--------|
| `CREATE USER` | Cria um novo usuário no SGBD |
| `GRANT` | Concede permissões a um usuário |
| `REVOKE` | Revoga permissões concedidas |
| `SHOW GRANTS` | Exibe as permissões de um usuário |
| `FLUSH PRIVILEGES` | Efetiva as mudanças de permissão |
| `DROP USER` | Remove um usuário do SGBD |

---

## 📋 Exercício

### [Exercício 08 — Praticando DCL no MySQL](./Exercicio08/README.md)

Neste exercício você vai criar um usuário, conceder e revogar permissões, consultar os privilégios e apagar o usuário — tudo via Query Editor no Workbench.

> ⚠️ Nos slides, este exercício aparece como "Exercício 07". A numeração sequencial da disciplina o identifica como **Exercício 08**.

---

> 💡 Ao finalizar este bloco, avance para o Bloco 2 para praticar os comandos DML.
