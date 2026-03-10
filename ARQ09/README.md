# Aula ARQ09 — Álgebra Relacional, Linguagem SQL e Prática DML (INSERT, UPDATE, DELETE)

Bem-vindo à **Aula ARQ09**, aula teórico-prática da disciplina de **Banco de Dados**. Nesta aula você conhecerá os fundamentos da Álgebra Relacional, entenderá a organização da linguagem SQL em seus subconjuntos (DDL, DML, DCL, DTL) e praticará os comandos de manipulação de dados no banco da imobiliária criado na aula anterior.

## 🎯 Objetivos da Aula
* Compreender os conceitos da **Álgebra Relacional** e suas operações (Seleção, Projeção, Junção, União, Interseção, Diferença e Produto Cartesiano).
* Conhecer a organização da **linguagem SQL** e seus subconjuntos: DDL, DML, DCL e DTL.
* Revisar os principais comandos **DDL** (CREATE, DROP, ALTER TABLE) e compreender o tratamento de constraints.
* Praticar comandos **DCL** (CREATE USER, GRANT, REVOKE, DROP USER) no MySQL.
* Aprofundar a prática dos comandos **DML**: INSERT, SELECT, UPDATE e DELETE.
* Compreender o comportamento de **ROLLBACK** em diferentes cenários.

---

## 📂 Organização dos Blocos

### [Bloco 01 — Álgebra Relacional + Linguagem SQL (DDL e DCL)](./Bloco1/README.md)
* **Foco:** Teoria da Álgebra Relacional, organização da SQL, revisão DDL e prática DCL.
* **Exercício:**
  * [Exercício 08 — Praticando DCL no MySQL](./Bloco1/Exercicio08/README.md)

### [Bloco 02 — Prática DML: INSERT, UPDATE e DELETE](./Bloco2/README.md)
* **Foco:** Sintaxe detalhada dos comandos DML e prática no banco da imobiliária (tabela Cidade).
* **Exercícios:**
  * [Exercício 09 — INSERT e UPDATE na Tabela Cidade](./Bloco2/Exercicio09/README.md)
  * [Exercício 10 — UPDATE em Massa, DELETE e ROLLBACK](./Bloco2/Exercicio10/README.md)

---

## 🚀 Como estudar este conteúdo
1. Leia o **Bloco 1** para compreender a Álgebra Relacional e a organização da SQL.
2. No Exercício 08, pratique os comandos DCL no Workbench — crie usuários, conceda e revogue permissões.
3. No **Bloco 2**, siga os Exercícios 09 e 10 no banco da imobiliária (schema `imobiliaria`).
4. Preste atenção especial ao comportamento do **ROLLBACK** — o resultado depende do modo de autocommit do MySQL.

---

## 📌 Importante
* O banco da imobiliária (schema `imobiliaria`) deve estar criado e vazio (resultado da Aula 08 / Exercício 06).
* Se você executou o `TRUNCATE TABLE Cidade` no Exercício 07 da aula anterior, a tabela está pronta para receber novos dados.
* Os exercícios dos slides estão referenciados como "Exercício 07, 08 e 09". Neste repositório, a numeração sequencial da disciplina os identifica como **Exercícios 08, 09 e 10** (continuando de onde a Aula 08 parou).

---

## 📍 Posição no Cronograma

| Aula | Data | Conteúdo |
|------|------|----------|
| 01 | 04/02 | Apresentação, plano pedagógico, contexto (ARQ01) |
| 02 | 09/02 | Introdução a BD — SGBD, arquitetura, papéis (ARQ02) |
| 03 | 11/02, 23/02, 25/02 | Modelagem Conceitual — MER (ARQ03) |
| 04 | 04/03 | DER + primeira prática no Workbench (ARQ04) |
| 05 | 09/03 | Normalização — 1ª a 4ª Forma Normal (ARQ05) |
| 06 | 11/03 | Laboratório: DER, Forward Engineering e DDL manual (ARQ06) |
| 07 | 16/03 | Sincronização DER ↔ BD + Tipos de Dados (ARQ07) |
| 08 | 18/03 | DER Imobiliária + DML (ARQ08) |
| **09** | **23/03** | **← VOCÊ ESTÁ AQUI** — Álgebra Relacional, SQL e Prática DML (ARQ09) |

---

### Estrutura de pastas da Aula `ARQ09`:

```
ARQ09/
├── Bloco1/
│   ├── README.md (Álgebra Relacional + SQL: DDL e DCL)
│   └── Exercicio08/
│       ├── README.md (Praticando DCL)
│       └── codigo-fonte/
│           └── Gabarito_DCL.sql
├── Bloco2/
│   ├── README.md (DML: INSERT, UPDATE, DELETE)
│   ├── Exercicio09/
│   │   ├── README.md (INSERT + UPDATE pontual)
│   │   └── codigo-fonte/
│   │       └── Gabarito_Exercicio09.sql
│   └── Exercicio10/
│       ├── README.md (UPDATE em massa, DELETE, ROLLBACK)
│       └── codigo-fonte/
│           └── Gabarito_Exercicio10.sql
└── README.md (Este arquivo)
```

---

> 💭 *"A Álgebra Relacional é a matemática por trás da SQL. Você não vai usá-la no dia a dia, mas entendê-la transforma o SELECT de receita decorada em ferramenta compreendida."*
