# 📘 Bloco 6 — Integrando Trigger + Transação em SP

> **Duração estimada:** 50 minutos  
> **Objetivo:** Construir `sp_altera_livros` — uma SP transacional que altera o preço de um livro e, automaticamente, dispara a Trigger `Audita_Livros` criada no Bloco 5.  
> **Modalidade:** Guiada — você reusa o padrão transacional do Bloco 3 e observa o efeito colateral da Trigger do Bloco 5.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- A SP **`sp_altera_livros`** — recebe `ISBN` e novo `Precolivro` como parâmetros, faz um `UPDATE` transacional em `LIVROS`.
- A SP **dispara automaticamente** a Trigger `Audita_Livros` (do Bloco 5), que registra cada alteração em `tab_audit`.
- Mensagens de retorno claras com **ISBN + preço novo** em caso de sucesso.
- Bateria de testes com **chamadas válidas** (devem aparecer em `tab_audit`) e **chamadas inválidas** (não devem deixar rastro).

> 💡 **Este é o coração da aula.** Aqui você vê, com seus próprios olhos, três objetos do banco trabalhando juntos: SP + Trigger + tabela de auditoria.

---

## 💡 Antes de começar — o trio já é seu velho conhecido

Para esta SP, **não há comandos novos**. Você reutiliza, pela terceira vez, exatamente o mesmo padrão do Bloco 3:

* `DECLARE erro_sql boolean DEFAULT FALSE;`
* `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;`
* `START TRANSACTION;`
* `IF erro_sql = FALSE THEN COMMIT … ELSE ROLLBACK … END IF;`

> 🔁 Se ainda tem dúvida sobre algum desses comandos, releia o Bloco 3.

---

## 🧱 Estrutura geral da SP

A `sp_altera_livros` segue exatamente o esqueleto que você já conhece — **com uma única diferença em relação à `sp_insere_livros`**: o comando interno é um `UPDATE`, não um `INSERT`. E a mensagem de sucesso retorna **mais informações** (o ISBN e o novo preço).

```text
DELIMITER //
CREATE PROCEDURE sp_altera_livros (parâmetros…)
BEGIN
    -- (1) declarar erro_sql
    -- (2) declarar handler

    -- (3) START TRANSACTION

    -- (4) UPDATE livros SET Precolivro = v_PRECOLIVRO WHERE ISBN = v_ISBN

    -- (5) IF erro_sql = FALSE THEN
    --        COMMIT
    --        SELECT 'mensagem de sucesso' AS RESULTADO, ISBN, PRECOLIVRO AS 'PREÇO NOVO'
    --        FROM LIVROS WHERE ISBN = v_ISBN
    --     ELSE
    --        ROLLBACK
    --        SELECT 'mensagem de falha' AS RESULTADO
    --     END IF
END //
DELIMITER ;
```

---

## 🧭 Passo a passo

### Passo 1 — Defina os parâmetros

A SP precisa receber **2 parâmetros**:

| Parâmetro | Tipo | Origem |
|-----------|------|--------|
| `v_ISBN` | `BIGINT` | identifica qual livro será atualizado |
| `v_PRECOLIVRO` | `FLOAT` | novo preço do livro |

### Passo 2 — Reuso do padrão transacional

Coloque, no início do `BEGIN…END`, o trio já conhecido:

* `DECLARE erro_sql boolean DEFAULT FALSE;`
* `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;`
* `START TRANSACTION;`

### Passo 3 — O comando central: `UPDATE LIVROS`

Em vez de um `INSERT`, agora você faz:

```text
UPDATE livros
SET Precolivro = v_PRECOLIVRO
WHERE ISBN = v_ISBN;
```

Note que o `UPDATE` afeta **uma única linha** (a do `ISBN` informado). Mas para a Trigger `Audita_Livros`, isso significa **uma execução** do bloco `FOR EACH ROW BEGIN … END`. Resultado: **uma nova linha em `tab_audit`** para cada chamada bem-sucedida.

### Passo 4 — Mensagem de sucesso enriquecida

Diferente da SP do Bloco 3 (que retornava apenas uma string), aqui a mensagem de sucesso retorna **três colunas**:

* `RESULTADO` → string `'Preço do Livro alterado com sucesso:'`.
* `ISBN` → ISBN do livro alterado.
* `PRECOLIVRO AS 'PREÇO NOVO'` → preço atual (o novo).

A consulta deve filtrar pelo `ISBN` recém-atualizado, ou seja:

```text
SELECT 'Preço do Livro alterado com sucesso:' AS RESULTADO,
       ISBN,
       PRECOLIVRO AS 'PREÇO NOVO'
FROM LIVROS
WHERE ISBN = v_ISBN;
```

> 💡 **Por que retornar mais informação?** Porque o usuário do sistema espera **confirmação visível** da alteração — ver a string "alterado com sucesso" não é suficiente; mostrar o ISBN e o preço novo dá segurança de que a operação aconteceu como esperado.

### Passo 5 — Mensagem de falha

No caminho do `ROLLBACK`, retorne apenas:

```text
SELECT 'ATENÇÃO: Erro na transação, preço do livro não alterado!!!' AS RESULTADO;
```

---

## 🧪 Testes obrigatórios

Após criar a SP, execute as 3 chamadas abaixo, **na ordem**:

```sql
CALL sp_altera_livros(9786525223742, 44.44);
CALL sp_altera_livros(8888888888888, 10.99);
CALL sp_altera_livros(7777777777777, NULL);
```

| Chamada | Comportamento esperado |
|---------|-----------------------|
| #1 | ✅ Sucesso. Trigger dispara → 1 nova linha em `tab_audit`. |
| #2 | ✅ Sucesso. Trigger dispara → 1 nova linha em `tab_audit`. |
| #3 | ❌ Falha (`NULL` em coluna `NOT NULL`). `ROLLBACK` impede o `UPDATE`, **a Trigger não dispara** → `tab_audit` permanece com 2 linhas, não 3. |

### Verificações finais

1. `SELECT * FROM LIVROS;` → você deve ver os 4 livros, com **dois preços alterados** (`9786525223742` agora com `44.44`, `8888888888888` agora com `10.99`) e os outros dois inalterados.

2. `SELECT * FROM tab_audit;` → você deve ver **exatamente 2 linhas**, registrando as duas alterações bem-sucedidas. Nenhum registro da chamada #3.

> 🤔 **Por que a Trigger não dispara na chamada #3?** Porque o `UPDATE` falha **antes** de modificar a linha (o tipo `FLOAT NOT NULL` rejeita `NULL`). A Trigger é `AFTER UPDATE` — só executa **se o `UPDATE` modificou alguma linha**. Como nada foi modificado, a Trigger nem é chamada. Junto com o `ROLLBACK` da SP, o resultado é **transparente**: nem em `LIVROS`, nem em `tab_audit`, há rastro da chamada #3.

---

## ✏️ Atividade Prática

### 📝 Atividade 6 — Integração SP + Trigger

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Conferir, linha a linha, o conteúdo de `tab_audit` após as 3 chamadas.
- Refletir sobre como a Trigger e a SP cooperam (e por que essa cooperação é elegante).

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco6.sql](./codigo-fonte/COMANDOS-BD-03-bloco6.sql)

---

## ✅ Resumo do Bloco 6

Neste bloco você:

- Construiu sua segunda SP transacional (`sp_altera_livros`), agora com `UPDATE`.
- Verificou — **na prática** — que a Trigger criada no Bloco 5 é disparada automaticamente toda vez que a SP altera um preço com sucesso.
- Confirmou que `ROLLBACK` na SP **impede** o registro de auditoria (nada foi alterado, nada para registrar).
- Aprendeu a retornar mensagens **enriquecidas** (com colunas adicionais) em SPs.

---

## 🎯 Conceitos-chave para fixar

💡 **A Trigger é independente da SP** — qualquer `UPDATE` em `LIVROS`, mesmo fora de SP, dispara `Audita_Livros`.

💡 **`ROLLBACK` da SP impede a Trigger** porque a Trigger é `AFTER UPDATE` — sem `UPDATE` efetivado, sem Trigger.

💡 **Mensagens enriquecidas** (com colunas adicionais) tornam a confirmação de operação mais transparente para o usuário final.

💡 **Padrão SP transacional + Trigger de auditoria** é uma arquitetura comum em sistemas reais — separa a **lógica** (SP) do **rastro** (Trigger).

---

## ➡️ Próximos Passos

No Bloco 7 você vai aprender a **criar e gerenciar usuários** no MySQL — `CREATE USER`, `GRANT`, `SHOW GRANTS`, `FLUSH PRIVILEGES` e `DROP USER`. Tudo o que envolve dar e tirar acesso a um banco.

Acesse: [📁 Bloco 7](../Bloco7/README.md)

---

> 💭 *"SP é a operação. Trigger é a memória da operação. Juntas, dão ao banco a capacidade de **lembrar do passado**."*
