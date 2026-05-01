# 🧠 Atividade 4 — Sua primeira SP transacional não trivial

> **Duração:** 30 minutos  
> **Formato:** Individual  
> **Objetivo:** Validar a `sp_transf_bancaria`, documentar a estrutura `IF` aninhada e refletir sobre decisões de design.

---

## 📋 Parte 1 — Execução

31. Após criar a SP e executar as 4 chamadas obrigatórias do roteiro, preencha:

| Chamada | Mensagem retornada | Saldo origem após | Saldo destino após |
|---------|-------------------|------------------|-------------------|
| #1: (1111, 2222, 5000) | _____ | _____ | _____ |
| #2: (5555, 6666, 1600) | _____ | _____ | _____ |
| #3: (1111, 2222, 7000) | _____ | _____ | _____ |
| #4: (1111, NULL, 2000) | _____ | _____ | _____ |

32. Execute `SELECT * FROM Conta;`. Os 4 saldos finais correspondem ao seu preenchimento da questão 31?

---

## 📋 Parte 2 — Estrutura IF Aninhada

33. Construa um diagrama de fluxo (em texto) da SP, mostrando os 3 níveis de IF e os 4 caminhos possíveis:

```
sp_transf_bancaria(v_origem, v_destino, v_valor)
│
├─ IF v_origem is not null AND v_destino is not null
│   │
│   ├─ IF @saldo_origem >= v_valor
│   │   │
│   │   ├─ START TRANSACTION → 2 UPDATEs
│   │   │   │
│   │   │   ├─ IF erro_sql = FALSE → CAMINHO #1: ___________
│   │   │   └─ ELSE                  → CAMINHO #2: ___________
│   │   │
│   ├─ ELSE                          → CAMINHO #3: ___________
│   │
├─ ELSE                              → CAMINHO #4: ___________
```

Preencha cada caminho com a **mensagem** correspondente.

34. Para cada chamada do roteiro, indique **qual caminho do diagrama acima** ela percorreu:
* Chamada #1 → caminho ___
* Chamada #2 → caminho ___
* Chamada #3 → caminho ___
* Chamada #4 → caminho ___

---

## 📋 Parte 3 — Questões Conceituais

35. Por que a captura `SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem)` é feita **antes** do `START TRANSACTION`, e não dentro dele?

36. Linha por linha, descreva o que acontece em cada uma das 4 chamadas — **antes** do `START TRANSACTION`. Dica: foque em `@saldo_origem` e nas duas validações (`IF`s).

| Chamada | `@saldo_origem` recebe | IF nível 1 (params) | IF nível 2 (saldo) | Inicia TRANSAÇÃO? |
|---------|------------------------|--------------------|--------------------|--------------------|
| #1: (1111, 2222, 5000) | _____ | _____ | _____ | _____ |
| #2: (5555, 6666, 1600) | _____ | _____ | _____ | _____ |
| #3: (1111, 2222, 7000) | _____ | _____ | _____ | _____ |
| #4: (1111, NULL, 2000) | _____ | _____ | _____ | _____ |

37. A SP retorna mensagem de sucesso com **3 colunas** (RESULTADO, NOVO SALDO ORIGEM, NOVO SALDO DESTINO). Compare com a `sp_altera_livros` da ARQ12 (Bloco 6), que também retornava 3 colunas. Qual o ganho prático dessa "mensagem enriquecida"?

38. Suponha que, no **`UPDATE` que credita o destino**, ocorra um erro inesperado (por exemplo, falha de I/O do disco). O que acontece com o saldo da conta origem (que já foi debitada na linha anterior)?

39. Por que `@saldo_destino` é inicializada com `0` antes da transação, e depois reatribuída após o `COMMIT`?

40. Em qual situação a captura `@saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem)` resultaria em **`NULL`**? E o que acontece com a comparação `@saldo_origem >= v_valor` quando um dos lados é `NULL`?

---

## 📋 Parte 4 — Antecipação

41. Uma colega sua, examinando seu código, comenta: *"E se eu chamar `sp_transf_bancaria(9999, 2222, 100)`, sendo que a conta `9999` não existe? O que acontece?"*. Faça este teste e relate **exatamente** a mensagem retornada e o saldo final de cada conta.

42. Outra colega: *"E se eu chamar `sp_transf_bancaria(1111, 9999, 100)`, sendo que a conta de **destino** `9999` não existe?"* Faça este teste e relate o saldo da conta `1111` antes e depois.

> 💡 **Atenção:** as questões 41 e 42 antecipam o conteúdo do Bloco 5. Não corrija a SP agora — apenas observe os comportamentos para análise no próximo bloco.

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

31. Preenchimento esperado:

| Chamada | Mensagem | Saldo origem | Saldo destino |
|---------|----------|--------------|---------------|
| #1: (1111, 2222, 5000) | `Contas alteradas com sucesso:` | 5000 | 5000 |
| #2: (5555, 6666, 1600) | `Contas alteradas com sucesso:` | 8400 | 2600 |
| #3: (1111, 2222, 7000) | `Saldo Insuficiente, transação cancelada!!!` | (não retorna) | (não retorna) |
| #4: (1111, NULL, 2000) | `Parâmetros inadequados, transação cancelada!!!` | (não retorna) | (não retorna) |

32. Os 4 saldos em `Conta`:
* `1111` → 5000 (debitado pela #1).
* `2222` → 5000 (creditado pela #1).
* `5555` → 8400 (debitado pela #2).
* `6666` → 2600 (creditado pela #2).

---

### Parte 2

33. Caminhos:
* CAMINHO #1: `'Contas alteradas com sucesso:'` + 3 colunas.
* CAMINHO #2: `'ATENÇÃO: Erro na transação, Contas não alteradas!!!'`.
* CAMINHO #3: `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'`.
* CAMINHO #4: `'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'`.

34. * Chamada #1 → caminho **#1** (sucesso).
* Chamada #2 → caminho **#1** (sucesso).
* Chamada #3 → caminho **#3** (saldo insuficiente).
* Chamada #4 → caminho **#4** (parâmetro inválido).

---

### Parte 3

35. Para evitar abrir transação desnecessariamente. Se o saldo for capturado dentro de uma transação aberta, mas a validação `@saldo_origem >= v_valor` falhar, teríamos uma transação **aberta sem nada para fazer** — desperdício e fonte de bugs (ex.: esquecer de fechar com `ROLLBACK`).

36. Tabela:

| Chamada | `@saldo_origem` | IF nível 1 | IF nível 2 | Transação? |
|---------|-----------------|-----------|-----------|------------|
| #1 | 10000 | TRUE (ambos não-NULL) | TRUE (10000 >= 5000) | SIM |
| #2 | 10000 | TRUE | TRUE (10000 >= 1600) | SIM |
| #3 | 5000 (já debitado pela #1) | TRUE | FALSE (5000 < 7000) | NÃO |
| #4 | 5000 (já debitado pela #1) | FALSE (v_destino é NULL) | (não chega aqui) | NÃO |

37. Em uma SP de operação financeira, o usuário precisa de **prova imediata** do estado pós-operação. Mostrar os saldos novos elimina a necessidade de fazer `SELECT` separado, e ainda permite que o app móvel/web exiba imediatamente "Você tinha R$ X, agora tem R$ Y" — UX mais clara.

38. Como ambos os `UPDATE`s estão **dentro** do `START TRANSACTION` e o `CONTINUE HANDLER FOR SQLEXCEPTION` está ativo, qualquer erro é capturado, `erro_sql` vira `TRUE`, e o `IF` final dispara `ROLLBACK`. **O `UPDATE` da origem é desfeito** — atomicidade preservada.

39. Inicialização (`= 0`) garante que a variável **existe** desde o começo da SP, evitando referência a variável não inicializada caso algum caminho exótico chegue à mensagem de sucesso. A reatribuição **depois** do `COMMIT` é necessária porque os valores em `@saldo_origem` (capturado **antes** dos `UPDATE`s) e `@saldo_destino` (=0) **não refletem** mais o estado atual após os `UPDATE`s.

40. **Quando `v_origem` aponta para uma conta inexistente** — o `SELECT` retorna 0 linhas → variável recebe `NULL`. **Comparações com `NULL` em SQL retornam `UNKNOWN`** (não `TRUE` nem `FALSE`). Em um `IF`, `UNKNOWN` é tratado como **falso** — então a comparação `NULL >= v_valor` cai no `ELSE`, e a SP retorna `'Saldo Insuficiente'` — **mensagem enganosa**, já que o problema real é "conta não existe". Esse é o bug latente que o Bloco 5 explora.

---

### Parte 4

41. **Mensagem retornada:** `'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'` — **diagnóstico errado!** A conta 9999 não existe, mas a mensagem culpa o saldo. Saldo das contas: **inalterado** (nada foi modificado).

42. Mais grave: **a chamada retorna sucesso!** Saldo de `1111` antes: 5000. Saldo de `1111` depois: 4900. **A conta perdeu R$100 — e o destino não recebeu nada (nem é uma conta que existe).** Em `SELECT * FROM Conta;`, você verá apenas 4 linhas, mas com `1111` debitada. O R$100 simplesmente **sumiu**. Esse é um bug crítico que será corrigido no Bloco 6.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Construir SPs com `IF` aninhado de 3 níveis e múltiplos caminhos de retorno.  
✅ Justificar **onde** colocar cada validação (antes ou dentro da transação).  
✅ Reconhecer que **`NULL` em comparações SQL não é `FALSE`** — é `UNKNOWN`, e isso causa diagnósticos enganosos.  
✅ Identificar bugs silenciosos para correção no próximo bloco.  

> 💡 *"Saber que sua SP tem um bug é o começo da maturidade. O fim da maturidade é ter testes que **encontram** o bug antes do cliente."*
