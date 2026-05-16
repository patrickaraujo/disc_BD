# 🧠 Atividade 7 — Auditoria Financeira

> **Duração:** 30 minutos  
> **Formato:** Individual  
> **Objetivo:** Confirmar a estrutura e o funcionamento da Trigger `tg_Audita_Fin`, e refletir sobre as escolhas de tipo e cálculo.

---

## 📋 Parte 1 — Inspeção

69. Execute:

```sql
SHOW CREATE TABLE AuditFin;
```

Localize cada coluna e confirme o tipo. Em particular:
* `dataautitoria` é `DATE` ou `DATETIME`?
* `saldo_antigo`, `valor_transacao`, `saldo_novo` são `DECIMAL(9,2)` ou outro tipo?

70. Execute:

```sql
SHOW TRIGGERS LIKE 'Conta';
```

A Trigger `tg_Audita_Fin` aparece? Em qual evento (`UPDATE`, `INSERT`, `DELETE`) ela está vinculada?

---

## 📋 Parte 2 — Verificação dos Resultados da Bateria

71. Após executar as 4 chamadas obrigatórias do roteiro, execute:

```sql
SELECT * FROM AuditFin ORDER BY idAuditoria;
```

Quantas linhas aparecem? Por que esse número específico, dado que houve **4 chamadas**?

72. Calcule a soma de `valor_transacao` por par de linhas (linhas 1+2, 3+4, 5+6):

```sql
SELECT idAuditoria, conta, valor_transacao FROM AuditFin ORDER BY idAuditoria;
```

A soma de cada par é **zero**? Por quê?

73. Calcule a **soma global** de `valor_transacao`:

```sql
SELECT SUM(valor_transacao) FROM AuditFin;
```

O resultado é zero? O que isso prova sobre a integridade do sistema?

74. Olhe a coluna `saldo_antigo` da linha 5 (`idAuditoria = 5`). Esse valor é `5000.00`. Por que não é `10000.00` (o saldo inicial da conta 1111)?

---

## 📋 Parte 3 — Por que DECIMAL e não FLOAT?

75. Execute, no MySQL:

```sql
SELECT 0.1 + 0.2 AS soma_float;
SELECT CAST(0.1 AS DECIMAL(5,2)) + CAST(0.2 AS DECIMAL(5,2)) AS soma_decimal;
```

Os resultados são iguais a `0.3`? Comente a importância dessa diferença em sistema financeiro.

76. Suponha que a coluna `saldo` da `Conta` fosse alterada para `DECIMAL(10,2)`. A Trigger `tg_Audita_Fin` continuaria funcionando? Ou seria preciso recriá-la?

---

## 📋 Parte 4 — Variações Hipotéticas

77. Imagine que a Trigger fosse **`BEFORE UPDATE`** em vez de `AFTER UPDATE`. Qual seria o efeito **prático**? Pense no caso de uma falha durante o `UPDATE` (ex.: SQL exception).

78. Imagine que a Trigger não calculasse `valor_transacao = NEW − OLD`, mas registrasse apenas `OLD.SALDO` e `NEW.SALDO`. Como você calcularia `valor_transacao` em uma consulta posterior?

```sql
SELECT idAuditoria, conta, _____ AS valor_transacao FROM AuditFin;
```

79. Que vantagem prática a coluna `valor_transacao` calculada na Trigger oferece em relação a calcular sob demanda em consultas?

80. Suponha que a Trigger fosse `INSERT, UPDATE, DELETE` em vez de só `UPDATE`. Quais cenários adicionais ela cobriria? E quais novos riscos surgiriam?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

69. Estrutura esperada:
* `dataautitoria` → **`DATE`** (apenas data, sem hora).
* `saldo_antigo`, `valor_transacao`, `saldo_novo` → **`DECIMAL(9,2)`**.

70. Sim, `tg_Audita_Fin` aparece com `Event = UPDATE`, `Timing = AFTER`.

---

### Parte 2

71. **6 linhas.** A explicação:
* Chamada #1 (1111 → 2222, 5000): 2 `UPDATE`s → 2 linhas.
* Chamada #2 (5555 → 6666, 1600): 2 `UPDATE`s → 2 linhas.
* Chamada #3 (1111, NULL, 2000): **falha — nenhum `UPDATE`** → 0 linhas.
* Chamada #4 (1111 → 2222, 450.55): 2 `UPDATE`s → 2 linhas.

Total: 2 + 2 + 0 + 2 = **6 linhas**.

72. Pares e somas:

| Par | conta + valor_transacao | conta + valor_transacao | Soma do par |
|-----|------------------------|------------------------|-------------|
| 1, 2 | 1111: -5000.00 | 2222: 5000.00 | 0 |
| 3, 4 | 5555: -1600.00 | 6666: 1600.00 | 0 |
| 5, 6 | 1111: -450.55 | 2222: 450.55 | 0 |

Cada par soma zero porque uma transferência **conserva o dinheiro** — o que sai de um lado entra no outro.

73. **Sim, soma é zero.** Isso prova que **toda transferência foi simétrica** — o dinheiro sempre saiu de algum lugar e chegou a algum lugar. Em outras palavras: nenhuma "fuga" no sistema.

74. Porque a chamada #1 (que aconteceu **antes** da #4) já havia debitado 5000 da conta 1111. Quando a #4 começou, o saldo de 1111 era `10000 − 5000 = 5000`. A Trigger registra o `OLD.SALDO` no momento do `UPDATE` — que é o estado vigente naquele instante.

---

### Parte 3

75. **`0.1 + 0.2` em FLOAT** retorna `0.30000000000000004` (ou similar — depende da plataforma). **Em DECIMAL** retorna exatamente `0.30`. Em finanças, mesmo um centavo de erro **não é aceitável** — clientes, contadores e fiscalização exigem cálculo exato. `DECIMAL` é o tipo correto.

76. **A Trigger continuaria funcionando.** O MySQL faz conversão implícita entre `FLOAT` e `DECIMAL` em operações aritméticas. A precisão da auditoria poderia até **melhorar** se a fonte (`Conta.saldo`) fosse `DECIMAL`. Não é necessário recriar a Trigger.

---

### Parte 4

77. Com `BEFORE UPDATE`, a Trigger executaria **antes** do `UPDATE` modificar a linha. O `OLD.SALDO` ainda seria o saldo atual, mas o `NEW.SALDO` seria o **valor proposto** — não confirmado. Se o `UPDATE` falhasse depois (ex.: violação de constraint), o registro de auditoria já teria sido inserido — registrando uma alteração que **não aconteceu**. Em ambiente transacional, o `ROLLBACK` da SP desfaria o `INSERT` em `AuditFin`, mas em código fora de transação, o registro ficaria órfão. **`AFTER UPDATE` é a escolha correta** para garantir que **só o que efetivamente aconteceu** seja registrado.

78. Cálculo sob demanda: `(saldo_novo - saldo_antigo) AS valor_transacao`.

```sql
SELECT idAuditoria, conta, (saldo_novo - saldo_antigo) AS valor_transacao FROM AuditFin;
```

79. Vantagens de **calcular na Trigger**:
* **Performance**: o cálculo já está feito; consultas a relatórios são mais rápidas.
* **Indexabilidade**: você pode criar índice em `valor_transacao` (não pode em uma expressão calculada).
* **Filtros simples**: `WHERE valor_transacao < 0` (saídas) é mais legível e rápido que `WHERE saldo_novo < saldo_antigo`.
* **Imutabilidade do passado**: o valor registrado não muda mesmo se houver mudança futura na conta.

80. **Cenários adicionais cobertos:**
* `INSERT` em `Conta`: registraria a criação da conta.
* `DELETE` em `Conta`: registraria a remoção.

**Novos riscos:**
* Em `INSERT`, **`OLD.SALDO` não existe** — precisaria de tratamento especial (`IF OLD.NROCONTA IS NULL`).
* Em `DELETE`, **`NEW.SALDO` não existe** — mesma observação.
* A Trigger ficaria mais complexa, com mais ramificações. Em geral, é melhor ter **3 Triggers separadas** (uma para cada evento), cada uma especializada.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Reconhecer **`DECIMAL`** como tipo obrigatório em campos monetários.  
✅ Entender que **a soma de `valor_transacao` em uma transferência é sempre zero** — princípio físico-contábil do sistema.  
✅ Justificar **`AFTER UPDATE`** como timing correto para auditoria.  
✅ Antecipar quando **calcular em Trigger** é melhor que calcular sob demanda.  

> 💡 *"Auditoria não é só guardar — é **dar significado**. Uma trilha que diz `+1000` é mais útil que uma que diz `'mudou de X para Y'`."*
