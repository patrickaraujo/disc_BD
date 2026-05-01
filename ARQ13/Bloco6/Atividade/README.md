# 🧠 Atividade 6 — Validação Robusta

> **Duração:** 30 minutos  
> **Formato:** Individual  
> **Objetivo:** Confirmar que a v2 corrige cada uma das falhas do Bloco 5 e reforçar a compreensão do padrão `@conta = (SELECT NroConta WHERE …)`.

---

## 📋 Parte 1 — Execução dos Testes

58. Após criar `sp_transf_bancaria02` e restaurar os saldos originais, execute os 6 testes do roteiro. Para cada um, preencha:

| Teste | Mensagem retornada | Soma total preservada? |
|-------|-------------------|----------------------|
| #1: (1111, 2222, 7000) | _____ | _____ |
| #2: (9999, 2222, 100) | _____ | _____ |
| #3: (1111, 9999, 100) | _____ | _____ |
| #4: (1111, 2222, -500) | _____ | _____ |
| #5: (1111, 2222, 0) | _____ | _____ |
| #6: (1111, NULL, 2000) | _____ | _____ |

59. Compare os testes #2, #3, #4, #5 e #6: todos retornam a **mesma mensagem**? Por quê? Isso é vantagem ou desvantagem?

---

## 📋 Parte 2 — Comparação v1 × v2 lado a lado

60. Execute a v1 e a v2 com a mesma chamada que era catastrófica no Bloco 5:

```sql
-- (Garanta que os saldos estejam restaurados)
SELECT SUM(saldo) FROM Conta;

CALL sp_transf_bancaria(1111, 9999, 100);   -- v1
SELECT SUM(saldo) FROM Conta;
SELECT saldo FROM Conta WHERE NroConta = 1111;

-- Restaure: faça ROLLBACK não dá (já comitou). Use UPDATE manual:
UPDATE Conta SET saldo = saldo + 100 WHERE NroConta = 1111;
COMMIT;

CALL sp_transf_bancaria02(1111, 9999, 100); -- v2
SELECT SUM(saldo) FROM Conta;
SELECT saldo FROM Conta WHERE NroConta = 1111;
```

* Após a chamada **v1**: saldo de 1111 = ___, soma total = ___
* Após a chamada **v2**: saldo de 1111 = ___, soma total = ___

A v2 preservou a soma total?

---

## 📋 Parte 3 — Comportamento de SELECT com NULL

61. Execute, no MySQL:

```sql
SELECT NroConta FROM Conta WHERE NroConta = NULL;
```

Quantas linhas retornam? Por quê?

62. Agora execute:

```sql
SELECT NroConta FROM Conta WHERE NroConta IS NULL;
```

Quantas linhas retornam? Há diferença entre as duas formas de comparação?

63. Em decorrência das questões 61 e 62, explique **por que** `SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = NULL)` resulta em `@conta_destino = NULL` e como isso ajuda a v2 a tratar parâmetros nulos sem precisar de validação separada.

---

## 📋 Parte 4 — Questões Conceituais

64. Por que a v2 captura `@conta_origem` e `@conta_destino` (com `SELECT NroConta`) em vez de só capturar `@saldo_origem` e `@saldo_destino`? Não bastaria checar `@saldo_origem IS NOT NULL`?

> 💡 **Pista:** considere uma conta que existe mas tem saldo `0` ou `NULL`.

65. A v2 não trata o caso "origem == destino". Imagine que um cliente faz `CALL sp_transf_bancaria02(1111, 1111, 100);`. Descreva, passo a passo, o que acontece. É um problema de integridade?

66. Em produção, depois de validar a v2, é comum apagar a v1 com `DROP PROCEDURE sp_transf_bancaria;`. **Antes** de fazer esse drop, que verificação operacional você faria para garantir que nada quebra?

67. Suponha que você quisesse adicionar uma **mensagem mais específica** para cada tipo de falha: "Conta origem inexistente", "Conta destino inexistente", "Valor inválido". Qual seria a estrutura `IF/ELSEIF/ELSE` necessária? Esboce em pseudocódigo.

---

## 📋 Parte 5 — Análise de Trade-offs

68. Para cada decisão de design da v2, indique se concorda e justifique:

| Decisão | Concorda? | Justificativa |
|---------|-----------|---------------|
| Usar **mesma mensagem** para todos os erros de validação | _____ | _____ |
| **Coexistir** v1 e v2 (em vez de substituir) | _____ | _____ |
| **Não testar** origem == destino | _____ | _____ |
| Manter o `CONTINUE HANDLER` mesmo com validações robustas | _____ | _____ |

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

58. Tabela:

| Teste | Mensagem | Soma preservada? |
|-------|----------|-----------------|
| #1: (1111, 2222, 7000) | `'Contas alteradas com sucesso:'` (3 colunas) | Sim — só transferência interna |
| #2: (9999, 2222, 100) | `'Parâmetros inadequados…'` | Sim |
| #3: (1111, 9999, 100) | `'Parâmetros inadequados…'` | Sim ✅ (corrige bug crítico da v1) |
| #4: (1111, 2222, -500) | `'Parâmetros inadequados…'` | Sim |
| #5: (1111, 2222, 0) | `'Parâmetros inadequados…'` | Sim |
| #6: (1111, NULL, 2000) | `'Parâmetros inadequados…'` | Sim |

59. **Mesma mensagem.** Vantagem: simplicidade de código (uma só validação combinada). Desvantagem: o usuário não sabe **qual** dos parâmetros está errado — precisa adivinhar. Em sistemas críticos, valeria desmembrar em mensagens específicas (ver questão 67).

---

### Parte 2

60. Comparação:
* **v1**: saldo 1111 = 4900 (perdeu 100), soma total = (anterior − 100) — DINHEIRO SOMIU.
* **v2**: saldo 1111 = inalterado, soma total = inalterada — DINHEIRO PRESERVADO.

A v2 preservou a soma total. **Conservação do dinheiro garantida.**

---

### Parte 3

61. **0 linhas.** `WHERE NroConta = NULL` é sempre `UNKNOWN` — em `WHERE`, isso é tratado como `FALSE`, então nenhuma linha casa.

62. **0 linhas** (porque a coluna `NroConta` é `NOT NULL`, nenhuma linha tem `NULL` lá). Em uma coluna que aceitasse `NULL`, `IS NULL` retornaria as linhas com `NULL`.

63. Quando `v_destino` chega com `NULL`, o `SELECT NroConta FROM Conta WHERE NroConta = NULL` retorna 0 linhas → atribuição em variável de sessão recebe `NULL` (em vez de erro). A validação `@conta_destino IS NOT NULL` então captura **simultaneamente**: (a) parâmetro era NULL, (b) parâmetro era um valor que não existe na tabela. **Uma única condição cobre dois problemas.** Elegante e sem código duplicado.

---

### Parte 4

64. Porque o saldo pode ser **zero legítimo** (uma conta recém-criada, por exemplo), e poderia também ser `NULL` se a coluna permitisse (não é o caso aqui, mas é boa prática defensiva). **`SELECT NroConta WHERE NroConta = v_origem`** é o teste **inequívoco de existência** — só retorna não-NULL se a linha realmente existe.

65. Passo a passo:
* `@conta_origem = 1111` (existe).
* `@conta_destino = 1111` (existe).
* `v_valor = 100 > 0` ✅.
* IF nível 1 passa → IF nível 2 (saldo): `@saldo_origem = saldo de 1111`. Se for ≥ 100, passa.
* `START TRANSACTION` → `UPDATE` debita 100 de 1111 → `UPDATE` credita 100 em 1111 (mesma linha) → saldo final inalterado.
* `COMMIT`. Mensagem de sucesso.

**Não é problema de integridade** (saldo correto). Mas é **inútil** — gasta recurso do banco e gera registro de auditoria sem motivo. Em uma SP idealmente robusta, deveria ser bloqueada com mensagem específica.

66. Verificações: **(1)** procurar referências em código de aplicação (procurar por "sp_transf_bancaria" no codebase). **(2)** examinar logs do banco para identificar se há `CALL sp_transf_bancaria` recente (de jobs agendados, scripts manuais, etc.). **(3)** verificar permissões `EXECUTE` concedidas para a v1 — esses usuários precisam ser realocados para a v2. **(4)** comunicar a equipe e fazer "deprecation period" (algumas semanas mostrando aviso antes de apagar).

67. Pseudocódigo:

```text
IF @conta_origem IS NULL THEN
   SELECT 'Conta origem inexistente' AS RESULTADO;
ELSEIF @conta_destino IS NULL THEN
   SELECT 'Conta destino inexistente' AS RESULTADO;
ELSEIF v_valor IS NULL OR v_valor <= 0 THEN
   SELECT 'Valor inválido' AS RESULTADO;
ELSE
   -- prossegue com a transação
   IF @saldo_origem >= v_valor THEN
       ...
   ELSE
       SELECT 'Saldo insuficiente' AS RESULTADO;
   END IF;
END IF;
```

---

### Parte 5

68. Análise de trade-offs:

| Decisão | Concorda? | Justificativa |
|---------|-----------|---------------|
| Mesma mensagem para todos | Discutível | **Pró:** código simples. **Contra:** usuário não sabe o que corrigir. Em sistemas reais, mensagens específicas são preferíveis. |
| Coexistir v1 e v2 | Concorda | Permite migração gradual e comparação direta. Importante em produção. |
| Não testar origem == destino | Discutível | Não causa erro de integridade, mas é **operação inútil**. Boa prática seria bloquear. |
| Manter `CONTINUE HANDLER` | Concorda | Defesa em profundidade — mesmo com validações, erros inesperados (falha de I/O, deadlock) podem ocorrer durante a transação. O handler permanece relevante. |

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Escrever validações que cobrem múltiplos cenários com **uma única condição** elegante.  
✅ Aproveitar o comportamento do SQL com `NULL` (`WHERE col = NULL` retorna 0 linhas) **a seu favor**.  
✅ Reconhecer **trade-offs** entre simplicidade e clareza de mensagens de erro.  
✅ Justificar a coexistência v1/v2 em ambientes de produção.  

> 💡 *"Validar antes de executar é programação defensiva. Detectar erro depois de executar é programação ofensiva. Profissionais escolhem a primeira sempre que possível."*
