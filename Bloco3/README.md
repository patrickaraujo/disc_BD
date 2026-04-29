# 📘 Bloco 3 — Encapsulando Transações em Stored Procedures

> **Duração estimada:** 50 minutos  
> **Objetivo:** Construir `sp_insere_livros` — uma Stored Procedure que insere um livro em uma transação e, em caso de erro, **desfaz tudo automaticamente**.  
> **Modalidade:** Guiada — a SP é construída por você, mas três comandos pouco trabalhados em sala são apresentados explicitamente.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Uma SP chamada **`sp_insere_livros`** que recebe os 4 atributos de um livro como parâmetros.
- A SP usa uma **transação interna** com `START TRANSACTION` e decide entre `COMMIT` e `ROLLBACK` com base na ocorrência de erro durante o `INSERT`.
- Mensagens de retorno claras para o usuário em ambos os casos (sucesso e falha).
- A SP testada com **chamadas válidas** (4 livros) e **uma chamada inválida** (que dispara o `ROLLBACK`).

---

## 💡 Antes de começar — três comandos novos que você precisa conhecer

Para detectar automaticamente um erro dentro de uma SP transacional, o MySQL fornece um mecanismo de **handler de exceção**. Os três comandos abaixo aparecem **sempre juntos** no início do corpo da SP — vale a pena memorizar este "trio".

### 🔹 Comando 1 — Variável-flag de erro

```sql
DECLARE erro_sql boolean DEFAULT FALSE;
```

* `DECLARE` cria uma **variável local** dentro da SP.
* `erro_sql` é o nome convencional dessa variável-flag.
* `boolean` é o tipo. (Tecnicamente, no MySQL `boolean` é alias de `TINYINT(1)`.)
* `DEFAULT FALSE` inicializa a flag com `FALSE` — partimos do princípio de que **nada deu errado** até prova em contrário.

> 💭 **Pense assim:** é um "termômetro" que começa apontando "tudo bem" e que pode ser virado para "deu erro" pelo handler logo abaixo.

---

### 🔹 Comando 2 — Handler que captura qualquer erro SQL

```sql
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;
```

Este é o **comando-coração** do controle transacional em SP. Vamos quebrá-lo em pedaços:

| Parte | O que significa |
|-------|-----------------|
| `DECLARE … HANDLER FOR …` | Declara um manipulador (handler) — um pedaço de código que será executado **se** uma condição específica acontecer durante a SP. |
| `CONTINUE` | Diz ao MySQL: "Quando a condição for capturada, **continue** executando a SP a partir da próxima instrução". (A alternativa é `EXIT`, que abortaria a SP.) |
| `SQLEXCEPTION` | A condição capturada: **qualquer** erro de SQL (`NOT NULL` violado, FK ausente, tipo errado, divisão por zero, etc.). |
| `SET erro_sql = TRUE` | A ação executada: virar a flag `erro_sql` para `TRUE`. |

> 💭 **Pense assim:** "Se durante a transação acontecer qualquer erro de SQL, **não pare** — apenas marque o termômetro como 'erro' e continue. Eu vou verificar essa marca lá no fim e decidir se faço `COMMIT` ou `ROLLBACK`."

---

### 🔹 Comando 3 — Abertura da transação dentro da SP

```sql
START TRANSACTION;
```

Você já viu este comando no Bloco 2. **A diferença aqui** é que ele aparece **dentro** de uma SP — ele abre uma transação **toda vez que a SP é chamada**. Tudo que vier a seguir, dentro da SP, fica pendente até a decisão final.

---

## 🧱 Estrutura geral da SP que você vai construir

A `sp_insere_livros` segue o esqueleto abaixo (cabe a você preencher cada parte com o SQL apropriado):

```text
DELIMITER //
CREATE PROCEDURE sp_insere_livros (parâmetros…)
BEGIN
    -- (1) declarar a flag erro_sql           ← comando exibido acima
    -- (2) declarar o handler de SQLEXCEPTION ← comando exibido acima
    
    -- (3) START TRANSACTION                  ← comando exibido acima
    
    -- (4) INSERT INTO LIVROS (…) VALUES (…)
    
    -- (5) IF erro_sql = FALSE THEN
    --        COMMIT
    --        SELECT 'mensagem de sucesso' AS RESULTADO
    --     ELSE
    --        ROLLBACK
    --        SELECT 'mensagem de falha'   AS RESULTADO
    --     END IF
END //
DELIMITER ;
```

---

## 🧭 Passo a passo

### Passo 1 — Defina os parâmetros

A SP precisa receber **4 parâmetros**, um para cada coluna da tabela `LIVROS`:

| Parâmetro | Tipo | Origem |
|-----------|------|--------|
| `v_ISBN` | `BIGINT` | corresponde à coluna `ISBN` |
| `v_AUTOR` | `VARCHAR(50)` | corresponde a `Autor` |
| `v_NOMELIVRO` | `VARCHAR(100)` | corresponde a `Nomelivro` |
| `v_PRECOLIVRO` | `FLOAT` | corresponde a `Precolivro` |

> 💡 **Convenção:** o prefixo `v_` (de "variável") é usado para distinguir parâmetros de colunas. Útil em SPs onde o nome da coluna se confundiria com o do parâmetro.

### Passo 2 — Use `DELIMITER //`

Antes do `CREATE PROCEDURE`, troque o delimitador (você já fez isso na ARQ11). Lembre de **voltar para `;`** ao final.

### Passo 3 — No início do `BEGIN…END`, coloque o "trio"

Os três comandos exibidos acima aparecem **nesta ordem**:

1. `DECLARE erro_sql …`
2. `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION …`
3. `START TRANSACTION;`

> ⚠️ **Atenção:** os `DECLARE` precisam vir **antes** de qualquer outra instrução dentro do `BEGIN…END`. Essa é uma regra do MySQL — declarações primeiro, depois lógica.

### Passo 4 — O `INSERT INTO LIVROS`

Faça um `INSERT INTO LIVROS (...) VALUES (...)` usando os **4 parâmetros** como valores (na ordem correta). Esta é a única instrução de modificação dentro da transação.

### Passo 5 — A decisão final: `IF … THEN COMMIT ELSE ROLLBACK END IF`

Use um `IF erro_sql = FALSE THEN ... ELSE ... END IF;` para:

* **Caminho de sucesso (`erro_sql = FALSE`):** execute `COMMIT;` e retorne uma linha de resultado com a mensagem `'Transação efetivada com sucesso!!!'` (use `SELECT 'texto' AS RESULTADO;`).
* **Caminho de falha (`erro_sql = TRUE`):** execute `ROLLBACK;` e retorne `'ATENÇÃO: Erro na transação!!!'` da mesma forma.

---

## 🧪 Testes obrigatórios

Após `CREATE PROCEDURE`, faça as 5 chamadas abaixo, **na ordem**, e relate o que cada uma retorna:

1. `CALL sp_insere_livros(9786525223742, 'Rubens Zampar Jr', 'As Expectativas e Dilemas dos Alunos do Ensino Médio acerca do Papel da Universidade', 74.90);` → **deve dar sucesso**.
2. `CALL sp_insere_livros(9999999999999, 'Maria José Almeida', 'Livro Exemplo 02', 34.50);` → **deve dar sucesso**.
3. `CALL sp_insere_livros(8888888888888, 'Américo da Silva', 'Livro Exemplo 03', 55.90);` → **deve dar sucesso**.
4. `CALL sp_insere_livros(7777777777777, 'Adalberto Felisbino Cruz', 'Livro Exemplo 02', 29.90);` → **deve dar sucesso**.
5. `CALL sp_insere_livros(6666666666666, 'XXXXXXXXXXXX', 'YYYYYYYYYYYYY', null);` → **deve dar falha**.

> 🤔 Por que a chamada 5 falha? Porque a coluna `Precolivro` foi criada com `NOT NULL` — passar `null` quebra a constraint, o handler vira `erro_sql = TRUE`, e a SP executa `ROLLBACK`.

### Verifique o estado final

Execute `SELECT * FROM LIVROS;`. Você deve ver **exatamente 4 registros** — nenhum traço da chamada 5.

---

## ✏️ Atividade Prática

### 📝 Atividade 3 — Sua primeira SP transacional

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Construir, executar e testar a SP completa.
- Refletir sobre o papel do `CONTINUE HANDLER` e da flag `erro_sql`.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco3.sql](./codigo-fonte/COMANDOS-BD-03-bloco3.sql)

---

## ✅ Resumo do Bloco 3

Neste bloco você aprendeu a:

- Combinar `DECLARE`, `CONTINUE HANDLER` e `START TRANSACTION` para construir SPs **resilientes a erro**.
- Usar uma **flag booleana** (`erro_sql`) como termômetro de estado da transação.
- Decidir entre `COMMIT` e `ROLLBACK` com base nessa flag, em um `IF … THEN … ELSE … END IF`.
- Retornar mensagens claras de sucesso/falha via `SELECT` interno.

---

## 🎯 Conceitos-chave para fixar

💡 **`DECLARE CONTINUE HANDLER FOR SQLEXCEPTION` = "se algo der errado, marque a flag e continue"**.

💡 **A flag `erro_sql` é o ponto de decisão** entre `COMMIT` e `ROLLBACK`.

💡 **O trio `DECLARE …; DECLARE CONTINUE HANDLER …; START TRANSACTION;`** é a **abertura padrão** de toda SP transacional.

💡 **A ordem importa:** `DECLARE`s sempre antes de qualquer outra instrução dentro do `BEGIN…END`.

---

## ➡️ Próximos Passos

No Bloco 4 você vai **reaplicar exatamente este padrão** em um cenário diferente — pedidos × estoque (`ItemPedido` × `Produtos`). É uma oportunidade para consolidar o padrão.

Acesse: [📁 Bloco 4](../Bloco4/README.md)

---

> 💭 *"O handler é o cinto de segurança da SP — você espera nunca precisar, mas ele é o que separa um pequeno susto de um acidente grave."*
