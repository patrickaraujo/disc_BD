# 📘 Bloco 2 — Schema Financeiro e Tabelas Cliente / TipoConta

> **Duração estimada:** 30 minutos  
> **Objetivo:** Criar o schema `Financeiro` e as duas tabelas "satélite" (`Cliente` e `TipoConta`), populá-las e confirmar as inserções.  
> **Modalidade:** Guiada — você implementa cada `CREATE` e `INSERT` no MySQL Workbench.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, seu MySQL terá:

- O **schema `Financeiro`** criado e selecionado para uso.
- A tabela **`Cliente`** com `idCliente AUTO_INCREMENT` e dois clientes inseridos.
- A tabela **`TipoConta`** com `idTipoConta AUTO_INCREMENT` e dois tipos de conta inseridos.
- As inserções **confirmadas** com `COMMIT`.

---

## 🧭 Passo 1 — Crie o schema `Financeiro`

No MySQL, "schema" e "database" são sinônimos. Você já fez isso na ARQ12 (com `procs_armazenados`). Agora, repita:

1. Use `CREATE SCHEMA IF NOT EXISTS Financeiro` com charset `utf8`.
2. Marque-o como banco corrente com `USE Financeiro`.

> 💡 **`SCHEMA` ou `DATABASE`?** No MySQL, são equivalentes. O Workbench gera `CREATE SCHEMA` por padrão. `CREATE DATABASE` produz o mesmo resultado.

> 💡 **Por que `IF NOT EXISTS`?** Para que o script seja **reexecutável** — se o schema já existir, o MySQL apenas avisa em vez de quebrar. Boa prática em scripts compartilhados.

---

## 🧭 Passo 2 — Crie a tabela `Cliente`

### 📋 Especificação da tabela `Cliente`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `idCliente` | `INT` | `NOT NULL`, `AUTO_INCREMENT`, **chave primária** |
| `NomeCli` | `VARCHAR(60)` | `NOT NULL` |

**Detalhes adicionais:**
* Use **`ENGINE = InnoDB`** — necessária para o controle transacional dos próximos blocos.
* O Workbench tipicamente usa **crase** (\` \`) ao redor de nomes de objetos no script gerado, ex.: `` `Financeiro`.`Cliente` ``. Você pode escrever sem crase também — é estilo, não obrigação. (Crase só é necessária quando o nome conflita com palavra reservada ou tem caracteres especiais.)

> 💡 **Dica:** se preferir, especifique a tabela com nome qualificado: `CREATE TABLE Financeiro.Cliente (...)`. Isso é equivalente a `USE Financeiro;` seguido de `CREATE TABLE Cliente (...)`.

---

## 🧭 Passo 3 — Crie a tabela `TipoConta`

### 📋 Especificação da tabela `TipoConta`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `idTipoConta` | `INT` | `NOT NULL`, `AUTO_INCREMENT`, **chave primária** |
| `DescricaoConta` | `VARCHAR(30)` | `NOT NULL` |

**Detalhes:**
* Mesma engine `InnoDB`.
* Mesma estrutura conceitual de `Cliente` — só muda o domínio.

> 🤔 **Por que essas duas tabelas têm a mesma estrutura?** Porque ambas são **catálogos** simples — armazenam um nome/descrição com um identificador único. É comum em modelagem ter várias tabelas "lookup" parecidas (cidade, estado, categoria, status, tipo, etc.).

---

## 🧭 Passo 4 — Popule as tabelas

### Inserindo clientes

Insira **dois clientes** na tabela `Cliente`. Detalhe importante: como `idCliente` é `AUTO_INCREMENT`, **não informe** essa coluna no `INSERT`. Use a sintaxe que **lista apenas a coluna que você quer fornecer** (`NomeCli`):

| Cliente | `NomeCli` |
|---------|-----------|
| 1º | `RUBENS ZAMPAR JUNIOR` |
| 2º | `OSWALDO MARTINS DE SOUZA` |

O MySQL atribuirá automaticamente `idCliente = 1` ao primeiro e `idCliente = 2` ao segundo.

### Inserindo tipos de conta

Insira **dois tipos** na tabela `TipoConta`, do mesmo jeito (omitindo `idTipoConta`):

| Tipo | `DescricaoConta` |
|------|------------------|
| 1º | `Conta Corrente` |
| 2º | `Conta Poupança` |

> 💡 **Dica:** você pode usar `INSERT … VALUES (...), (...);` para inserir as duas linhas em **um único comando**.

---

## 🧭 Passo 5 — Confirme com `COMMIT` e verifique

### `COMMIT`

Como você está com `autocommit = 0` (configuração que vem da ARQ12, ou que você pode ajustar agora), os `INSERT`s ainda estão pendentes. Confirme com `COMMIT;`.

> 📌 **Se você não está com `autocommit = 0`**, o `COMMIT` é inofensivo (não tem nada para confirmar). Mas é hábito útil incluir.

### Verifique

Execute:

```sql
SELECT * FROM Cliente;
SELECT * FROM TipoConta;
```

**Resultado esperado** em `Cliente`:

| idCliente | NomeCli |
|-----------|---------|
| 1 | RUBENS ZAMPAR JUNIOR |
| 2 | OSWALDO MARTINS DE SOUZA |

**Resultado esperado** em `TipoConta`:

| idTipoConta | DescricaoConta |
|-------------|----------------|
| 1 | Conta Corrente |
| 2 | Conta Poupança |

---

## ✏️ Atividade Prática

### 📝 Atividade 2 — Tabelas-Catálogo

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Verificar a estrutura criada com `SHOW CREATE TABLE`.
- Refletir sobre `AUTO_INCREMENT`, comportamento em rollback e cenários comuns.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco2.sql](./codigo-fonte/COMANDOS-BD-03-bloco2.sql)

---

## ✅ Resumo do Bloco 2

Neste bloco você executou:

- A criação do schema `Financeiro`.
- A criação das tabelas `Cliente` e `TipoConta` com PKs `AUTO_INCREMENT`.
- A inserção de 2 clientes e 2 tipos de conta.
- O `COMMIT` que persistiu os dados.

---

## 🎯 Conceitos-chave para fixar

💡 **`AUTO_INCREMENT`** se aplica apenas a colunas inteiras com índice (geralmente PK). Cada `INSERT` que omite a coluna recebe o **próximo valor disponível**.

💡 **`INSERT INTO tabela (col_b) VALUES (...)`** — listar só as colunas que você quer fornecer é a forma idiomática de usar `AUTO_INCREMENT`.

💡 **Tabelas "satélite" / "catálogo"** geralmente têm estrutura simples (id + nome/descrição) — são suporte para outras tabelas via FK.

💡 **`CREATE SCHEMA`** e **`CREATE DATABASE`** são equivalentes no MySQL.

---

## ➡️ Próximos Passos

No Bloco 3 você vai criar a tabela central `Conta`, com **PK composta**, dois `INDEX` `VISIBLE` e duas `CONSTRAINT FOREIGN KEY` apontando para `Cliente` e `TipoConta`.

Acesse: [📁 Bloco 3](../Bloco3/README.md)

---

> 💭 *"Tabelas-catálogo são pequenas mas essenciais — sem elas, tudo o que viesse depois apontaria para o vazio."*
