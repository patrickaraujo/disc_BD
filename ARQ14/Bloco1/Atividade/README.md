# 🧠 Atividade 1 — Gerenciando o Ciclo de Privilégios

> **Duração:** 30 minutos
> **Formato:** Individual
> **Objetivo:** Praticar o ciclo completo de gerenciamento de usuários (`CREATE`, `GRANT`, `REVOKE`, `DROP`) com dois perfis distintos e refletir sobre o princípio do menor privilégio.

---

## 📋 Parte 1 — Sessão e inspeção inicial

1. Verifique o valor atual de `@@autocommit`. Caso esteja em `1`, desligue-o. Anote o valor inicial: _____

2. Execute `SELECT * FROM mysql.user;` e identifique:
   * Quantos usuários **distintos** (combinações `User@Host`) existem? _____
   * Existe algum usuário com `Host = '%'` (curinga)? Quem? _____
   * Algum usuário tem `account_locked = 'Y'`? Quem? _____

3. Por que o MySQL identifica usuário pelo **par `'nome'@'host'`** em vez de apenas pelo nome? Cite **uma situação** em que essa distinção é útil.

---

## 📋 Parte 2 — Criando dois perfis de usuário

Você vai criar **dois usuários** com perfis diferentes:

* **`leitor_rel'@'localhost`** — analista de relatórios. Senha: `'r3l4t'`.
  * Precisa apenas **ler** dados de qualquer schema.
* **`dev_app'@'localhost`** — desenvolvedor de aplicação. Senha: `'d3v4pp'`.
  * Precisa de **CRUD completo** (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) **apenas no schema `Financeiro`**.

4. Crie o usuário `leitor_rel@localhost`. Escreva o comando:

```sql
-- seu comando aqui
```

5. Crie o usuário `dev_app@localhost`. Escreva o comando:

```sql
-- seu comando aqui
```

6. Conceda **apenas `SELECT`** em todos os schemas para `leitor_rel`:

```sql
-- seu comando aqui
```

7. Conceda `SELECT`, `INSERT`, `UPDATE`, `DELETE` no schema `Financeiro` para `dev_app`:

```sql
-- seu comando aqui (lembre do escopo Financeiro.*)
```

8. Execute `SHOW GRANTS FOR …` para cada um. Cole abaixo o resultado:

* `leitor_rel`: _____
* `dev_app`: _____

---

## 📋 Parte 3 — Refletindo sobre os escopos

9. Por que **não** concedemos `GRANT ALL` para `dev_app`, mesmo que ele seja um "desenvolvedor de confiança"? Cite **dois riscos** que isso traria.

10. O `dev_app` tem permissão para criar **uma nova tabela** dentro do schema `Financeiro`? **Justifique** comparando os privilégios concedidos com os privilégios necessários.

11. Se `leitor_rel` tentar executar `UPDATE Conta SET saldo = 0`, qual seria a mensagem retornada pelo MySQL?

---

## 📋 Parte 4 — Revogando e re-concedendo

Suponha que `leitor_rel` foi promovido — agora ele também precisa **alterar** a tabela `Cliente` (apenas essa, do schema `Financeiro`).

12. Não revogue o `SELECT` global dele — apenas **adicione** o privilégio específico de `UPDATE` na tabela `Cliente`:

```sql
-- seu comando aqui (escopo: Financeiro.Cliente)
```

13. Execute `SHOW GRANTS FOR 'leitor_rel'@'localhost';`. Agora aparecem **duas linhas** de `GRANT`. Por quê?

14. Agora suponha que `leitor_rel` foi rebaixado novamente — ele perde o `UPDATE` em `Cliente`, mas mantém o `SELECT` global. Escreva o `REVOKE` correto:

```sql
-- seu comando aqui
```

15. **Reflexão:** por que o MySQL guarda os `GRANT`s em **linhas separadas por escopo** em vez de uma "lista única"? Pense em manutenção e auditoria.

---

## 📋 Parte 5 — Limpeza

16. Apague os dois usuários criados:

```sql
-- comando 1: dropar leitor_rel
-- comando 2: dropar dev_app
```

17. Confirme via `SELECT User, Host FROM mysql.user WHERE User IN ('leitor_rel', 'dev_app');`. O retorno deve ser **vazio**.

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1. Valor inicial varia por conexão. Se era `1`, foi alterado para `0` via `SET autocommit = 0;`.

2. Em uma instalação típica do MySQL 8, existem normalmente entre 4 e 6 usuários padrão: `root@localhost`, `mysql.infoschema@localhost`, `mysql.session@localhost`, `mysql.sys@localhost`. Algumas instalações têm `root@%` ou usuários adicionais criados pelo instalador. Os usuários `mysql.*` vêm com `account_locked = 'Y'` por padrão (são contas de sistema).

3. O par `usuario@host` permite:
   * Que o mesmo nome funcione com **regras diferentes** dependendo da origem (ex.: `'admin'@'localhost'` com senha forte, sem `admin@%` para evitar conexões externas).
   * Auditoria mais granular (quem fez algo **de onde**).
   * Bloqueio cirúrgico: derrubar `admin@%` sem afetar `admin@localhost`.

---

### Parte 2

4. `CREATE USER 'leitor_rel'@'localhost' IDENTIFIED BY 'r3l4t';`

5. `CREATE USER 'dev_app'@'localhost' IDENTIFIED BY 'd3v4pp';`

6. `GRANT SELECT ON *.* TO 'leitor_rel'@'localhost';`

7. `GRANT SELECT, INSERT, UPDATE, DELETE ON Financeiro.* TO 'dev_app'@'localhost';`

8. Saídas:
   * `leitor_rel`: `GRANT USAGE ON *.* TO ...` e `GRANT SELECT ON *.* TO ...`
   * `dev_app`: `GRANT USAGE ON *.* TO ...` e `GRANT SELECT, INSERT, UPDATE, DELETE ON Financeiro.* TO ...`
   * Observação: `USAGE` aparece sempre — significa "sem privilégios reais, apenas permissão de logar".

---

### Parte 3

9. Dois riscos de `GRANT ALL` para `dev_app`:
   * Se a credencial vazar, o atacante pode dropar bancos, criar usuários, ler dados sensíveis.
   * O desenvolvedor pode executar comandos destrutivos por engano (ex.: `DROP DATABASE` em vez de `DROP TABLE`).

10. **Não.** O `dev_app` tem apenas `SELECT, INSERT, UPDATE, DELETE` — falta o privilégio `CREATE`. Criar tabela requer `CREATE` no escopo do schema.

11. `ERROR 1142 (42000): UPDATE command denied to user 'leitor_rel'@'localhost' for table 'Conta'`

---

### Parte 4

12. `GRANT UPDATE ON Financeiro.Cliente TO 'leitor_rel'@'localhost';`

13. Porque cada `GRANT` é registrado **no escopo em que foi concedido**. O MySQL guarda:
    * `GRANT SELECT ON *.* TO 'leitor_rel'@'localhost'` (escopo global)
    * `GRANT UPDATE ON Financeiro.Cliente TO 'leitor_rel'@'localhost'` (escopo de tabela)
    Não há "unificação" porque os escopos são distintos — uma linha não substitui a outra.

14. `REVOKE UPDATE ON Financeiro.Cliente FROM 'leitor_rel'@'localhost';`

15. Manter `GRANT`s por escopo permite:
    * **Reversão cirúrgica**: revogar exatamente o que foi concedido sem afetar privilégios em outros escopos.
    * **Auditoria clara**: "este usuário tem `UPDATE` em quais tabelas exatamente?" — basta listar.
    * **Performance**: consulta de permissão checa o escopo mais específico primeiro.

---

### Parte 5

16. ```sql
    DROP USER 'leitor_rel'@'localhost';
    DROP USER 'dev_app'@'localhost';
    ```

17. Retorno vazio confirma a remoção.

---

## 💭 Reflexão Final

Após esta atividade, você deve ser capaz de:

✅ Aplicar o **princípio do menor privilégio** em cenários reais.
✅ Escolher o **escopo correto** (`*.*`, `db.*`, `db.tabela`) para cada concessão.
✅ Auditar permissões via `SHOW GRANTS` e `mysql.user`.
✅ Compreender por que o par `'usuario'@'host'` é a unidade fundamental do MySQL — e não apenas o nome.

> 💡 *"Em segurança, é mais fácil adicionar uma permissão depois do que descobrir, no dia seguinte ao incidente, que alguém tinha permissão demais."*
