# 📘 Bloco 2 — Transações Manuais: ROLLBACK e COMMIT

> **Duração estimada:** 30 minutos  
> **Objetivo:** Abrir transações manualmente e observar — antes e depois — o efeito de `ROLLBACK` (desfaz tudo) e de `COMMIT` (grava tudo).  
> **Modalidade:** Guiada — você experimenta, observa e tira conclusões.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- **Aberto duas transações manuais** sobre a tabela `LIVROS`.
- Observado, em uma delas, que o `ROLLBACK` **descarta** os `INSERT`s.
- Observado, na outra, que o `COMMIT` **persiste** os `INSERT`s.
- Limpado a tabela `LIVROS` com `TRUNCATE` para deixar o ambiente preparado para o Bloco 3.

---

## 💡 Antes de começar — um comando que você precisa conhecer

Para que o MySQL deixe de confirmar cada `INSERT/UPDATE/DELETE` automaticamente e **passe a esperar a sua decisão**, você abre uma transação com:

```sql
START TRANSACTION;
```

> 📌 **Por que mostrar este comando explicitamente?** Embora `START TRANSACTION` seja simples, ele é o **marco de abertura** de toda a aula. A partir daqui, **nenhum** `INSERT`, `UPDATE` ou `DELETE` é confirmado até você pedir explicitamente. Tudo fica em "área de espera" — pode ser confirmado (`COMMIT`) ou descartado (`ROLLBACK`).

**O que ele faz:**

* Abre uma nova transação na sua sessão atual.
* Marca o ponto de partida — qualquer alteração feita a partir daqui será **reversível** até o próximo `COMMIT` ou `ROLLBACK`.
* É equivalente a `BEGIN;` no MySQL, mas `START TRANSACTION` é o padrão recomendado (mais explícito e portável).

---

## 🧪 Experimento 1 — Transação com ROLLBACK

### Passo 1.1 — Abra uma transação

Use o comando `START TRANSACTION;` apresentado acima.

### Passo 1.2 — Insira 4 livros na tabela `LIVROS`

Execute um único `INSERT INTO LIVROS (...) VALUES (...);` com **quatro registros** de uma só vez (a sintaxe `VALUES (...), (...), (...), (...)` permite isso). Use os dados abaixo:

| ISBN | Autor | Nomelivro | Precolivro |
|------|-------|-----------|------------|
| `9786525223742` | Rubens Zampar Jr | As Expectativas e Dilemas dos Alunos do Ensino Médio acerca do Papel da Universidade | `74.90` |
| `9999999999999` | Maria José Almeida | Livro Exemplo 02 | `34.50` |
| `8888888888888` | Américo da Silva | Livro Exemplo 03 | `55.90` |
| `7777777777777` | Adalberto Felisbino Cruz | Livro Exemplo 02 | `29.90` |

### Passo 1.3 — Verifique que os 4 registros estão "presentes"

Execute um `SELECT * FROM LIVROS;`. Você deve ver as **4 linhas** que acabou de inserir.

> 🤔 **Mas atenção:** elas estão presentes apenas para **a sua sessão**. Outra sessão, conectada simultaneamente, ainda não veria nada. Por quê? Porque você ainda não confirmou nada — esses dados estão em "área de espera".

### Passo 1.4 — Desfaça tudo

Execute `ROLLBACK;`.

### Passo 1.5 — Confirme que sumiu

Execute novamente `SELECT * FROM LIVROS;`. O retorno esperado é **zero linhas** — os 4 livros desapareceram.

> 💡 **Lição do experimento 1:** o `ROLLBACK` é uma **borracha** — apaga todas as alterações desde o último `START TRANSACTION` (ou desde o último `COMMIT`).

---

## 🧪 Experimento 2 — Transação com COMMIT

### Passo 2.1 — Abra uma nova transação

Refaça o `START TRANSACTION;`. (Ele encerra qualquer transação implícita anterior e inicia uma nova.)

### Passo 2.2 — Repita o `INSERT` com os mesmos 4 livros

Use exatamente os mesmos 4 registros do Experimento 1.

### Passo 2.3 — Verifique que estão "presentes" para a sua sessão

`SELECT * FROM LIVROS;` → 4 linhas.

### Passo 2.4 — Confirme

Execute `COMMIT;`.

### Passo 2.5 — Confirme que **continuam** lá

`SELECT * FROM LIVROS;` → 4 linhas.

> 💡 **Lição do experimento 2:** o `COMMIT` é a **caneta** — escreve definitivamente no banco. **Após o `COMMIT`, não há `ROLLBACK` que volte atrás.**

---

## 🧪 Experimento 3 — Limpando a tabela com TRUNCATE

Para que o Bloco 3 comece com a tabela vazia, use `TRUNCATE TABLE LIVROS;` e em seguida confirme com `SELECT * FROM LIVROS;` que voltou a zero registros.

> 📌 **`TRUNCATE` vs `DELETE`:** o `TRUNCATE` é **muito mais rápido** porque não remove linha a linha — ele apaga a tabela inteira e a recria. Em compensação, **não pode ser desfeito por `ROLLBACK`** em algumas configurações (no MySQL/InnoDB, ele faz commit implícito). Trate-o como **definitivo**.

---

## 📊 Mapa Mental — Linha do Tempo de uma Transação

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  START TRANSACTION → INSERT/UPDATE/DELETE → ??? → ???         ║
║                                              ↓                ║
║                                           ROLLBACK             ║
║                                              (apaga)           ║
║                                              ou                ║
║                                           COMMIT               ║
║                                              (grava)           ║
╚═══════════════════════════════════════════════════════════════╝
```

A pergunta-chave durante uma transação é sempre: **"Posso confirmar tudo? Ou aconteceu algo que me obriga a desfazer tudo?"**

---

## ✏️ Atividade Prática

### 📝 Atividade 2 — Observando ROLLBACK e COMMIT na prática

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Repetir os experimentos 1 e 2 com seus próprios dados.
- Responder questões sobre estado pendente, sessões concorrentes e atomicidade.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco2.sql](./codigo-fonte/COMANDOS-BD-03-bloco2.sql)

---

## ✅ Resumo do Bloco 2

Neste bloco você executou:

- Duas transações manuais com `START TRANSACTION`.
- Um `ROLLBACK` que apagou 4 inserts.
- Um `COMMIT` que persistiu 4 inserts.
- Um `TRUNCATE TABLE` para zerar `LIVROS`.

---

## 🎯 Conceitos-chave para fixar

💡 **`START TRANSACTION`** abre uma transação manual — a partir daqui, alterações ficam pendentes.

💡 **`ROLLBACK`** descarta tudo o que foi feito desde o `START TRANSACTION`.

💡 **`COMMIT`** persiste tudo definitivamente — não há retorno depois.

💡 **`TRUNCATE TABLE`** zera a tabela rapidamente, mas é um comando **definitivo** (commit implícito).

💡 **Atomicidade** é o princípio do "tudo ou nada" — em uma transação, ou todas as operações sobrevivem, ou nenhuma sobrevive.

---

## ➡️ Próximos Passos

No Bloco 3 você vai **encapsular essa lógica de transação dentro de uma Stored Procedure**, com **tratamento automático de erro**. Você verá pela primeira vez três comandos importantes: `DECLARE erro_sql`, `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION` e o reuso do `START TRANSACTION` dentro de SP.

Acesse: [📁 Bloco 3](../Bloco3/README.md)

---

> 💭 *"ROLLBACK é a borracha. COMMIT é a caneta. Use as duas com a mesma intenção."*
