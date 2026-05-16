# 📘 Bloco 4 — Integrador: SP Transacional + LOCK Explícito

> **Duração estimada:** 55 minutos
> **Objetivo:** Combinar o **`LOCK TABLE`** dos blocos anteriores com o padrão de **SP transacional com `CONTINUE HANDLER`** já dominado em ARQ12/ARQ13. Discutir criticamente **quando** essa combinação é apropriada — e quando é redundante (ou prejudicial) dado o row-level locking automático do InnoDB.
> **Modalidade:** Guiada + reflexiva. Você implementa o padrão e depois questiona suas próprias decisões.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Criado a tabela **`LIVROS`** (`ISBN BIGINT UNSIGNED PK`, `Autor`, `Nomelivro`, `Precolivro FLOAT`).
- Implementado a SP **`sp_insere_livros_02`** — recap do padrão `DECLARE CONTINUE HANDLER` + `COMMIT/ROLLBACK`.
- Executado o padrão **`LOCK TABLE WRITE → CALL sp → UNLOCK TABLES`** e observado o efeito conjunto.
- Comparado, em uma tabela final, os mecanismos de controle vistos em **ARQ12, ARQ13 e ARQ14**.
- Respondido à pergunta crítica: **dado que o InnoDB já faz row-locking automático em transações, em que cenários `LOCK TABLE` explícito agrega valor?**

---

## 💡 Antes de começar — o que une os blocos anteriores

Os três blocos anteriores trataram, respectivamente:

| Bloco | Foco | O que controla |
|-------|------|----------------|
| **1** | Usuários e privilégios (`GRANT`/`REVOKE`) | **Quem** pode acessar |
| **2** | `LOCK TABLE READ` com 2 sessões | **Concorrência de leitura** |
| **3** | `LOCK TABLE WRITE` com 2 sessões | **Concorrência total** |

Neste bloco fechamos o ciclo: **controle de acesso (usuário com privilégio) + controle de concorrência (lock explícito) + integridade transacional (SP com handler)**. É a "receita completa" do controle defensivo.

---

## 🧭 Passo 1 — Criar a tabela `LIVROS`

Em uma sessão (basta uma para o conteúdo principal):

```sql
USE BLOQUEIOS;

CREATE TABLE IF NOT EXISTS LIVROS (
    ISBN       BIGINT UNSIGNED NOT NULL,
    Autor      VARCHAR(50)  NOT NULL,
    Nomelivro  VARCHAR(100) NOT NULL,
    Precolivro FLOAT        NOT NULL,
    PRIMARY KEY (ISBN)
)
ENGINE = InnoDB;

SELECT * FROM LIVROS;
-- Esperado: vazio
```

### Por que `BIGINT UNSIGNED` para `ISBN`?

| Pedaço | Justificativa |
|--------|---------------|
| `BIGINT` | ISBN moderno tem 13 dígitos — não cabe em `INT` (máx ~2 bilhões). |
| `UNSIGNED` | ISBN é sempre positivo; ganhamos o "espaço da metade negativa". |

> 💡 **Lembrete:** `FLOAT` para preço é uma escolha didática **discutível** — em produção, `DECIMAL(7,2)` é mais apropriado (sem imprecisões binárias). Mantemos `FLOAT` para fidelidade ao roteiro original.

---

## 🧭 Passo 2 — Criar a SP `sp_insere_livros_02`

Este é o padrão clássico **HANDLER + COMMIT/ROLLBACK** que você já viu em ARQ12 e ARQ13. Aqui ele aparece em forma mínima — um único `INSERT` envolvido em transação.

```sql
DELIMITER //

CREATE PROCEDURE sp_insere_livros_02(
    v_ISBN       BIGINT,
    v_AUTOR      VARCHAR(50),
    v_NOMELIVRO  VARCHAR(100),
    v_PRECOLIVRO FLOAT
)
BEGIN
    DECLARE erro_sql BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    INSERT INTO LIVROS (ISBN, Autor, Nomelivro, Precolivro)
    VALUES (v_ISBN, v_AUTOR, v_NOMELIVRO, v_PRECOLIVRO);

    IF erro_sql = FALSE THEN
        COMMIT;
        SELECT 'Transação efetivada com sucesso!!!' AS RESULTADO;
    ELSE
        ROLLBACK;
        SELECT 'ATENÇÃO: Erro na transação!!!' AS RESULTADO;
    END IF;
END //

DELIMITER ;
```

### O que essa SP faz (recap)

1. Declara `erro_sql = FALSE` e instala um handler que muda para `TRUE` em qualquer `SQLEXCEPTION`.
2. Tenta o `INSERT`.
3. Se o handler **não disparou** (`erro_sql = FALSE`), faz `COMMIT` e mensagem de sucesso.
4. Se **disparou** (`erro_sql = TRUE`), faz `ROLLBACK` e mensagem de erro.

> 💡 **Em ARQ13**, esse padrão evoluiu para **3 níveis de IF aninhados** (parâmetros → saldo → transação). Aqui ele aparece em sua forma mais simples — sem validações de parâmetros, só o tratamento de erro do `INSERT`.

---

## 🧭 Passo 3 — Combinar `LOCK + CALL + UNLOCK`

Esta é a novidade do bloco. O padrão completo:

```sql
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(22222222222222, 'Golias Alencar', 'Pet - O livro', 29.99);
UNLOCK TABLES;
```

Sequência de eventos:

```
   ┌────────────────────────────────────────────────────────┐
   │  1. LOCK TABLE LIVROS WRITE                            │
   │     → S1 obtém exclusividade. Outras sessões travam.   │
   │                                                        │
   │  2. CALL sp_insere_livros_02(...)                      │
   │     → SP executa o INSERT.                             │
   │     → Se OK: COMMIT interno + mensagem de sucesso.     │
   │     → Se erro: ROLLBACK interno + mensagem de erro.    │
   │                                                        │
   │  3. UNLOCK TABLES                                      │
   │     → S1 libera o lock. Outras sessões destravam.      │
   └────────────────────────────────────────────────────────┘
```

### Bateria de testes

```sql
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(22222222222222, 'Golias Alencar',    'Pet - O livro',     29.99);
UNLOCK TABLES;

LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(3333333333333,  'Rosimeire Alencar', 'Receitas da Rosi',  19.90);
SELECT * FROM LIVROS;
UNLOCK TABLES;

-- Sem LOCK (apenas a SP)
CALL sp_insere_livros_02(44444, 'QUATRO', 'QUATRO', 4.44);

-- Tentando inserir duplicata (mesma PK que já existe)
CALL sp_insere_livros_02(44444, 'DUPLICADO', 'DUPLICADO', 9.99);
-- Esperado: 'ATENÇÃO: Erro na transação!!!' (violação de PK)
```

### Resultados esperados

| Chamada | `erro_sql` | Ramo executado | Mensagem |
|---------|------------|----------------|----------|
| #1 (22222222222222) | `FALSE` | `COMMIT` | `'Transação efetivada com sucesso!!!'` |
| #2 (3333333333333) | `FALSE` | `COMMIT` | `'Transação efetivada com sucesso!!!'` |
| #3 (44444 — primeiro) | `FALSE` | `COMMIT` | `'Transação efetivada com sucesso!!!'` |
| #4 (44444 — duplicata) | `TRUE` | `ROLLBACK` | `'ATENÇÃO: Erro na transação!!!'` |

> 💡 A duplicata dispara `SQLEXCEPTION` por violar a `PRIMARY KEY (ISBN)`. O handler captura, faz `ROLLBACK`, retorna a mensagem de erro. Sem o handler, a SP abortaria e propagaria o erro ao chamador.

---

## 🔬 A pergunta crítica do bloco

> **Se o InnoDB já faz row-level locking automático dentro de transações, por que precisaríamos do `LOCK TABLE WRITE` em volta do `CALL`?**

Resposta honesta: **na maioria dos casos, NÃO precisamos**. A combinação `LOCK + CALL + UNLOCK` neste bloco é **didática** — serve para você ver o padrão funcionando lado a lado. Em produção, a decisão depende do cenário:

### Quando `LOCK TABLE` explícito **agrega valor**

| Cenário | Por quê |
|---------|---------|
| **Operação batch que precisa de tabela "congelada"** | Você vai processar a tabela inteira (ex.: recalcular todos os totais) e não pode ter atualizações concorrentes corrompendo o resultado. |
| **Migração de schema/dados** | Você está alterando estrutura ou movendo dados em massa. Exclusividade total simplifica raciocínio. |
| **Backup lógico consistente** | `mysqldump` pode usar `LOCK TABLES READ` para garantir snapshot consistente em tabelas MyISAM. |
| **Tabelas MyISAM** | MyISAM **não tem row-locking**. `LOCK TABLE` é a única ferramenta de coordenação. |
| **Multi-table coordination** | `LOCK TABLES t1 WRITE, t2 WRITE` para garantir que **ambas** as tabelas permaneçam consistentes em uma operação cruzada. |

### Quando `LOCK TABLE` explícito **é prejudicial**

| Cenário | Por quê |
|---------|---------|
| **OLTP de alta concorrência** | Travar a tabela toda para uma inserção de uma linha **mata a throughput** da aplicação. Confie no row-lock automático. |
| **Web app com milhares de inserções/segundo** | Sequencializar tudo em uma única tabela com `LOCK WRITE` cria gargalo brutal. |
| **Quando você está dentro de uma `TRANSACTION` InnoDB que já protege as linhas** | É redundante. Os locks granulares do InnoDB já fazem o trabalho. |

---

## 📊 Tabela comparativa — Mecanismos de controle nas aulas ARQ12, ARQ13, ARQ14

| Aula | Mecanismo principal | Granularidade | Propósito | Custo |
|------|---------------------|---------------|-----------|-------|
| **ARQ12** | `Trigger` `AFTER UPDATE` (auditoria reativa) | Por **linha alterada** | Registrar mudanças automaticamente | Baixo (overhead por linha) |
| **ARQ13** | SP transacional com validação multinível | Por **chamada de SP** | Garantir consistência semântica antes de transacionar | Médio (validações em SQL) |
| **ARQ14** | `LOCK TABLE` + SP transacional | Por **tabela inteira** | Garantir exclusividade temporária explícita | **Alto** (serialização total) |

A trajetória vai de **granular e implícito** (Trigger por linha) para **grosseiro e explícito** (Lock por tabela). Conforme você sobe na escala, ganha **garantia** e perde **paralelismo**. Saber escolher a granularidade certa é a competência sênior em controle de concorrência.

---

## ⚠️ Cuidados ao combinar `LOCK` com SP que faz `COMMIT`

Uma sutileza importante: a SP `sp_insere_livros_02` faz `COMMIT` **dentro do seu próprio corpo**. Isso significa que, em uma sequência como:

```sql
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(...);
-- COMMIT já aconteceu dentro da SP
UNLOCK TABLES;
```

O `COMMIT` interno da SP **não libera o lock** — o lock persiste até o `UNLOCK TABLES` explícito. Os dois mecanismos são **independentes**: `COMMIT/ROLLBACK` controla **transação**, `LOCK/UNLOCK` controla **lock de tabela**.

> 💡 **Diferença chave em relação ao InnoDB:** os **row-locks** do InnoDB **SÃO liberados** no `COMMIT/ROLLBACK`. Os **table-locks** explícitos **NÃO** — só morrem com `UNLOCK TABLES` (ou desconexão da sessão).

---

## ✏️ Atividade Prática

### 📝 Atividade 4 — Integrador final

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Reproduzir a sequência `LOCK + CALL + UNLOCK` com 4 chamadas distintas (sucesso, sucesso, sucesso, erro).
- Observar o comportamento de uma S2 enquanto S1 mantém o lock + executa a SP.
- Refletir sobre redundância de `LOCK + InnoDB` em cenários reais.
- Decidir, para 5 cenários hipotéticos, qual mecanismo (Trigger, SP, Lock, ou combinação) é mais apropriado.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-04-bloco4.sql](./codigo-fonte/COMANDOS-BD-04-bloco4.sql)

---

## ✅ Resumo do Bloco 4

Neste bloco você:

- Criou a tabela `LIVROS` e a SP `sp_insere_livros_02`.
- Executou o padrão `LOCK TABLE WRITE → CALL sp → UNLOCK TABLES`.
- Observou que o `HANDLER` da SP captura `SQLEXCEPTION` (ex.: duplicata de PK) e executa `ROLLBACK`.
- Distinguiu **transação** (`COMMIT/ROLLBACK`) de **lock de tabela** (`LOCK/UNLOCK`) — dois mecanismos independentes.
- Construiu a tabela comparativa dos mecanismos de controle vistos em ARQ12, ARQ13 e ARQ14.
- Refletiu criticamente sobre **quando** `LOCK TABLE` agrega valor sobre o row-lock automático do InnoDB.

---

## 🎯 Conceitos-chave para fixar

💡 **`LOCK TABLE` + SP transacional** é um padrão raramente necessário em OLTP, **muito útil** em batch/manutenção.

💡 **`COMMIT` interno da SP NÃO libera o lock** — só `UNLOCK TABLES` libera.

💡 **Granularidade**: Trigger (linha) < SP (chamada) < `LOCK TABLE` (tabela).

💡 **Trade-off universal**: mais garantia ⇄ menos paralelismo.

💡 **Em InnoDB com transações**, o row-lock automático costuma ser **suficiente e mais eficiente** que `LOCK TABLE`.

---

## 🎯 Encerramento da Aula ARQ14

Você agora domina:

✅ Controle de **acesso** (usuários e privilégios).
✅ Controle de **concorrência explícita** (`LOCK TABLE READ/WRITE`).
✅ Diagnóstico de concorrência (`SHOW PROCESSLIST`, `CONNECTION_ID()`).
✅ **Combinação** de lock explícito com SP transacional.
✅ **Critério** para decidir entre lock explícito e row-lock automático.

### Limitação aberta (para aulas futuras)

Tudo o que vimos opera em granularidade de **tabela inteira**. Para travar **apenas algumas linhas** sem afetar o resto da tabela, o InnoDB oferece `SELECT ... FOR UPDATE` e `SELECT ... LOCK IN SHARE MODE` — tema da próxima aula.

---

> 💭 *"Toda ferramenta de concorrência paga em paralelismo o que dá em garantia. A maturidade técnica está em pagar o mínimo necessário, não o máximo possível."*
