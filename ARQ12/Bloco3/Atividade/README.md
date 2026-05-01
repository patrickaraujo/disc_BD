# 🧠 Atividade 3 — Sua primeira SP transacional

> **Duração:** 30 minutos  
> **Formato:** Individual  
> **Objetivo:** Construir, executar e validar a `sp_insere_livros`, e refletir sobre o papel do handler de erro.

---

## 📋 Parte 1 — Execução

21. Após criar a SP `sp_insere_livros` e antes de chamá-la, execute:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'procs_armazenados' AND Name = 'sp_insere_livros';
```

Quais informações o MySQL retorna sobre a sua SP? Liste pelo menos 3.

22. Execute as 5 chamadas do roteiro principal e relate, para cada uma, **a mensagem retornada**:

| Chamada | ISBN passado | Resultado retornado |
|---------|-------------|---------------------|
| #1 | `9786525223742` | _________________________________ |
| #2 | `9999999999999` | _________________________________ |
| #3 | `8888888888888` | _________________________________ |
| #4 | `7777777777777` | _________________________________ |
| #5 | `6666666666666` (preço NULL) | _________________________________ |

23. Após as 5 chamadas, execute `SELECT * FROM LIVROS;`. Quantos registros aparecem? Quais ISBNs estão presentes?

---

## 📋 Parte 2 — Questões Conceituais

24. Por que o `DECLARE erro_sql boolean DEFAULT FALSE` precisa aparecer **antes** do `START TRANSACTION`? O que aconteceria se você invertesse essa ordem?

25. Qual é a diferença prática entre `CONTINUE HANDLER` e `EXIT HANDLER`? Em qual situação você usaria cada um?

26. Suponha que você troque `SQLEXCEPTION` por `NOT FOUND` no handler. Que tipo de condição passaria a ser capturada? Esse handler seria útil em uma SP que faz `INSERT`?

27. Imagine que, na chamada #5 (com `Precolivro = NULL`), a SP **não** tivesse o handler. O que aconteceria nesse caso? A transação ficaria aberta? Os outros 4 registros seriam afetados?

28. Por que a SP retorna a mensagem com `SELECT 'texto' AS RESULTADO;` em vez de algo como `PRINT` ou `RETURN`?

---

## 📋 Parte 3 — Experimentação

29. Tente chamar a SP com um ISBN **já existente** (por exemplo, `9786525223742` novamente). O que acontece? Por quê?

30. Modifique mentalmente a SP, removendo o `IF erro_sql = FALSE THEN ... ELSE ... END IF` e deixando apenas um `COMMIT` no final, sem condição. Qual seria o problema? Em uma chamada inválida (como a #5), o que aconteceria com os dados?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

21. Aparecem (entre outras): **`Db`** (nome do banco), **`Name`** (nome da SP), **`Type`** (`PROCEDURE`), **`Definer`** (usuário que criou), **`Created`**, **`Modified`** (datas de criação e modificação), **`Security_type`**, **`Comment`**, **`character_set_client`**.

22. Resultados esperados:

| Chamada | Resultado retornado |
|---------|---------------------|
| #1 | `Transação efetivada com sucesso!!!` |
| #2 | `Transação efetivada com sucesso!!!` |
| #3 | `Transação efetivada com sucesso!!!` |
| #4 | `Transação efetivada com sucesso!!!` |
| #5 | `ATENÇÃO: Erro na transação!!!` |

23. **4 registros**. ISBNs: `7777777777777`, `8888888888888`, `9786525223742`, `9999999999999`. O ISBN `6666666666666` da chamada #5 não está lá — foi descartado pelo `ROLLBACK` interno da SP.

---

### Parte 2

24. Porque, no MySQL, **todas as declarações `DECLARE` precisam aparecer no início do `BEGIN…END`**, antes de qualquer instrução executável. Se você puser o `DECLARE` depois do `START TRANSACTION`, o MySQL retornará erro de sintaxe na criação da SP.

25. **`CONTINUE`** marca a flag e **continua** a SP — é o que queremos aqui, para chegar até o `IF … END IF` e decidir manualmente entre `COMMIT` e `ROLLBACK`. **`EXIT`** abortaria a SP imediatamente, sem oportunidade de fazer `ROLLBACK` explícito (o MySQL faria um implícito ao final, mas não teríamos controle sobre a mensagem retornada).

26. **`NOT FOUND`** captura situações de cursor "vazio" — por exemplo, um `SELECT INTO` que não retornou nenhuma linha. **Não é útil** em uma SP de `INSERT`, pois o `INSERT` em si não dispara `NOT FOUND`. Para `INSERT`, `UPDATE` e `DELETE`, o handler relevante é `SQLEXCEPTION`.

27. **A SP iria até o final, executaria `COMMIT` cegamente**. O `INSERT` em si já teria falhado (com erro 1048 — coluna `Precolivro` não pode ser nula), mas como nada teria detectado a falha, o `COMMIT` confirmaria… **nada**. Não existem dados parciais a perder porque o `INSERT` falhou inteiro, mas o usuário receberia a mensagem de **sucesso** mesmo tendo havido erro — situação muito perigosa em produção.

28. Porque o MySQL **não tem `PRINT`** nem `RETURN` para SPs (apenas para Functions). A forma usual de "imprimir" mensagens em uma SP é executar um `SELECT` com a string como literal — esse `SELECT` aparece como resultado para quem chamou a SP.

---

### Parte 3

29. **Erro 1062 — Duplicate entry**. A chave primária `ISBN` impede que o mesmo valor apareça duas vezes. O handler captura, vira `erro_sql = TRUE`, a SP executa `ROLLBACK` e retorna `'ATENÇÃO: Erro na transação!!!'`. Comportamento correto.

30. Sem o `IF … END IF`, a SP **sempre** executaria `COMMIT`, mesmo após erro. Em uma chamada como a #5, o `INSERT` já teria falhado e o `COMMIT` simplesmente confirmaria uma transação vazia. **Mas o usuário receberia a mensagem de sucesso** — e nas próximas iterações, com bugs mais sutis, isso poderia mascarar perda de dados.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Construir uma SP transacional com handler de erro do zero.  
✅ Justificar a ordem dos comandos dentro do `BEGIN…END`.  
✅ Distinguir entre `CONTINUE` e `EXIT` em handlers.  
✅ Reconhecer por que **uma SP sem handler é uma SP perigosa**.  

> 💡 *"Em transação, silêncio não é ouro — é dívida técnica acumulando juros."*
