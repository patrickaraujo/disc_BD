# 🧠 Atividade 8 — Resolução Documentada do Exercício Integrador

> **Duração:** 60 minutos  
> **Formato:** Individual  
> **Objetivo:** Documentar passo a passo a sua resolução do exercício integrador, explicando suas escolhas e refletindo sobre tudo que aprendeu na ARQ13.

> ⚠️ **Esta atividade é avaliativa.** Resolva o exercício do Bloco 8 antes de responder.

---

## 📋 Parte 1 — Sua Resolução

81. Cole, abaixo, o seu `CREATE PROCEDURE sp_saque(...)`. Identifique:
* Em qual linha está a captura de `@conta`?
* Em qual linha está a validação combinada (existência + valor positivo)?
* Em qual linha está a validação de saldo?
* Quantos níveis de IF aninhado sua SP tem? Por quê?

82. Cole o seu `CREATE PROCEDURE sp_deposito(...)`. Compare estruturalmente com `sp_saque`:
* O que é **idêntico**?
* O que é **diferente**?
* Quantos níveis de IF? Por quê?

---

## 📋 Parte 2 — Bateria de Testes

83. Liste cada chamada feita à `sp_saque` e relate o resultado:

| Chamada | Resultado esperado | Resultado obtido |
|---------|-------------------|------------------|
| `sp_saque(1111, 3000)` | Sucesso | _____ |
| `sp_saque(1111, 100000)` | Saldo insuficiente | _____ |
| `sp_saque(9999, 100)` | Conta inexistente | _____ |
| `sp_saque(1111, -500)` | Valor negativo | _____ |
| `sp_saque(1111, 0)` | Valor zero | _____ |

84. Liste cada chamada feita à `sp_deposito`:

| Chamada | Resultado esperado | Resultado obtido |
|---------|-------------------|------------------|
| `sp_deposito(2222, 5000)` | Sucesso | _____ |
| `sp_deposito(9999, 100)` | Conta inexistente | _____ |
| `sp_deposito(2222, -200)` | Valor negativo | _____ |
| `sp_deposito(2222, 0)` | Valor zero | _____ |

---

## 📋 Parte 3 — Verificação da Auditoria

85. Após as 9 chamadas (5 de saque, 4 de depósito), execute:

```sql
SELECT * FROM AuditFin ORDER BY idAuditoria;
```

Quantas linhas aparecem? Por que esse número?

86. Para cada linha de `AuditFin`, identifique se é um **saque** ou um **depósito** (pela coluna `valor_transacao`):

| idAuditoria | conta | valor_transacao | É saque ou depósito? |
|-------------|-------|-----------------|---------------------|
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |
| ... | ... | ... | ... |

87. Execute:

```sql
SELECT SUM(valor_transacao) FROM AuditFin;
```

O resultado é **zero**? Por que sim ou por que não? Compare com a observação do Bloco 7.

---

## 📋 Parte 4 — Reflexão Final

88. Liste **três técnicas/padrões** que você aprendeu na ARQ13 e que reusou no exercício do Bloco 8:

| Padrão | Veio do Bloco | Como apareceu no Bloco 8 |
|--------|---------------|--------------------------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

89. Em uma frase, descreva o que mais te ajudou a resolver o exercício: foi o conhecimento prévio (vindo da aula teórica), foi a prática dos blocos 1-7, foi a comparação v1 × v2, ou foi outra coisa?

90. Em qual das duas SPs (saque ou depósito) **a v2 da transferência (sp_transf_bancaria02) foi mais útil como referência**? Por quê?

91. Imagine que, na próxima aula, você precise criar **uma terceira SP**: `sp_transferencia_internacional`. Ela transfere entre duas contas, mas aplica uma **taxa cambial** (parâmetro adicional `v_taxa FLOAT`) e gera **três `UPDATE`s**: debita origem, credita destino com valor convertido, e credita uma "conta-banco" (1, 1, 1) com o valor da taxa. Sem implementar agora, descreva em poucas linhas:
* Quantas linhas em `AuditFin` cada chamada bem-sucedida geraria?
* `SUM(valor_transacao)` por chamada seria zero?
* Quais validações da v2 você reutilizaria? Quais novas você precisaria adicionar?

---

## ✅ Gabarito sugestivo (use apenas após tentar!)

### Parte 1

81. Estrutura esperada da `sp_saque`:
* Captura de `@conta` (e `@saldo`) logo após `DECLARE`s.
* Validação combinada `IF @conta IS NOT NULL AND v_valor > 0 THEN`.
* Validação de saldo `IF @saldo >= v_valor THEN`.
* **2 níveis de IF aninhado** — análogo à v2 da transferência, mas sem o IF do destino.

82. Comparação:
* **Idêntico:** estrutura geral (DECLARE + handler, captura de `@conta`, IF de validação, START TRANSACTION, COMMIT/ROLLBACK).
* **Diferente:** `sp_deposito` **não tem** validação de saldo (depósito não exige saldo prévio). Tem **1 nível de IF aninhado** (apenas a validação combinada).
* **Quantidade de IFs:** `sp_saque` tem 2 níveis de IF (params + saldo); `sp_deposito` tem 1 (params). É menos complexa.

---

### Parte 2

83. Resultados esperados:

| Chamada | Resultado |
|---------|-----------|
| `sp_saque(1111, 3000)` | ✅ Sucesso. Saldo: 10000 → 7000 |
| `sp_saque(1111, 100000)` | ❌ `'Saldo Insuficiente, saque cancelado!!!'` |
| `sp_saque(9999, 100)` | ❌ `'Parâmetros inadequados, saque cancelado!!!'` |
| `sp_saque(1111, -500)` | ❌ `'Parâmetros inadequados, saque cancelado!!!'` |
| `sp_saque(1111, 0)` | ❌ `'Parâmetros inadequados, saque cancelado!!!'` |

84. Resultados:

| Chamada | Resultado |
|---------|-----------|
| `sp_deposito(2222, 5000)` | ✅ Sucesso. Saldo: 0 → 5000 |
| `sp_deposito(9999, 100)` | ❌ `'Parâmetros inadequados, depósito cancelado!!!'` |
| `sp_deposito(2222, -200)` | ❌ `'Parâmetros inadequados, depósito cancelado!!!'` |
| `sp_deposito(2222, 0)` | ❌ `'Parâmetros inadequados, depósito cancelado!!!'` |

---

### Parte 3

85. **2 linhas** em `AuditFin`:
* 1 linha do saque bem-sucedido em 1111 (valor_transacao = -3000).
* 1 linha do depósito bem-sucedido em 2222 (valor_transacao = +5000).

As outras 7 chamadas falharam antes do `UPDATE`, então nada foi auditado.

86. Identificação:

| idAuditoria | conta | valor_transacao | Tipo |
|-------------|-------|-----------------|------|
| 1 | 1111 | -3000.00 | Saque |
| 2 | 2222 | 5000.00 | Depósito |

87. **Resultado: +2000.00** (= 5000 − 3000). **Não é zero.** Diferente do Bloco 7, onde transferências sempre geravam pares simétricos. Saques e depósitos **alteram a soma total** do banco — saque tira dinheiro do sistema, depósito injeta dinheiro do exterior. **`SUM(valor_transacao)` em `AuditFin` é, na verdade, o resultado líquido das movimentações externas** (depósitos − saques). Se o resultado for positivo, o banco recebeu mais do que pagou; se negativo, o oposto.

---

### Parte 4

88. Exemplos de padrões reusados:

| Padrão | Veio do Bloco | Como apareceu no Bloco 8 |
|--------|---------------|--------------------------|
| Trio `DECLARE erro_sql / DECLARE CONTINUE HANDLER / START TRANSACTION` | Bloco 4 | Início de cada SP |
| Captura `@conta = (SELECT NroConta WHERE NroConta = v_param)` | Bloco 6 | Validação de existência da conta |
| Validação combinada `@conta IS NOT NULL AND v_valor > 0` | Bloco 6 | IF nível 1 das duas SPs |
| Padrão Trigger `AFTER UPDATE` calculando `NEW − OLD` | Bloco 7 | Aproveitada automaticamente — não precisei modificar a Trigger |

89. Resposta livre. Espera-se reconhecimento de que a **comparação v1 × v2 (Bloco 5 + 6)** foi crucial — sem ela, o aluno tenderia a copiar a estrutura "errada" da v1.

90. **Para `sp_saque`**, porque `sp_transf_bancaria02` tem 2 níveis de IF (params + saldo) — exatamente como `sp_saque`. Para `sp_deposito`, foi mais útil **simplificar** removendo o IF de saldo. Ambas as referências valem; a v2 foi a base mais próxima.

91. Resposta esperada:
* **3 linhas em `AuditFin`** por chamada bem-sucedida (3 `UPDATE`s).
* **`SUM(valor_transacao)` ≠ zero** se a taxa cambial não for trivialmente derivada — porque o "valor convertido" tipicamente difere de `v_valor` (multiplicado pela taxa). Ou seja: o que sai da origem ≠ o que entra no destino. Não há mais simetria perfeita.
* **Validações reutilizadas:** existência de origem e destino, `v_valor > 0`. **Novas validações:** `v_taxa > 0`, e provavelmente verificar a existência da "conta-banco" (1,1,1).

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Construir, do zero, SPs unitárias com validação robusta.  
✅ Reconhecer que **a Trigger é independente da SP** — qualquer `UPDATE` em `Conta` é auditado.  
✅ Diferenciar **operações simétricas** (transferência, soma zero) de **operações assimétricas** (saque/depósito, soma não-zero).  
✅ Antecipar como adaptar o que aprendeu para cenários mais complexos.  

> 💡 *"Programar é resolver problemas. Programar bem é **antecipar** quais problemas surgirão depois."*

---

## 🎓 Encerramento da Aula ARQ13

Parabéns! Ao chegar até aqui, você aplicou:

* **Modelagem** (Bloco 1) → leu um diagrama ER complexo com 3 entidades.
* **DDL avançada** (Blocos 2-3) → criou tabelas com PK composta, FKs, índices nomeados.
* **Stored Procedures evolutivas** (Blocos 4-6) → construiu, criticou e refez uma SP transacional.
* **Triggers calculadas** (Bloco 7) → registrou auditoria com semântica de débito/crédito.
* **Síntese autoral** (Bloco 8) → integrou tudo em um exercício sem cola.

Use bem o que aprendeu. Em produção, são esses cuidados que separam um banco de dados confiável de uma "fonte de problemas".

> 💭 *"Construir software é fácil. Construir software que **não falha em silêncio** é arte."*
