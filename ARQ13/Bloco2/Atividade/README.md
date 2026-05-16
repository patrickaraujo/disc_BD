# 🧠 Atividade 2 — Tabelas-Catálogo

> **Duração:** 20 minutos  
> **Formato:** Individual  
> **Objetivo:** Verificar a criação correta das tabelas e fixar o comportamento de `AUTO_INCREMENT` em situações reais.

---

## 📋 Parte 1 — Execução e Inspeção

11. Execute:

```sql
SHOW CREATE TABLE Cliente;
```

Localize, no retorno, a cláusula `AUTO_INCREMENT=`. Que valor aparece? Por quê?

12. Execute:

```sql
SELECT * FROM Cliente;
SELECT * FROM TipoConta;
```

Confirme: em cada tabela, há **2 linhas**. Os ids são `1` e `2`?

13. Execute:

```sql
SELECT TABLE_NAME, ENGINE, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Financeiro';
```

Quais valores aparecem na coluna `AUTO_INCREMENT` de cada tabela? O que esse valor representa?

---

## 📋 Parte 2 — Comportamento de AUTO_INCREMENT

14. Faça **um experimento mental** (não execute ainda):

```sql
START TRANSACTION;
INSERT INTO Cliente (NomeCli) VALUES ('JOÃO TESTE');
ROLLBACK;
INSERT INTO Cliente (NomeCli) VALUES ('MARIA TESTE');
SELECT idCliente, NomeCli FROM Cliente WHERE NomeCli LIKE '%TESTE%';
```

Que valor de `idCliente` você espera que `MARIA TESTE` receba? **`3`** (continuando a sequência) ou **`4`** (porque o `INSERT` de João consumiu uma sequência mesmo após `ROLLBACK`)? Justifique.

15. Agora execute o experimento da questão 14 e relate o que aconteceu. Combina com a sua previsão?

16. Após o experimento, restaure a tabela `Cliente` apagando o registro de teste:

```sql
DELETE FROM Cliente WHERE NomeCli LIKE '%TESTE%';
COMMIT;
```

Verifique que a tabela voltou a ter apenas os 2 clientes originais. O `idCliente` da `MARIA TESTE` foi **liberado** ou **consumido permanentemente**?

---

## 📋 Parte 3 — Questões Conceituais

17. Por que **não devemos** especificar valor para uma coluna `AUTO_INCREMENT` em um `INSERT` típico? O que aconteceria se você fizesse `INSERT INTO Cliente (idCliente, NomeCli) VALUES (10, 'Z');`?

18. Imagine que você quer adicionar uma coluna `email` na tabela `Cliente`, do tipo `VARCHAR(80)`, **única**. Qual comando SQL você usaria? (Pense em `ALTER TABLE … ADD COLUMN`.)

19. As duas tabelas deste bloco — `Cliente` e `TipoConta` — têm estrutura idêntica em forma. Em que aspectos elas diferem **conceitualmente** (não na estrutura)?

20. A tabela `TipoConta` provavelmente nunca terá milhões de linhas — apenas algumas dezenas. Já a tabela `Cliente` pode crescer indefinidamente. Em qual delas o tipo `INT` é "exagero" e poderia ser substituído por `TINYINT`? Justifique.

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

11. Aparece `AUTO_INCREMENT=3` (em uma instalação típica). É o **próximo valor** que será atribuído ao próximo `INSERT`. Como já há 2 linhas com ids `1` e `2`, o próximo seria `3`.

12. Sim, em ambas há 2 linhas com `id = 1` e `id = 2`.

13. Em `information_schema.TABLES`, a coluna `AUTO_INCREMENT` mostra o **valor seguinte** a ser usado. Tipicamente: `Cliente.AUTO_INCREMENT = 3`, `TipoConta.AUTO_INCREMENT = 3`. (Para `Conta`, será `NULL` — você criará no Bloco 3 sem `AUTO_INCREMENT`.)

---

### Parte 2

14. Espera-se **`4`**. Por quê? Porque `AUTO_INCREMENT` no MySQL **consome a sequência mesmo em `ROLLBACK`**. O `INSERT` de João incrementou o contador interno para `3`, mas o `ROLLBACK` removeu a linha — o contador **não retrocede**. O próximo `INSERT` (Maria) recebe `4`.

15. Confirmação: `MARIA TESTE` aparece com `idCliente = 4`. (Também pode aparecer com outro valor maior, se a sessão tiver feito outros `INSERT`s entre os experimentos.)

16. Após o `DELETE`, a tabela volta a ter apenas os 2 originais. O id `3` (que foi atribuído ao João revertido) e o id `4` (atribuído à Maria deletada) **foram permanentemente consumidos** — nunca serão reutilizados. Esse é um comportamento intencional do MySQL para garantir unicidade absoluta de identificadores em ambientes concorrentes.

---

### Parte 3

17. Porque o sistema é responsável por garantir unicidade — você intervir manualmente abre risco de **conflitos** (dois clientes com mesmo id) ou **lacunas inesperadas** na sequência. Se você fizer `INSERT … VALUES (10, 'Z')`, o MySQL aceita (já que `10` não está em uso), e o **próximo `AUTO_INCREMENT` salta para `11`** — você "consumiu" os ids 3 a 10 sem usá-los.

18. Comando esperado: `ALTER TABLE Cliente ADD COLUMN email VARCHAR(80) UNIQUE;` (também aceita `ADD CONSTRAINT uk_email UNIQUE (email)` em separado).

19. **`Cliente`** representa **pessoas reais** (entidades do mundo) — cresce com o negócio, recebe novos registros constantemente. **`TipoConta`** representa **categorias estáticas** (tipos definidos pelo banco/sistema) — quase nunca muda; é controlada por administradores. Conceitualmente: uma é **transacional**, a outra é **referencial/metadados**.

20. **`TipoConta`** pode ter `idTipoConta TINYINT` (até 127 valores positivos) ou `SMALLINT` — bem mais que suficiente para tipos de conta. Em `Cliente`, manter `INT` é prudente (cobre até ~2,1 bilhões; até `BIGINT` para sistemas globais). Essa otimização tem ganho prático mínimo em uma tabela com 2 linhas, mas em desenhos de centenas de tabelas, escolher tipo certo economiza espaço de armazenamento e melhora performance de índices.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Diferenciar tabelas **transacionais** (que crescem com o negócio) e **referenciais** (catálogos).  
✅ Justificar por que `AUTO_INCREMENT` "consome" valores em rollback.  
✅ Antecipar implicações da escolha de tipo (`INT` vs `TINYINT`).  

> 💡 *"Catálogo bem desenhado é simples — mas é a base que sustenta toda a complexidade do sistema."*
