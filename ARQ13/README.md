# Aula ARQ13 — Transferências Bancárias com Auditoria

Bem-vindo à **Aula ARQ13** da disciplina de **Banco de Dados**. Esta aula é a **continuação prática** da ARQ12 — o cenário muda da **livraria** para o **mundo financeiro**, e o foco principal passa de "auditar uma alteração simples" para um problema mais ambicioso: **garantir a integridade de uma transferência bancária**, evolução de uma SP e trilhas de auditoria balanceadas.

> 🧑‍🏫 **Importante:** assim como a ARQ12, esta é uma aula **100% prática**. Os blocos guiam **o que construir** e **o que observar**, mas **não entregam o código pronto**. Algumas técnicas pouco vistas em sala (a sequência de `SET` do Forward Engineering, `INDEX … VISIBLE`, `ON DELETE NO ACTION`, e o padrão `@conta = SELECT … WHERE …` para validar existência) são apresentadas e explicadas explicitamente.

---

## 🎯 Objetivos da Aula

* Modelar e implementar um **schema relacional** com 3 tabelas e 2 chaves estrangeiras.
* Aplicar a sequência de **`SET`s** que o MySQL Workbench gera em `Forward Engineering`.
* Construir uma **Stored Procedure transacional com validação aninhada** (parâmetros → saldo → transação).
* Identificar, em estudo de caso, as **falhas silenciosas** de uma SP mal validada (incluindo o cenário em que "dinheiro desaparece").
* Reescrever a SP em **versão mais robusta**, com validação de existência das contas e do valor.
* Criar uma **Trigger de auditoria financeira** que registra `saldo_antigo`, `valor_transacao` e `saldo_novo` para cada `UPDATE` em `Conta`.
* Resolver, ao final, um **exercício integrador** com SPs de operação unitária (`sp_saque` e `sp_deposito`).

---

## 📂 Organização dos Blocos

A aula está dividida em **oito blocos práticos**. Os blocos são cumulativos — o **estado do banco de dados** é construído ao longo da sequência. Execute na ordem.

### [Bloco 01 — Modelagem do Schema Financeiro: Diagrama ER e Forward Engineering](./Bloco1/README.md)
* **Foco:** ler o diagrama ER, identificar entidades/cardinalidades e entender a sequência de `SET`s do MySQL Workbench.
* **Destaque:** `SET @OLD_UNIQUE_CHECKS=…`, `SET FOREIGN_KEY_CHECKS=0`, `SET SQL_MODE=…`.

### [Bloco 02 — Schema Financeiro + Tabelas Cliente e TipoConta](./Bloco2/README.md)
* **Foco:** criar o schema `Financeiro` e as duas tabelas "satélite" (`Cliente` e `TipoConta`) com `AUTO_INCREMENT`.
* **Destaque:** `CREATE SCHEMA IF NOT EXISTS`, `INT NOT NULL AUTO_INCREMENT`, `INSERT` sem informar a coluna `AUTO_INCREMENT`.

### [Bloco 03 — Tabela Conta: PK Composta e Chaves Estrangeiras](./Bloco3/README.md)
* **Foco:** criar a tabela central `Conta` com **chave primária composta**, **dois `INDEX`** (um por FK) e **dois `CONSTRAINT FOREIGN KEY`** com `ON DELETE NO ACTION`.
* **Destaque:** `INDEX … VISIBLE`, `CONSTRAINT … FOREIGN KEY … ON DELETE NO ACTION ON UPDATE NO ACTION`.

### [Bloco 04 — Stored Procedure de Transferência Bancária (v1)](./Bloco4/README.md)
* **Foco:** construir `sp_transf_bancaria` com **validação aninhada de 3 níveis** (parâmetros → saldo → transação) e **dois `UPDATE`s encadeados** (debita origem + credita destino).
* **Destaque:** uso de variáveis de sessão (`@saldo_origem`) para capturar dados antes de decidir.

### [Bloco 05 — Aprendendo com falhas: análise crítica da v1](./Bloco5/README.md)
* **Foco:** estudar **três cenários de falha silenciosa** da v1: conta inexistente como origem, conta inexistente como destino (o **"dinheiro que some"**), valor zero/negativo.
* **Destaque:** discussão sobre `NULL` em comparações SQL e diagnóstico errado.

### [Bloco 06 — Stored Procedure de Transferência (v2 — validação robusta)](./Bloco6/README.md)
* **Foco:** reescrever a SP como `sp_transf_bancaria02`, usando `@conta_origem` e `@conta_destino` para validar **existência** das contas antes de qualquer operação.
* **Destaque:** padrão `SET @x = (SELECT coluna FROM tabela WHERE …)` como mecanismo de validação.

### [Bloco 07 — Auditoria de Transações com Trigger](./Bloco7/README.md)
* **Foco:** criar a tabela `AuditFin` e a Trigger `tg_Audita_Fin` (`AFTER UPDATE ON CONTA`), que registra `saldo_antigo`, `valor_transacao` e `saldo_novo`.
* **Destaque:** cada transferência gera **2 linhas espelhadas** em `AuditFin` (uma com valor negativo, uma com valor positivo) — soma sempre zero.

### [Bloco 08 — Exercício Integrador: sp_saque e sp_deposito](./Bloco8/README.md)
* **Foco:** entrega final — implementar duas SPs unitárias (`sp_saque` e `sp_deposito`) com validação robusta e suporte automático à auditoria.
* **Destaque:** sem código guia. Apenas requisitos funcionais e critérios de validação.

---

## 🚀 Como estudar este conteúdo

1. Comece pelo **Bloco 1** entendendo o diagrama ER e cada um dos 3 `SET`s — eles aparecem em todo script gerado pelo Workbench.
2. Crie o schema e as tabelas "satélite" no **Bloco 2**.
3. Construa a tabela central no **Bloco 3** com atenção especial à PK composta e às FKs.
4. Implemente sua primeira SP transacional complexa no **Bloco 4** — observe a estrutura de `IF` aninhado.
5. **Não pule o Bloco 5** — é nele que você descobre as falhas da v1 que motivam a v2.
6. Reescreva a SP no **Bloco 6** corrigindo as falhas identificadas.
7. Adicione a Trigger no **Bloco 7** e observe a "trilha simétrica" da auditoria.
8. Resolva o **Bloco 8** sem consultar o código-fonte dos blocos anteriores.

> ⚠️ **Pré-requisitos:** este material assume que você concluiu a **ARQ12** (controle transacional, tratamento de erro com `CONTINUE HANDLER`, Triggers de auditoria) e domina os comandos do "trio" (`DECLARE erro_sql`, `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION`, `START TRANSACTION`).

---

## 🛠️ Ferramentas

* **MySQL** + **MySQL Workbench**.
* `autocommit = 0` durante toda a aula (ou use `START TRANSACTION` em cada bloco do Bloco 4 em diante).
* Conhecimento prévio:
  * **DDL completa** (`CREATE TABLE`, FKs, índices) — visto em ARQ04 a ARQ08.
  * **Stored Procedures e Triggers** — vistos em ARQ11.
  * **Padrão transacional** com handler de erro — visto em ARQ12.

---

## 📌 Importante

* Esta aula é **100% prática** — todo o conteúdo é construído diretamente no MySQL Workbench.
* **O guia não entrega código pronto**, exceto para os comandos abaixo, que merecem destaque e explicação:
  * Sequência inicial do **Forward Engineering**: `SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;`, `SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;`, `SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='…';`.
  * `INDEX nome_idx (coluna ASC) VISIBLE` — sintaxe usada pelo Workbench na criação de índices em FK.
  * `CONSTRAINT … FOREIGN KEY … ON DELETE NO ACTION ON UPDATE NO ACTION` — sintaxe completa de FK.
  * `SET @variavel = (SELECT coluna FROM tabela WHERE …)` — padrão para capturar valor (ou `NULL`) de uma consulta em variável de sessão.
* **Cada bloco contém atividade obrigatória** (`Atividade/README.md`).
* **Cada bloco mantém um arquivo `codigo-fonte/COMANDOS-BD-03-bloco{N}.sql`** — gabarito de referência.

---

## 🎯 Ao Final desta Aula

Você será capaz de:

✅ Ler um diagrama ER e implementá-lo em SQL respeitando cardinalidades e FKs.
✅ Aplicar a sequência de `SET`s do Forward Engineering com consciência do que cada um faz.
✅ Construir SPs transacionais com **validação multinível** antes da transação.
✅ Identificar **falhas silenciosas** em SPs e corrigi-las em uma versão robusta.
✅ Implementar auditoria financeira com `valor_transacao = NEW − OLD`.
✅ Resolver, de forma autônoma, um cenário completo de operações financeiras unitárias.

---

## 📊 Mapa de Comandos Trabalhados na Aula

| Categoria | Comandos / Construções |
|-----------|------------------------|
| **Forward Engineering** | `SET @OLD_X=@@X`, `SET FOREIGN_KEY_CHECKS`, `SET UNIQUE_CHECKS`, `SET SQL_MODE` |
| **DDL** | `CREATE SCHEMA IF NOT EXISTS`, `INT NOT NULL AUTO_INCREMENT`, **PK composta**, `INDEX … VISIBLE`, `CONSTRAINT … FOREIGN KEY … ON DELETE NO ACTION ON UPDATE NO ACTION` |
| **DML** | `TRUNCATE` em ordem reversa de FK, `INSERT INTO tabela (cols) VALUES (...)` (omitindo `AUTO_INCREMENT`) |
| **Variáveis de sessão** | `SET @saldo_origem = (SELECT … WHERE …)`, `SET @conta_X = (SELECT … WHERE …)` |
| **Stored Procedure** | `IF` aninhado de 3 níveis, `START TRANSACTION` dentro de bloco condicional, mensagens distintas por caminho |
| **Trigger** | `AFTER UPDATE ON CONTA`, cálculo `NEW.SALDO - OLD.SALDO` |
| **Auditoria** | `DECIMAL(9,2)` para valores financeiros, `dataautitoria DATE` |

---

### Estrutura de pastas da Aula `ARQ13`:

```
ARQ13/
├── Bloco1/ (Modelagem ER + Forward Engineering)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco1.sql
├── Bloco2/ (Schema + Cliente + TipoConta)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco2.sql
├── Bloco3/ (Tabela Conta com PK composta e FKs)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco3.sql
├── Bloco4/ (sp_transf_bancaria — v1)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco4.sql
├── Bloco5/ (Análise crítica das falhas da v1)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco5.sql
├── Bloco6/ (sp_transf_bancaria02 — v2 robusta)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco6.sql
├── Bloco7/ (Trigger tg_Audita_Fin + AuditFin)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco7.sql
├── Bloco8/ (Exercício Integrador — sp_saque + sp_deposito)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-03-bloco8.sql
└── README.md (este arquivo)
```

---

> 💭 *"Em transferência bancária, atomicidade não é teoria — é a diferença entre 'sistema funcionando' e 'cliente sem dinheiro'."*
