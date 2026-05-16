# 🧠 Atividade 2 — Locks de Leitura Entre Sessões

> **Duração:** 40 minutos
> **Formato:** Individual (exige 2 sessões no Workbench)
> **Objetivo:** Reproduzir o cenário do `LOCK TABLE READ`, documentar o comportamento observado e fixar os conceitos de lock compartilhado e diagnóstico via `SHOW PROCESSLIST`.

---

## 📋 Parte 1 — Setup do cenário

18. Abra **duas abas de query** no MySQL Workbench (`Ctrl+T`).

19. Em **cada aba**, execute `SELECT CONNECTION_ID();` e anote:

| Sessão | `CONNECTION_ID()` |
|--------|-------------------|
| S1 | _____ |
| S2 | _____ |

20. Se os dois retornos forem **iguais**, o que está errado e o que você deve fazer?

21. Em S1, crie o database e a tabela `messages` (caso não existam ainda). Execute:

```sql
-- [S1]
CREATE DATABASE IF NOT EXISTS BLOQUEIOS;
USE BLOQUEIOS;
-- (cole o CREATE TABLE messages do gabarito aqui)
TRUNCATE TABLE messages;
```

22. Em S2, execute `USE BLOQUEIOS;` e `SELECT * FROM messages;`. O retorno deve ser **vazio**. Por que o `TRUNCATE` da S1 já é visível na S2 sem `COMMIT`?

---

## 📋 Parte 2 — Inserção sem lock

23. Em S1:

```sql
-- [S1]
INSERT INTO messages(message) VALUES('Ola da S1');
SELECT * FROM messages;
```

Quantas linhas você vê em S1? _____

24. **Sem commitar ainda em S1**, vá para S2 e execute:

```sql
-- [S2]
SELECT * FROM messages;
```

Quantas linhas você vê em S2? _____

25. Por que S2 não vê a inserção da S1? (Pense em isolamento transacional do InnoDB.)

26. Em S1, faça `COMMIT;`. Agora reexecute o `SELECT` em S2. Quantas linhas? _____

---

## 📋 Parte 3 — Aplicando o READ lock

27. Em S1:

```sql
-- [S1]
LOCK TABLE messages READ;
```

28. **Ainda em S1**, tente inserir:

```sql
-- [S1]
INSERT INTO messages(message) VALUES('Vai dar erro?');
```

Qual foi a mensagem retornada (literal)? _____

29. **Em uma frase**, explique POR QUE a S1 não pode escrever, mesmo sendo a detentora do lock.

30. **Ainda em S1**, execute:

```sql
-- [S1]
SELECT * FROM messages;
```

A leitura funcionou? _____

31. Vá para S2 e execute:

```sql
-- [S2]
SELECT * FROM messages;
```

A leitura funcionou? Por quê?

32. **Ainda em S2**, tente:

```sql
-- [S2]
INSERT INTO messages(message) VALUES('S2 quer escrever');
```

O que aconteceu visualmente no Workbench? (Marque a opção certa)
* (   ) Retornou erro imediato como na questão 28
* (   ) Inseriu normalmente e retornou sucesso
* (   ) **Travou** — o cursor fica girando, o resultado não volta

---

## 📋 Parte 4 — Diagnóstico via `SHOW PROCESSLIST`

33. **Sem destravar a S2**, vá para S1 (que está livre) e execute:

```sql
-- [S1]
SHOW PROCESSLIST;
```

Localize a linha cuja coluna `Id` corresponde à S2 (você anotou na questão 19). Preencha:

| Coluna | Valor observado |
|--------|----------------|
| `State` | _____ |
| `Time` (segundos esperando) | _____ |
| `Info` (comando preso) | _____ |

34. Em **uma frase**, descreva o que o estado `"Waiting for table lock"` significa para o usuário do banco.

---

## 📋 Parte 5 — Liberação

35. Em S1, libere o lock:

```sql
-- [S1]
UNLOCK TABLES;
```

36. O que aconteceu na S2 **imediatamente** após o `UNLOCK` da S1?

37. Em S2, execute `COMMIT;` e depois `SELECT * FROM messages;`. Quantas linhas há agora? _____

38. **Reflexão final:** se uma terceira sessão (S3) também estivesse tentando escrever, o que aconteceria no `UNLOCK` da S1? Qual seria a ordem de liberação?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

18. *(passo de execução, sem resposta)*

19. Os IDs **devem ser diferentes**. Valores típicos em uma instância recém-iniciada: `S1 = 42`, `S2 = 43` (ou próximos).

20. Se os IDs forem iguais, você executou os dois `SELECT`s **na mesma aba**. Solução: abra uma nova aba com `Ctrl+T` (ou nova conexão via `Database → Connect to Database`) e re-execute.

21. *(passo de execução)*

22. Porque **DDL** (`CREATE`, `DROP`, `TRUNCATE`) faz **commit implícito** no MySQL — não respeita o `autocommit = 0` que aplicamos. O `TRUNCATE` é efetivado imediatamente e fica visível em todas as sessões.

---

### Parte 2

23. **1 linha** (`'Ola da S1'`).

24. **0 linhas** (S2 não vê a inserção não commitada da S1).

25. O InnoDB, em nível de isolamento `REPEATABLE READ` (padrão), oferece a S2 um **snapshot consistente** baseado no momento em que ela iniciou sua transação. A escrita não commitada da S1 não faz parte desse snapshot.

26. **1 linha** — após o `COMMIT` da S1, o registro é visível para todas as sessões (na próxima leitura da S2, se ela ainda estiver em uma transação aberta, pode precisar de novo `COMMIT` ou `BEGIN` para ver — depende do nível de isolamento).

---

### Parte 3

27. *(passo de execução)*

28. `ERROR 1099 (HY000): Table 'messages' was locked with a READ lock and can't be updated`

29. O `READ` lock garante que a tabela **não mude durante a vigência do lock**. Se o detentor pudesse escrever, essa garantia seria violada — a regra vale para **todos**, inclusive o detentor.

30. **Sim** — a leitura funciona normalmente. O `READ` lock libera leituras.

31. **Sim, funcionou.** Porque o `READ` lock é **compartilhado entre leitores** — múltiplas sessões podem ler simultaneamente.

32. ✅ **Travou** — o cursor fica girando. A S2 entrou em fila de espera pelo `UNLOCK` da S1.

---

### Parte 4

33. Linha esperada para S2:
    * `State`: `Waiting for table lock` (ou `Waiting for table metadata lock` em versões mais recentes)
    * `Time`: cresce a cada segundo (quanto mais você esperar, maior será)
    * `Info`: `INSERT INTO messages(message) VALUES('S2 quer escrever')`

34. Significa que aquela sessão está **dormindo, sem consumir CPU**, esperando que outro detentor libere o lock que ela precisa para continuar.

---

### Parte 5

35. *(passo de execução)*

36. **Imediatamente** o `INSERT` da S2 destrava e processa — a S2 retorna sucesso.

37. **2 linhas**: `'Ola da S1'` (commit da Parte 2) e `'S2 quer escrever'` (commit implícito após `UNLOCK` + `COMMIT` explícito da S2).

38. Se houvesse uma S3 também esperando, ela continuaria em fila após o `UNLOCK` da S1: a S2 (que entrou primeiro na fila) é atendida, faz seu trabalho, e quando libera (via `COMMIT` ou outro `UNLOCK`), a S3 entra. A ordem é tipicamente **FIFO** (first-in, first-out), embora o MySQL não garanta estritamente — pode haver priorização interna.

---

## 💭 Reflexão Final

Após esta atividade, você deve ser capaz de:

✅ Explicar por que o **detentor** do `READ` lock também não pode escrever.
✅ Diagnosticar uma sessão travada usando **`SHOW PROCESSLIST`** e identificar o `State`, o `Time` e o `Info`.
✅ Trabalhar confortavelmente com **2 sessões simultâneas** no Workbench.
✅ Distinguir **escrita commitada** de **escrita não commitada** do ponto de vista de outra sessão.

> 💡 *"O lock não é uma sugestão — é um contrato. Quem detém também obedece, senão o contrato não vale."*
