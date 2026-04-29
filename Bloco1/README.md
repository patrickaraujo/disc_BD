# 📘 Bloco 1 — Preparação do Ambiente: Autocommit e Banco de Trabalho

> **Duração estimada:** 25 minutos  
> **Objetivo:** Garantir que o ambiente de trabalho está configurado para controlarmos transações manualmente e construir a tabela `LIVROS` que será usada nos blocos seguintes.  
> **Modalidade:** Guiada — você implementa cada passo no MySQL Workbench.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, seu MySQL terá:

- O **autocommit desligado**, para que `START TRANSACTION`, `COMMIT` e `ROLLBACK` façam sentido.
- O banco de dados `procs_armazenados` **recriado do zero**.
- A tabela `LIVROS`, criada com chave primária `ISBN`, pronta para receber os experimentos transacionais dos próximos blocos.

> ℹ️ Você já estudou cada um desses tópicos em aulas anteriores. Aqui o foco é **executar com fluência** e **observar o estado do banco** antes de avançar.

---

## 🧭 Passo 1 — Verifique o estado atual do `autocommit`

Em todo SGBD relacional, **toda instrução DML é, por padrão, uma mini-transação que é confirmada automaticamente** assim que termina. Isso é o `autocommit = 1` (ligado). Para que possamos abrir uma transação e decidir, manualmente, se ela será confirmada (`COMMIT`) ou desfeita (`ROLLBACK`), precisamos do `autocommit = 0`.

**Sua tarefa:**

1. Consulte a variável de sessão `@@autocommit` (lembre-se: variáveis de sessão são lidas com `@@`).
2. Anote o valor retornado:
   * **`1`** → autocommit ligado (padrão do MySQL).
   * **`0`** → autocommit desligado.

> 💡 **Dica:** o resultado é uma única linha, com uma única coluna.

---

## 🧭 Passo 2 — Desligue o `autocommit`

Se o passo 1 retornou `1`, ajuste a variável de sessão `autocommit` para `0` (ou, equivalentemente, para `OFF`).

**Verifique novamente** com a consulta do passo 1. O retorno agora deve ser `0`.

> 📌 **Observação importante:** o `SET autocommit = 0` só vale **para a sessão atual** do Workbench. Se você fechar o Workbench e abrir de novo, precisará repetir o comando.

---

## 🧭 Passo 3 — (Re)crie o banco de dados `procs_armazenados`

Você já utilizou o banco `procs_armazenados` na aula anterior (ARQ11). Para garantir que **estamos partindo de um ambiente limpo**, faça:

1. Apague o banco se ele existir (`DROP DATABASE`).
2. Crie-o novamente (`CREATE DATABASE`).
3. Marque-o como banco corrente (`USE`).

> ⚠️ **Atenção:** o `DROP DATABASE` é definitivo. Se você tinha objetos dessa base que queira preservar, faça backup antes.

---

## 🧭 Passo 4 — Crie a tabela `LIVROS`

A tabela `LIVROS` será a **protagonista** dos próximos blocos. Construa-a respeitando rigorosamente as especificações abaixo:

### 📋 Especificação da tabela `LIVROS`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `ISBN` | `BIGINT UNSIGNED` | `NOT NULL`, **chave primária** |
| `Autor` | `VARCHAR(50)` | `NOT NULL` |
| `Nomelivro` | `VARCHAR(100)` | `NOT NULL` |
| `Precolivro` | `FLOAT` | `NOT NULL` |

**Detalhes adicionais:**

* Use `CREATE TABLE IF NOT EXISTS LIVROS (...)`. O `IF NOT EXISTS` é uma proteção contra erro caso a tabela já exista.
* Use **`ENGINE = InnoDB`**. A engine InnoDB é a única que suporta transações no MySQL — sem ela, `COMMIT` e `ROLLBACK` simplesmente são ignorados em silêncio. **Toda a aula depende disso.**

> 💡 **Dica:** `BIGINT UNSIGNED` aceita valores entre `0` e ~`1,8 × 10¹⁹`. Um ISBN-13 (13 dígitos) cabe sem problema; `INT UNSIGNED` (até ~`4,3 × 10⁹`) **não caberia** — é por isso que escolhemos `BIGINT`.

---

## 🧭 Passo 5 — Verifique a tabela vazia

Execute um `SELECT *` na tabela `LIVROS`. O retorno esperado é:

```
0 row(s) returned
```

Isso confirma que a tabela existe, mas ainda **não há nenhum registro**. É exatamente desse ponto de partida que o Bloco 2 começa.

---

## ✏️ Atividade Prática

### 📝 Atividade 1 — Verificação do Ambiente

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Confirmar que o `autocommit` está em `0`.
- Confirmar que a tabela `LIVROS` foi criada com a engine correta.
- Refletir conceitualmente sobre o papel da engine InnoDB nas transações.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.** O arquivo abaixo contém o SQL completo deste bloco. Trate-o como gabarito de referência, não como ponto de partida.

➡️ [codigo-fonte/COMANDOS-BD-03-bloco1.sql](./codigo-fonte/COMANDOS-BD-03-bloco1.sql)

---

## ✅ Resumo do Bloco 1

Neste bloco você executou:

- A leitura e o ajuste da variável de sessão `autocommit`.
- O `DROP` e `CREATE` do banco `procs_armazenados`.
- A criação da tabela `LIVROS` com a engine `InnoDB`.

---

## 🎯 Conceitos-chave para fixar

💡 **Sem `autocommit = 0`, não há transação manual** — cada `INSERT`, `UPDATE` ou `DELETE` é confirmado sozinho.

💡 **Sem `ENGINE = InnoDB`, não há transação alguma** — a engine `MyISAM`, por exemplo, ignora `COMMIT`/`ROLLBACK`.

💡 **`SET autocommit = 0` é por sessão** — fechou o Workbench, perdeu a configuração.

---

## ➡️ Próximos Passos

No Bloco 2 você vai abrir transações manualmente e observar — com `SELECT *` antes e depois — exatamente o que `ROLLBACK` e `COMMIT` fazem com seus dados.

Acesse: [📁 Bloco 2](../Bloco2/README.md)

---

> 💭 *"Antes de transacionar, configure. Antes de configurar, entenda o que está configurando."*
