# 🧠 Atividade 7 — DCL aplicado

> **Duração:** 25 minutos  
> **Formato:** Individual  
> **Objetivo:** Fixar a sintaxe e a semântica dos comandos `CREATE USER`, `GRANT`, `SHOW GRANTS`, `FLUSH PRIVILEGES` e `DROP USER`, e refletir sobre boas práticas de segurança.

> ⚠️ **Atenção:** os comandos abaixo precisam ser executados como **`root`** (ou outro superusuário). Se você estiver conectado como um usuário comum, primeiro reabra a conexão como administrador.

---

## 📋 Parte 1 — Execução

61. Liste **apenas** os campos `User` e `Host` da tabela `mysql.user`. Quantos usuários aparecem? Cite os nomes que você vê.

62. Crie um novo usuário **`aluno_leitura`** que se conecta a partir de `localhost`, com a senha `senha_segura@2025`.

63. Conceda a esse usuário **somente** o privilégio `SELECT` no banco `procs_armazenados` (não use `*.*`):

```sql
GRANT SELECT ON procs_armazenados.* TO 'aluno_leitura'@'localhost';
```

64. Liste os privilégios concedidos a `'aluno_leitura'@'localhost'`. O que aparece?

65. Apague o usuário com `DROP USER`. Em seguida, liste novamente os usuários (questão 61) e confirme que `aluno_leitura` sumiu.

---

## 📋 Parte 2 — Questões Conceituais

66. Por que `'rzampar'@'localhost'` e `'rzampar'@'%'` podem ter privilégios diferentes? Em que cenário você criaria as duas contas?

67. Qual a diferença prática entre os dois `GRANT`s abaixo?

```sql
GRANT ALL PRIVILEGES ON *.* TO 'usuario1'@'localhost';
GRANT SELECT, INSERT ON procs_armazenados.LIVROS TO 'usuario2'@'localhost';
```

Qual deles representa melhor o **princípio do menor privilégio**?

68. Suponha que você tenha executado, por engano, um `INSERT` direto na tabela `mysql.user` (em vez de `CREATE USER`). O `FLUSH PRIVILEGES` se torna **necessário**? Por quê?

69. Após um `DROP USER 'fulano'@'localhost'`, o que acontece com:
* As **sessões abertas** desse usuário no momento do drop?
* As **novas tentativas de conexão** desse usuário?
* Os **dados** que esse usuário criou (tabelas, registros)?

70. Por que `SHOW GRANTS FOR 'usuario'@'host'` é preferível a tentar interpretar diretamente as colunas da tabela `mysql.user`?

---

## 📋 Parte 3 — Princípio do Menor Privilégio

71. Para cada um dos perfis abaixo, sugira um conjunto de privilégios mínimos:

| Perfil | Comandos `GRANT` que você concederia |
|--------|--------------------------------------|
| **Aplicação web (front-end de loja)** — só lê catálogo de produtos | _____ |
| **Sistema de checkout** — insere pedidos e itens, atualiza estoque | _____ |
| **DBA junior** — administra tabelas e índices, mas não cria usuários | _____ |
| **DBA sênior / superusuário** | _____ |

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

61. Em uma instalação padrão do MySQL 8, aparecem (entre outros):
* `'mysql.session'@'localhost'`, `'mysql.sys'@'localhost'`, `'mysql.infoschema'@'localhost'` (contas internas).
* `'root'@'localhost'` (administrador padrão).

O número total varia — geralmente entre 4 e 7 usuários após uma instalação limpa.

62. Comando esperado:
```sql
CREATE USER 'aluno_leitura'@'localhost' IDENTIFIED BY 'senha_segura@2025';
```

63. Comando dado no enunciado.

64. Resultado esperado:
```
+------------------------------------------------------------+
| Grants for aluno_leitura@localhost                          |
+------------------------------------------------------------+
| GRANT USAGE ON *.* TO `aluno_leitura`@`localhost`           |
| GRANT SELECT ON `procs_armazenados`.* TO `aluno_leitura`…   |
+------------------------------------------------------------+
```

`USAGE ON *.*` é o privilégio "vazio" automático de qualquer usuário criado — significa "pode se conectar, mas não pode fazer mais nada por padrão".

65. `DROP USER 'aluno_leitura'@'localhost';` → após o drop, o `SELECT User, Host FROM mysql.user;` deve mostrar **0 linhas** com `User = 'aluno_leitura'`.

---

### Parte 2

66. Porque o MySQL trata `'rzampar'@'localhost'` e `'rzampar'@'%'` como **duas contas distintas**. **Cenário:** o mesmo desenvolvedor pode acessar o banco localmente (com privilégios completos durante o desenvolvimento) e remotamente (com privilégios apenas de leitura, por motivos de segurança).

67. **Diferenças:**
* `usuario1` recebe **todos os privilégios** em **todos os bancos e tabelas** — pode criar/dropar bancos, alterar tabelas do sistema, criar outros usuários, etc.
* `usuario2` recebe **apenas `SELECT` e `INSERT`** em **uma única tabela** (`LIVROS` do banco `procs_armazenados`) — não pode `UPDATE`, `DELETE`, alterar estrutura nem acessar outras tabelas.

O segundo é o **princípio do menor privilégio**: conceda **só o necessário**, nada mais. Se a aplicação é comprometida, o atacante herda apenas o que aquele usuário podia fazer — limitando o estrago.

68. **Sim, necessário.** Quando você manipula `mysql.user` por `INSERT`/`UPDATE`/`DELETE`, o servidor **não recarrega automaticamente** as tabelas de privilégios em memória. O `FLUSH PRIVILEGES` força essa recarga, fazendo a alteração ter efeito. Após `CREATE USER`/`GRANT`/`DROP USER`/`REVOKE`, o servidor já recarrega sozinho — `FLUSH` é redundante (mas inofensivo).

69. * **Sessões abertas:** continuam funcionando até serem encerradas (não são derrubadas instantaneamente). Mas qualquer comando que dependa dos privilégios revogados pode começar a falhar.
* **Novas tentativas de conexão:** são imediatamente recusadas (usuário não existe mais).
* **Dados criados:** **não são afetados**. Tabelas, linhas, índices, etc., permanecem intactos. O `DROP USER` afeta a **conta**, não os dados.

70. Porque `mysql.user` tem **dezenas de colunas booleanas** (uma para cada privilégio possível) e **mais de uma tabela** envolvida (`mysql.user`, `mysql.db`, `mysql.tables_priv`, `mysql.columns_priv`). Interpretar isso manualmente é trabalhoso e propenso a erro. O `SHOW GRANTS` consolida tudo em uma forma **legível e idêntica à sintaxe do `GRANT`** — você lê o privilégio do usuário do mesmo jeito que o concederia.

---

### Parte 3

71. Sugestões:

| Perfil | Comandos `GRANT` mínimos |
|--------|--------------------------|
| **App web (catálogo)** | `GRANT SELECT ON loja.Produtos TO 'app_catalogo'@'%';` |
| **Sistema de checkout** | `GRANT SELECT, INSERT, UPDATE ON loja.Pedido TO 'app_checkout'@'%';` + similar para `ItemPedido` e `Produtos` (apenas `UPDATE` em `Produtos.QTDESTOQUE`). Idealmente, conceder `EXECUTE` em SPs específicas em vez de DML direto. |
| **DBA junior** | `GRANT ALL PRIVILEGES ON loja.* TO 'dba_junior'@'%';` (no banco específico, sem privilégios em `mysql.*` ou outros bancos críticos). |
| **DBA sênior** | `GRANT ALL PRIVILEGES ON *.* TO 'dba_senior'@'localhost' WITH GRANT OPTION;` |

> 💡 Outras boas práticas: usar `EXECUTE` em SPs em vez de DML direto (encapsular regras de negócio), restringir `Host` quando possível, e sempre evitar `'%'` em produção quando o `Host` puder ser determinado.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Criar, listar, conceder privilégios e remover usuários no MySQL.  
✅ Distinguir quando `FLUSH PRIVILEGES` é necessário e quando é apenas hábito.  
✅ Aplicar o **princípio do menor privilégio** — conceder só o que a aplicação realmente precisa.  

> 💡 *"O usuário mais seguro do banco é aquele que só pode fazer **uma** coisa. O mais perigoso é aquele que pode fazer **tudo** — e que esquecemos de remover."*
