# 📘 Bloco 3 — Tabela Conta: PK Composta e Chaves Estrangeiras

> **Duração estimada:** 45 minutos  
> **Objetivo:** Criar a tabela central do schema (`Conta`) com **PK composta de 3 colunas**, **dois índices** para acelerar consultas pelas FKs e **duas constraints** de chave estrangeira.  
> **Modalidade:** Guiada — você implementa cada parte da tabela com explicações para construções pouco vistas em sala.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, seu MySQL terá:

- A tabela **`Conta`** com 4 colunas e **PK composta** `(NroConta, Cliente_idCliente, TipoConta_idTipoConta)`.
- Dois **`INDEX … VISIBLE`** para as colunas de FK — necessários para performance e para a constraint funcionar adequadamente.
- Duas **`CONSTRAINT FOREIGN KEY`** com `ON DELETE NO ACTION ON UPDATE NO ACTION`.
- Quatro contas inseridas (2 contas para cada um dos 2 clientes do Bloco 2).
- Os dados **confirmados** com `COMMIT`.

---

## 💡 Antes de começar — três construções pouco vistas em sala

A tabela `Conta` traz três construções que costumam aparecer em scripts gerados pelo Workbench mas que raramente são discutidas em aulas teóricas. Vamos olhá-las antes de implementar.

### 🔹 Construção 1 — `INDEX nome_idx (coluna ASC) VISIBLE`

Sintaxe completa que aparece dentro do `CREATE TABLE`:

```sql
INDEX `fk_Conta_Cliente_idx` (`Cliente_idCliente` ASC) VISIBLE
```

| Pedaço | O que significa |
|--------|-----------------|
| `INDEX` | Cria um índice (estrutura B-tree) sobre as colunas indicadas. |
| `` `fk_Conta_Cliente_idx` `` | **Nome** do índice. Convenção do Workbench: `fk_<tabelaFilha>_<tabelaPai>_idx`. |
| `(`Cliente_idCliente` ASC)` | Coluna(s) indexada(s) e ordem (`ASC` ascendente, `DESC` descendente — só relevante para múltiplas colunas em alguns SGBDs). |
| `VISIBLE` | O otimizador de consultas **enxerga** este índice e pode usá-lo. (`INVISIBLE` esconderia do otimizador, sem apagar o índice.) |

**Por que criar índice na coluna FK?** Porque, sem índice na FK, certas operações em **muitas linhas** ficam **muito lentas** (especialmente `DELETE CASCADE` ou `JOIN`s pela FK). O MySQL exige automaticamente um índice na coluna da FK — se você não criar, o MySQL cria um sozinho, com nome interno. **A boa prática é criar com nome explícito**, para facilitar manutenção.

> 💡 **`VISIBLE` é o padrão.** Você pode omitir e o índice será visível. O Workbench escreve explicitamente para registrar a intenção.

> 💡 **`INVISIBLE` é útil em produção** quando você quer "testar a remoção" de um índice sem realmente removê-lo: torne-o invisível, monitore a performance, e se piorar, volte para visível.

### 🔹 Construção 2 — `CONSTRAINT … FOREIGN KEY … REFERENCES …`

Sintaxe completa:

```sql
CONSTRAINT `fk_Conta_Cliente`
  FOREIGN KEY (`Cliente_idCliente`)
  REFERENCES `Financeiro`.`Cliente` (`idCliente`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
```

| Pedaço | O que significa |
|--------|-----------------|
| `CONSTRAINT `fk_Conta_Cliente`` | Nome da restrição — útil para `DROP CONSTRAINT` no futuro. |
| `FOREIGN KEY (`Cliente_idCliente`)` | A coluna desta tabela (`Conta`) que será FK. |
| `REFERENCES `Financeiro`.`Cliente` (`idCliente`)` | Aponta para a coluna da tabela "pai". |
| `ON DELETE NO ACTION` | Regra para quando o **pai for excluído**: nenhuma ação automática. (Ver abaixo.) |
| `ON UPDATE NO ACTION` | Regra para quando o **pai for atualizado**: nenhuma ação automática. |

### 🔹 Construção 3 — `ON DELETE NO ACTION`

`NO ACTION` (e seu sinônimo `RESTRICT`) é a **opção padrão e mais conservadora** entre as 5 possíveis para `ON DELETE`/`ON UPDATE`:

| Opção | Comportamento ao excluir/atualizar o **pai** |
|-------|---------------------------------------------|
| `NO ACTION` (sinônimo de `RESTRICT` no MySQL) | **Bloqueia** a operação se houver filhos referenciando o pai |
| `CASCADE` | **Propaga** — exclui/atualiza os filhos automaticamente |
| `SET NULL` | Coloca `NULL` na coluna FK do filho (precisa que a coluna aceite `NULL`) |
| `SET DEFAULT` | Coloca o valor padrão da coluna FK do filho |

**Por que `NO ACTION` é uma escolha defensiva?** Porque **impede** o usuário de excluir um cliente que ainda tem contas — protege contra perda acidental de dados. Em sistemas financeiros, é a opção correta na vasta maioria dos casos.

> 💡 **`NO ACTION` vs `RESTRICT` no MySQL:** são **funcionalmente idênticos** no MySQL/InnoDB (a verificação é imediata em ambos). Em outros SGBDs (Oracle, PostgreSQL), `NO ACTION` permite verificação adiada — no MySQL, essa diferença não existe.

---

## 🧭 Passo 1 — Construa a tabela `Conta`

### 📋 Especificação completa da tabela `Conta`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `NroConta` | `INT` | `NOT NULL` |
| `saldo` | `FLOAT` | `NOT NULL` |
| `Cliente_idCliente` | `INT` | `NOT NULL` |
| `TipoConta_idTipoConta` | `INT` | `NOT NULL` |

**Constraints adicionais:**
* **PK composta:** `(NroConta, Cliente_idCliente, TipoConta_idTipoConta)`
* **Índice 1:** sobre `Cliente_idCliente` — nome `fk_Conta_Cliente_idx`, modificador `VISIBLE`.
* **Índice 2:** sobre `TipoConta_idTipoConta` — nome `fk_Conta_TipoConta1_idx`, modificador `VISIBLE`.
* **FK 1:** `fk_Conta_Cliente` — `Cliente_idCliente` → `Cliente.idCliente`, com `ON DELETE NO ACTION ON UPDATE NO ACTION`.
* **FK 2:** `fk_Conta_TipoConta1` — `TipoConta_idTipoConta` → `TipoConta.idTipoConta`, com `ON DELETE NO ACTION ON UPDATE NO ACTION`.
* **Engine:** `InnoDB`.

### 🧱 Estrutura geral

```text
CREATE TABLE IF NOT EXISTS Financeiro.Conta (
    NroConta INT NOT NULL,
    saldo FLOAT NOT NULL,
    Cliente_idCliente INT NOT NULL,
    TipoConta_idTipoConta INT NOT NULL,
    PRIMARY KEY (NroConta, Cliente_idCliente, TipoConta_idTipoConta),
    INDEX fk_Conta_Cliente_idx     (Cliente_idCliente     ASC) VISIBLE,
    INDEX fk_Conta_TipoConta1_idx  (TipoConta_idTipoConta ASC) VISIBLE,
    CONSTRAINT fk_Conta_Cliente
        FOREIGN KEY (Cliente_idCliente)
        REFERENCES Financeiro.Cliente (idCliente)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_Conta_TipoConta1
        FOREIGN KEY (TipoConta_idTipoConta)
        REFERENCES Financeiro.TipoConta (idTipoConta)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;
```

> 💡 **Sobre a PK composta:** ela diz que **a unicidade é a combinação de 3 colunas**. Você poderia ter dois registros com `NroConta = 1111` desde que pertencessem a clientes ou tipos diferentes — embora, no contexto bancário, isso provavelmente não seja desejável. Veja a discussão sobre PK composta vs simples no Bloco 1.

---

## 🧭 Passo 2 — Garanta que as 3 tabelas estão limpas (TRUNCATE em ordem)

Antes de inserir contas, vamos garantir um estado limpo. Como há FKs entre as tabelas, **a ordem do `TRUNCATE` importa**:

```sql
TRUNCATE Conta;        -- primeiro: filha
TRUNCATE TipoConta;    -- depois:   pai 2
TRUNCATE Cliente;      -- por fim:  pai 1
```

> ⚠️ **Por que essa ordem?** Porque `TRUNCATE` em uma tabela "pai" falha se houver filhos referenciando — exceto, claro, se `FOREIGN_KEY_CHECKS=0` estiver ativo (o que é o nosso caso desde o Bloco 1). Mesmo assim, é boa prática **truncar de baixo para cima**.

> ⚠️ **`TRUNCATE` resseta o `AUTO_INCREMENT`** das tabelas pai. O próximo `INSERT` em `Cliente` ou `TipoConta` recomeçará do `1`. **Importante:** isso significa que você **precisa repopular** `Cliente` e `TipoConta` antes de inserir em `Conta`.

---

## 🧭 Passo 3 — Repopule `Cliente` e `TipoConta`

Repita os `INSERT`s do Bloco 2:

* `Cliente` recebe `'RUBENS ZAMPAR JUNIOR'` e `'OSWALDO MARTINS DE SOUZA'`.
* `TipoConta` recebe `'Conta Corrente'` e `'Conta Poupança'`.

> 💡 Como o `AUTO_INCREMENT` foi resetado pelo `TRUNCATE`, os novos `idCliente` e `idTipoConta` voltam a ser `1` e `2` — o que é exatamente o que precisamos para os `INSERT`s em `Conta` abaixo.

---

## 🧭 Passo 4 — Insira as 4 contas

A tabela `Conta` recebe **uma linha por conta concreta**. O cenário do exemplo:

| Cliente | Tipo | NroConta | saldo |
|---------|------|----------|-------|
| Rubens (`idCliente=1`) | Conta Corrente (`idTipoConta=1`) | 1111 | 10000 |
| Rubens (`idCliente=1`) | Conta Poupança (`idTipoConta=2`) | 2222 | 0 |
| Oswaldo (`idCliente=2`) | Conta Corrente (`idTipoConta=1`) | 5555 | 10000 |
| Oswaldo (`idCliente=2`) | Conta Poupança (`idTipoConta=2`) | 6666 | 1000 |

Use **dois `INSERT INTO Conta VALUES (...), (...)`** (um para cada cliente, com 2 contas em cada).

> 💡 Os 4 valores numéricos para cada linha são, na ordem das colunas: `NroConta`, `saldo`, `Cliente_idCliente`, `TipoConta_idTipoConta`.

---

## 🧭 Passo 5 — Confirme e verifique

```sql
COMMIT;

SELECT * FROM Cliente;
SELECT * FROM TipoConta;
SELECT * FROM Conta;
```

**Estado esperado** em `Conta`:

| NroConta | saldo | Cliente_idCliente | TipoConta_idTipoConta |
|----------|-------|-------------------|----------------------|
| 1111 | 10000 | 1 | 1 |
| 2222 | 0 | 1 | 2 |
| 5555 | 10000 | 2 | 1 |
| 6666 | 1000 | 2 | 2 |

---

## ✏️ Atividade Prática

### 📝 Atividade 3 — Conta, PK composta e FKs

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Verificar a estrutura da tabela com `SHOW CREATE TABLE` e `information_schema`.
- Refletir sobre `NO ACTION` vs `CASCADE` em cenários reais.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco3.sql](./codigo-fonte/COMANDOS-BD-03-bloco3.sql)

---

## ✅ Resumo do Bloco 3

Neste bloco você executou:

- A criação da tabela `Conta` com **PK composta de 3 colunas**.
- A criação de **2 índices visíveis** para colunas de FK (boas práticas).
- A criação de **2 constraints de FK** com `ON DELETE NO ACTION ON UPDATE NO ACTION`.
- A repopulação de `Cliente` e `TipoConta` (após `TRUNCATE`).
- A inserção de **4 contas** (2 para cada cliente).

---

## 🎯 Conceitos-chave para fixar

💡 **PK composta** define unicidade pela **combinação** de várias colunas.

💡 **`INDEX … VISIBLE`** é a sintaxe completa para criar um índice em uma coluna de FK — boa prática nomear explicitamente.

💡 **`ON DELETE NO ACTION`** = bloqueia exclusão do pai se houver filhos referenciando — escolha conservadora e segura.

💡 **`NO ACTION` ≡ `RESTRICT`** no MySQL.

💡 **`TRUNCATE` em tabelas com FK** exige ordem reversa (filha → pai) ou `FOREIGN_KEY_CHECKS=0`.

---

## ➡️ Próximos Passos

No Bloco 4 você vai construir sua primeira **Stored Procedure transacional não trivial**: `sp_transf_bancaria`, com validação aninhada de 3 níveis e dois `UPDATE`s encadeados.

Acesse: [📁 Bloco 4](../Bloco4/README.md)

---

> 💭 *"Chave estrangeira não é só sintaxe — é compromisso de integridade. Cada `NO ACTION` é uma decisão consciente."*
