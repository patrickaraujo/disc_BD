# Aula ARQ14 — Controle de Acesso e Bloqueios de Tabela

Bem-vindo à **Aula ARQ14** da disciplina de **Banco de Dados**. Esta aula é a **continuação direta** da ARQ13 — naquela, confiamos no **InnoDB** para controlar concorrência **implicitamente** durante as transferências bancárias. Aqui, atacamos as duas pontas que ficaram em aberto: **quem pode** acessar (controle de acesso via usuários e privilégios) e **quem pode ao mesmo tempo** (controle explícito de concorrência via `LOCK TABLE`).

> 🧑‍🏫 **Importante:** esta aula é **100% prática** e exige **duas conexões abertas no MySQL Workbench** a partir do Bloco 2. Sem isso, o efeito do `LOCK TABLE` é invisível — o conceito só fica claro quando você vê uma sessão **travar esperando** a outra.

---

## 🎯 Objetivos da Aula

* Administrar **usuários** no MySQL: criar, conceder privilégios, revogar e remover.
* Aplicar o **princípio do menor privilégio** com `GRANT` específico em vez de `GRANT ALL`.
* Trabalhar com **duas sessões simultâneas** no Workbench, identificando cada uma via `CONNECTION_ID()`.
* Diagnosticar estado de sessões com `SHOW PROCESSLIST`.
* Aplicar **`LOCK TABLE READ`** e entender por que o detentor do lock **não pode escrever**.
* Aplicar **`LOCK TABLE WRITE`** e observar **outras sessões travando** à espera do `UNLOCK`.
* Combinar **LOCK explícito + SP transacional com `CONTINUE HANDLER`**, e discutir criticamente **quando essa combinação faz sentido** dado que o InnoDB já faz row-locking automático.

---

## 📂 Organização dos Blocos

A aula está dividida em **quatro blocos práticos**. Os Blocos 2 e 3 **exigem duas sessões abertas** — o efeito do lock é só visível com a interação entre elas.

### [Bloco 01 — Administração: Usuários e Privilégios](./Bloco1/README.md)
* **Foco:** criar usuário, conceder e revogar privilégios, aplicar princípio do menor privilégio.
* **Destaque:** ciclo `CREATE USER → GRANT ALL → REVOKE → GRANT específico → DROP USER`; sintaxe `'usuario'@'host'`.

### [Bloco 02 — Setup de Duas Sessões + LOCK TABLE READ](./Bloco2/README.md)
* **Foco:** criar database `BLOQUEIOS`, abrir 2 conexões no Workbench, aplicar `LOCK TABLE READ`.
* **Destaque:** `SELECT CONNECTION_ID()` para identificar cada sessão; o detentor do `READ` lock **não pode escrever** (contraintuitivo!).

### [Bloco 03 — LOCK TABLE WRITE e Bloqueio Entre Sessões](./Bloco3/README.md)
* **Foco:** aplicar `LOCK TABLE WRITE` na Sessão 1 e observar a Sessão 2 **travar** ao tentar ler/escrever.
* **Destaque:** `SHOW PROCESSLIST` mostrando o estado *"Waiting for table metadata lock"*; comparação **READ (compartilhado)** vs **WRITE (exclusivo)**.

### [Bloco 04 — Integrador: SP Transacional + LOCK Explícito](./Bloco4/README.md)
* **Foco:** tabela `LIVROS`, `sp_insere_livros_02` (recap do padrão HANDLER + COMMIT/ROLLBACK), combinação `LOCK + CALL + UNLOCK`.
* **Destaque:** discussão crítica — **quando** faz sentido `LOCK TABLE` explícito se o InnoDB já protege linhas individualmente?

---

## 🚀 Como estudar este conteúdo

1. Comece pelo **Bloco 1** criando e gerenciando o usuário `rzampar` — entenda o ciclo completo de privilégios.
2. **Antes do Bloco 2**, abra **duas abas de query** no MySQL Workbench (Ctrl+T) ou, melhor ainda, **duas conexões separadas** (`Database → Connect to Database`). Confirme com `SELECT CONNECTION_ID()` que cada aba tem um ID diferente.
3. No **Bloco 2**, observe que o `READ` lock é "amigável com leitores" mas hostil ao próprio detentor para escrita.
4. No **Bloco 3**, observe a Sessão 2 **literalmente travada** esperando o `UNLOCK` da Sessão 1 — é o ponto alto da aula.
5. No **Bloco 4**, combine tudo: usuário com privilégios + lock explícito + SP transacional.

> ⚠️ **Pré-requisitos:** ARQ12 (transações + Triggers) e ARQ13 (SP transacional com `CONTINUE HANDLER`, `START TRANSACTION`, `COMMIT/ROLLBACK`). O Bloco 4 reaproveita esse padrão sem reexplicá-lo.

---

## 🛠️ Ferramentas

* **MySQL** + **MySQL Workbench** com **2 conexões abertas** a partir do Bloco 2.
* `autocommit = 0` durante toda a aula (configurado no Bloco 1).
* Conhecimento prévio:
  * **DDL básica** (`CREATE TABLE`, PK, `AUTO_INCREMENT`) — visto desde ARQ04.
  * **Stored Procedures com `CONTINUE HANDLER`** — visto em ARQ11/ARQ12.
  * **Padrão transacional** com `COMMIT/ROLLBACK` — visto em ARQ12/ARQ13.

---

## 📌 Importante

* Esta aula é **100% prática** — todo o conteúdo é construído no MySQL Workbench.
* Os Blocos 2 e 3 **exigem duas sessões abertas simultaneamente**. Sem isso, o conceito de bloqueio é invisível.
* **Cada bloco contém atividade obrigatória** (`Atividade/README.md`).
* **Cada bloco mantém um arquivo `codigo-fonte/COMANDOS-BD-04-bloco{N}.sql`** — gabarito de referência.

---

## 🎯 Ao Final desta Aula

Você será capaz de:

✅ Gerenciar usuários do MySQL: criar, autenticar, conceder, revogar e remover.
✅ Aplicar **princípio do menor privilégio** em produção (`GRANT` específico, não `GRANT ALL`).
✅ Trabalhar com **múltiplas sessões simultâneas** e diagnosticar concorrência com `SHOW PROCESSLIST`.
✅ Distinguir **`LOCK READ`** (compartilhado) de **`LOCK WRITE`** (exclusivo) e prever o comportamento em cada sessão.
✅ Decidir **quando** usar `LOCK TABLE` explícito vs **quando confiar no row-locking automático** do InnoDB.

---

## 📊 Mapa de Comandos Trabalhados na Aula

| Categoria | Comandos / Construções |
|-----------|------------------------|
| **Configuração de sessão** | `SELECT @@autocommit`, `SET autocommit = 0` |
| **DCL (Data Control Language)** | `CREATE USER … IDENTIFIED BY …`, `GRANT … ON … TO …`, `REVOKE … FROM …`, `SHOW GRANTS FOR …`, `FLUSH PRIVILEGES`, `DROP USER` |
| **Escopos de privilégio** | `*.*`, `db.*`, `db.tabela` |
| **Diagnóstico de sessão** | `SELECT CONNECTION_ID()`, `SHOW PROCESSLIST`, `SELECT * FROM mysql.user` |
| **Bloqueios explícitos** | `LOCK TABLE … READ`, `LOCK TABLE … WRITE`, `UNLOCK TABLES` |
| **SP transacional** (recap) | `DECLARE … CONTINUE HANDLER FOR SQLEXCEPTION`, `COMMIT`, `ROLLBACK` |

---

### Estrutura de pastas da Aula `ARQ14`:

```
ARQ14/
├── Bloco1/ (Usuários e Privilégios)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-04-bloco1.sql
├── Bloco2/ (Setup 2 Sessões + LOCK READ)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-04-bloco2.sql
├── Bloco3/ (LOCK WRITE entre sessões)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-04-bloco3.sql
├── Bloco4/ (SP Transacional + LOCK explícito)
│   ├── README.md
│   ├── Atividade/
│   │   └── README.md
│   └── codigo-fonte/
│       └── COMANDOS-BD-04-bloco4.sql
└── README.md (este arquivo)
```

---

> 💭 *"Em concorrência, o silêncio é o inimigo: uma sessão travada sem aviso é pior do que uma sessão que reclama. `SHOW PROCESSLIST` existe para dar voz a quem está esperando."*
