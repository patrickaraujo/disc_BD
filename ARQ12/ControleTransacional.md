# Controle Transacional

> **Disciplina:** Banco de Dados

---

## Visão geral

Esta aula cobre quatro tópicos interligados:

1. O que é uma transação e como o SGBD a processa.
2. Propriedades ACID e log de operações.
3. Controle de concorrência em sistemas multiusuário.
4. Recuperação após falhas.

**Definição.** Uma transação é um programa em execução que acessa o BD por meio de operações de leitura e/ou escrita. Seus limites são marcados por `BEGIN` e `END`.

**Atomicidade.** A transação é executada por completo ou não tem efeito algum.

**No MySQL.** Transações são suportadas pelo motor **InnoDB**, mas não pelo **MyISAM**.

**Para o SGBD, só existem dois tipos de operação:**

* **READ** → `SELECT`
* **WRITE** → `INSERT`, `UPDATE`, `DELETE`

---

## 1. Storage Engines: InnoDB × MyISAM

Storage engines decidem como o MySQL grava, lê e gerencia os dados em disco. Cada tabela pode usar um motor diferente.

### InnoDB (padrão desde a versão 5.5)

* Suporta transações ACID — em caso de falha, faz `ROLLBACK`.
* Suporta chaves estrangeiras.
* Bloqueio em nível de **linha** — alta concorrência.
* Recuperação automática via *Redo Log*.

### MyISAM (legado)

* Sem transações — não há `BEGIN` nem `COMMIT`.
* Bloqueio em nível de **tabela** — gera filas em sistemas com escrita intensa.
* Pode ser ligeiramente mais rápido em cenários só-leitura.
* Frágil: queda durante gravação pode corromper a tabela.

### Comparativo

| Característica         | InnoDB                          | MyISAM                          |
| ---------------------- | ------------------------------- | ------------------------------- |
| Transações (ACID)      | ✅                              | ❌                              |
| Chaves Estrangeiras    | ✅                              | ❌                              |
| Bloqueio               | Linha                           | Tabela                          |
| Recuperação            | Automática                      | Manual / Risco de corrupção     |
| Uso ideal              | Web, ERPs, finanças             | Logs simples, tabelas só-leitura|

> **Recomendação prática.** Use InnoDB por padrão. O MyISAM raramente se justifica hoje.

---

## 2. Operações READ e WRITE

Toda transação se reduz a duas operações primitivas (Elmasri & Navathe, 2018):

* `READ_ITEM(X)` — copia o valor de X do BD para uma variável de programa.
* `WRITE_ITEM(X)` — grava o valor da variável no item X do BD.

**Passos do READ:**

1. Localiza o bloco no disco.
2. Carrega o bloco no *buffer*.
3. Copia X do *buffer* para a variável.

**Passos do WRITE:**

1. Localiza o bloco no disco.
2. Carrega o bloco no *buffer*.
3. Atualiza X no *buffer*.
4. Grava o bloco do *buffer* no disco.

### Exemplo: transferência bancária de N entre as contas X e Y

```
BEGIN_TRANSACTION
    READ_ITEM (X);
    X := X – N;
    WRITE_ITEM (X);
    READ_ITEM (Y);
    Y := Y + N;
    WRITE_ITEM (Y);
END_TRANSACTION
```

**Grão da operação.** O "ITEM" pode ser um campo, uma linha ou uma tabela — o comando executado define o tamanho.

---

## 3. Estados de uma transação

Durante a execução, uma transação passa por **cinco estados**, conectados por operações que disparam transições.

### Diagrama de transição (Figura 5.1)

```
                 Read, Write
                     ↺
  Begin transaction      End transaction         Commit
 ──────────────► [Ativo] ──────────► [Parcialmente ──────► [Confirmado]
                    │                 confirmado]                │
                    │ Abort                  │ Abort             │
                    ▼                        ▼                   ▼
                                        [Falha] ──────────► [Terminado]
```

### Estados

| Estado                  | Quando ocorre                                            |
| ----------------------- | -------------------------------------------------------- |
| Ativo                   | Após `BEGIN_TRANSACTION`, durante READs e WRITEs         |
| Parcialmente confirmado | Após `END_TRANSACTION`, antes do COMMIT físico           |
| Confirmado              | Após o `COMMIT` — efeitos gravados permanentemente       |
| Falha                   | Quando `ABORT` é disparado por erro do sistema           |
| Terminado               | Estado final, com sucesso ou após recuperação            |

### Operações de transição

| Operação               | Função                                                     |
| ---------------------- | ---------------------------------------------------------- |
| `BEGIN_TRANSACTION`    | Inicia a transação (Ativo)                                 |
| `READ` / `WRITE`       | Permanece em Ativo                                         |
| `END_TRANSACTION`      | Move para Parcialmente confirmado                          |
| `COMMIT_TRANSACTION`   | Move para Confirmado e depois Terminado                    |
| `ABORT`                | Move para Falha                                            |
| `UNDO` / `REDO`        | Acionadas pelo sistema de recuperação a partir de Falha    |

---

## 4. Log de operações

O SGBD mantém um **log** (diário) com todos os eventos relevantes das transações. Cada registro identifica a transação por um `T` único.

| Registro                                            | Significado                                               |
| --------------------------------------------------- | --------------------------------------------------------- |
| `[start_transaction, T]`                            | T foi iniciada                                            |
| `[write_item, T, X, valor_antigo, valor_novo]`      | T alterou X — `valor_antigo` permite UNDO; `valor_novo`, REDO |
| `[read_item, T, X]`                                 | T leu X                                                   |
| `[commit, T]`                                       | T concluída — pode ser gravada em disco                   |
| `[abort, T]`                                        | T cancelada                                               |
| `[checkpoint]`                                      | Marca um ponto de sincronismo                             |

**Checkpoint.** Marca o instante em que o conteúdo do log é "descarregado" para o BD em disco. Tudo que ocorreu antes do checkpoint está garantido.

### Figura 5.2 — Transações no log

```
                 |     T4      |
        |   T2  |              |
| T1 |                  |       T5        |
        |  T3   |       |  T6  |
─────────────────────────────────────► tempo
                        C        F

C — checkpoint
F — falha
```

> *Fonte: elaborado pelo autor.*

**Análise.** Após uma falha em F, o sistema retrocede até C:

* **Garantidas:** T1, T2, T3, T4 (concluídas antes do checkpoint).
* **Devem ser refeitas/desfeitas:** T5 e T6 (ocorreram após C).

---

## 5. Propriedades ACID

| Letra | Propriedade   | O que garante                                                              |
| ----- | ------------- | -------------------------------------------------------------------------- |
| **A** | Atomicidade   | A transação roda 100% ou 0%                                                |
| **C** | Consistência  | Se o BD estava consistente antes, permanece consistente depois             |
| **I** | Isolamento    | Uma transação não interfere em outra                                       |
| **D** | Durabilidade  | Efeitos de transação confirmada não se perdem, mesmo após falha do sistema |

ACID é responsabilidade do **controle de concorrência** e dos **métodos de recuperação** do SGBD.

---

## 6. Controle de concorrência

### Por que existe?

Sistemas multiusuário executam várias transações ao mesmo tempo. Sem controle, transações concorrentes podem deixar o BD inconsistente.

### Intercalado vs. paralelo (Figura 5.3)

```
Tempo ──────────────────────────────────────────────►
       |   A   |     |    A    |
              |  B  |          | B |
                                    |─────  C  ─────|
                                    |─────  D  ─────|
       t1     t2     t3              t3              t4
```

* **Intercalado (A e B):** um único processador alterna entre transações.
* **Paralelo (C e D):** processadores distintos executam em paralelo real.

A maioria dos SGBDs usa execução **intercalada**.

### Os dois problemas clássicos da concorrência

Considere as transações:

```
T1 = READ_ITEM (X);       T2 = READ_ITEM (X);
     X := X – N;                X := X + M;
     WRITE_ITEM (X);            WRITE_ITEM (X);
     READ_ITEM (Y);
     Y := Y + N;
     WRITE_ITEM (Y);
```

#### a) Atualização perdida

A atualização de uma transação é sobrescrita pela outra:

```
        T1                      T2
        ──                      ──
   read_item(X);
   X := X – N;
                            read_item(X);
                            X := X + M;
   write_item(X);
   read_item(Y);
                            write_item(X);   ← X incorreto: T1 foi sobrescrita
   Y := Y + N;
   write_item(Y);
```

#### b) Leitura suja (valor temporário)

Uma transação lê um valor que ainda não foi confirmado e que pode ser desfeito:

```
        T1                      T2
        ──                      ──
   read_item(X);
   X := X – N;
   write_item(X);
                            read_item(X);   ← T2 leu valor temporário de T1.
                            X := X + M;       Se T1 falhar, T2 trabalhou
                            write_item(X);    com dado inválido.
   read_item(Y);
   ↓ falha
```

### Escalonamento (*schedule*)

É a ordem definida pelo SGBD para entrelaçar operações de várias transações de forma segura. O escalonamento preserva a ordem interna de cada transação individualmente.

### Técnicas de controle de concorrência

| Técnica                      | Abordagem  | Uso real                                                   |
| ---------------------------- | ---------- | ---------------------------------------------------------- |
| **Bloqueio**                 | Pessimista | A mais usada — bloqueia o item para evitar conflito        |
| **Marcadores de tempo**      | Pessimista | Segura, mas complexa — pouco usada                         |
| **Múltiplas versões (MVCC)** | Otimista   | Amplamente adotada (PostgreSQL, InnoDB, Oracle, SQL Server)|
| **Validação**                | Otimista   | Útil em baixa concorrência (ex.: ORMs com lock otimista)   |

> A partir daqui, foco apenas em **bloqueio**, que pode ser **binário** ou **múltiplo**.

---

## 7. LOCK TABLES e UNLOCK TABLES no MySQL

`LOCK TABLES` permite que uma sessão adquira bloqueios explícitos para cooperar ou impedir alterações concorrentes. Uma sessão só pode adquirir/liberar seus próprios bloqueios.

### Comportamento implícito

* Bloquear uma tabela bloqueia também tabelas usadas em **triggers** e **views**.
* Tabelas relacionadas por **chave estrangeira** são bloqueadas implicitamente:
  * `READ` para verificações de FK
  * `WRITE` para atualizações em cascata

### Tipos de bloqueio

#### `READ [LOCAL]`

* Sessão pode **ler** a tabela; não pode escrever.
* Várias sessões podem manter `READ` simultaneamente.
* `LOCAL` permite `INSERT` concorrente por outras sessões.

#### `WRITE`

* Sessão pode ler **e escrever**.
* **Exclusivo:** nenhuma outra sessão acessa a tabela.
* Tem prioridade sobre `READ` — atualizações são processadas primeiro.

> ⚠️ Adquira todos os bloqueios necessários em **uma única instrução** `LOCK TABLES`. Enquanto eles estiverem ativos, a sessão só acessa as tabelas bloqueadas.

### `UNLOCK TABLES`

Libera todos os bloqueios da sessão. Também libera o bloqueio de leitura global obtido por `FLUSH TABLES WITH READ LOCK`.

---

## 8. Bloqueio binário

Apenas dois estados: **bloqueado** ou **desbloqueado**. Operações: `LOCK_ITEM(X)` e `UNLOCK_ITEM(X)`.

**Regras:**

1. T deve executar `LOCK_ITEM(X)` antes de qualquer `READ_ITEM(X)` ou `WRITE_ITEM(X)`.
2. T deve executar `UNLOCK_ITEM(X)` após terminar todos os acessos a X.
3. T não pode bloquear X se já estiver bloqueado.
4. T não pode desbloquear X se já estiver desbloqueado.

**Limitação.** Não permite leituras simultâneas — concorrência muito baixa.

---

## 9. Bloqueio múltiplo (compartilhado e exclusivo)

> **Serializabilidade.** Um escalonamento é **serializável** quando produz o mesmo resultado final que seria obtido executando as mesmas transações em série (uma após a outra, sem entrelaçamento). É a garantia formal de que o entrelaçamento entre transações concorrentes não corrompeu o BD.
>
> *Exemplo.* Sejam `X = 100`, `T1: X := X + 10` e `T2: X := X * 2`. Execuções seriais possíveis: T1→T2 produz `X = 220`; T2→T1 produz `X = 210`. Qualquer escalonamento entrelaçado cujo resultado bata com **um desses dois valores** é serializável. Qualquer outro resultado (ex.: `X = 200`) indica escalonamento **não-serializável** — sintoma típico de atualização perdida.

Diferencia o tipo de bloqueio conforme a operação:

* `READ_LOCK(X)` — **compartilhado**: várias transações leem X ao mesmo tempo.
* `WRITE_LOCK(X)` — **exclusivo**: só uma transação acessa X.
* `UNLOCK(X)` — libera o bloqueio.

**Regras principais:**

1. `READ_LOCK` ou `WRITE_LOCK` antes de qualquer `READ_ITEM`.
2. `WRITE_LOCK` antes de qualquer `WRITE_ITEM`.
3. `UNLOCK` somente após terminar todos os acessos.
4. Não pedir bloqueio em item já bloqueado por outra transação.
5. É possível promover (*upgrade*) `READ_LOCK` para `WRITE_LOCK` na mesma transação.

### Bloqueio múltiplo não garante serializabilidade

```
        T1                      T2
        ──                      ──
   read_lock(Y);
   read_item(Y);
   unlock(Y);              ← desbloqueio cedo demais
                            read_lock(X);
                            ...
                            write_lock(Y);
                            ...
                            unlock(Y);
   write_lock(X);
   ...
```

Y em T1 e X em T2 são liberados **antes** do final da transação, permitindo escalonamento não-serializável.

### Protocolo de bloqueio em duas fases (*Two-Phase Locking* — 2PL)

Garante serialização. Toda transação tem duas fases:

1. **Expansão:** todos os bloqueios são adquiridos.
2. **Contração:** todos os desbloqueios — nenhum novo bloqueio pode ser pedido.

**Regra de ouro.** Uma vez liberado o primeiro bloqueio, a transação não pode pedir nenhum bloqueio novo.

```
        T1'                     T2'
        ───                     ───
   read_lock(Y);            read_lock(X);
   read_item(Y);            read_item(X);
   write_lock(X);           write_lock(Y);   [Fase de expansão]
   unlock(Y);               unlock(X);
   read_item(X);            read_item(Y);
   X := X + Y;              Y := X + Y;
   write_item(X);           write_item(Y);
   unlock(X);               unlock(Y);       [Fase de contração]
```

> ✅ Se todas as transações seguem 2PL, o escalonamento é **garantidamente serializável**.

---

## 10. Deadlock e Livelock

### Deadlock (impasse)

Duas transações esperam mutuamente pela liberação de itens bloqueados:

```
        T1'                     T2'
        ───                     ───
   read_lock(Y);
   read_item(Y);
                            read_lock(X);
                            read_item(X);
   write_lock(X);   ← espera T2'
                            write_lock(Y);   ← espera T1'
        ↓                        ↓
        ────────── DEADLOCK ─────────
```

**Solução.** O SGBD aborta uma das transações (geralmente a mais recente).

### Livelock (inanição)

Quando o SGBD não consegue decidir qual transação abortar, ou quando uma transação é repetidamente escolhida e abortada.

**Solução.** Atribuir prioridade — por exemplo, transações já abortadas têm prioridade maior na próxima rodada.

---

## 11. Recuperação de falhas

### Tipos de falhas

| Tipo                          | Exemplo                                                  |
| ----------------------------- | -------------------------------------------------------- |
| Falha do computador           | Erro de hardware/software, perda de memória              |
| Erro de transação             | Divisão por zero, *overflow*                             |
| Exceção local                 | Dado não encontrado                                      |
| Controle de concorrência      | Aborto por *deadlock*                                    |
| Falha de disco                | Defeito no cabeçote — perda de blocos                    |
| Sinistros físicos             | Falta de energia, fogo, sabotagem                        |

### Estratégias do SGBD

* **Falha catastrófica.** Restaura a partir de **backup** + `REDO` das transações confirmadas no log. Geralmente requer parar o sistema. Responsabilidade do **DBA**.
* **Falha não-catastrófica.** O módulo de recuperação desfaz/refaz operações pelo log até retornar a um estado consistente.

### Duas técnicas de recuperação

| Técnica               | Algoritmo       | Quando o BD é alterado                              |
| --------------------- | --------------- | --------------------------------------------------- |
| Atualização imediata  | `UNDO / REDO`   | Durante a execução da transação                     |
| Atualização adiada    | `NO UNDO / REDO`| Apenas após o `COMMIT`                              |

---

### 11.1 Atualização imediata (UNDO / REDO)

As alterações são feitas **diretamente no BD** durante a execução, mas o log é gravado **antes** da alteração física (regra *Write-Ahead Logging* — WAL).

**Em caso de falha:**

* Transações **não confirmadas** → `UNDO` (usa `valor_antigo` do log).
* Transações **confirmadas após o último checkpoint** → `REDO` (usa `valor_novo` do log).

#### Processo de recuperação (Figura 5.4)

```
Tempo                   TC (Checkpoint)         TF (Falha do Sistema)
                              │                        │
T1   ←──────►                 │                        │
                              │                        │
T2          ←─────────►       │                        │
                              │                        │
T3                  ←─────────┼────────────────────────│
                              │                        │
T4                            │  ←─────────►           │
                              │                        │
T5                            │           ←────────────│
                              │                        │
─────────────────────────────────────────────────────────► tempo
```

| Transação | Situação                                       | Ação    |
| --------- | ---------------------------------------------- | ------- |
| T1        | Confirmada antes do checkpoint                 | Nada    |
| T2, T4    | Confirmadas após o checkpoint                  | `REDO`  |
| T3, T5    | Ativas no momento da falha (não confirmadas)   | `UNDO`  |

> *Fonte: elaborado pelo autor.*

> **Checkpoint.** Atualização física dos *buffers* do SGBD para o disco.

---

### 11.2 Atualização adiada (NO UNDO / REDO)

As alterações ficam apenas em uma **área de trabalho** e no log durante a execução. Só são gravadas no BD **após o COMMIT**.

**Vantagem.** Em caso de falha, dados não confirmados nunca chegaram ao BD — não há nada a desfazer (`NO UNDO`). Basta `REDO` das transações já confirmadas.

**Protocolo:**

1. A transação não pode alterar o BD antes do ponto de comprometimento.
2. A transação só atinge o ponto de comprometimento após o log estar gravado em disco.

A operação `REDO` busca cada `[write_item, T, X, valor_antigo, valor_novo]` no log e substitui X no BD por `valor_novo`.

Transações ativas no momento da falha são reiniciadas (**ROLLBACK implícito**), e o usuário recebe a notificação.

---

## 12. Interação entre LOCK TABLES e transações

| Comando                       | Efeito sobre transação ativa                                        |
| ----------------------------- | ------------------------------------------------------------------- |
| `LOCK TABLES`                 | **Confirma implicitamente** a transação atual antes de bloquear     |
| `UNLOCK TABLES`               | Confirma implicitamente — apenas se `LOCK TABLES` foi usado         |
| `START TRANSACTION`           | Confirma implicitamente e libera bloqueios de tabela existentes     |
| `FLUSH TABLES WITH READ LOCK` | Bloqueio de leitura **global** — não interage com `LOCK TABLES`     |
| `ROLLBACK`                    | **Não** libera bloqueios de tabela                                  |

### Forma correta com tabelas InnoDB

```sql
SET autocommit = 0;
LOCK TABLES t1 WRITE, t2 READ;
-- operações com t1 e t2
COMMIT;
UNLOCK TABLES;
```

> ⚠️ **Não use `autocommit = 1`** com `LOCK TABLES`. O InnoDB libera o bloqueio interno no commit, e *deadlocks* ficam quase inevitáveis.

> ⚠️ **Não use `START TRANSACTION` aqui** — use `SET autocommit = 0`. Caso contrário, o `START TRANSACTION` libera os bloqueios de tabela ativos.

---

## Considerações finais

* **Transações** são unidades atômicas de processamento, regidas pelas propriedades **ACID**.
* **Concorrência** é resolvida principalmente por **bloqueio múltiplo** com protocolo **2PL**.
* **Falhas** ocorrem mesmo com controles ativos — daí a necessidade do sistema de recuperação, baseado em log com `UNDO`/`REDO`.
* A escolha do SGBD e da configuração depende do contexto da aplicação e é, em geral, decisão do **DBA**.

---

## Referências

ELMASRI, R.; NAVATHE, S. B. **Sistemas de Banco de Dados.** 7. ed. São Paulo: Pearson, 2018.
