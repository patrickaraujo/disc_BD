# 📘 Bloco 7 — Auditoria de Transações com Trigger

> **Duração estimada:** 50 minutos  
> **Objetivo:** Criar a tabela `AuditFin` e a Trigger `tg_Audita_Fin` (`AFTER UPDATE ON CONTA`), que registrará automaticamente cada alteração de saldo. Observar que **cada transferência gera 2 linhas espelhadas** em `AuditFin`.  
> **Modalidade:** Guiada — você já dominou Triggers na ARQ12; o foco aqui é a **especificidade financeira** (cálculo de `valor_transacao` = `NEW − OLD`).

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- A tabela **`AuditFin`** com 8 colunas, incluindo `saldo_antigo`, `valor_transacao` e `saldo_novo` em `DECIMAL(9,2)`.
- A Trigger **`tg_Audita_Fin`** (`AFTER UPDATE ON CONTA`) que registra cada alteração de saldo automaticamente.
- A constatação prática de que **cada chamada da SP gera 2 linhas em `AuditFin`** (uma por `UPDATE`), com `valor_transacao` espelhados (um negativo, um positivo) e soma = 0.
- A confirmação de que a Trigger captura tanto chamadas da v1 (`sp_transf_bancaria`) quanto da v2 (`sp_transf_bancaria02`) — porque o gatilho é o `UPDATE`, não a SP.

---

## 💡 Antes de começar — o conceito-chave deste bloco

A Trigger que você vai criar tem uma característica **distintiva** em relação à `Audita_Livros` da ARQ12:

| Aspecto | `Audita_Livros` (ARQ12) | `tg_Audita_Fin` (ARQ13) |
|---------|-------------------------|------------------------|
| Tabela monitorada | `LIVROS` | `Conta` |
| Evento | `AFTER UPDATE` | `AFTER UPDATE` |
| Registra | `OLD.PRECOLIVRO`, `NEW.PRECOLIVRO` | `OLD.SALDO`, `NEW.SALDO` |
| **Calcula algo?** | Não — só guarda valores | **Sim — `NEW.SALDO - OLD.SALDO`** |
| Coluna de saída | `preco_unitario_antigo`, `preco_unitario_novo` | `saldo_antigo`, `valor_transacao`, `saldo_novo` |

> 💡 **A grande novidade:** a Trigger calcula `valor_transacao = NEW.SALDO - OLD.SALDO`. Isso significa:
> * Se o `UPDATE` **debitou** a conta: `valor_transacao` é **negativo**.
> * Se o `UPDATE` **creditou** a conta: `valor_transacao` é **positivo**.
>
> Como cada transferência envolve **dois `UPDATE`s** (debita origem + credita destino), a Trigger dispara **duas vezes**, gerando **duas linhas espelhadas** em `AuditFin`. **A soma dos `valor_transacao` de uma transferência sempre é zero** — é a "conservação do dinheiro" do Bloco 5, agora **registrada em auditoria**.

---

## 🧭 Passo 1 — Restaurar o estado da tabela `Conta`

Os blocos anteriores já mexeram nos saldos. Antes da auditoria, restaure o estado original:

```sql
USE Financeiro;
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0, 1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;
```

> 💡 **Importante:** o `TRUNCATE` zera a tabela, mas **não dispara Triggers** (Triggers são para `INSERT/UPDATE/DELETE`). Os 4 `INSERT`s seguintes **também não disparam** a Trigger que vamos criar — porque ela é `AFTER UPDATE`, não `AFTER INSERT`.

---

## 🧭 Passo 2 — Crie a tabela `AuditFin`

### 📋 Especificação da tabela `AuditFin`

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `idAuditoria` | `INT` | `AUTO_INCREMENT`, **chave primária** |
| `usuario` | `CHAR(30)` | `NOT NULL` |
| `estacao` | `CHAR(30)` | `NOT NULL` |
| `dataautitoria` | **`DATE`** | `NOT NULL` |
| `conta` | `INT` | `NOT NULL` |
| `saldo_antigo` | `DECIMAL(9,2)` | `NOT NULL` |
| `valor_transacao` | `DECIMAL(9,2)` | `NOT NULL` |
| `saldo_novo` | `DECIMAL(9,2)` | `NOT NULL` |

> 📌 **Atenção (1):** o tipo é **`DATE`** (apenas data, sem horas), diferente da `tab_audit` da ARQ12 que usava `DATETIME`. Essa decisão do professor reduz o granularidade temporal — em 1 dia, várias transações terão a mesma `dataautitoria`. Em produção real, `DATETIME` ou `TIMESTAMP` seria mais apropriado.

> 📌 **Atenção (2):** preserve o nome `dataautitoria` (com a digitação do roteiro original).

> 📌 **Atenção (3):** os 3 valores financeiros são `DECIMAL(9,2)` — ou seja, até 7 dígitos antes da vírgula e 2 depois. Suporta até `9.999.999,99`. Por que `DECIMAL` e não `FLOAT`? Porque **`FLOAT` tem imprecisões binárias** que são inadmissíveis em finanças (saldo poderia ficar `2999.9999999...`). `DECIMAL` é exato.

> 💡 **Curiosidade:** a coluna `saldo` da tabela `Conta` é `FLOAT` (do diagrama original) — mas a auditoria usa `DECIMAL`. Há uma conversão implícita ao gravar.

---

## 🧭 Passo 3 — Crie a Trigger `tg_Audita_Fin`

### 📋 Especificação da Trigger

* **Nome:** `tg_Audita_Fin`.
* **Evento:** `AFTER UPDATE ON CONTA`.
* **Frequência:** `FOR EACH ROW BEGIN … END`.

### 📋 Comportamento

Para cada linha alterada, capturar em variáveis de sessão:

| Variável | Valor |
|----------|-------|
| `@NROCONTA` | `OLD.NROCONTA` |
| `@SALDOANTIGO` | `OLD.SALDO` |
| `@VALORTRANSACAO` | **`(NEW.SALDO - OLD.SALDO)`** ← cálculo central |
| `@SALDONOVO` | `NEW.SALDO` |

E inserir uma linha em `AuditFin` com:

| Coluna do AuditFin | Valor |
|---------------------|-------|
| `usuario` | `CURRENT_USER` |
| `estacao` | `USER()` |
| `dataautitoria` | `CURRENT_DATE` |
| `conta` | `@NROCONTA` |
| `saldo_antigo` | `@SALDOANTIGO` |
| `valor_transacao` | `@VALORTRANSACAO` |
| `saldo_novo` | `@SALDONOVO` |

### 🧱 Estrutura geral

```text
DELIMITER //

CREATE TRIGGER tg_Audita_Fin AFTER UPDATE ON CONTA
FOR EACH ROW BEGIN
    -- 4 SETs capturando OLD e NEW e calculando o valor_transacao

    -- 1 INSERT em AuditFin com CURRENT_USER, USER(), current_date, e os 4 valores
END //

DELIMITER ;
```

> 💡 **Sobre `CURRENT_USER` e `USER()`:** ambos retornam informações sobre o usuário conectado. `CURRENT_USER` retorna o usuário **autenticado** (forma `'usuario'@'host'`). `USER()` retorna o usuário **declarado na conexão**. Em geral são iguais, mas podem diferir em cenários com `SET ROLE`. Os dois são preservados na auditoria por completude.

---

## 🧭 Passo 4 — Execute a bateria de testes

A bateria abaixo é **a mesma** do roteiro original do professor. Execute-a **na ordem**:

```sql
CALL sp_transf_bancaria(1111, 2222, 5000);
CALL sp_transf_bancaria(5555, 6666, 1600);
CALL sp_transf_bancaria(1111, NULL, 2000);
CALL sp_transf_bancaria(1111, 2222, 450.55);
```

> 💡 **Note:** estamos usando a **v1** (`sp_transf_bancaria`) deliberadamente. A Trigger funciona igualmente bem com a v2 — porque o gatilho é o `UPDATE`, não a SP. Se você preferir, refaça com `sp_transf_bancaria02`; o resultado em `AuditFin` será o mesmo (exceto pela 3ª chamada, que com a v2 também falharia, mas com mensagem mais clara).

| Chamada | Expectativa |
|---------|-------------|
| #1: (1111, 2222, 5000) | ✅ Sucesso. 2 `UPDATE`s → **2 linhas em AuditFin** (origem -5000, destino +5000). |
| #2: (5555, 6666, 1600) | ✅ Sucesso. **Mais 2 linhas em AuditFin** (origem -1600, destino +1600). |
| #3: (1111, NULL, 2000) | ❌ Parâmetro inválido. **Nenhuma linha em AuditFin** (não houve `UPDATE`). |
| #4: (1111, 2222, 450.55) | ✅ Sucesso. **Mais 2 linhas em AuditFin** (origem -450.55, destino +450.55). |

### Verificação

```sql
SELECT * FROM Conta;
SELECT * FROM AuditFin;
```

**Em `AuditFin`, você deve ver 6 linhas** (3 transferências × 2 linhas cada). A coluna `valor_transacao` mostra um padrão claro: pares de **valores espelhados**.

> 💡 **Soma total da coluna `valor_transacao` deve ser zero:** `SELECT SUM(valor_transacao) FROM AuditFin;`. Esse resultado é a **prova matemática** da conservação do dinheiro.

---

## 📋 Linhas esperadas em `AuditFin`

Após as 4 chamadas (sendo a #3 inválida), `AuditFin` deve ter **6 linhas**:

| idAuditoria | conta | saldo_antigo | valor_transacao | saldo_novo |
|-------------|-------|--------------|-----------------|------------|
| 1 | 1111 | 10000.00 | -5000.00 | 5000.00 |
| 2 | 2222 | 0.00 | 5000.00 | 5000.00 |
| 3 | 5555 | 10000.00 | -1600.00 | 8400.00 |
| 4 | 6666 | 1000.00 | 1600.00 | 2600.00 |
| 5 | 1111 | 5000.00 | -450.55 | 4549.45 |
| 6 | 2222 | 5000.00 | 450.55 | 5450.55 |

(`usuario`, `estacao`, `dataautitoria` variam conforme seu ambiente.)

> 💡 **Confirme a conservação:** `SELECT SUM(valor_transacao) FROM AuditFin;` retorna `0.00`.

---

## ✏️ Atividade Prática

### 📝 Atividade 7 — Auditoria Financeira

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Verificar a estrutura criada com `SHOW CREATE TABLE` e `SHOW TRIGGERS`.
- Refletir sobre `DECIMAL` vs `FLOAT` em finanças.
- Demonstrar que a soma de `valor_transacao` é sempre zero por transferência.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco7.sql](./codigo-fonte/COMANDOS-BD-03-bloco7.sql)

---

## ✅ Resumo do Bloco 7

Neste bloco você:

- Criou a tabela `AuditFin` com tipos financeiros adequados (`DECIMAL(9,2)`).
- Criou a Trigger `tg_Audita_Fin` (`AFTER UPDATE ON CONTA`) com **cálculo** `NEW − OLD`.
- Verificou que cada transferência gera **2 linhas espelhadas** em `AuditFin`.
- Confirmou que a soma global de `valor_transacao` é **zero** — conservação do dinheiro.

---

## 🎯 Conceitos-chave para fixar

💡 **`AFTER UPDATE` dispara uma vez por linha alterada** — uma SP com 2 `UPDATE`s gera 2 disparos.

💡 **Cálculo `NEW − OLD`** distingue **debito** (negativo) e **crédito** (positivo) automaticamente.

💡 **`DECIMAL(p,s)`** é o tipo correto para **valores financeiros** — `FLOAT` tem imprecisão binária inadmissível.

💡 **Conservação do dinheiro** = `SUM(valor_transacao)` por transferência **sempre** zero.

💡 **A Trigger não diferencia** se o `UPDATE` veio da v1 ou v2 da SP — só importa que o `UPDATE` aconteceu.

---

## ➡️ Próximos Passos

No Bloco 8 você vai resolver o **exercício integrador**: criar `sp_saque` e `sp_deposito`, duas SPs **unitárias** (mexem em uma só conta cada). Diferente da transferência, cada chamada gera **uma única linha** em `AuditFin`. Sem código guia.

Acesse: [📁 Bloco 8](../Bloco8/README.md)

---

> 💭 *"Trigger que apenas registra é como câmera que só filma. Trigger que **calcula** dá ao dado bruto significado financeiro: positivo, negativo, zero. É auditoria de verdade."*
