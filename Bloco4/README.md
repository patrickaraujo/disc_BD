# 📘 Bloco 4 — Aplicando em Cenário Real: ItemPedido × Produtos

> **Duração estimada:** 40 minutos  
> **Objetivo:** Reaplicar o padrão de SP transacional do Bloco 3 em um **cenário comercial real** — inserir um item de pedido com tratamento de erro automático.  
> **Modalidade:** Guiada — você reusa o padrão, sem o guia mostrar o código novamente.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Recriadas as tabelas `ItemPedido` e `Produtos` (já vistas no Bloco 2 da ARQ11).
- Populado as tabelas com dados iniciais e **confirmado** com `COMMIT`.
- A SP **`sp_insere_itempedido`**, transacional, espelhando exatamente o padrão da `sp_insere_livros` do Bloco 3.
- Testes com chamadas válidas e inválidas, evidenciando a robustez do padrão.

---

## 💡 Por que repetir o padrão?

No Bloco 3 você implementou o padrão **`DECLARE flag → DECLARE CONTINUE HANDLER → START TRANSACTION → INSERT → IF flag THEN COMMIT ELSE ROLLBACK END IF`**. Essa receita é **agnóstica** ao contexto — funciona para qualquer SP que precise garantir atomicidade em uma única operação de modificação. Aplicá-la em um segundo cenário consolida o padrão na sua memória de longo prazo.

---

## 🧭 Passo 1 — Recrie as tabelas `ItemPedido` e `Produtos`

### 📋 Especificação da tabela `ItemPedido`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `CODIGOPRODUTO` | `INT` | `NOT NULL` |
| `CODIGOPEDIDO` | `INT` | `NOT NULL` |
| `QTD` | `INT` | `NOT NULL` |

**Chave primária composta:** (`CODIGOPRODUTO`, `CODIGOPEDIDO`)

### 📋 Especificação da tabela `Produtos`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `CODIGOPRODUTO` | `INT` | `NOT NULL`, **chave primária** |
| `NOME` | `VARCHAR(30)` | `NOT NULL` |
| `QTDESTOQUE` | `INT` | `NOT NULL` |
| `PRECO` | `DECIMAL(5,2)` | (sem NOT NULL) |

> 📌 **Nota:** as duas tabelas são as mesmas que você usou no Bloco 2 da ARQ11. Nesta aula, a engine permanece sendo `InnoDB` (padrão do MySQL 8). Não é necessário declarar explicitamente.

---

## 🧭 Passo 2 — Populando as tabelas

Insira os dados iniciais a seguir e confirme com `COMMIT;`. **Anote**: como agora estamos com `autocommit = 0`, sem o `COMMIT` esses dados não persistiriam.

### Dados de `ItemPedido`

| CODIGOPRODUTO | CODIGOPEDIDO | QTD |
|---------------|--------------|-----|
| 1 | 10 | 1 |
| 2 | 10 | 3 |

### Dados de `Produtos`

| CODIGOPRODUTO | NOME | QTDESTOQUE | PRECO |
|---------------|------|-----------|-------|
| 1 | DVD | 100 | 50.00 |
| 2 | LIQUIDIFICADOR | 30 | 180.00 |

Após o `COMMIT`, valide com `SELECT * FROM ItemPedido;` e `SELECT * FROM Produtos;` — devem aparecer os 2 registros em cada uma.

---

## 🧭 Passo 3 — Construa a SP `sp_insere_itempedido`

A SP recebe **3 parâmetros**:

| Parâmetro | Tipo | Origem |
|-----------|------|--------|
| `v_CODIGOPRODUTO` | `INT` | `ItemPedido.CODIGOPRODUTO` |
| `v_CODIGOPEDIDO` | `INT` | `ItemPedido.CODIGOPEDIDO` |
| `v_QTD` | `INT` | `ItemPedido.QTD` |

**Estrutura da SP:** *é exatamente a mesma do Bloco 3*. Use:

* `DELIMITER //`
* `DECLARE erro_sql boolean DEFAULT FALSE;`
* `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;`
* `START TRANSACTION;`
* `INSERT INTO ITEMPEDIDO (...) VALUES (...);`
* `IF erro_sql = FALSE THEN COMMIT; SELECT '…sucesso…'; ELSE ROLLBACK; SELECT '…erro…'; END IF;`
* `DELIMITER ;`

### 💬 Mensagens de retorno

* **Sucesso:** `'Item do Pedido incluído com sucesso e Estoque atualizado!!!'`
* **Falha:** `'ATENÇÃO: Erro na transação, item do Pedido não incluído e Produto não atualizado!!!'`

> 💭 **Por que a mensagem de sucesso menciona "estoque atualizado", se a SP só faz `INSERT`?** Boa pergunta — neste momento a SP de fato **só insere**. A atualização de estoque virá depois, via Trigger (você verá esse padrão na continuação da disciplina). A mensagem já antecipa o cenário completo, comum em sistemas de e-commerce.

---

## 🧪 Testes obrigatórios

Após criar a SP, execute as 4 chamadas abaixo, **na ordem**:

### Chamadas válidas (devem dar sucesso)

```sql
CALL sp_insere_itempedido(1, 11, 5);
CALL sp_insere_itempedido(1, 12, 6);
```

### Chamadas inválidas (devem dar falha)

```sql
CALL sp_insere_itempedido(1, 11, NULL);
CALL sp_insere_itempedido(1, NULL, 5);
```

> 🤔 **Por que falham?** A primeira passa `QTD = NULL`, violando a constraint `NOT NULL` da coluna `QTD`. A segunda passa `CODIGOPEDIDO = NULL`, que faz parte da **chave primária composta** — toda chave primária é, implicitamente, `NOT NULL`.

### Verifique o estado final

```sql
SELECT * FROM ItemPedido;
SELECT * FROM Produtos;
```

* `ItemPedido` deve ter **4 linhas**: as 2 originais (`1,10,1` e `2,10,3`) e as 2 novas das chamadas válidas (`1,11,5` e `1,12,6`).
* `Produtos` permanece com 2 linhas, **sem alterações no estoque** (essa parte ficará para uma Trigger no futuro).

---

## ✏️ Atividade Prática

### 📝 Atividade 4 — Consolidando o padrão de SP transacional

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Comparar as duas SPs (Bloco 3 e Bloco 4) e identificar as partes que mudam e as que se repetem.
- Refletir sobre como esse padrão se generaliza.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco4.sql](./codigo-fonte/COMANDOS-BD-03-bloco4.sql)

---

## ✅ Resumo do Bloco 4

Neste bloco você executou:

- A criação das tabelas `ItemPedido` e `Produtos`.
- A inserção e o `COMMIT` dos dados iniciais.
- A construção da SP `sp_insere_itempedido` no padrão transacional.
- 4 chamadas (2 válidas, 2 inválidas) que confirmaram a robustez do padrão.

---

## 🎯 Conceitos-chave para fixar

💡 **O padrão transacional é reusável** — só mudam os parâmetros e o `INSERT` interno.

💡 **Chave primária composta também é `NOT NULL` por padrão** — passar `NULL` em qualquer parte dela quebra a constraint.

💡 **A mensagem de retorno pode antecipar funcionalidades futuras** (como a atualização de estoque por Trigger).

---

## ➡️ Próximos Passos

No Bloco 5 você vai criar a **tabela de auditoria** `tab_audit` e a primeira **Trigger** da aula — `Audita_Livros`, que registra automaticamente toda alteração de preço.

Acesse: [📁 Bloco 5](../Bloco5/README.md)

---

> 💭 *"Aprendizado virou hábito quando você consegue aplicar o mesmo padrão em um cenário diferente sem reler o original."*
