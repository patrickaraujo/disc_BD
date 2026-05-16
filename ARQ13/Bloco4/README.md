# 📘 Bloco 4 — Stored Procedure de Transferência Bancária (v1)

> **Duração estimada:** 60 minutos  
> **Objetivo:** Construir `sp_transf_bancaria` — uma SP transacional que **transfere um valor entre duas contas**, com validação de parâmetros, validação de saldo e tratamento de erro.  
> **Modalidade:** Guiada — você escreve a SP, sem o guia mostrar o código completo.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- A SP **`sp_transf_bancaria`**, transacional, com **validação aninhada de 3 níveis** (parâmetros → saldo → transação).
- A SP capturando saldo da conta origem em uma **variável de sessão** (`@saldo_origem`).
- **Dois `UPDATE`s encadeados** na mesma transação: debita origem, credita destino.
- **Quatro mensagens de retorno distintas**, dependendo do caminho percorrido.
- Bateria de testes com **4 chamadas** que percorrem cada um dos caminhos.

> 💡 **Importante:** esta é uma SP **propositalmente incompleta**. Ela tem falhas de validação que serão analisadas e corrigidas no Bloco 5 e Bloco 6. Aqui o objetivo é **dominar o esqueleto** antes de melhorar.

---

## 💡 Antes de começar — uma técnica nova: variável de sessão capturando `SELECT`

Você já viu na ARQ12 que variáveis de sessão (`@nome`) podem armazenar valores temporários dentro de Triggers e SPs. Aqui vamos usá-las **para capturar o resultado de um `SELECT`** e usar esse valor em decisões posteriores.

### 🔹 Padrão: `SET @variavel = (SELECT coluna FROM tabela WHERE …)`

```sql
SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem);
```

| Comportamento | Resultado |
|---------------|-----------|
| O `SELECT` retorna **1 linha** | `@saldo_origem` recebe o valor da coluna |
| O `SELECT` retorna **0 linhas** (conta não existe) | `@saldo_origem` recebe `NULL` |
| O `SELECT` retorna **mais de 1 linha** | **Erro!** "Subquery returns more than 1 row". |

> 💭 **A última situação não vai acontecer aqui** porque `NroConta` faz parte da PK composta — é único. Mas em outros cenários (sem `WHERE` ou com critério ambíguo), seu código quebraria.

> 💡 **Use parênteses ao redor do `SELECT`** — sem eles, o MySQL não interpreta como subquery e retorna erro de sintaxe.

---

## 🎬 Cenário

Você está construindo o backend de um app bancário. O cliente faz uma transferência:

```
Conta origem (1111) ───[transfere R$ 5000]───▶ Conta destino (2222)
```

Sua SP deve:
1. Validar que **ambos os parâmetros não são NULL**.
2. Validar que a conta origem **tem saldo suficiente**.
3. Em uma transação, **debitar a origem** e **creditar o destino**.
4. **Confirmar** ou **desfazer** com base em erros do SQL durante os `UPDATE`s.
5. Retornar uma mensagem clara, **diferente para cada caminho**.

---

## 🧱 Estrutura da SP que você vai construir

```text
DELIMITER //

CREATE PROCEDURE sp_transf_bancaria (
    IN v_origem  INT,
    IN v_destino INT,
    IN v_valor   FLOAT
)
BEGIN
    -- (1) Declarar a flag erro_sql + handler de SQLEXCEPTION
    
    -- (2) Capturar saldo da origem em @saldo_origem (via SELECT)
    -- (3) Inicializar @saldo_destino = 0 (será sobrescrito após o UPDATE)
    
    IF v_origem is not null AND v_destino is not null THEN
        IF @saldo_origem >= v_valor THEN
            START TRANSACTION;
                -- (4) Debitar origem (UPDATE)
                -- (5) Creditar destino (UPDATE)
                
                IF erro_sql = FALSE THEN
                    COMMIT;
                    -- (6) Reler @saldo_origem e @saldo_destino atualizados
                    -- (7) SELECT 'Contas alteradas com sucesso:' AS RESULTADO,
                    --             @saldo_origem  AS "NOVO SALDO ORIGEM",
                    --             @saldo_destino AS "NOVO SALDO DESTINO";
                ELSE
                    ROLLBACK;
                    -- (8) SELECT 'ATENÇÃO: Erro na transação, Contas não alteradas!!!'
                END IF;
        ELSE
            -- (9) SELECT 'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!'
        END IF;
    ELSE
        -- (10) SELECT 'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!'
    END IF;
END //

DELIMITER ;
```

---

## 🧭 Passo a passo

### Passo 1 — Defina os parâmetros

A SP recebe **3 parâmetros**, todos com modo `IN` (entrada — padrão; pode-se omitir):

| Parâmetro | Tipo | Significado |
|-----------|------|-------------|
| `v_origem` | `INT` | Número da conta de origem (NroConta) |
| `v_destino` | `INT` | Número da conta de destino |
| `v_valor` | `FLOAT` | Quantia a ser transferida |

> 💡 **Modo `IN`** é o padrão e o único que vamos usar aqui. Existem ainda `OUT` (saída) e `INOUT`, mas são menos comuns em SPs transacionais.

### Passo 2 — O trio de tratamento de erro (já conhecido)

Repita o trio que você dominou na ARQ12:

```text
DECLARE erro_sql boolean DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;
```

> 🔁 Lembre: o `START TRANSACTION` **não** vem logo aqui — ele aparece **dentro** do `IF` aninhado, só quando os pré-requisitos estão atendidos. Mais sobre isso adiante.

### Passo 3 — Capture o saldo da origem antes da transação

Use o padrão apresentado na seção "Antes de começar":

```text
SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem);
SET @saldo_destino = 0;
```

> 💡 **Por que `@saldo_destino = 0`?** Para inicializar a variável. Logo após o `COMMIT`, ela será sobrescrita com o valor correto.

> ⚠️ **O que acontece se `v_origem` aponta para uma conta que não existe?** O `SELECT` retorna 0 linhas → `@saldo_origem` recebe `NULL`. Veja que **isso NÃO disparará a próxima validação** — `v_origem is not null` permanece verdadeiro porque o **parâmetro** não é NULL (apenas o saldo é). Esse é justamente o **bug latente** que será discutido no Bloco 5.

### Passo 4 — IF nível 1: validação de parâmetros

```text
IF v_origem is not null AND v_destino is not null THEN
    -- continua para o nível 2
ELSE
    SELECT 'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!' AS RESULTADO;
END IF;
```

> 💡 **Note:** essa validação só verifica se os parâmetros são `NULL`. Não verifica se as contas **existem** no banco — esse é o ponto crítico que será discutido no Bloco 5.

### Passo 5 — IF nível 2: validação de saldo

Dentro do `IF` nível 1:

```text
IF @saldo_origem >= v_valor THEN
    -- continua para o nível 3 (transação)
ELSE
    SELECT 'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!' AS RESULTADO;
END IF;
```

### Passo 6 — IF nível 3: transação

Dentro do `IF` nível 2, **abra a transação** e faça **dois `UPDATE`s encadeados**:

```text
START TRANSACTION;
    UPDATE Conta SET Saldo = (saldo - v_valor) WHERE NroConta = v_origem;
    UPDATE Conta SET Saldo = (saldo + v_valor) WHERE NroConta = v_destino;

    IF erro_sql = FALSE THEN
        COMMIT;
        -- reler saldos atualizados e retornar mensagem de sucesso (3 colunas)
    ELSE
        ROLLBACK;
        SELECT 'ATENÇÃO: Erro na transação, Contas não alteradas!!!' AS RESULTADO;
    END IF;
```

### Passo 7 — Mensagem de sucesso enriquecida

Após `COMMIT`, releia os saldos atualizados (já que o estado mudou) e retorne 3 colunas:

```text
SET @saldo_origem  = (SELECT saldo FROM Conta WHERE NroConta = v_origem);
SET @saldo_destino = (SELECT saldo FROM Conta WHERE NroConta = v_destino);

SELECT 'Contas alteradas com sucesso:' AS RESULTADO,
       @saldo_origem  AS "NOVO SALDO ORIGEM",
       @saldo_destino AS "NOVO SALDO DESTINO";
```

> 💡 **Por que reler?** Os valores em `@saldo_origem` e `@saldo_destino` **antes** do `COMMIT` eram do estado anterior. Após os `UPDATE`s, é preciso reler para mostrar os novos saldos.

---

## 🧪 Testes obrigatórios

Após criar a SP, execute as 4 chamadas abaixo **na ordem** e observe o caminho percorrido em cada uma:

```sql
CALL sp_transf_bancaria(1111, 2222, 5000);
CALL sp_transf_bancaria(5555, 6666, 1600);
CALL sp_transf_bancaria(1111, 2222, 7000);
CALL sp_transf_bancaria(1111, NULL, 2000);
```

| # | Chamada | Caminho esperado | Mensagem esperada |
|---|---------|------------------|-------------------|
| 1 | (1111, 2222, 5000) | Sucesso | `'Contas alteradas com sucesso:'` + saldos novos |
| 2 | (5555, 6666, 1600) | Sucesso | idem |
| 3 | (1111, 2222, 7000) | Saldo insuficiente | `'Saldo Insuficiente, transação cancelada!!!'` |
| 4 | (1111, NULL, 2000) | Parâmetro inválido | `'Parâmetros inadequados, transação cancelada!!!'` |

### Verificação do estado de `Conta`

```sql
SELECT * FROM Conta;
```

Estado esperado:

| NroConta | saldo | Cliente | Tipo |
|----------|-------|---------|------|
| 1111 | 5000 | 1 | 1 | ← debitada 5000 (chamada #1) |
| 2222 | 5000 | 1 | 2 | ← creditada 5000 (chamada #1) |
| 5555 | 8400 | 2 | 1 | ← debitada 1600 (chamada #2) |
| 6666 | 2600 | 2 | 2 | ← creditada 1600 (chamada #2) |

---

## ✏️ Atividade Prática

### 📝 Atividade 4 — Sua primeira SP transacional não trivial

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Documentar a estrutura `IF` aninhada.
- Refletir sobre quando reler os saldos e por que a SP usa `@saldo_destino = 0` antes da transação.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco4.sql](./codigo-fonte/COMANDOS-BD-03-bloco4.sql)

---

## ✅ Resumo do Bloco 4

Neste bloco você:

- Construiu sua primeira SP com **3 parâmetros** e **`IF` aninhado de 3 níveis**.
- Usou **variáveis de sessão capturando `SELECT`** como técnica de validação.
- Encadeou **dois `UPDATE`s** em uma única transação.
- Retornou **mensagens diferentes** para cada caminho da execução.
- Validou os 4 caminhos com bateria de testes.

---

## 🎯 Conceitos-chave para fixar

💡 **`SET @x = (SELECT col FROM t WHERE …)`** captura o valor (ou `NULL`) em variável de sessão.

💡 **Validações **antes** do `START TRANSACTION`** evitam abrir transações que não vão dar em nada.

💡 **`IF` aninhado de 3 níveis** é normal em SPs robustas — cada nível filtra um tipo de erro diferente.

💡 **Mensagens distintas por caminho** permitem ao usuário entender **por que** a operação falhou.

---

## ➡️ Próximos Passos

No Bloco 5 você vai **questionar criticamente** a SP que acabou de construir. Vai descobrir que ela tem **falhas silenciosas graves** — incluindo um cenário em que o dinheiro pode "desaparecer".

Acesse: [📁 Bloco 5](../Bloco5/README.md)

---

> 💭 *"A primeira versão de uma SP transacional resolve **um problema**. A segunda versão evita **um desastre**."*
