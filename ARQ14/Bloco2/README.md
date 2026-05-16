# 📘 Bloco 2 — Setup de Duas Sessões + LOCK TABLE READ

> **Duração estimada:** 55 minutos
> **Objetivo:** Preparar o cenário de **duas conexões simultâneas** no MySQL Workbench, identificar cada sessão via `CONNECTION_ID()` e aplicar **`LOCK TABLE READ`** para observar o comportamento contraintuitivo: **quem detém o `READ` lock NÃO pode escrever**.
> **Modalidade:** Guiada — **exige duas conexões abertas** no Workbench. Sem isso, o efeito do lock é invisível.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Criado o **database `BLOQUEIOS`** e a tabela **`messages`** (`InnoDB`).
- Aberto **duas conexões/abas** no MySQL Workbench, cada uma com seu `CONNECTION_ID()` próprio.
- Inserido a mensagem `'Hello'` na Sessão 1 e confirmado a visibilidade na Sessão 2 após o `COMMIT`.
- Aplicado **`LOCK TABLE messages READ`** na Sessão 1.
- Observado que a **própria Sessão 1** **NÃO consegue mais escrever** na tabela — `INSERT` retorna erro.
- Confirmado que a **Sessão 2 ainda consegue ler** mas **não consegue escrever**.
- Usado **`SHOW PROCESSLIST`** para inspecionar o estado das sessões.

---

## 💡 Antes de começar — por que precisamos de duas sessões?

Bloqueios de tabela existem para coordenar **acesso concorrente**. Em uma única sessão, eles parecem inúteis ou até obstrutivos. O efeito didático só aparece quando você tem **duas conexões competindo pela mesma tabela** — uma "trava" e a outra "fica esperando".

### Como abrir duas sessões no MySQL Workbench

Você tem **duas opções**, em ordem crescente de isolamento:

| Opção | Como | Conexão TCP | `CONNECTION_ID()` |
|-------|------|-------------|--------------------|
| **(a) Duas abas de query** | `Ctrl+T` na mesma conexão | Mesma | **Diferente em cada aba** (cada aba é uma sessão separada) |
| **(b) Duas conexões** | `Database → Connect to Database` (abre nova janela) | **Distintas** | Diferente |

Para esta aula, **qualquer uma das opções funciona** — a opção (a) é mais simples e suficiente. O importante é que **cada aba/janela seja uma sessão independente** com seu próprio `CONNECTION_ID()`.

> ⚠️ **NÃO execute os comandos das duas sessões na mesma aba.** Se você fizer isso, vai parecer que "o lock não funciona" — quando na verdade você está dentro da mesma sessão que detém o lock.

---

## 🧭 Passo 1 — Criar o database e a tabela `messages`

Em **qualquer uma das sessões** (a Sessão 1, daqui em diante):

```sql
CREATE DATABASE BLOQUEIOS;
USE BLOQUEIOS;

CREATE TABLE messages (
    id      INT NOT NULL AUTO_INCREMENT,
    message VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
)
ENGINE = InnoDB;

TRUNCATE TABLE messages;
```

> 💡 **Por que `ENGINE = InnoDB`?** Porque InnoDB suporta **transações** e **row-level locking** — o que vamos contrastar com o `LOCK TABLE` (table-level locking) nos próximos passos. A discussão de quando usar um vs outro fica para o Bloco 4.

> 💡 **Por que o `TRUNCATE` logo após o `CREATE`?** Não é estritamente necessário (a tabela acabou de ser criada e está vazia), mas é uma boa prática **defensiva** — garante estado limpo mesmo se o bloco for reexecutado.

---

## 🧭 Passo 2 — Identificar a Sessão 1

Ainda na Sessão 1:

```sql
SELECT CONNECTION_ID();
```

**Anote o valor retornado.** Por exemplo: `42`.

> 💡 **`CONNECTION_ID()`** retorna o identificador único da sessão atual — é a "matrícula" da conexão. Cada conexão recebe um ID diferente, sequencial, no momento em que conecta.

---

## 🧭 Passo 3 — Abrir a Sessão 2 e identificá-la

Agora abra uma **segunda aba** (`Ctrl+T`) ou **nova conexão**. Esta é a Sessão 2.

```sql
USE BLOQUEIOS;
SELECT CONNECTION_ID();
```

**Anote o valor.** Por exemplo: `43`.

Os dois IDs **devem ser diferentes**. Se forem iguais, você está executando os dois `SELECT`s na mesma sessão — refaça abrindo nova aba.

> 💡 **Daqui em diante**, todos os comandos serão prefixados por **`[S1]`** ou **`[S2]`** indicando em qual sessão executar. **Preste atenção.**

---

## 🧭 Passo 4 — Inserção inicial na Sessão 1

```sql
-- [S1]
INSERT INTO messages(message) VALUES('Hello');
SELECT * FROM messages;
```

Você vê:

```
+----+---------+
| id | message |
+----+---------+
|  1 | Hello   |
+----+---------+
```

Mas **a Sessão 2 ainda não vê esse registro** (porque `autocommit = 0` e ainda não houve `COMMIT`). Verifique:

```sql
-- [S2]
SELECT * FROM messages;
```

A Sessão 2 vê tabela **vazia** (ou, em alguns níveis de isolamento, vê o snapshot anterior). Isso é **isolamento transacional** do InnoDB em ação — assunto da ARQ12.

Agora commit na Sessão 1:

```sql
-- [S1]
COMMIT;
```

E **agora** a Sessão 2 vê:

```sql
-- [S2]
SELECT * FROM messages;
-- vê 'Hello' agora
```

> 💡 **Antes de aplicar locks, observe que sem eles** as duas sessões coexistem normalmente: uma escreve, commita, a outra lê. É o cenário "feliz" da concorrência.

---

## 🧭 Passo 5 — Aplicar `LOCK TABLE messages READ` na Sessão 1

```sql
-- [S1]
LOCK TABLE messages READ;
```

A Sessão 1 agora detém um **lock de leitura compartilhado** sobre a tabela `messages`.

### O comportamento contraintuitivo

Tente, **ainda na Sessão 1**, inserir uma nova mensagem:

```sql
-- [S1]
INSERT INTO messages(message) VALUES('Hi');
```

Resultado:

```
ERROR 1099 (HY000): Table 'messages' was locked with a READ lock and can't be updated
```

🤯 **A própria sessão que detém o lock NÃO pode escrever na tabela.**

### Por quê?

O `READ` lock significa: **"esta tabela é, neste momento, apenas para leitura"**. O propósito do lock é **garantir que a tabela não mude** durante a operação — para você ou para qualquer outra sessão. Se o detentor pudesse escrever, a garantia seria violada.

| Quem | Pode ler? | Pode escrever? |
|------|-----------|----------------|
| Sessão 1 (detentora do `READ`) | ✅ Sim | ⛔ **Não** (erro 1099) |
| Sessão 2 (outras) | ✅ Sim | ⛔ Não (fica esperando) |

> 💡 **Mnemônico:** `READ` lock = "todo mundo lê, ninguém escreve, **incluindo você**".

---

## 🧭 Passo 6 — Verificar comportamento na Sessão 2

```sql
-- [S2]
SELECT * FROM messages;
```

✅ Funciona — a Sessão 2 lê normalmente. O `READ` lock é **compartilhado** entre leitores.

Agora tente escrever:

```sql
-- [S2]
INSERT INTO messages(message) VALUES('Bye');
```

⏳ A Sessão 2 **TRAVA** — o cursor fica girando, esperando. O `INSERT` está em uma "fila de espera" pelo `UNLOCK` da Sessão 1.

**Deixe a Sessão 2 travada** e vá para o próximo passo.

---

## 🧭 Passo 7 — Inspecionar com `SHOW PROCESSLIST`

Em qualquer sessão (vamos usar a Sessão 1):

```sql
-- [S1]
SHOW PROCESSLIST;
```

Você verá algo como:

```
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
| Id | User   | Host      | db        | Command | Time | State                  | Info                             |
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
| 42 | root   | localhost | BLOQUEIOS | Query   | 0    | starting               | SHOW PROCESSLIST                 |
| 43 | root   | localhost | BLOQUEIOS | Query   | 15   | Waiting for table lock | INSERT INTO messages ...         |
+----+--------+-----------+-----------+---------+------+------------------------+----------------------------------+
```

Interpretação:

| Coluna | O que mostra |
|--------|--------------|
| `Id` | `CONNECTION_ID()` da sessão. `42` é a Sessão 1, `43` é a Sessão 2 (no nosso exemplo). |
| `Time` | Segundos no estado atual. A Sessão 2 está há 15s esperando. |
| `State` | **"Waiting for table lock"** — a Sessão 2 está dormindo, aguardando. |
| `Info` | O comando que está bloqueado. |

> 💡 **`SHOW PROCESSLIST` é a ferramenta universal de diagnóstico** quando algo "não responde" no MySQL — você vê **quem está esperando, há quanto tempo, em qual recurso**.

---

## 🧭 Passo 8 — Liberar o lock

```sql
-- [S1]
UNLOCK TABLES;
```

**Imediatamente** a Sessão 2 destrava — o `INSERT 'Bye'` que estava preso processa, e a Sessão 2 volta a responder.

Confirme:

```sql
-- [S2]
SELECT * FROM messages;
-- agora vê 'Hello' e 'Bye'
```

Ainda em S2:

```sql
-- [S2]
COMMIT;
```

> 💡 **O `UNLOCK TABLES` libera TODOS os locks da sessão**, não apenas o último. Não há `UNLOCK TABLE nome_específico`.

---

## 📋 Resumo do comportamento do `LOCK TABLE READ`

```
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │   Sessão 1                           Sessão 2               │
   │   ─────────                          ─────────              │
   │                                                             │
   │   LOCK TABLE messages READ;                                 │
   │   (detém READ lock)                                         │
   │                                                             │
   │   SELECT * FROM messages;  ✅        SELECT * FROM ...  ✅  │
   │                                                             │
   │   INSERT INTO ...  ⛔ ERRO            INSERT INTO ...  ⏳    │
   │   "locked with READ lock              (travada esperando    │
   │   and can't be updated"               o UNLOCK)             │
   │                                                             │
   │   UNLOCK TABLES;  ────────────────►   (destrava aqui!)      │
   │                                                             │
   └─────────────────────────────────────────────────────────────┘
```

---

## ✏️ Atividade Prática

### 📝 Atividade 2 — Locks de leitura entre sessões

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Reproduzir o cenário das duas sessões.
- Documentar tempos de espera observados com `SHOW PROCESSLIST`.
- Refletir sobre por que o `READ` lock bloqueia o próprio detentor para escrita.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-04-bloco2.sql](./codigo-fonte/COMANDOS-BD-04-bloco2.sql)

> 💡 **Atenção:** o gabarito está dividido em **dois trechos**, um para cada sessão. **Não execute tudo na mesma aba.**

---

## ✅ Resumo do Bloco 2

Neste bloco você:

- Criou o database `BLOQUEIOS` e a tabela `messages` (InnoDB).
- Abriu **duas sessões** no Workbench e confirmou IDs distintos via `CONNECTION_ID()`.
- Aplicou `LOCK TABLE messages READ` na Sessão 1.
- Observou que a **própria Sessão 1 não pode escrever** (erro 1099) sob o `READ` lock.
- Observou que a **Sessão 2 lê** mas **trava ao tentar escrever**.
- Usou `SHOW PROCESSLIST` para diagnosticar o estado `"Waiting for table lock"`.

---

## 🎯 Conceitos-chave para fixar

💡 **`READ` lock é compartilhado entre leitores**, mas bloqueia toda escrita — inclusive do próprio detentor.

💡 **`CONNECTION_ID()`** identifica unicamente cada sessão; é a "matrícula" da conexão.

💡 **`SHOW PROCESSLIST`** é a ferramenta canônica de diagnóstico de sessões — mostra **quem está esperando o quê, há quanto tempo**.

💡 **`UNLOCK TABLES`** libera **todos** os locks da sessão atual (não há liberação seletiva).

💡 **Sessões diferentes precisam de abas/conexões diferentes** no Workbench — comandos na mesma aba são uma única sessão.

---

## ➡️ Próximos Passos

Você viu o lock "mais ameno" — o `READ`. No Bloco 3 vamos ao `WRITE`, que é **exclusivo**: bloqueia até as **leituras** de outras sessões. O efeito de "travamento" será ainda mais visível.

Acesse: [📁 Bloco 3](../Bloco3/README.md)

---

> 💭 *"Lock de leitura é o sinal de 'estou copiando o documento — ninguém escreve nada até eu terminar'. Justo para a tabela, frustrante para quem precisa atualizar."*
