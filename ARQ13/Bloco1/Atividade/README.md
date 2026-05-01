# 🧠 Atividade 1 — Diagrama e Forward Engineering

> **Duração:** 20 minutos  
> **Formato:** Individual  
> **Objetivo:** Consolidar a leitura do diagrama ER, fixar o efeito dos 3 `SET`s do Forward Engineering e antecipar implicações práticas.

---

## 📋 Parte 1 — Execução

1. Após executar os 3 `SET`s do roteiro, execute:

```sql
SELECT @@UNIQUE_CHECKS, @@FOREIGN_KEY_CHECKS, @@SQL_MODE;
```

Quais valores você obteve para cada variável? Identifique pelo menos **três flags** dentro de `@@SQL_MODE`.

2. Execute também:

```sql
SELECT @OLD_UNIQUE_CHECKS, @OLD_FOREIGN_KEY_CHECKS;
```

Os valores retornados são `0`, `1`, `NULL` ou outros? Por que esses valores são importantes (mesmo que você não vá restaurá-los nesta aula)?

---

## 📋 Parte 2 — Diagrama ER

3. Olhando o diagrama do schema `Financeiro`, indique:

| Pergunta | Resposta |
|----------|----------|
| Quantas tabelas existem? | _____ |
| Quantas chaves primárias simples (1 coluna) existem? | _____ |
| Quantas chaves primárias compostas existem? | _____ |
| Quantas chaves estrangeiras existem? | _____ |
| Em qual tabela existe um atributo `FLOAT`? | _____ |

4. As cardinalidades das duas relações no diagrama são `1:N`. Reescreva-as em forma de frase, do tipo "Cada __ pode ter __ contas, e cada conta pertence a um único __":
   * Relação Cliente ↔ Conta:
   * Relação TipoConta ↔ Conta:

5. Por que `idCliente` e `idTipoConta` são **`AUTO_INCREMENT`**, mas `NroConta` **não é**? Pense em quem decide o valor de cada uma na vida real (sistema X usuário humano).

---

## 📋 Parte 3 — Questões Conceituais

6. Em uma sessão com `FOREIGN_KEY_CHECKS=0`, é possível **criar** uma tabela `Conta` que faz FK para `Cliente` mesmo se `Cliente` ainda não existir? E é possível **inserir uma linha** em `Conta` apontando para um `idCliente` que não está em `Cliente`? Justifique para os dois casos.

7. Imagine que durante o desenvolvimento você esqueceu de religar `FOREIGN_KEY_CHECKS=1` ao final do script. Liste **dois riscos práticos** dessa configuração permanecer em `0`.

8. A flag `STRICT_TRANS_TABLES` faz parte do `SQL_MODE` definido pelo Workbench. Sem ela ativa, o que aconteceria se você executasse:

```sql
INSERT INTO Cliente (idCliente, NomeCli) VALUES (1, NULL);
```

Compare com o comportamento **com** `STRICT_TRANS_TABLES`.

9. Por que o Workbench **salva os valores antigos** das variáveis (em `@OLD_*`) antes de modificá-las, em vez de simplesmente sobrescrever?

---

## 📋 Parte 4 — Antecipação

10. Após este bloco, sua sessão tem `FOREIGN_KEY_CHECKS=0`. No Bloco 3, você vai criar a tabela `Conta` com **duas chaves estrangeiras** (para `Cliente` e `TipoConta`). Se o flag estivesse em `1`, em qual situação você teria erro? E qual o efeito prático de tê-lo em `0` durante a criação?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1. `@@UNIQUE_CHECKS = 0`, `@@FOREIGN_KEY_CHECKS = 0`. O `@@SQL_MODE` contém ao menos `ONLY_FULL_GROUP_BY`, `STRICT_TRANS_TABLES`, `NO_ZERO_IN_DATE`, `NO_ZERO_DATE`, `ERROR_FOR_DIVISION_BY_ZERO`, `NO_ENGINE_SUBSTITUTION`.

2. Em uma instalação padrão do MySQL 8, antes do roteiro `@@UNIQUE_CHECKS` e `@@FOREIGN_KEY_CHECKS` valem `1` — então `@OLD_UNIQUE_CHECKS = 1` e `@OLD_FOREIGN_KEY_CHECKS = 1`. São importantes porque, ao final do script, o ideal é **restaurar** com `SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;` etc., devolvendo a sessão ao estado original.

---

### Parte 2

3. Tabela:

| Pergunta | Resposta |
|----------|----------|
| Quantas tabelas existem? | 3 (`Cliente`, `TipoConta`, `Conta`) |
| Quantas chaves primárias simples (1 coluna) existem? | 2 (`Cliente.idCliente` e `TipoConta.idTipoConta`) |
| Quantas chaves primárias compostas existem? | 1 (`Conta` — 3 colunas) |
| Quantas chaves estrangeiras existem? | 2 (em `Conta`: para `Cliente` e para `TipoConta`) |
| Em qual tabela existe um atributo `FLOAT`? | `Conta` (`saldo FLOAT`) |

4. * Cliente ↔ Conta: "Cada **cliente** pode ter **várias** contas, e cada **conta** pertence a um único **cliente**".
* TipoConta ↔ Conta: "Cada **tipo de conta** pode ser usado por **várias** contas, e cada **conta** tem um único **tipo de conta**".

5. **`idCliente` e `idTipoConta` são `AUTO_INCREMENT`** porque são **chaves substitutas** ("surrogate keys") — o sistema precisa de algum identificador único, mas o valor concreto não tem significado de negócio (o cliente "1" não é especial, é só "o primeiro registrado"). Já **`NroConta` é um valor de negócio** (número da conta no banco), atribuído por regras externas — não pode ser apenas "o próximo da sequência".

---

### Parte 3

6. * **Criar a tabela `Conta` antes de `Cliente` existir:** sim, com `FOREIGN_KEY_CHECKS=0`, é possível. Sem o flag, o MySQL recusa porque a referência aponta para uma tabela inexistente.
* **Inserir linha em `Conta` apontando para `idCliente` inexistente:** sim, com o flag em `0`, é aceito. O risco é deixar o banco em estado **inconsistente** — quando o flag voltar a `1`, novas operações continuam funcionando, mas a integridade já foi quebrada.

7. Riscos: **(1)** dados inconsistentes podem ser inseridos sem o MySQL reclamar, levando a "filhos órfãos" (registros que apontam para pais inexistentes). **(2)** Operações `DELETE`/`UPDATE` que normalmente seriam bloqueadas por `RESTRICT`/`NO ACTION` passam a ser executadas, possivelmente "quebrando" relacionamentos críticos.

8. Sem `STRICT_TRANS_TABLES`, o `INSERT` com `NomeCli = NULL` em uma coluna `NOT NULL` resultaria em **um aviso (warning) e um valor "padrão" silencioso** (string vazia ou similar) — comportamento perigoso. **Com** `STRICT_TRANS_TABLES`, o MySQL **rejeita** com erro `ER_BAD_NULL_ERROR`. Para sistemas profissionais, queremos sempre o erro.

9. Porque a sessão pode estar sendo usada para outras coisas além desse script. Se simplesmente sobrescrevêssemos os valores, ao final do script a sessão ficaria com os flags do Workbench — possivelmente diferentes do que o usuário tinha antes. O padrão `@OLD_X = @@X` permite **rastrear o estado original** e, ao final, executar `SET X = @OLD_X` para reverter.

---

### Parte 4

10. Com `FOREIGN_KEY_CHECKS=1`, ao criar `Conta` antes de `Cliente`, o MySQL retornaria erro: "Cannot resolve table name". A solução tradicional seria criar primeiro `Cliente`, depois `TipoConta`, depois `Conta` — ordem importa. Com o flag em `0`, **a ordem é irrelevante** durante a criação. Isso é especialmente útil para scripts gerados automaticamente, que listam tabelas em ordem alfabética ou em ordem do diagrama.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Ler e interpretar um diagrama ER simples.  
✅ Justificar as cardinalidades observadas.  
✅ Explicar **por que** o Forward Engineering começa com 3 `SET`s.  
✅ Antecipar quando relaxar `FOREIGN_KEY_CHECKS` é prático e quando é perigoso.  

> 💡 *"Diagrama é a arquitetura. Script é a construção. SET é a fundação que ninguém vê — mas que sustenta tudo."*
