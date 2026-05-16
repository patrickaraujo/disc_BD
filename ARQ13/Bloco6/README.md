# 📘 Bloco 6 — Stored Procedure de Transferência (v2 — validação robusta)

> **Duração estimada:** 45 minutos  
> **Objetivo:** Construir `sp_transf_bancaria02`, a **versão corrigida** da SP do Bloco 4 — agora com validação de existência das contas e validação de valor positivo.  
> **Modalidade:** Guiada — você reescreve a SP aplicando as lições do Bloco 5.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- A SP **`sp_transf_bancaria02`** (nome novo — coexiste com a v1 do Bloco 4).
- **Duas variáveis de sessão extras**: `@conta_origem` e `@conta_destino`, capturadas via `SELECT` para validar existência das contas.
- Uma **única validação combinada** no `IF` nível 1 que cobre os 3 problemas identificados no Bloco 5.
- Bateria de testes que **prova** que a v2 corrige cada uma das falhas da v1.

---

## 💡 Antes de começar — o padrão `@conta_X = (SELECT NroConta WHERE …)`

A técnica que vamos aplicar é uma **extensão natural** do que você fez no Bloco 4 com `@saldo_origem`. A diferença é o que captura:

| Variável | O que captura | Para que serve |
|----------|---------------|---------------|
| `@saldo_origem` (já usada na v1) | Saldo da conta origem (`FLOAT`) | Validar suficiência de saldo |
| `@conta_origem` (**nova**) | NroConta da conta origem (`INT`) — ou `NULL` se não existir | Validar **existência** da conta origem |
| `@conta_destino` (**nova**) | NroConta da conta destino — ou `NULL` se não existir | Validar **existência** da conta destino |

### 🔹 O comando-chave

```sql
SET @conta_origem = (SELECT NroConta FROM Conta WHERE NroConta = v_origem);
```

| Cenário | Resultado |
|---------|-----------|
| `v_origem = 1111` (conta existe) | Subquery retorna `1111` → `@conta_origem = 1111` (não-NULL) |
| `v_origem = 9999` (conta não existe) | Subquery retorna 0 linhas → `@conta_origem = NULL` |
| `v_origem = NULL` (parâmetro nulo) | Subquery `WHERE NroConta = NULL` retorna 0 linhas (porque `= NULL` é UNKNOWN) → `@conta_origem = NULL` |

> 💡 **Observe a elegância da técnica:** `@conta_X IS NOT NULL` testa **simultaneamente** se a conta existe E se o parâmetro não é nulo. Uma única verificação cobre os dois casos. Essa é a **chave** da robustez da v2.

---

## 🧱 Estrutura geral da v2

A `sp_transf_bancaria02` é **quase idêntica** à v1. As únicas diferenças são:

1. **Nome diferente** (`sp_transf_bancaria02` em vez de `sp_transf_bancaria`).
2. **Duas linhas novas** capturando `@conta_origem` e `@conta_destino`.
3. **Validação ampliada** no `IF` nível 1: `@conta_origem IS NOT NULL AND @conta_destino IS NOT NULL AND v_valor > 0`.

Todo o resto — handler de erro, captura de saldo, validação de saldo, transação, reler saldos, mensagens — permanece **inalterado**.

> 💡 **Por que a v2 tem nome diferente** em vez de substituir a v1? Para que **ambas coexistam** e você possa **comparar lado a lado** o comportamento das duas. Em produção, depois de validada a v2, você poderia apagar a v1 com `DROP PROCEDURE sp_transf_bancaria;`.

---

## 🧭 Passo a passo

### Passo 1 — Defina o cabeçalho da SP

Idêntico à v1, mudando apenas o nome:

```text
CREATE PROCEDURE sp_transf_bancaria02 (
    IN v_origem  INT,
    IN v_destino INT,
    IN v_valor   FLOAT
)
```

### Passo 2 — Trio de tratamento de erro (já dominado)

```text
DECLARE erro_sql boolean DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;
```

### Passo 3 — Capture as **três** variáveis de sessão

```text
SET @conta_origem  = (SELECT NroConta FROM Conta WHERE NroConta = v_origem);
SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = v_destino);
SET @saldo_origem  = (SELECT saldo    FROM Conta WHERE NroConta = v_origem);
```

> 💡 **Note:** `@saldo_destino` **não é** mais inicializada com 0 aqui (a v1 fazia isso). Em vez disso, ela só é setada **dentro** da transação, junto com a re-leitura final. (No fundo, é um detalhe estilístico — o roteiro original da v2 omitiu essa linha, então vamos seguir o mesmo estilo.)

### Passo 4 — IF nível 1: validação **combinada**

A grande mudança da v2 é aqui. Em vez de validar só `v_origem IS NOT NULL AND v_destino IS NOT NULL`, validamos:

```text
IF @conta_origem IS NOT NULL
   AND @conta_destino IS NOT NULL
   AND v_valor > 0
THEN
    -- prossegue para o nível 2 (validação de saldo)
ELSE
    SELECT 'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!' AS RESULTADO;
END IF;
```

> 💡 **Esta única condição cobre os 3 cenários do Bloco 5:**
> * **Conta origem inexistente** → `@conta_origem IS NULL` → falha aqui.
> * **Conta destino inexistente** → `@conta_destino IS NULL` → falha aqui (antes do `UPDATE`!).
> * **Valor zero ou negativo** → `v_valor > 0` falha → cai aqui.
> * **Parâmetros NULL** → também caem aqui (porque `WHERE NroConta = NULL` retorna 0 linhas → `@conta_X = NULL`).

> 💭 **A única falha que NÃO cai aqui** é "saldo insuficiente" — essa continua sendo tratada pelo IF nível 2, exatamente como na v1.

### Passo 5 — IF nível 2 e nível 3 (idênticos à v1)

Validação de saldo, transação com 2 `UPDATE`s, decisão entre `COMMIT`/`ROLLBACK`, re-leitura dos saldos e mensagem de sucesso/falha — **tudo igual à v1**.

---

## 🧪 Testes obrigatórios

A bateria abaixo prova, **caso por caso**, que a v2 corrige as falhas da v1.

### Setup — restaurar estado conhecido

Antes de testar, restaure os saldos originais:

```sql
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0, 1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;
```

### Teste 1 — caso simples (a transferência que originalmente falhava por saldo)

```sql
CALL sp_transf_bancaria02(1111, 2222, 7000);
```

**Esperado:** com saldo de 10000 em 1111, a transferência de 7000 **funciona** agora (em vez do erro "Saldo Insuficiente" da v1, que ocorria após o saldo já ter sido decrementado pelos testes anteriores). Saldo final: 1111 → 3000, 2222 → 7000.

### Teste 2 — caso que dava "diagnóstico errado" na v1

```sql
CALL sp_transf_bancaria02(9999, 2222, 100);
```

**Esperado:** mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`. **Honesta** desta vez — bloqueia antes de qualquer `UPDATE`. Soma total dos saldos **inalterada**.

### Teste 3 — caso "dinheiro some" (o catastrófico da v1)

```sql
CALL sp_transf_bancaria02(1111, 9999, 100);
```

**Esperado:** mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`. A conta 1111 **NÃO** é debitada. Soma total **preservada**.

### Teste 4 — valor negativo

```sql
CALL sp_transf_bancaria02(1111, 2222, -500);
```

**Esperado:** mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`. Nenhum saldo muda.

### Teste 5 — valor zero

```sql
CALL sp_transf_bancaria02(1111, 2222, 0);
```

**Esperado:** mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`.

### Teste 6 — parâmetro NULL

```sql
CALL sp_transf_bancaria02(1111, NULL, 2000);
```

**Esperado:** mensagem `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`. (`@conta_destino` recebe NULL porque `WHERE NroConta = NULL` não casa com nenhuma linha.)

---

## 🔄 Comparativo v1 × v2

| Aspecto | v1 (`sp_transf_bancaria`) | v2 (`sp_transf_bancaria02`) |
|---------|--------------------------|----------------------------|
| Variáveis capturadas via `SELECT` | `@saldo_origem` | `@conta_origem`, `@conta_destino`, `@saldo_origem` |
| Validação no IF nível 1 | `v_origem IS NOT NULL AND v_destino IS NOT NULL` | `@conta_origem IS NOT NULL AND @conta_destino IS NOT NULL AND v_valor > 0` |
| Aceita conta origem inexistente? | ❌ Sim — diagnóstico errado | ✅ Não — bloqueia honestamente |
| Aceita conta destino inexistente? | ❌ Sim — DINHEIRO SOME | ✅ Não — bloqueia antes do `UPDATE` |
| Aceita valor zero? | ❌ Sim | ✅ Não |
| Aceita valor negativo? | ❌ Sim — inverte fluxo | ✅ Não |
| Aceita parâmetro NULL? | ✅ Não (já validava) | ✅ Não |
| Tratamento de SQLEXCEPTION dentro da transação | ✅ Sim | ✅ Sim |

---

## ✏️ Atividade Prática

### 📝 Atividade 6 — Validação Robusta

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Reproduzir os 6 testes do roteiro e confirmar que a v2 corrige cada falha.
- Refletir sobre por que `WHERE NroConta = NULL` retorna 0 linhas em vez de erro.
- Comparar v1 × v2 lado a lado.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco6.sql](./codigo-fonte/COMANDOS-BD-03-bloco6.sql)

---

## ✅ Resumo do Bloco 6

Neste bloco você:

- Reescreveu a SP como `sp_transf_bancaria02`, **mantendo** a v1 e criando uma v2 ao lado.
- Adicionou **2 variáveis de sessão** (`@conta_origem`, `@conta_destino`) que cumprem **dupla função**: validar existência E lidar com parâmetros NULL.
- Substituiu a validação do IF nível 1 por uma **combinação** que cobre todas as falhas do Bloco 5.
- Provou, com bateria de 6 testes, que a v2 é robusta nos casos onde a v1 falhava.

---

## 🎯 Conceitos-chave para fixar

💡 **`SET @x = (SELECT col FROM t WHERE col = v_param)`** captura o valor (se a linha existir) ou `NULL` (se não existir) — padrão idiomático para validação de existência.

💡 **`WHERE col = NULL`** **não funciona** — retorna 0 linhas. Por sorte, é exatamente o que queremos para detectar parâmetros NULL.

💡 **Validação combinada com `AND`** cobre múltiplos cenários em uma só condição.

💡 **Coexistência de versões** (`sp_X` e `sp_X02`) permite **migração gradual** em produção — nenhum sistema é alterado de uma vez.

---

## ➡️ Próximos Passos

No Bloco 7 você vai criar a **Trigger de auditoria financeira** — `tg_Audita_Fin` — que registrará automaticamente toda alteração de saldo nas contas. Cada transferência gerará **2 linhas espelhadas** em `AuditFin`.

Acesse: [📁 Bloco 7](../Bloco7/README.md)

---

> 💭 *"Versão 1: faz funcionar. Versão 2: faz não-falhar. Profissional é quem sabe quando passar de uma para outra."*
