# 🧠 Atividade 3 — Bloqueio Total Entre Sessões

> **Duração:** 40 minutos
> **Formato:** Individual (exige 2 sessões; opcionalmente 3)
> **Objetivo:** Reproduzir o cenário do `LOCK TABLE WRITE`, confirmar empiricamente cada célula da tabela comparativa `READ` vs `WRITE` e refletir sobre casos de uso reais.

---

## 📋 Parte 1 — Setup

39. Confirme `CONNECTION_ID()` em cada sessão. Anote:

| Sessão | `CONNECTION_ID()` |
|--------|-------------------|
| S1 | _____ |
| S2 | _____ |

40. Garanta estado conhecido da tabela:

```sql
-- [S1]
USE BLOQUEIOS;
TRUNCATE TABLE messages;
INSERT INTO messages(message) VALUES('Hello');
COMMIT;
SELECT * FROM messages;
```

Quantas linhas? _____

---

## 📋 Parte 2 — Detentor com `WRITE` lock pode tudo

41. Em S1:

```sql
-- [S1]
LOCK TABLE messages WRITE;
```

42. **Ainda em S1**, execute em sequência e marque cada resultado:

| Comando | Funcionou? | Mensagem (se erro) |
|---------|------------|--------------------|
| `SELECT * FROM messages;` | _____ | _____ |
| `INSERT INTO messages(message) VALUES('Good Morning');` | _____ | _____ |
| `SELECT * FROM messages;` | _____ | _____ |
| `COMMIT;` | _____ | _____ |

43. **Compare com o Bloco 2**: qual destes comandos teria falhado se o lock fosse `READ` em vez de `WRITE`? Por quê?

---

## 📋 Parte 3 — Outras sessões travam (até para ler)

44. Em S2:

```sql
-- [S2]
SELECT * FROM messages;
```

O que acontece visualmente? Marque a opção certa:
* (   ) Retorna imediatamente com as 2 linhas
* (   ) Retorna erro
* (   ) **Trava** — cursor girando

45. **Anote o horário** em que você executou o `SELECT` em S2 (ou inicie um cronômetro):

Horário/início: _____

46. Volte para S1 (que está livre) e execute:

```sql
-- [S1]
SHOW PROCESSLIST;
```

Preencha para a linha da S2:

| Coluna | Valor |
|--------|-------|
| `State` | _____ |
| `Time` (segundos) | _____ |
| `Info` | _____ |

47. **Reflexão:** o que **NUNCA** apareceria em `SHOW PROCESSLIST` sob um `READ` lock e está aparecendo agora?

---

## 📋 Parte 4 — Liberação e impacto

48. Em S1, libere:

```sql
-- [S1]
UNLOCK TABLES;
```

49. **Imediatamente**, observe S2. Anote o horário em que o `SELECT` de S2 retornou:

Horário/fim: _____

50. **Calcule** quanto tempo a S2 ficou esperando:

Tempo de espera ≈ _____ segundos

51. Em S2, quantas linhas retornaram? _____

---

## 📋 Parte 5 — Tabela comparativa completa

52. Preencha a tabela abaixo a partir do que **você observou empiricamente** nos Blocos 2 e 3. Use ✅ (funciona normalmente), ⛔ERRO (retorna erro imediato), ou ⏳TRAVA (fica esperando).

| Cenário | `LOCK READ` | `LOCK WRITE` |
|---------|-------------|--------------|
| S1 (detentora): `SELECT` | _____ | _____ |
| S1 (detentora): `INSERT` | _____ | _____ |
| S2 (outra): `SELECT` | _____ | _____ |
| S2 (outra): `INSERT` | _____ | _____ |

53. Em **uma frase**, descreva a diferença essencial entre `READ` e `WRITE` lock.

---

## 📋 Parte 6 — Casos de uso

Para cada cenário abaixo, indique qual lock seria mais apropriado (`READ`, `WRITE`, ou **nenhum**) e justifique brevemente:

54. **Cenário A:** uma sessão precisa gerar um relatório de balanço diário (read-only, mas que pode levar 30 segundos). Não pode haver mudanças no meio para que os totais batam.

Resposta: _____

55. **Cenário B:** uma sessão precisa renumerar todos os IDs da tabela `Produto`, recriando os índices. Operação batch, manutenção de madrugada, ninguém pode interferir.

Resposta: _____

56. **Cenário C:** dois usuários da aplicação web tentam dar `UPDATE` na conta de um cliente quase ao mesmo tempo (atualização normal de saldo, milhares por minuto).

Resposta: _____

57. **Cenário D:** preciso fazer um `TRUNCATE` em uma tabela de logs antes de iniciar um teste de carga. Só eu vou mexer.

Resposta: _____

---

## 📋 Parte 7 — Limitações

58. Cite **dois custos** que o `LOCK TABLE` impõe e que o row-level locking automático do InnoDB não impõe.

59. **Pergunta de fechamento:** se o InnoDB já protege transações automaticamente, por que ainda existe `LOCK TABLE` no MySQL? Cite **pelo menos uma situação** em que ele continua sendo útil.

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

39. IDs distintos. *(valores variam)*

40. **1 linha** após o `TRUNCATE` e `INSERT`.

---

### Parte 2

41. *(passo de execução)*

42. Todos funcionam:

| Comando | Funcionou? | Mensagem |
|---------|------------|----------|
| `SELECT *` | ✅ | retorna `Hello` |
| `INSERT 'Good Morning'` | ✅ | 1 row affected |
| `SELECT *` | ✅ | retorna `Hello` e `Good Morning` |
| `COMMIT` | ✅ | OK |

43. **O `INSERT`** teria falhado sob `READ` lock (com erro 1099 — "Table was locked with a READ lock and can't be updated"). Sob `WRITE` lock, o detentor tem permissão plena de escrita.

---

### Parte 3

44. ⏳ **Trava** — cursor girando.

45. *(anotação pessoal)*

46. Linha da S2 em `SHOW PROCESSLIST`:
    * `State`: `Waiting for table lock` (ou `Waiting for table metadata lock`)
    * `Time`: cresce a cada segundo
    * `Info`: `SELECT * FROM messages`

47. **Um `SELECT` travado.** Sob `READ` lock, `SELECT`s de outras sessões nunca travavam — passavam livremente porque o lock é compartilhado entre leitores. Sob `WRITE` lock, **nem leitura passa**.

---

### Parte 4

48-50. *(observação pessoal — tempo varia)*

51. **2 linhas** (`Hello` e `Good Morning`) — após o `UNLOCK`, a S2 enxerga as escritas commitadas pela S1.

---

### Parte 5

52. Tabela completa:

| Cenário | `LOCK READ` | `LOCK WRITE` |
|---------|-------------|--------------|
| S1 (detentora): `SELECT` | ✅ | ✅ |
| S1 (detentora): `INSERT` | ⛔ ERRO (1099) | ✅ |
| S2 (outra): `SELECT` | ✅ | ⏳ TRAVA |
| S2 (outra): `INSERT` | ⏳ TRAVA | ⏳ TRAVA |

53. `READ` é **compartilhado entre leitores** (várias sessões podem ler em paralelo, mas ninguém escreve); `WRITE` é **exclusivo** (só o detentor faz qualquer coisa; todos os outros, leitores ou escritores, ficam esperando).

---

### Parte 6

54. **`LOCK READ`** — o relatório precisa de leitura consistente sem que ninguém escreva no meio. Não bloqueia outros leitores (relatórios paralelos podem rodar), mas garante imutabilidade.

55. **`LOCK WRITE`** — manutenção crítica, ninguém pode ler ou escrever durante a operação. Lock exclusivo é o apropriado.

56. **Nenhum lock explícito.** O InnoDB já trata isso com row-level locking automático em transações. Usar `LOCK TABLE WRITE` aqui seria **catastrófico para performance** — serializaria todas as atualizações de conta da aplicação. Confiar no InnoDB é a escolha correta.

57. **`LOCK WRITE`** — embora você seja o único usuário previsto, garantir exclusividade evita "surpresas" (um job automatizado, outro analista). Custo baixo, garantia alta.

---

### Parte 7

58. Dois custos:
    * **Granularidade grosseira**: bloqueia a tabela inteira mesmo que você só vá tocar em uma linha.
    * **Serialização forçada**: outras sessões esperam, mesmo que fossem operar em linhas completamente diferentes. Em tabelas com alta concorrência, vira gargalo.

59. O `LOCK TABLE` continua útil:
    * **Tabelas MyISAM** (sem row-locking) — ali é a única forma de coordenação.
    * **Operações de manutenção/batch** que precisam de exclusividade total temporária (migração de estrutura, reorganização, dumps consistentes).
    * **Coerência multi-tabela** quando você quer travar várias tabelas ao mesmo tempo, antes de uma operação que mistura todas — `LOCK TABLES t1 WRITE, t2 WRITE`.

---

## 💭 Reflexão Final

Após esta atividade, você deve ser capaz de:

✅ Distinguir **`READ` (compartilhado)** de **`WRITE` (exclusivo)** com clareza.
✅ Prever o comportamento de qualquer sessão (detentora ou não) sob cada tipo de lock.
✅ Usar **`SHOW PROCESSLIST`** como ferramenta primária de diagnóstico.
✅ Decidir, em casos reais, **se vale a pena** usar `LOCK TABLE` ou se o row-locking automático do InnoDB já basta.

> 💡 *"Lock explícito é uma ferramenta poderosa. Como toda ferramenta poderosa, na mão errada faz mais estrago do que ajuda."*
