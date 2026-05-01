# 🧠 Atividade 1 — Verificação do Ambiente

> **Duração:** 15 minutos  
> **Formato:** Individual  
> **Objetivo:** Confirmar que o ambiente está pronto para o controle transacional dos próximos blocos.

---

## 📋 Parte 1 — Execução

Após executar o roteiro do Bloco 1 no MySQL Workbench, responda:

1. Qual valor a consulta `SELECT @@autocommit;` está retornando **agora**? Por que esse valor é importante para os próximos blocos?

2. Quantos registros a tabela `LIVROS` possui imediatamente após a sua criação?

3. Qual engine foi atribuída à tabela `LIVROS`? Como você pode **verificar** isso usando uma consulta SQL?

> 💡 **Dica para a questão 3:** existe uma tabela do schema `information_schema` chamada `TABLES` que guarda metadados de todas as tabelas. Procure pela coluna `ENGINE`.

---

## 📋 Parte 2 — Questões Conceituais

4. Em poucas palavras, o que aconteceria se você tentasse executar `ROLLBACK` em uma sessão com `autocommit = 1`?

5. Por que escolhemos `BIGINT UNSIGNED` para o `ISBN` em vez de `INT UNSIGNED`?

6. A cláusula `IF NOT EXISTS` em `CREATE TABLE IF NOT EXISTS LIVROS (...)` está protegendo de qual situação concreta? Em quais cenários ela é útil?

7. Suponha que você crie a tabela `LIVROS` usando `ENGINE = MyISAM` em vez de `ENGINE = InnoDB`. O que acontecerá quando, no Bloco 2, você executar `START TRANSACTION` seguido de `INSERT` e depois `ROLLBACK`?

---

## 📋 Parte 3 — Experimentação

8. Execute o comando abaixo e descreva, com suas palavras, o resultado:

```sql
SHOW CREATE TABLE LIVROS;
```

Quais informações relevantes aparecem? Por que o resultado está formatado como uma única coluna gigante?

9. Execute o comando abaixo e explique o que cada coluna do resultado representa:

```sql
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'procs_armazenados';
```

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1. Deve retornar **`0`**. Esse valor é importante porque desliga o commit automático: a partir de agora, toda alteração feita por `INSERT`, `UPDATE` ou `DELETE` fica **pendente** até que o aluno execute, manualmente, um `COMMIT` (que confirma) ou um `ROLLBACK` (que desfaz).

2. **Zero registros.** A tabela foi recém-criada, não há nenhum `INSERT` ainda.

3. A engine é **`InnoDB`**. Pode ser verificada com a consulta da questão 9, ou abrindo o `SHOW CREATE TABLE LIVROS;` (questão 8) e procurando pela cláusula `ENGINE=InnoDB` ao final.

---

### Parte 2

4. **Nada relevante.** Como cada instrução já foi confirmada automaticamente, não há transação aberta para desfazer. O MySQL aceita o comando, mas não há nenhum estado pendente para reverter.

5. Porque um **ISBN-13 tem 13 dígitos**, podendo chegar a `9.999.999.999.999` (~10¹³). O `INT UNSIGNED` aceita até ~`4,3 × 10⁹`, valor menor do que um ISBN-13 típico. O `BIGINT UNSIGNED`, com capacidade até ~`1,8 × 10¹⁹`, comporta o ISBN-13 sem risco de estouro.

6. O `IF NOT EXISTS` evita o **erro de criação duplicada** caso a tabela já exista. É útil em scripts que precisam ser **reexecutáveis** (executar mais de uma vez sem quebrar) — comum em scripts de migração, deploy e ambientes de aula em que o aluno pode rodar o roteiro várias vezes.

7. O `ROLLBACK` **não terá nenhum efeito**. A engine `MyISAM` não suporta transações; o `INSERT` será confirmado imediatamente e o `ROLLBACK` é ignorado em silêncio (sem mensagem de erro). Esse comportamento silencioso é especialmente perigoso em produção — por isso, **InnoDB é obrigatória** sempre que houver transação.

---

### Parte 3

8. O `SHOW CREATE TABLE LIVROS;` retorna **duas colunas**: `Table` (com o nome) e `Create Table` (com o comando `CREATE TABLE …` reconstituído pelo MySQL, com a sintaxe que ele realmente usou — incluindo o tipo de cada coluna, as constraints, a engine e o charset). É formatado como uma "coluna gigante" porque tudo está numa string só, com quebras de linha. É a forma mais rápida de **inspecionar a estrutura real** de uma tabela.

9. As colunas representam:
   * **`TABLE_NAME`** → nome da tabela.
   * **`ENGINE`** → engine de armazenamento (`InnoDB`, `MyISAM`, etc.).
   * **`TABLE_COLLATION`** → regra de comparação e ordenação aplicada (ex.: `utf8mb4_0900_ai_ci`).

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Verificar o estado da variável `autocommit` em uma sessão MySQL.  
✅ Justificar por que `InnoDB` é obrigatória para o restante da aula.  
✅ Inspecionar a estrutura de uma tabela com `SHOW CREATE TABLE` e `information_schema`.  

> 💡 *"O ambiente é a parte invisível da prática. Quando ele está mal configurado, todo o seu SQL parece estar mentindo."*
