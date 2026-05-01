# 📘 Bloco 7 — Gestão de Usuários e Privilégios

> **Duração estimada:** 40 minutos  
> **Objetivo:** Criar, listar, conceder privilégios, inspecionar e remover usuários no MySQL — operações de **DCL (Data Control Language)** que costumam aparecer pouco em sala.  
> **Modalidade:** Guiada, com **comandos exibidos explicitamente** — porque DCL avançado raramente é praticado em laboratório, vamos mostrar e explicar cada um.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Listado os usuários atualmente registrados no servidor MySQL.
- Criado um novo usuário (`rzampar`) com senha definida.
- Concedido **todos os privilégios** sobre todos os bancos para esse usuário.
- Listado os privilégios concedidos para conferir.
- Aplicado `FLUSH PRIVILEGES` (e entendido em que situações ele é necessário).
- Removido o usuário recém-criado.

> 💡 **Pré-requisito de permissão:** para executar todos os comandos abaixo, sua sessão MySQL precisa estar conectada como **`root`** (ou outro superusuário com privilégios de `CREATE USER` e `GRANT`).

---

## 💡 Antes de começar — todos os comandos deste bloco são "exibidos"

Diferente dos blocos anteriores, **neste bloco apresentamos os comandos completos**, com explicações detalhadas. Por quê? Porque comandos de DCL sobre usuários são pouco rotineiros em aulas práticas — alunos chegam ao final do curso sem nunca ter executado um `CREATE USER`. Vamos corrigir isso aqui.

---

## 🧭 Passo 1 — Listar os usuários atuais

Antes de criar um usuário, vale conhecer quem já existe. Os usuários ficam registrados na tabela do sistema **`mysql.user`**.

```sql
SELECT * FROM mysql.user;
```

**O que esperar:**
* O retorno tem **muitas colunas** (mais de 40), porque cada coluna representa um privilégio ou uma propriedade do usuário (nome, host, política de senha, plug-in de autenticação, etc.).
* Você verá usuários internos do MySQL como `mysql.session`, `mysql.sys`, `mysql.infoschema` — são contas reservadas para o próprio servidor. **Não as toque.**

> 💡 **Dica:** se quiser ver apenas os nomes e os hosts, simplifique:
> ```sql
> SELECT User, Host FROM mysql.user;
> ```

---

## 🧭 Passo 2 — Criar um novo usuário

Vamos criar um usuário fictício chamado **`rzampar`** que se conecta apenas a partir da máquina local (`localhost`), com a senha `12345@`.

```sql
CREATE USER 'rzampar'@'localhost' IDENTIFIED BY '12345@';
```

**Anatomia do comando:**

| Pedaço | Significado |
|--------|-------------|
| `CREATE USER` | Comando que registra um novo usuário no MySQL. |
| `'rzampar'` | Nome do usuário. **Sempre entre aspas simples.** |
| `@` | Separador entre o nome do usuário e o host. |
| `'localhost'` | Host de onde o usuário pode se conectar. `localhost` = só da máquina local; `'%'` = de qualquer lugar; `'192.168.1.10'` = só desse IP. |
| `IDENTIFIED BY '12345@'` | Define a senha em texto puro. **Aspas simples** ao redor da senha. |

> ⚠️ **Em produção, nunca use senhas como `12345@`.** Use senhas longas, geradas, e considere usar hashes (`IDENTIFIED WITH mysql_native_password BY '...'` ou autenticação LDAP/PAM).

> 💡 **`'rzampar'@'localhost'`** é tratado como um **par único** no MySQL — você pode ter `'rzampar'@'localhost'` e `'rzampar'@'%'` como **duas contas diferentes**, com permissões diferentes.

---

## 🧭 Passo 3 — Conceder privilégios ao novo usuário

O usuário foi criado, mas ainda **não pode fazer nada**. É necessário conceder privilégios explicitamente. Para fins didáticos, vamos dar **todos** os privilégios em **todos os bancos** — uma configuração de superusuário.

```sql
GRANT ALL PRIVILEGES ON *.* TO 'rzampar'@'localhost';
```

**Anatomia do comando:**

| Pedaço | Significado |
|--------|-------------|
| `GRANT` | Comando de concessão de privilégios. |
| `ALL PRIVILEGES` | Concede **todos** os privilégios disponíveis (`SELECT`, `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `DROP`, `ALTER`, etc.). |
| `ON *.*` | **Em todos os bancos** (primeiro `*`) e **todas as tabelas** (segundo `*`). |
| `TO 'rzampar'@'localhost'` | Para o usuário criado no passo anterior. |

> 💡 **Variações comuns:**
> * `GRANT SELECT, INSERT ON procs_armazenados.* TO 'usuario'@'host';` → só `SELECT` e `INSERT`, e só no banco `procs_armazenados`.
> * `GRANT SELECT ON procs_armazenados.LIVROS TO 'usuario'@'host';` → apenas `SELECT` na tabela `LIVROS`.

> ⚠️ **Em ambiente real, `ALL PRIVILEGES ON *.*` é equivalente a dar a chave-mestre.** Use somente para administradores.

---

## 🧭 Passo 4 — Conferir os privilégios concedidos

Para verificar exatamente quais privilégios um usuário possui:

```sql
SHOW GRANTS FOR 'rzampar'@'localhost';
```

**O que esperar:**

```
+---------------------------------------------------------------+
| Grants for rzampar@localhost                                  |
+---------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO `rzampar`@`localhost`          |
+---------------------------------------------------------------+
```

> 💡 Se houvesse `GRANT OPTION` (capacidade de o próprio `rzampar` conceder privilégios a outros), apareceria `WITH GRANT OPTION` no final.

> 💡 **Use sempre `SHOW GRANTS FOR …`** em vez de tentar "ler a tabela `mysql.user`" — a tabela tem dezenas de colunas booleanas e a interpretação manual é trabalhosa.

---

## 🧭 Passo 5 — `FLUSH PRIVILEGES` — quando é necessário?

```sql
FLUSH PRIVILEGES;
```

**O que ele faz:**
* Recarrega as tabelas de privilégios (`mysql.user`, `mysql.db`, `mysql.tables_priv`, etc.) **da memória**, garantindo que mudanças feitas diretamente nessas tabelas (com `INSERT`/`UPDATE`/`DELETE`) sejam reconhecidas.

**Quando é necessário?**

| Cenário | Precisa de `FLUSH PRIVILEGES`? |
|---------|------------------------------|
| `CREATE USER`, `GRANT`, `DROP USER`, `REVOKE` | ❌ **Não** — o MySQL já recarrega automaticamente. |
| `INSERT INTO mysql.user (...)` direto na tabela | ✅ **Sim** — sem isso, a alteração não é vista. |
| `UPDATE mysql.user SET Password = ... WHERE ...` direto | ✅ **Sim** — mesma razão. |

> 💡 **Boa prática:** mesmo sem ser obrigatório após `GRANT`, **executar `FLUSH PRIVILEGES`** depois de uma sequência de mudanças de privilégios é hábito comum entre DBAs — é um "cinto de segurança" barato.

---

## 🧭 Passo 6 — Remover o usuário

Para apagar o usuário criado:

```sql
DROP USER 'rzampar'@'localhost';
```

**Anatomia do comando:**

| Pedaço | Significado |
|--------|-------------|
| `DROP USER` | Comando que remove o usuário do servidor. |
| `'rzampar'@'localhost'` | A combinação usuário+host a ser removida. |

**O que acontece:**
* O usuário é removido de `mysql.user`.
* **Todos os privilégios** associados a ele (em qualquer banco/tabela) são revogados automaticamente.
* **Sessões abertas** desse usuário continuam funcionando até serem encerradas — mas novas conexões serão recusadas.

> ⚠️ **Sem confirmação.** O `DROP USER` é definitivo (mas pode ser refeito com `CREATE USER` novamente — só perde, claro, qualquer histórico de privilégios concedidos).

---

## 🧭 Passo 7 — Verificação final

Para confirmar a remoção:

```sql
SELECT User, Host FROM mysql.user WHERE User = 'rzampar';
```

**Esperado:** 0 linhas — o usuário sumiu.

E para confirmar que `LIVROS` continua intacta (a remoção do usuário não afeta dados):

```sql
SELECT * FROM LIVROS;
```

**Esperado:** as 4 linhas com os preços do Bloco 6 (`9786525223742` com `44.44`, `8888888888888` com `10.99`, e os outros dois inalterados).

---

## 📋 Resumo dos comandos

| Comando | Para quê |
|---------|----------|
| `SELECT * FROM mysql.user` | Ver todos os usuários cadastrados. |
| `CREATE USER 'nome'@'host' IDENTIFIED BY 'senha'` | Criar um novo usuário. |
| `GRANT ALL PRIVILEGES ON *.* TO 'nome'@'host'` | Conceder todos os privilégios em todos os bancos. |
| `SHOW GRANTS FOR 'nome'@'host'` | Listar os privilégios do usuário. |
| `FLUSH PRIVILEGES` | Recarregar tabelas de privilégios da memória. |
| `DROP USER 'nome'@'host'` | Remover o usuário do servidor. |

---

## ✏️ Atividade Prática

### 📝 Atividade 7 — DCL aplicado

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Listar usuários do servidor.
- Criar um segundo usuário e conceder privilégios mais restritos.
- Refletir sobre o princípio do menor privilégio.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco7.sql](./codigo-fonte/COMANDOS-BD-03-bloco7.sql)

---

## ✅ Resumo do Bloco 7

Neste bloco você executou os comandos de **DCL aplicado a usuários**:

- `SELECT * FROM mysql.user` — listar usuários.
- `CREATE USER` — criar um usuário.
- `GRANT ALL PRIVILEGES` — conceder privilégios.
- `SHOW GRANTS` — listar privilégios.
- `FLUSH PRIVILEGES` — recarregar tabelas de privilégios.
- `DROP USER` — remover o usuário.

---

## 🎯 Conceitos-chave para fixar

💡 **`'usuario'@'host'`** é um **par único** — `'rzampar'@'localhost'` ≠ `'rzampar'@'%'`.

💡 **`CREATE USER` cria a conta;** o **`GRANT` define o que ela pode fazer**. Sem `GRANT`, o usuário entra mas não acessa nada.

💡 **`SHOW GRANTS FOR …`** é a forma legível de auditar privilégios.

💡 **`FLUSH PRIVILEGES`** é necessário **só** após manipulação manual de `mysql.user` (`INSERT`/`UPDATE`/`DELETE` direto). Após `CREATE USER`/`GRANT`/`DROP USER`/`REVOKE`, é redundante (mas inofensivo).

💡 **`DROP USER`** revoga todos os privilégios automaticamente.

---

## ➡️ Próximos Passos

No Bloco 8 você vai resolver o **exercício integrador** — sem código guia, apenas requisitos. Você terá de aplicar tudo o que aprendeu nos sete blocos anteriores: criar uma tabela de auditoria, uma Trigger, uma SP transacional e validar com testes.

Acesse: [📁 Bloco 8](../Bloco8/README.md)

---

> 💭 *"Privilégio é responsabilidade transferida. Conceda só o necessário, nunca mais."*
