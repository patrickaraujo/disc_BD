# Aula ARQ08 — Prática Completa: DER com ENUM + Comandos DML (INSERT, SELECT, UPDATE, DELETE)

Bem-vindo à **Aula ARQ08**, aula de laboratório da disciplina de **Banco de Dados**. O foco desta aula é construir um modelo mais robusto — um sistema de **imobiliária para aluguel de imóveis** — e praticar os primeiros comandos de **manipulação de dados** (DML) no banco criado.

## 🎯 Objetivos da Aula
* Criar um DER com **8 tabelas** inter-relacionadas no MySQL Workbench.
* Utilizar tipos de dados variados: INT, SMALLINT, VARCHAR, DECIMAL, DATE e **ENUM**.
* Gerar o modelo físico via Forward Engineering e verificar a estrutura no MySQL.
* Executar comandos DDL de consulta à estrutura: `SHOW`, `DESCRIBE`.
* Praticar os comandos DML fundamentais: `INSERT`, `SELECT`, `UPDATE`, `DELETE`.
* Compreender o comportamento de `ROLLBACK`, `COMMIT` e `TRUNCATE`.

---

## 📂 Organização dos Blocos

### [Bloco 01 — Criar o DER da Imobiliária e Gerar o Modelo Físico](./Bloco1/README.md)
* **Foco:** Construir o DER completo com 8 tabelas, definir colunas, tipos, chaves e relacionamentos. Gerar o banco físico via Forward Engineering.
* **Exercício:**
  * [Exercício 06 — Criar o DER da Imobiliária](./Bloco1/Exercicio06/README.md)

### [Bloco 02 — Comandos DDL de Consulta + DML (INSERT, SELECT, UPDATE, DELETE)](./Bloco2/README.md)
* **Foco:** Consultar a estrutura do banco com comandos DDL e praticar inserção, consulta, atualização e exclusão de dados.
* **Exercício:**
  * [Exercício 07 — Praticando DML no Banco da Imobiliária](./Bloco2/Exercicio07/README.md)

---

## 🚀 Como estudar este conteúdo
1. No **Bloco 1**, siga o Exercício 06 para criar o DER completo e gerar o banco físico.
2. No **Bloco 2**, use o banco criado para executar os comandos DML do Exercício 07.
3. Preste atenção especial ao tipo **ENUM** — é a primeira vez que ele aparece na disciplina.
4. Guarde os arquivos `.mwb` e `.sql` gerados.

---

## 📌 Importante
* Esta aula marca a **transição de DDL para DML** — você deixa de apenas criar estruturas e passa a manipular dados.
* O modelo da imobiliária é significativamente mais complexo que o `TabMae/TabFilha` das aulas anteriores — são 8 tabelas com múltiplos relacionamentos.
* Os comandos `ROLLBACK`, `COMMIT` e `TRUNCATE` podem ter comportamentos diferentes dependendo do modo de autocommit do MySQL — observe os resultados com atenção.

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
| **08** | **18/03** | **← VOCÊ ESTÁ AQUI** — DER Imobiliária + DML (ARQ08) |

---

### Estrutura de pastas da Aula `ARQ08`:

```
ARQ08/
├── Bloco1/
│   ├── README.md (Criar o DER da Imobiliária)
│   └── Exercicio06/
│       ├── README.md (Passo a passo do DER)
│       └── Arquivos/
│           └── Imobiliaria.sql (Script de criação — gabarito)
├── Bloco2/
│   ├── README.md (Comandos DDL de consulta + DML)
│   ├── Exercicio07/
│   │   └── README.md (Praticando DML)
│   └── gabarito/
│       └── DML_Imobiliaria.sql (Todos os comandos DML da aula)
└── README.md (Este arquivo)
```

---

> 💭 *"DDL constrói a casa. DML é o dia a dia de quem mora nela — entra dado, sai dado, muda dado."*
