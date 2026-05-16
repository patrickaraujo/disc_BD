# 📘 Bloco 3 — LOCK TABLE WRITE e Bloqueio Entre Sessões

> **Duração estimada:** 50 minutos
> **Objetivo:** Aplicar **`LOCK TABLE WRITE`** na Sessão 1 e observar o **bloqueio total** que isso impõe à Sessão 2 — incluindo **leitura**. Comparar formalmente os dois tipos de lock e fixar `SHOW PROCESSLIST` como ferramenta de diagnóstico.
> **Modalidade:** Guiada — **exige duas sessões abertas** (mesma configuração do Bloco 2).

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Aplicado **`LOCK TABLE messages WRITE`** na Sessão 1.
- Confirmado que a **Sessão 1 pode tudo** (ler **e** escrever) com o `WRITE` lock.
- Observado a **Sessão 2 travando** ao tentar **ler** (não apenas escrever!) — diferença marcante em relação ao `READ` lock.
- Diagnosticado o bloqueio entre sessões via `SHOW PROCESSLIST`.
- Construído a **tabela comparativa completa** entre `READ` lock e `WRITE` lock.

---

## 💡 Antes de começar — o salto conceitual deste bloco

No Bloco 2, o `READ` lock travou apenas a **escrita** das outras sessões. As leituras coexistiam pacificamente. Agora, no Bloco 3, vamos ver um lock **mais agressivo**:

| Pergunta | `READ` lock (Bloco 2) | `WRITE` lock (este bloco) |
|----------|----------------------|---------------------------|
| Outras sessões podem **ler**? | ✅ Sim | ⛔ **Não** — travam |
| Outras sessões podem **escrever**? | ⛔ Não — travam | ⛔ **Não** — travam |
| O **detentor** pode ler? | ✅ Sim | ✅ Sim |
| O **detentor** pode escrever? | ⛔ Não (erro 1099) | ✅ **Sim** |

A diferença é dramática: o `WRITE` lock dá ao detentor **monopólio total** sobre a tabela e suspende **toda atividade** das demais sessões.

> ⚠️ **Pré-requisito:** o database `BLOQUEIOS` e a tabela `messages` devem existir (criados no Bloco 2). Se você fechou o Workbench entre os blocos, recrie a tabela e abra novamente as duas sessões.

---

## 🧭 Passo 1 — Restaurar o cenário das duas sessões

Confirme:

```sql
-- [S1]
USE BLOQUEIOS;
SELECT CONNECTION_ID();
```

```sql
-- [S2]
USE BLOQUEIOS;
SELECT CONNECTION_ID();
```

Os IDs devem ser **diferentes**. Se forem iguais, abra nova aba (`Ctrl+T`).

Estado esperado da tabela `messages` (vindo do Bloco 2): contém `'Hello'` e `'Bye'`. Se preferir, limpe e re-insira:

```sql
-- [S1]
TRUNCATE TABLE messages;
INSERT INTO messages(message) VALUES('Hello');
COMMIT;
```

---

## 🧭 Passo 2 — Aplicar o `WRITE` lock na Sessão 1

```sql
-- [S1]
LOCK TABLE messages WRITE;
```

Pronto. A Sessão 1 agora detém **monopólio total** sobre `messages`.

---

## 🧭 Passo 3 — Confirmar que o detentor pode tudo

```sql
-- [S1]
SELECT * FROM messages;       -- ✅ funciona
INSERT INTO messages(message) VALUES('Good Morning');  -- ✅ funciona
SELECT * FROM messages;       -- ✅ vê as 3 mensagens
COMMIT;                       -- ✅ commit funciona
```

Diferença chave em relação ao `READ` lock: aqui o `INSERT` da Sessão 1 **funciona**, porque o `WRITE` lock é o lock de **propriedade plena** sobre a tabela.

> 💡 **Mnemônico:** `WRITE` lock = "eu sou o dono temporário desta tabela; ninguém entra, nem pra olhar".

---

## 🧭 Passo 4 — Tentar ler na Sessão 2

```sql
-- [S2]
SELECT * FROM messages;
```

⏳ **TRAVA.** O cursor fica girando. Diferente do Bloco 2, aqui **nem leitura passa**.

**Deixe a S2 travada.**

---

## 🧭 Passo 5 — Diagnosticar com `SHOW PROCESSLIST`

```sql
-- [S1]
SHOW PROCESSLIST;
```

Saída esperada:

```
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
| Id | User   | Host      | db        | Command | Time | State                  | Info                             |
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
| 42 | root   | localhost | BLOQUEIOS | Query   | 0    | starting               | SHOW PROCESSLIST                 |
| 43 | root   | localhost | BLOQUEIOS | Query   | 12   | Waiting for table lock | SELECT * FROM messages           |
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
```

Note que o **`Info`** agora mostra um **`SELECT`** travado — o que **não acontecia** no Bloco 2. Sob `READ` lock, leituras passam; sob `WRITE` lock, nem leituras passam.

---

## 🧭 Passo 6 — Tentar também escrever na Sessão 2

Volte para S2. Você verá que o `SELECT` ainda está travado. **Você não consegue rodar nenhum comando novo enquanto o anterior estiver pendente** na mesma aba.

> 💡 **Workaround:** abra uma **terceira aba** (`Ctrl+T` de novo) — chame-a de S3 — e teste em paralelo. Lá execute:

```sql
-- [S3]
USE BLOQUEIOS;
INSERT INTO messages(message) VALUES('Tentativa de S3');
```

A S3 **também trava**. Em `SHOW PROCESSLIST` (rodando em S1), você verá agora **duas linhas em espera** — a S2 esperando para ler e a S3 esperando para escrever.

---

## 🧭 Passo 7 — Liberar o lock

```sql
-- [S1]
UNLOCK TABLES;
```

**Imediatamente** as sessões em espera destravam. O `SELECT` da S2 retorna os 3 registros. O `INSERT` da S3 processa e fica disponível para `COMMIT`.

```sql
-- [S3]
COMMIT;
SELECT * FROM messages;
-- agora vê 4 linhas: Hello, Good Morning, Tentativa de S3 (+ Bye se ainda estava lá)
```

---

## 📊 Tabela comparativa — `READ` lock vs `WRITE` lock

Esta é **a tabela mais importante da aula**. Imprima ou anote.

| Cenário | `LOCK READ` (Bloco 2) | `LOCK WRITE` (este bloco) |
|---------|----------------------|---------------------------|
| **Sessão detentora — `SELECT`** | ✅ funciona | ✅ funciona |
| **Sessão detentora — `INSERT/UPDATE/DELETE`** | ⛔ erro 1099 | ✅ funciona |
| **Outras sessões — `SELECT`** | ✅ funciona (compartilhado) | ⛔ trava (esperando) |
| **Outras sessões — `INSERT/UPDATE/DELETE`** | ⛔ trava (esperando) | ⛔ trava (esperando) |
| **Tipo de lock** | Compartilhado (`S` — Shared) | Exclusivo (`X` — Exclusive) |
| **Múltiplos detentores simultâneos** | ✅ Sim (várias sessões podem ter `READ` ao mesmo tempo) | ⛔ Não (no máximo 1 detentor) |
| **Caso de uso típico** | Snapshot consistente para relatório longo | Operação de manutenção exclusiva |

### Visualização do impacto

```
   ┌──────────────────────────────────────────────────────────────┐
   │                       LOCK READ (S1)                         │
   ├──────────────────────────────────────────────────────────────┤
   │                                                              │
   │   S1: SELECT ✅   INSERT ⛔   |   S2: SELECT ✅   INSERT ⛔  │
   │                                                              │
   │   "Todo mundo lê, ninguém escreve."                          │
   └──────────────────────────────────────────────────────────────┘

   ┌──────────────────────────────────────────────────────────────┐
   │                       LOCK WRITE (S1)                        │
   ├──────────────────────────────────────────────────────────────┤
   │                                                              │
   │   S1: SELECT ✅   INSERT ✅   |   S2: SELECT ⛔   INSERT ⛔  │
   │                                                              │
   │   "Só o detentor faz qualquer coisa. Os demais esperam."     │
   └──────────────────────────────────────────────────────────────┘
```

---

## 💡 Por que existem dois tipos de lock?

| Tipo | Para que serve |
|------|----------------|
| **`READ`** (shared) | Garantir que a tabela **não mude** enquanto você gera relatório, faz backup lógico ou consulta consistente. **Você não vai escrever**, mas precisa de garantia de que ninguém escreve. |
| **`WRITE`** (exclusive) | Garantir que **só você** opera na tabela durante manutenção crítica: migrações de dados, reorganizações, operações batch que precisam de coerência total. |

Em ambos os casos, o lock é uma forma de **comunicar intenção** ao servidor: "vou fazer X, garanta-me o ambiente apropriado".

> 💡 **`READ` lock é "defensivo"** — você se protege contra mudanças alheias.
> **`WRITE` lock é "ofensivo"** — você impede que qualquer um interfira.

---

## ⚠️ Custos do `LOCK TABLE`

Locks de tabela são **caros** quando há muitas sessões competindo:

* **Tempo de espera**: cada sessão bloqueada fica dormindo até o `UNLOCK`. Em produção com alta carga, isso vira gargalo.
* **Granularidade grosseira**: trava a tabela **inteira**, mesmo que você só vá tocar em uma linha.
* **Não dá deadlock**, mas pode dar **starvation** (sessão eternamente preterida).

Para casos em que a granularidade fina é necessária — travar **apenas uma linha** — o InnoDB oferece **row-level locking automático** quando você usa transações. É exatamente isso que veremos no Bloco 4 e o porquê de a combinação `LOCK + SP transacional` ser usada com cuidado.

---

## ✏️ Atividade Prática

### 📝 Atividade 3 — Bloqueio total entre sessões

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Reproduzir o cenário com 2 (ou 3) sessões.
- Cronometrar o tempo de espera observado.
- Completar a tabela comparativa `READ` vs `WRITE` a partir de experimentação direta.
- Discutir cenários reais em que cada tipo de lock faz sentido.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-04-bloco3.sql](./codigo-fonte/COMANDOS-BD-04-bloco3.sql)

---

## ✅ Resumo do Bloco 3

Neste bloco você:

- Aplicou `LOCK TABLE messages WRITE` na Sessão 1.
- Confirmou que o detentor do `WRITE` lock **pode tudo** (ler e escrever).
- Observou a Sessão 2 **travar até para ler** — diferença chave em relação ao `READ` lock.
- Diagnosticou o bloqueio com `SHOW PROCESSLIST` mostrando `"Waiting for table lock"` em **`SELECT`s** (não apenas em `INSERT`s).
- Construiu a tabela comparativa completa entre `READ` (compartilhado) e `WRITE` (exclusivo).
- Refletiu sobre os custos de granularidade grosseira do `LOCK TABLE`.

---

## 🎯 Conceitos-chave para fixar

💡 **`WRITE` lock é exclusivo**: bloqueia até as leituras de outras sessões.

💡 **O detentor do `WRITE` lock tem monopólio total** — pode ler, escrever, commitar.

💡 **No máximo um detentor** de `WRITE` por vez; várias sessões podem ter `READ` simultaneamente.

💡 **`SHOW PROCESSLIST` mostra `SELECT`s travados** sob `WRITE` lock — algo impossível sob `READ`.

💡 **Granularidade de tabela é grosseira**: travar a tabela inteira para tocar em uma linha é caro. InnoDB oferece row-level locking automático em transações.

---

## ➡️ Próximos Passos

Você já domina os dois tipos de lock e sabe diagnosticar bloqueios. No Bloco 4 vamos **combinar** o `LOCK TABLE WRITE` com a SP transacional do padrão ARQ12/ARQ13 (HANDLER + COMMIT/ROLLBACK) — e fazer a discussão crítica: **isso é redundante com o InnoDB ou agrega algo?**

Acesse: [📁 Bloco 4](../Bloco4/README.md)

---

> 💭 *"Lock de escrita é o sinal de 'tabela em manutenção — volte mais tarde'. Em alguns casos é a única forma honesta de operar. Em outros, é overkill com um custo gigante. Saber diferenciar é o que separa o DBA do estagiário."*
