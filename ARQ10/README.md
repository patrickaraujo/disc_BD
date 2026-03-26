# Aula ARQ10 — Comando SELECT: Junções, Agregações e Filtros Avançados

Bem-vindo à **Aula ARQ10** da disciplina de **Banco de Dados**. Nesta aula, iniciamos o uso efetivo do comando `SELECT` — o coração da linguagem DML (Data Manipulation Language). Você vai aprender a consultar dados de múltiplas tabelas, aplicar junções, utilizar funções de agregação e construir filtros avançados.

## 🎯 Objetivos da Aula
* Construir um banco de dados prático (`familia02`) para exercitar consultas.
* Compreender e evitar o Produto Cartesiano indevido.
* Dominar os tipos de JOIN: INNER, LEFT, RIGHT e FULL (via UNION ALL).
* Utilizar funções de agregação: `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`, `ROUND`.
* Aplicar `ORDER BY`, `GROUP BY`, `DISTINCT` e `HAVING`.
* Construir filtros com `LIKE`, `BETWEEN`, `IN`, `EXISTS` e subqueries.
* Trabalhar com variáveis SQL e `GROUP_CONCAT`.

---

## 📂 Organização dos Blocos

### [Bloco 01 — Preparação do Ambiente e Introdução ao SELECT](./Bloco1/README.md)
* **Foco:** Montar o banco `familia02`, criar tabelas, inserir dados e estabelecer o relacionamento FK com `ON DELETE CASCADE`.
* **Destaque:** `CREATE DATABASE`, `CREATE TABLE`, `INSERT INTO`, `ALTER TABLE`, `COMMIT`, `ROLLBACK` e o `SELECT *` básico.

### [Bloco 02 — Junções (JOINs) entre Tabelas](./Bloco2/README.md)
* **Foco:** Consultas que relacionam duas ou mais tabelas.
* **Destaque:** Produto Cartesiano, `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, FULL JOIN via `UNION ALL`, exclusão em cascata e integridade referencial na prática.

### [Bloco 03 — Funções de Agregação e Ordenação](./Bloco3/README.md)
* **Foco:** Extrair estatísticas e organizar resultados.
* **Destaque:** `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`, `ROUND`, `ORDER BY`, `GROUP BY`, `DISTINCT`, `HAVING`, `IS NULL` / `IS NOT NULL` e expressões aritméticas.

### [Bloco 04 — Filtros Avançados, Subqueries e Variáveis SQL](./Bloco4/README.md)
* **Foco:** Construir consultas sofisticadas com filtros de padrão, intervalos, listas e subqueries.
* **Destaque:** `LIKE`, `BETWEEN`, `IN` / `NOT IN`, `EXISTS` / `NOT EXISTS`, `TRUNCATE`, variáveis SQL (`SET @var`) e `GROUP_CONCAT`.

---

## 🚀 Como estudar este conteúdo
1. Comece pelo **Bloco 1** para montar o ambiente prático no MySQL Workbench.
2. Siga para o **Bloco 2** para entender como unir tabelas com JOINs.
3. Continue no **Bloco 3** para dominar funções de agregação e agrupamento.
4. Finalize com o **Bloco 4** aplicando filtros avançados e subqueries.

> ⚠️ **Importante:** Execute os comandos SQL de cada bloco **na ordem apresentada**. Cada bloco depende do estado do banco deixado pelo bloco anterior.

---

## 🛠️ Pré-requisitos
* **MySQL** e **MySQL Workbench** instalados e funcionando.
* Conhecimento prévio de DDL (`CREATE`, `ALTER`, `DROP`) e DML básico (`INSERT`, `UPDATE`, `DELETE`).
* O arquivo **COMANDOS-BD-01.sql** como referência completa — cada bloco contém os trechos correspondentes na pasta `codigo-fonte`.

---

## 📌 Importante
* Esta aula é **100% prática** — todo o conteúdo é aplicado diretamente no MySQL Workbench.
* O banco `familia02` (Pai × Filha) é proposital: simples o bastante para focar nos comandos, complexo o bastante para demonstrar junções e integridade referencial.
* Ao final dos 4 blocos, você terá exercitado **todos os principais recursos do SELECT**.

---

### Estrutura de pastas da Aula `ARQ10`:

```
ARQ10/
├── Bloco1/
│   ├── README.md (Preparação do Ambiente + Introdução ao SELECT)
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-01-bloco1.sql
├── Bloco2/
│   ├── README.md (Junções — JOINs)
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-01-bloco2.sql
├── Bloco3/
│   ├── README.md (Funções de Agregação e Ordenação)
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-01-bloco3.sql
├── Bloco4/
│   ├── README.md (Filtros Avançados, Subqueries e Variáveis)
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-01-bloco4.sql
└── README.md (Este arquivo)
```
---

> 💭 *"SELECT é a pergunta. JOIN é o contexto. WHERE é o foco. GROUP BY é a síntese."*
