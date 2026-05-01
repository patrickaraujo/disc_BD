# 📘 Bloco 5 — Auditoria Automática: tab_audit + Trigger Audita_Livros

> **Duração estimada:** 50 minutos  
> **Objetivo:** Construir a tabela de auditoria `tab_audit` e a Trigger `Audita_Livros`, que registra automaticamente toda alteração de preço na tabela `LIVROS`.  
> **Modalidade:** Guiada — você implementa a Trigger, com destaque para o cabeçalho `FOR EACH ROW BEGIN`.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- A tabela **`tab_audit`**, criada com `AUTO_INCREMENT` e tipos adequados ao registro de auditoria.
- A Trigger **`Audita_Livros`**, do tipo `AFTER UPDATE ON LIVROS`, disparada automaticamente toda vez que um preço de livro for atualizado.
- A Trigger usando os pseudo-registros **`OLD`** e **`NEW`** para capturar o preço antigo e o novo, e gravando ambos em `tab_audit` junto com o usuário, a estação e a data/hora.

> 💡 **Importante:** neste bloco a Trigger é **criada** mas ainda não é **acionada**. O acionamento virá no Bloco 6, dentro da SP `sp_altera_livros`.

---

## 🧭 Passo 1 — Crie a tabela de auditoria `tab_audit`

A `tab_audit` é uma tabela de **rastro** — guarda evidências do que foi alterado, por quem, quando e em qual estação. Construa-a respeitando rigorosamente as especificações abaixo:

### 📋 Especificação da tabela `tab_audit`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `codigo` | `INT` | `AUTO_INCREMENT`, **chave primária** |
| `usuario` | `CHAR(30)` | `NOT NULL` |
| `estacao` | `CHAR(30)` | `NOT NULL` |
| `dataautitoria` | `DATETIME` | `NOT NULL` |
| `codigo_Produto` | `BIGINT` | `NOT NULL` |
| `preco_unitario_novo` | `DECIMAL(10,4)` | `NOT NULL` |
| `preco_unitario_antigo` | `DECIMAL(10,4)` | `NOT NULL` |

> ⚠️ **Atenção ao tipo de `codigo_Produto`:** observe que ele é **`BIGINT`**, não `INT`. Isso é proposital — `tab_audit` será usada para auditar `LIVROS` (cuja PK é o `ISBN` em `BIGINT UNSIGNED`). Se o tipo da auditoria fosse menor, você teria estouro de capacidade.

> 💡 **Sobre o nome `dataautitoria`:** sim, parece um digitação ("dataautitoria" em vez de "dataauditoria"). É como aparece no roteiro original do professor — preserve o nome **exatamente** assim, para que seu código funcione com o gabarito e com o exercício final do Bloco 8.

---

## 💡 Antes de continuar — anatomia de uma Trigger

Você já viu Triggers na ARQ11. Aqui o foco é **um único cabeçalho que costuma confundir**: o `FOR EACH ROW BEGIN`. Vamos olhá-lo de perto.

### 🔹 O cabeçalho mostrado na íntegra

```sql
FOR EACH ROW BEGIN
```

Esse cabeçalho aparece **logo após** a declaração `CREATE TRIGGER ... ON tabela`. Ele tem **dois pedaços** que merecem atenção:

| Pedaço | O que significa |
|--------|-----------------|
| `FOR EACH ROW` | Diz ao MySQL: "execute o corpo da Trigger **uma vez para cada linha** afetada pelo `UPDATE` (ou `INSERT`/`DELETE`)". Se um único `UPDATE` afetar 50 linhas, a Trigger roda **50 vezes**, uma para cada linha. |
| `BEGIN` | Abre o **bloco de código** que será executado. Tudo até o `END` é o corpo da Trigger. |

### 🔹 Por que isso é importante?

Em alguns SGBDs (Oracle, por exemplo), você pode ter Triggers `FOR EACH STATEMENT` — disparam **uma vez** para o `UPDATE` inteiro, mesmo que ele afete 1.000 linhas. **No MySQL, isso não existe** — só temos `FOR EACH ROW`. Por isso, se o `UPDATE` afetar muitas linhas, a Trigger é executada muitas vezes.

> 📌 **Consequência prática:** dentro do corpo da Trigger, você sempre se refere a **uma única linha por vez** — usando os pseudo-registros `OLD` (estado antes) e `NEW` (estado depois).

### 🔹 OLD e NEW dentro de um `AFTER UPDATE`

Em uma Trigger `AFTER UPDATE`:

* **`OLD.coluna`** = valor da coluna **antes** do `UPDATE`.
* **`NEW.coluna`** = valor da coluna **depois** do `UPDATE`.

Para auditoria, esse par é **exatamente o que precisamos**: registrar de onde para onde foi a alteração.

---

## 🧭 Passo 2 — Construa a Trigger `Audita_Livros`

A Trigger será do tipo **`AFTER UPDATE ON LIVROS`** — disparada **após** cada linha atualizada na tabela `LIVROS`.

### 🧱 Esqueleto da Trigger

```text
DELIMITER //

CREATE TRIGGER Audita_Livros AFTER UPDATE ON LIVROS
FOR EACH ROW BEGIN
    -- (1) capturar OLD.ISBN, NEW.PRECOLIVRO e OLD.PRECOLIVRO em variáveis de sessão
    -- (2) INSERT INTO TAB_AUDIT (...)
    --     VALUES (CURRENT_USER, USER(), CURRENT_DATE, ISBN_capturado,
    --             preço_novo_capturado, preço_antigo_capturado);
END //

DELIMITER ;
```

### 🧭 Passo 2.1 — Capture os valores em variáveis de sessão

Use **três variáveis de sessão** (prefixo `@`) para capturar os dados que serão registrados:

| Variável de sessão | Conteúdo |
|--------------------|----------|
| `@ISBN` | `OLD.ISBN` (o ISBN do livro alterado) |
| `@PRECONOVO` | `NEW.PRECOLIVRO` (o preço novo) |
| `@PRECOANTIGO` | `OLD.PRECOLIVRO` (o preço antigo) |

> 💡 **Por que usar variáveis de sessão (`@`) em vez de `OLD.coluna` direto no `INSERT`?** Tecnicamente você poderia usar `OLD.coluna` direto. As variáveis de sessão tornam o código mais **legível**, especialmente quando o `INSERT` é longo — é o estilo adotado no roteiro original do professor.

### 🧭 Passo 2.2 — Faça o `INSERT INTO TAB_AUDIT`

O `INSERT` vai gravar **6 colunas** em `tab_audit` (a coluna `codigo` é preenchida automaticamente pelo `AUTO_INCREMENT`):

| Coluna de `tab_audit` | Valor a gravar |
|----------------------|----------------|
| `usuario` | `CURRENT_USER` (função MySQL — usuário do contexto de segurança) |
| `estacao` | `USER()` (função MySQL — usuário@host da conexão) |
| `dataautitoria` | `CURRENT_DATE` (função MySQL — data atual; sem hora) |
| `codigo_Produto` | `@ISBN` |
| `preco_unitario_novo` | `@PRECONOVO` |
| `preco_unitario_antigo` | `@PRECOANTIGO` |

> 💭 **Curiosidade:** `CURRENT_USER` × `USER()` retornam valores diferentes em cenários com `DEFINER`/`INVOKER` — `CURRENT_USER` é "quem **executa** a Trigger" e `USER()` é "quem **conectou**". Para auditoria mais robusta, é comum gravar ambos.

### 🧭 Passo 2.3 — Encerre a Trigger

Termine com `END //` e volte o `DELIMITER ;`.

---

## 🧭 Passo 3 — Inspeção e (eventualmente) limpeza

### Listar Triggers do banco

```sql
SHOW TRIGGERS;
```

Você deve ver `Audita_Livros` na listagem.

### Apagar a Trigger (caso precise refazer)

Caso erre algo e queira recriar, primeiro apague:

```sql
DROP TRIGGER Audita_Livros;
```

> ⚠️ Não há confirmação. A Trigger é apagada imediatamente.

---

## 🧪 Verificação — A Trigger ainda **não foi disparada**

Importante: criar uma Trigger não dispara nada. Ela **espera** por um evento. Para confirmar:

```sql
SELECT * FROM tab_audit;
```

Deve retornar **0 linhas** — nenhuma alteração de preço aconteceu desde a criação da Trigger. **No Bloco 6, ao alterarmos preços via `sp_altera_livros`, esta tabela passará a ser preenchida automaticamente.**

---

## ✏️ Atividade Prática

### 📝 Atividade 5 — Auditoria + Trigger AFTER UPDATE

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Verificar a Trigger criada com `SHOW TRIGGERS` e `SHOW CREATE TRIGGER`.
- Refletir sobre `OLD` × `NEW`, `FOR EACH ROW`, `CURRENT_USER` × `USER()`.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco5.sql](./codigo-fonte/COMANDOS-BD-03-bloco5.sql)

---

## ✅ Resumo do Bloco 5

Neste bloco você:

- Criou a tabela `tab_audit` com `AUTO_INCREMENT` e tipos adequados.
- Construiu a Trigger `Audita_Livros` (`AFTER UPDATE ON LIVROS`) com cabeçalho `FOR EACH ROW BEGIN`.
- Usou variáveis de sessão (`@ISBN`, `@PRECONOVO`, `@PRECOANTIGO`) para capturar os dados de auditoria.
- Verificou que a Trigger está **registrada**, mas ainda **não foi disparada**.

---

## 🎯 Conceitos-chave para fixar

💡 **`FOR EACH ROW BEGIN`** = "execute o corpo desta Trigger uma vez para cada linha afetada pelo evento".

💡 **`OLD.coluna`** = valor antes do `UPDATE` | **`NEW.coluna`** = valor depois.

💡 **Variáveis de sessão (`@nome`)** sobrevivem durante a sessão atual e melhoram a legibilidade do corpo da Trigger.

💡 **`CURRENT_USER`** ≠ **`USER()`** — em casos comuns retornam o mesmo, mas em SP/Trigger com `DEFINER` podem diferir.

💡 **A Trigger só dispara quando o evento acontece** — criá-la não a executa.

---

## ➡️ Próximos Passos

No Bloco 6 você vai construir `sp_altera_livros` — uma SP transacional que **altera** o preço de um livro. Como a alteração é um `UPDATE`, ela vai disparar automaticamente a Trigger `Audita_Livros` que você acabou de criar.

Acesse: [📁 Bloco 6](../Bloco6/README.md)

---

> 💭 *"Auditoria é a memória do sistema — registra o que aconteceu para que ninguém precise lembrar."*
