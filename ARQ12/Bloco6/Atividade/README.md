# 🧠 Atividade 6 — Integração SP + Trigger

> **Duração:** 30 minutos  
> **Formato:** Individual  
> **Objetivo:** Confirmar a cooperação entre `sp_altera_livros` e `Audita_Livros`, e refletir sobre o padrão "SP transacional + Trigger de auditoria".

---

## 📋 Parte 1 — Execução

51. Após executar as 3 chamadas obrigatórias do roteiro, execute:

```sql
SELECT * FROM LIVROS;
```

Quais ISBNs aparecem? Qual é o `Precolivro` de cada um? Identifique quais foram alterados e quais permaneceram com o preço original do Bloco 3.

52. Execute:

```sql
SELECT * FROM tab_audit;
```

Quantas linhas aparecem? Para cada linha, identifique:
* `codigo_Produto` (o ISBN auditado).
* `preco_unitario_antigo` (preço antes da alteração).
* `preco_unitario_novo` (preço depois da alteração).

53. Faça uma **quarta chamada** com o mesmo ISBN da chamada #1, mas com um preço diferente:

```sql
CALL sp_altera_livros(9786525223742, 50.00);
```

Em seguida, execute novamente o `SELECT * FROM tab_audit;`. Quantas linhas há agora? Qual `preco_unitario_antigo` aparece na nova linha? Por quê?

---

## 📋 Parte 2 — Questões Conceituais

54. A Trigger `Audita_Livros` é disparada **dentro** ou **fora** da transação aberta pela SP? Justifique pensando na ordem dos eventos.

55. Por que a chamada #3 (`Precolivro = NULL`) **não** deixou rastro em `tab_audit`? Existem duas razões — uma referente à Trigger, outra referente à SP. Cite ambas.

56. Imagine que, em vez de `AFTER UPDATE`, a Trigger fosse `BEFORE UPDATE`. O comportamento da chamada #3 (com `NULL`) mudaria? E a chamada #1?

57. Por que a mensagem de sucesso da `sp_altera_livros` retorna **3 colunas** em vez de apenas uma string? Compare com a mensagem da `sp_insere_livros` (Bloco 3).

58. Suponha que, hipoteticamente, em vez de uma SP, o usuário fizesse o `UPDATE` direto:
```sql
UPDATE LIVROS SET Precolivro = 99.99 WHERE ISBN = 9786525223742;
```
A Trigger dispararia? Por quê?

59. Suponha que a Trigger `Audita_Livros` falhe (por exemplo, alguém apagou a tabela `tab_audit` antes). Quando a SP `sp_altera_livros` for chamada, o que acontece com o `UPDATE` em `LIVROS`?

> 💡 **Dica:** pense no que o `CONTINUE HANDLER FOR SQLEXCEPTION` faz quando a Trigger lança um erro durante o `UPDATE`.

---

## 📋 Parte 3 — Comparação entre SPs

60. Construa uma tabela comparativa entre `sp_insere_livros` (Bloco 3) e `sp_altera_livros` (Bloco 6):

| Aspecto | `sp_insere_livros` | `sp_altera_livros` |
|---------|-------------------|-------------------|
| Operação principal (DML) | _____ | _____ |
| Quantidade de parâmetros | _____ | _____ |
| Há Trigger associada? | _____ | _____ |
| Mensagem de sucesso retorna | _____ | _____ |
| Tabelas afetadas (direta + indireta) | _____ | _____ |

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

51. Os 4 ISBNs aparecem. Após as 3 chamadas:
* `9786525223742` → `Precolivro = 44.44` (alterado pela #1).
* `8888888888888` → `Precolivro = 10.99` (alterado pela #2).
* `9999999999999` → `Precolivro = 34.50` (inalterado).
* `7777777777777` → `Precolivro = 29.90` (inalterado — chamada #3 falhou).

52. **2 linhas:**
| Linha | `codigo_Produto` | `preco_unitario_antigo` | `preco_unitario_novo` |
|-------|------------------|-------------------------|----------------------|
| 1 | `9786525223742` | `74.9000` | `44.4400` |
| 2 | `8888888888888` | `55.9000` | `10.9900` |

53. **3 linhas** em `tab_audit`. A nova linha tem:
* `codigo_Produto = 9786525223742`.
* `preco_unitario_antigo = 44.4400` (o preço **anterior** — que foi definido pela chamada #1).
* `preco_unitario_novo = 50.0000`.

A Trigger captura o **estado antes** desta nova alteração — não o estado original. Ou seja: cada linha de auditoria reflete **o passo daquela alteração**, não a história completa.

---

### Parte 2

54. **Dentro.** A Trigger é disparada pelo `UPDATE`, que está **dentro** do `START TRANSACTION` da SP. Ou seja: o `INSERT INTO tab_audit` da Trigger faz parte da mesma transação. Se houver `ROLLBACK`, o `INSERT` da Trigger também é desfeito — atomicidade preservada.

55. **Razão da Trigger:** ela é `AFTER UPDATE`. Se o `UPDATE` falha (porque `NULL` viola `NOT NULL`), nenhuma linha foi modificada → a Trigger não é executada para nenhuma linha. **Razão da SP:** mesmo se a Trigger tivesse executado e gravado em `tab_audit`, o `IF erro_sql = TRUE THEN ROLLBACK` desfaria essa gravação. Os dois mecanismos cooperam para garantir que **falha não deixa rastro**.

56. **A Trigger `BEFORE UPDATE` dispararia ANTES da modificação acontecer**. Para a chamada #1 (válida), o comportamento seria similar (a auditoria seria registrada antes do `UPDATE` ser confirmado). Para a chamada #3 (`NULL`), a Trigger executaria, **mas o `UPDATE` falharia depois** — ainda assim o `ROLLBACK` da SP descartaria a gravação na auditoria. **Conclusão:** o resultado final visível seria o mesmo, mas com `BEFORE` a Trigger executaria sem precisar — desperdício.

57. Porque um `UPDATE` é uma operação **destrutiva** (sobrescreve um valor anterior). Retornar o **ISBN + novo preço** dá ao usuário evidência imediata e confiável de que **o valor certo foi atualizado**. Já um `INSERT` é uma operação **construtiva** — uma simples mensagem de sucesso é suficiente.

58. **Sim, dispararia.** A Trigger está vinculada **à tabela**, não à SP. Qualquer `UPDATE` em `LIVROS` — seja por SP, por usuário direto, ou por uma aplicação cliente — dispara `Audita_Livros`. Esse é justamente o ponto da Trigger: rastrear **toda alteração**, independentemente de quem a fez.

59. O `INSERT INTO tab_audit` dentro da Trigger **falharia** (porque a tabela `tab_audit` não existe). Esse erro é capturado pelo `CONTINUE HANDLER FOR SQLEXCEPTION` da SP — a flag `erro_sql` é virada para `TRUE` — e a SP segue para o `ROLLBACK`. **Resultado:** o `UPDATE` em `LIVROS` é desfeito. **Conclusão importante:** se a auditoria não pode ser registrada, a alteração não acontece. Esse é o comportamento desejado em um sistema crítico.

---

### Parte 3

60. Tabela comparativa:

| Aspecto | `sp_insere_livros` | `sp_altera_livros` |
|---------|-------------------|-------------------|
| Operação principal (DML) | `INSERT` | `UPDATE` |
| Quantidade de parâmetros | 4 | 2 |
| Há Trigger associada? | Não | Sim (`Audita_Livros`) |
| Mensagem de sucesso retorna | 1 coluna (`RESULTADO`) | 3 colunas (`RESULTADO`, `ISBN`, `PREÇO NOVO`) |
| Tabelas afetadas | só `LIVROS` | `LIVROS` (direta) + `tab_audit` (indireta, via Trigger) |

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Explicar que **Trigger e SP cooperam** dentro de uma única transação.  
✅ Justificar por que **falha de qualquer parte** desfaz **tudo** (atomicidade preservada).  
✅ Reconhecer que `BEFORE` × `AFTER` muda **quando** a Trigger executa, não **se** ela executa.  
✅ Compreender por que a operação `UPDATE` merece mensagens mais informativas que `INSERT`.  

> 💡 *"Um sistema confiável é aquele em que **falha** e **memória** caminham juntas — falha não deixa memória; memória existe somente quando algo realmente aconteceu."*
