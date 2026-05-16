# 🧠 Atividade 4 — Integrador Final

> **Duração:** 50 minutos
> **Formato:** Individual (parte com 2 sessões)
> **Objetivo:** Integrar todos os conceitos da ARQ14 em um exercício final: criar tabela, construir SP transacional, combinar com `LOCK`, observar comportamento entre sessões e decidir, em casos reais, qual mecanismo de controle é o mais apropriado.

---

## 📋 Parte 1 — Construção

60. Crie a tabela `LIVROS` no schema `BLOQUEIOS`. Confirme com `SELECT * FROM LIVROS;` (deve retornar vazio).

61. Crie a SP `sp_insere_livros_02` seguindo o padrão `HANDLER + COMMIT/ROLLBACK`. Confirme listando suas SPs:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'BLOQUEIOS';
```

62. Antes do primeiro `CALL`, registre o estado:

```sql
SELECT COUNT(*) AS qtd_livros FROM LIVROS;
```

Resultado: _____

---

## 📋 Parte 2 — Bateria de testes da SP (sem LOCK)

63. Execute as 3 chamadas a seguir e preencha a tabela:

```sql
CALL sp_insere_livros_02(11111111111111, 'Autor A', 'Livro A', 10.50);
CALL sp_insere_livros_02(22222222222222, 'Autor B', 'Livro B', 25.00);
CALL sp_insere_livros_02(11111111111111, 'Autor C', 'Livro Duplicado', 99.99);
```

| Chamada | `erro_sql` | Mensagem retornada | Linhas em LIVROS após |
|---------|-----------|-------------------|----------------------|
| #1 (11...11) | _____ | _____ | _____ |
| #2 (22...22) | _____ | _____ | _____ |
| #3 (11...11 — duplicada) | _____ | _____ | _____ |

64. Explique o que aconteceu na chamada #3 — qual `SQLEXCEPTION` o handler capturou?

---

## 📋 Parte 3 — Combinando com LOCK (2 sessões)

65. Em S1, prepare:

```sql
-- [S1]
USE BLOQUEIOS;
TRUNCATE LIVROS;
COMMIT;
```

66. Em S1, execute a sequência completa:

```sql
-- [S1]
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(99999999999999, 'Autor X', 'Livro X', 50.00);
```

67. **Sem destravar a S1**, vá para S2 e tente:

```sql
-- [S2]
SELECT * FROM LIVROS;
```

O que aconteceu? _____

68. Em S1, faça `SHOW PROCESSLIST;` e localize a S2. Qual o `State`? _____

69. Em S1, libere:

```sql
-- [S1]
UNLOCK TABLES;
```

70. O que aconteceu na S2 imediatamente após? Quantas linhas retornaram? _____

71. **Reflexão importante:** o `COMMIT` da SP rodou **antes** do `UNLOCK TABLES`. Mesmo assim, a S2 não conseguiu ler. **Por quê o `COMMIT` interno da SP não destrava o lock?**

---

## 📋 Parte 4 — Distinção entre transação e lock

72. Em S1, execute:

```sql
-- [S1]
TRUNCATE LIVROS;
COMMIT;
LOCK TABLE LIVROS WRITE;
INSERT INTO LIVROS VALUES (88888888888888, 'Manual', 'Manual de Testes', 5.00);
ROLLBACK;        -- desfaz o INSERT
SELECT * FROM LIVROS;   -- vê quantas linhas?
```

73. **Quantas linhas tem `LIVROS` agora?** _____

74. **A tabela ainda está travada?** (Sim/Não) _____

75. Em S2, tente `SELECT * FROM LIVROS;`. Trava? _____

76. Em S1, libere com `UNLOCK TABLES;`. Agora a S2 destrava.

77. **Conclusão em uma frase:** `COMMIT/ROLLBACK` controla _______________, enquanto `LOCK/UNLOCK` controla _______________ — são mecanismos **independentes**.

---

## 📋 Parte 5 — Tabela comparativa final (ARQ12 / ARQ13 / ARQ14)

78. Complete a tabela abaixo a partir do que você aprendeu em cada aula:

| Aula | Mecanismo | Granularidade | Disparado por | Custo |
|------|-----------|---------------|--------------|-------|
| ARQ12 | Trigger `AFTER UPDATE` | _______ | _______ (evento DML) | Baixo |
| ARQ13 | SP transacional com IF aninhado | _______ | _______ (chamada explícita) | Médio |
| ARQ14 | `LOCK TABLE` + SP | _______ | _______ (comando explícito) | _______ |

---

## 📋 Parte 6 — Decisão técnica

Para cada cenário, indique qual **mecanismo** seria mais apropriado (Trigger, SP transacional, `LOCK TABLE`, ou **nenhum dos três** — confiar no row-locking automático do InnoDB):

79. **Cenário A:** registrar automaticamente toda mudança de saldo na tabela `Conta` em uma tabela `AuditFin`.

Resposta: _______

80. **Cenário B:** transferir R$1000 da conta A para a conta B, garantindo que a operação seja **atômica** e validando que A tem saldo.

Resposta: _______

81. **Cenário C:** uma rotina noturna que recalcula índices estatísticos de todas as 10.000 contas do banco. Precisa que nenhuma transferência aconteça durante o cálculo.

Resposta: _______

82. **Cenário D:** uma aplicação web onde 500 usuários por minuto fazem `UPDATE` em suas próprias contas (cada um na sua, nunca a mesma).

Resposta: _______

83. **Cenário E:** migrar todos os registros de `Cliente` para uma nova estrutura, sem mudar os dados, mas reorganizando colunas. Operação única, feita no final de semana.

Resposta: _______

---

## 📋 Parte 7 — Reflexão final

84. Em sua opinião, o exemplo deste bloco (`LOCK TABLE LIVROS WRITE` em volta de um único `INSERT`) é **didaticamente útil**, mas seria **adequado em produção**? Justifique.

85. Cite **uma situação real** em que você usaria `LOCK TABLE WRITE` de verdade (não apenas por didática).

86. Resuma, em **uma frase**, a lição central da Aula ARQ14:

_______

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

60-61. *(passos de execução)*

62. Resultado: **0** (tabela recém-criada).

---

### Parte 2

63. Tabela completa:

| Chamada | `erro_sql` | Mensagem | Linhas em LIVROS |
|---------|-----------|----------|------------------|
| #1 | `FALSE` | `'Transação efetivada com sucesso!!!'` | 1 |
| #2 | `FALSE` | `'Transação efetivada com sucesso!!!'` | 2 |
| #3 | `TRUE` | `'ATENÇÃO: Erro na transação!!!'` | 2 (sem alteração — rollback) |

64. Na #3, o `INSERT` tentou usar `ISBN = 11111111111111` que **já existia** (PK duplicada). Isso disparou `SQLEXCEPTION` com erro 1062 (`Duplicate entry … for key 'PRIMARY'`). O handler capturou, colocou `erro_sql = TRUE`, e o ramo `ELSE` fez `ROLLBACK`.

---

### Parte 3

65-66. *(passos de execução)*

67. **Travou** — cursor girando, sem retorno.

68. `State`: `Waiting for table lock` (ou `Waiting for table metadata lock`).

69. *(passo de execução)*

70. **Imediatamente destrava.** Retorna **1 linha** — o livro 99999999999999 (porque o `COMMIT` da SP já tinha sido feito antes do `UNLOCK`).

71. Porque **lock e transação são mecanismos independentes**. O `COMMIT` finaliza a transação (libera row-locks do InnoDB e torna as mudanças permanentes), mas **não** afeta o `LOCK TABLE` explícito — esse só morre com `UNLOCK TABLES` ou desconexão da sessão.

---

### Parte 4

72-73. **0 linhas** — o `ROLLBACK` desfez o `INSERT`. Mas...

74. **Sim, a tabela ainda está travada.** O `ROLLBACK` desfez a transação, mas não tocou no lock.

75. **Sim, trava.** Continua bloqueada pelo `WRITE` lock da S1.

76. *(passo de execução)*

77. `COMMIT/ROLLBACK` controla **transação (efetivar ou desfazer alterações)**, enquanto `LOCK/UNLOCK` controla **lock de tabela (exclusividade de acesso)** — são mecanismos independentes.

---

### Parte 5

78. Tabela completa:

| Aula | Mecanismo | Granularidade | Disparado por | Custo |
|------|-----------|---------------|---------------|-------|
| ARQ12 | Trigger `AFTER UPDATE` | **Linha** | Evento DML (`UPDATE`) — **implícito** | Baixo (overhead/linha) |
| ARQ13 | SP transacional com IF aninhado | **Chamada da SP** | `CALL` — **explícito** | Médio (validações + IFs) |
| ARQ14 | `LOCK TABLE` + SP | **Tabela inteira** | `LOCK TABLE` — **explícito** | **Alto** (serializa concorrência) |

---

### Parte 6

79. **Trigger `AFTER UPDATE`** — auditoria reativa por linha. É exatamente o caso da ARQ12/ARQ13.

80. **SP transacional** com handler. Lock explícito não é necessário; o InnoDB cuida da consistência das linhas alteradas dentro da transação.

81. **`LOCK TABLE WRITE`** (provavelmente combinado com a rotina de cálculo). Operação batch que precisa de "tabela congelada" — o caso ideal para lock explícito.

82. **Nenhum dos três** — confiar no **row-locking automático** do InnoDB. Os usuários atualizam contas distintas; sequenciamento explícito mataria a performance da aplicação.

83. **`LOCK TABLE WRITE`** — migração estrutural fora de horário comercial. Exclusividade total é apropriada.

---

### Parte 7

84. **Didaticamente útil**, mas **inadequado em produção**: travar a tabela inteira para uma única inserção é desperdício colossal de paralelismo. Em produção, o `INSERT` sozinho (sem `LOCK`) já é seguro porque o InnoDB protege o registro novo durante a transação.

85. Exemplos válidos:
* Backup lógico consistente de uma tabela MyISAM.
* Migração de schema/dados em janela de manutenção.
* Recálculo batch que precisa ler a tabela inteira sem interferência.
* Operação multi-tabela onde quero garantir que **duas tabelas** fiquem fixas ao mesmo tempo.

86. Exemplos de lição central:
* *"Cada mecanismo de controle (Trigger, SP, Lock) atende uma granularidade. A maturidade está em escolher a menor granularidade que ainda dá a garantia necessária."*
* *"Controle de acesso (`GRANT`) responde 'quem'; controle de concorrência (`LOCK`) responde 'quando'; controle transacional (`COMMIT/ROLLBACK`) responde 'se vai valer'."*
* *"`LOCK TABLE` é poderoso e raro. Use quando o InnoDB não basta — não quando você só não confia nele."*

---

## 💭 Reflexão Final

Após esta atividade, você deve ser capaz de:

✅ Combinar `LOCK + CALL sp + UNLOCK` corretamente.
✅ Distinguir `COMMIT/ROLLBACK` de `LOCK/UNLOCK` — mecanismos independentes.
✅ Posicionar os mecanismos de ARQ12, ARQ13 e ARQ14 em uma **escala de granularidade**.
✅ Decidir, em cenários reais, **qual mecanismo é apropriado** (ou se nenhum é necessário).

> 💡 *"Concorrência mal resolvida não dá erro — dá inconsistência. E inconsistência só aparece quando o usuário reclama. Por isso o estudo de controle de concorrência é tão difícil: você está prevenindo o problema que ninguém viu acontecer ainda."*
