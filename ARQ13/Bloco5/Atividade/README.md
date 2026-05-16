# 🧠 Atividade 5 — Diagnosticando bugs

> **Duração:** 35 minutos  
> **Formato:** Individual  
> **Objetivo:** Reproduzir os 3 cenários de falha da v1, fixar os conceitos de lógica de três valores em SQL e antecipar os requisitos da v2.

---

## 📋 Parte 1 — Cenário 1 (origem inexistente)

43. Antes do teste, registre a soma total dos saldos:

```sql
SELECT SUM(saldo) AS soma_total FROM Conta;
```

Anote o valor: ___________

44. Execute:

```sql
CALL sp_transf_bancaria(9999, 2222, 100);
```

Qual mensagem foi retornada? Ela é **honesta** com o usuário (descreve o problema real)?

45. Após o teste, execute novamente `SELECT SUM(saldo) FROM Conta;`. A soma mudou? Por quê?

---

## 📋 Parte 2 — Cenário 2 (destino inexistente — DINHEIRO SOME)

46. Registre o saldo da conta `1111`:

```sql
SELECT saldo FROM Conta WHERE NroConta = 1111;
```

Anote: ___________

47. Execute:

```sql
CALL sp_transf_bancaria(1111, 9999, 100);
```

Qual mensagem foi retornada? **A SP afirma sucesso**?

48. Releia o saldo da conta 1111. Mudou? **Para onde foi os R$100**?

49. Execute `SELECT SUM(saldo) FROM Conta;`. Compare com o valor da questão 43. **A soma diminuiu**? Quanto?

50. Em **uma frase**, descreva por que esse bug é chamado de "dinheiro que some" e por que ele é **catastrófico** em sistema bancário real.

---

## 📋 Parte 3 — Cenário 3 (valor inválido)

51. Execute, em sequência:

```sql
CALL sp_transf_bancaria(1111, 2222, 0);     -- valor zero
CALL sp_transf_bancaria(1111, 2222, -500);  -- valor negativo
CALL sp_transf_bancaria(1111, 1111, 100);   -- origem == destino
```

Para cada uma, complete:

| Chamada | Mensagem retornada | Saldos mudaram? |
|---------|-------------------|----------------|
| Valor zero | _____ | _____ |
| Valor negativo | _____ | _____ |
| Origem == destino | _____ | _____ |

52. **Especificamente para a chamada com valor `-500`:** olhe os saldos de `1111` e `2222` antes e depois. Qual deles **ganhou** dinheiro? Qual **perdeu**? Por quê?

---

## 📋 Parte 4 — Lógica de Três Valores

53. Teste, no MySQL, as seguintes expressões. Para cada uma, indique o retorno (`1` para TRUE, `0` para FALSE, `NULL` para UNKNOWN):

```sql
SELECT 5 >= 100;
SELECT NULL >= 100;
SELECT NULL = NULL;
SELECT NULL IS NULL;
SELECT (NULL >= 100) IS NULL;
```

54. Por que `NULL = NULL` retorna `NULL` em vez de `TRUE`? Justifique pensando em o que `NULL` representa **conceitualmente** (valor desconhecido).

55. Em SQL, qual operador deve-se usar para verificar se um valor é `NULL`? Por que `WHERE coluna = NULL` não funciona como esperado?

---

## 📋 Parte 5 — Antecipação da v2

56. Para cada falha identificada, descreva em uma frase **o que a v2 precisará fazer** para corrigi-la:

| Falha | Correção que a v2 precisa implementar |
|-------|---------------------------------------|
| Origem inexistente diagnosticada como "saldo insuficiente" | _____ |
| Destino inexistente, dinheiro some | _____ |
| Valor zero ou negativo aceito | _____ |

57. A correção das três falhas pode ser feita com **uma única validação extra** no `IF` nível 1. Como deve ser essa validação, em pseudocódigo? (Pista: ela vai usar variáveis novas `@conta_origem` e `@conta_destino`, e também testar `v_valor`.)

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

43. Soma total típica (após Bloco 4): **20000** (5000 + 5000 + 8400 + 2600).

44. Mensagem retornada: `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'`. **Não é honesta** — o problema real é "conta 9999 não existe", não saldo. O usuário fica confuso.

45. **Não mudou.** Os 4 saldos permanecem iguais. Por quê? Porque a SP caiu no `ELSE` da validação de saldo **antes** de qualquer `UPDATE`. Nada foi modificado.

---

### Parte 2

46. Saldo de 1111 antes: **5000** (após Bloco 4).

47. Mensagem retornada: `'Contas alteradas com sucesso:'` + `NOVO SALDO ORIGEM: 4900` + `NOVO SALDO DESTINO: NULL`. **A SP afirma sucesso, mesmo com 9999 não existindo.**

48. Saldo de 1111 depois: **4900**. Os R$100 saíram da conta 1111. **Não foram para lugar algum** — o `UPDATE` da conta 9999 afetou 0 linhas.

49. Soma total **diminuiu em R$100**. De 20000 → 19900. **Dinheiro sumiu.**

50. "Dinheiro que some" porque a soma total dos saldos do banco é menor do que era antes. Em sistema bancário real, isso quebra a contabilidade — o banco "deveria ter" R$ X em depósitos, mas tem R$ X − 100. É falha de **conservação do dinheiro**, princípio sagrado em finanças.

---

### Parte 3

51. Tabela:

| Chamada | Mensagem | Saldos mudaram? |
|---------|----------|----------------|
| Valor zero | `'Contas alteradas com sucesso:'` (saldos iguais) | Não |
| Valor negativo | `'Contas alteradas com sucesso:'` | **SIM, invertido!** |
| Origem == destino | `'Contas alteradas com sucesso:'` | Não (debita e credita a mesma conta) |

52. Com valor `-500`:
* `1111` (origem): saldo era 5000 (ou similar) → após executar, `saldo = saldo - (-500) = saldo + 500` → **aumentou 500**.
* `2222` (destino): saldo era 5000 (ou similar) → após executar, `saldo = saldo + (-500) = saldo - 500` → **diminuiu 500**.

A "transferência" inverteu o fluxo. **O usuário recebeu, em vez de pagar.**

---

### Parte 4

53. Retornos esperados:

| Expressão | Retorno |
|-----------|---------|
| `5 >= 100` | `0` (FALSE) |
| `NULL >= 100` | `NULL` (UNKNOWN) |
| `NULL = NULL` | `NULL` (UNKNOWN) |
| `NULL IS NULL` | `1` (TRUE) |
| `(NULL >= 100) IS NULL` | `1` (TRUE) — confirma que a expressão anterior é UNKNOWN |

54. `NULL` significa **"valor desconhecido"** — não é um valor concreto, é "ausência de informação". Comparar dois valores desconhecidos resulta em "não sabemos se são iguais" — daí o `UNKNOWN`. **Conceitualmente:** se você sabe que João tem alguma idade desconhecida e Maria também tem alguma idade desconhecida, você não pode afirmar "João e Maria têm a mesma idade".

55. Use **`IS NULL`** (e `IS NOT NULL`). `WHERE coluna = NULL` retorna sempre `UNKNOWN`, e em `WHERE`, `UNKNOWN` é tratado como `FALSE` — então **nenhuma linha** é retornada, mesmo as que de fato têm `NULL` na coluna.

---

### Parte 5

56. Tabela de correções:

| Falha | Correção |
|-------|----------|
| Origem inexistente | Capturar `@conta_origem = (SELECT NroConta FROM Conta WHERE NroConta = v_origem)` e validar `IS NOT NULL` antes da transação. |
| Destino inexistente | Capturar `@conta_destino` analogamente e validar `IS NOT NULL`. |
| Valor zero ou negativo | Adicionar `AND v_valor > 0` ao IF de validação. |

57. Pseudocódigo:

```text
SET @conta_origem  = (SELECT NroConta FROM Conta WHERE NroConta = v_origem);
SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = v_destino);

IF @conta_origem IS NOT NULL
   AND @conta_destino IS NOT NULL
   AND v_valor > 0
THEN
   -- prossegue com validação de saldo e transação
ELSE
   SELECT 'Parâmetros inadequados, transação cancelada!!!' AS RESULTADO;
END IF;
```

> 💡 **Note:** essa única validação **substitui** o `IF v_origem IS NOT NULL AND v_destino IS NOT NULL` da v1, e cobre todos os 3 problemas listados.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Identificar os **três modos de falha** da v1 e explicar o porquê de cada um.  
✅ Distinguir **`NULL`**, **`UNKNOWN`** e **`FALSE`** em SQL.  
✅ Reconhecer que `UPDATE` que afeta 0 linhas **não é erro**, e que isso é fonte de bugs sérios.  
✅ Antecipar **exatamente** as mudanças que a v2 deve trazer.  

> 💡 *"O programador iniciante escreve código que funciona. O programador maduro escreve código que **falha bem** — e que lhe diz **por que** falhou."*
