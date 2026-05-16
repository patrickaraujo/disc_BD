# 📘 Bloco 5 — Aprendendo com falhas: análise crítica da v1

> **Duração estimada:** 50 minutos  
> **Objetivo:** Examinar **três cenários de falha silenciosa** da `sp_transf_bancaria` (versão 1) — incluindo o caso em que dinheiro **simplesmente desaparece** — e formar uma lista clara de melhorias para a v2.  
> **Modalidade:** **Bloco analítico**, não construtivo. Você não cria código novo aqui — você **executa testes diagnósticos** sobre a SP do Bloco 4 e interpreta os resultados.

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você terá:

- Identificado **três cenários** em que a v1 falha silenciosamente ou retorna diagnóstico errado.
- Compreendido por que comparações `>=` com `NULL` produzem resultado inesperado em SQL.
- Entendido a diferença entre **`UPDATE` que falha** e **`UPDATE` que afeta 0 linhas**.
- Construído a **lista de requisitos** que orientarão a v2 no Bloco 6.

---

## 🚦 Antes de começar

> ⚠️ **Importante:** este bloco trabalha com a SP do Bloco 4 — sem alterações. Se você já modificou a SP, recrie-a a partir do gabarito do Bloco 4 antes de continuar.

> 💡 **Estado inicial recomendado** das contas (após o Bloco 4):
> * `1111` → 5000
> * `2222` → 5000
> * `5555` → 8400
> * `6666` → 2600
>
> Se quiser começar fresco, faça um `TRUNCATE Conta` e repopule com os valores originais (10000, 0, 10000, 1000) antes dos cenários abaixo.

---

## 🔬 Cenário 1 — Conta de **origem** inexistente

### A chamada

```sql
CALL sp_transf_bancaria(9999, 2222, 100);
```

A conta `9999` **não existe** em `Conta`. Vamos rastrear a SP linha a linha:

| Linha da SP | Estado |
|-------------|--------|
| `SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = 9999)` | A subquery retorna **0 linhas** → `@saldo_origem = NULL` |
| `SET @saldo_destino = 0` | OK |
| `IF v_origem IS NOT NULL AND v_destino IS NOT NULL` | `9999 IS NOT NULL` e `2222 IS NOT NULL` — **TRUE**. Avança. |
| `IF @saldo_origem >= v_valor` | `NULL >= 100` — em SQL, isso **não é TRUE nem FALSE**, é `UNKNOWN`. Em um `IF`, `UNKNOWN` cai no `ELSE`. |
| **Caminho percorrido:** branch do `ELSE` da validação de saldo | Mensagem retornada: `'Saldo Insuficiente, transação cancelada!!!'` |

### O problema

A SP retorna **`Saldo Insuficiente`** — mas o problema real é **`conta inexistente`**. O usuário recebe um diagnóstico **enganoso**: tenta carregar a conta com mais saldo, e depois não entende por que a transferência continua falhando.

### A explicação técnica

Em SQL, **comparações com `NULL` retornam `UNKNOWN`** — não retornam `FALSE`. Isso é a chamada **lógica de três valores** (TRUE, FALSE, UNKNOWN) do SQL. Em um `IF` ou `WHERE`, qualquer condição `UNKNOWN` é tratada como **falsa** para fins de fluxo, mas **a semântica é diferente**.

| Expressão | Lógica clássica | Lógica SQL |
|-----------|-----------------|-----------|
| `5 >= 100` | FALSE | FALSE |
| `NULL >= 100` | (não definida) | **UNKNOWN** |
| `NULL = NULL` | TRUE | **UNKNOWN** (use `IS NULL`!) |

> 💡 **Lição:** `IF @saldo_origem >= v_valor` **não distingue** entre "saldo é menor" e "saldo não foi capturado". A v2 precisa testar **explicitamente** se a conta existe.

---

## 🔬 Cenário 2 — Conta de **destino** inexistente — **DINHEIRO SUME**

### A chamada

```sql
CALL sp_transf_bancaria(1111, 9999, 100);
```

A conta de destino `9999` não existe. Vamos rastrear:

| Linha da SP | Estado |
|-------------|--------|
| `SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = 1111)` | Conta 1111 existe → `@saldo_origem` recebe o saldo atual (5000, supondo estado pós-Bloco 4) |
| `IF v_origem IS NOT NULL AND v_destino IS NOT NULL` | `1111 IS NOT NULL` e `9999 IS NOT NULL` — **TRUE**. Avança. |
| `IF @saldo_origem >= v_valor` | `5000 >= 100` — **TRUE**. Entra no caminho da transação. |
| `START TRANSACTION` | Abre transação. |
| `UPDATE Conta SET Saldo = (saldo - 100) WHERE NroConta = 1111` | ✅ **Debita 100 de 1111**. Saldo: 4900. |
| `UPDATE Conta SET Saldo = (saldo + 100) WHERE NroConta = 9999` | ⚠️ **Afeta 0 linhas** (porque 9999 não existe). **Mas `UPDATE` que afeta 0 linhas NÃO É ERRO em SQL!** `erro_sql` permanece FALSE. |
| `IF erro_sql = FALSE THEN COMMIT` | ✅ Commit executado. Mensagem: `'Contas alteradas com sucesso:'`. |

### O problema

**A SP retorna sucesso. Os R$100 saíram da conta 1111. Não foram para conta nenhuma. O dinheiro simplesmente desapareceu do sistema.**

### A explicação técnica

Em SQL, há uma **distinção crucial** entre:

| Situação | Comportamento |
|----------|--------------|
| `UPDATE` que viola FK / NOT NULL / tipo | **Erro `SQLEXCEPTION`** → handler vira `erro_sql = TRUE` → `ROLLBACK` |
| `UPDATE` que afeta 0 linhas (`WHERE` não casa com nenhuma linha) | **Não é erro**. `erro_sql` permanece FALSE. `COMMIT` é executado. |

> 💡 **Lição:** depender apenas de `SQLEXCEPTION` para detectar problemas é **insuficiente**. A v2 precisa **validar explicitamente** que as contas existem **antes** de qualquer `UPDATE`.

### Faça o teste e veja com seus próprios olhos

```sql
-- Estado antes
SELECT * FROM Conta WHERE NroConta = 1111;

-- A "transferência" para o nada
CALL sp_transf_bancaria(1111, 9999, 100);

-- Estado depois — note que 1111 perdeu 100 que não foram para lugar algum
SELECT * FROM Conta WHERE NroConta = 1111;

-- Confirme: a soma dos saldos diminuiu
SELECT SUM(saldo) FROM Conta;
```

> ⚠️ **Em um sistema bancário real, esse bug é catastrófico.** Vai dar um nó na contabilidade, gerar reclamações de cliente, possivelmente atrair fiscalização do Banco Central. Em produção, é o tipo de bug que **demite gente**.

---

## 🔬 Cenário 3 — Valor zero, negativo ou origem == destino

### Valor zero

```sql
CALL sp_transf_bancaria(1111, 2222, 0);
```

A SP executa normalmente — saldos não mudam (debita 0, credita 0), mas a transação consome recursos do banco e gera registro em auditoria (no Bloco 7) **sem motivo**. Não é catastrófico, mas é poluição do sistema.

### Valor negativo

```sql
CALL sp_transf_bancaria(1111, 2222, -500);
```

* `IF @saldo_origem >= -500` é sempre TRUE (qualquer saldo positivo é maior que -500).
* `UPDATE Conta SET Saldo = saldo - (-500)` → **credita** 500 na origem.
* `UPDATE Conta SET Saldo = saldo + (-500)` → **debita** 500 do destino.
* Resultado: a "transferência" inverteu o fluxo. **A origem ganhou, o destino perdeu.**

> 💡 **Em outras palavras:** com valor negativo, a SP vira uma "calotada legalizada". Se um usuário malicioso conseguir injetar valor negativo (via interface mal validada), pode roubar saldo de outras contas.

### Origem == destino

```sql
CALL sp_transf_bancaria(1111, 1111, 100);
```

* O `UPDATE` debita 100 da conta 1111.
* O `UPDATE` credita 100 na conta 1111.
* **Saldo final inalterado.** Mas a Trigger de auditoria (Bloco 7) registrará 2 movimentos contraditórios. Pode confundir relatórios.

> 💡 Não é catastrófico, mas é uma operação **sem sentido de negócio** que deveria ser bloqueada.

---

## 📋 Resumo das falhas identificadas

| # | Cenário | Severidade | O que a v1 faz | O que deveria fazer |
|---|---------|------------|----------------|---------------------|
| 1 | Conta origem inexistente | Média (diagnóstico errado) | Mensagem `'Saldo Insuficiente'` enganosa | Mensagem específica: conta inexistente |
| 2 | Conta destino inexistente | **CRÍTICA** (dinheiro some) | Retorna sucesso e debita origem em vão | Bloquear antes do primeiro `UPDATE` |
| 3a | Valor zero | Baixa | Executa sem motivo | Bloquear |
| 3b | Valor negativo | **CRÍTICA** (inverte transferência) | Executa, "rouba" do destino | Bloquear |
| 3c | Origem == destino | Baixa | Saldo inalterado, mas movimenta auditoria | Bloquear |

---

## 🎯 Lista de requisitos para a v2

A partir da análise acima, a versão 2 (`sp_transf_bancaria02`) deve garantir:

✅ **Validar existência das contas** (origem **e** destino) antes de qualquer `UPDATE`.
✅ **Validar que `v_valor > 0`** — rejeita zero, negativo e qualquer valor inválido.
✅ Continuar validando saldo (mantém a lógica `@saldo_origem >= v_valor` da v1).
✅ Continuar validando que parâmetros não são `NULL` (mantém a lógica da v1).
✅ Manter o padrão transacional com `CONTINUE HANDLER` (defesa em profundidade).

> 💡 **Observação opcional:** a validação `v_origem != v_destino` poderia ser adicionada, mas o roteiro do professor não exige. Vamos seguir o roteiro e ficar com 3 validações. (Se você quiser ir além no Bloco 8, pode incluir essa quarta.)

---

## ✏️ Atividade Prática

### 📝 Atividade 5 — Diagnosticando bugs

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Reproduzir os 3 cenários e relatar os comportamentos observados.
- Refletir sobre lógica de três valores em SQL.
- Antecipar a estrutura da v2.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco5.sql](./codigo-fonte/COMANDOS-BD-03-bloco5.sql)

> 💡 **Atenção:** o "código-fonte" deste bloco é um **roteiro de testes diagnósticos**, não uma SP nova.

---

## ✅ Resumo do Bloco 5

Neste bloco você:

- Examinou **3 cenários de falha silenciosa** da v1.
- Entendeu por que `NULL >= valor` é `UNKNOWN` (não `FALSE`) em SQL.
- Compreendeu que **`UPDATE` que afeta 0 linhas não é erro** — apenas `SQLEXCEPTION` é capturado pelo handler.
- Construiu a lista de requisitos para a v2.

---

## 🎯 Conceitos-chave para fixar

💡 **Lógica de 3 valores** em SQL: TRUE, FALSE, UNKNOWN. `NULL` em comparações produz `UNKNOWN`.

💡 **`UPDATE` que afeta 0 linhas ≠ erro.** Para detectar isso, é preciso verificar `ROW_COUNT()` ou validar antes via `SELECT`.

💡 **`SQLEXCEPTION`** captura erros **graves** (FK, NOT NULL, sintaxe) — mas não cobre "contas inexistentes" ou "valores semanticamente inválidos".

💡 **Programação defensiva** > programação ofensiva: melhor **prevenir** que detectar depois.

💡 **Diagnóstico errado** é frequentemente pior que falha: o usuário tenta corrigir o que não está quebrado.

---

## ➡️ Próximos Passos

No Bloco 6 você vai construir a **versão 2** da SP, corrigindo as falhas identificadas neste bloco. A técnica central será o uso de `@conta_origem` e `@conta_destino` capturadas via `SELECT` — analogamente ao que já fazemos com `@saldo_origem`.

Acesse: [📁 Bloco 6](../Bloco6/README.md)

---

> 💭 *"O bug mais perigoso é aquele que o sistema **diz que não existe**. Por isso, o primeiro dever de uma SP confiável é **não mentir**."*
