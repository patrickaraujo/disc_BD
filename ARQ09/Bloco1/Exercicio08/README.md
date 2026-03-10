# 📝 Exercício 08 — Praticando DCL no MySQL

> **Duração:** ~20 minutos  
> **Formato:** Individual  
> **Pré-requisito:** MySQL Workbench conectado ao MySQL Server  
> **Referência nos slides:** Exercício 07

---

## 🎯 Objetivo

Praticar os comandos DCL (Data Control Language) no MySQL: criar usuários, conceder e revogar permissões, consultar privilégios e remover usuários.

---

## 🖥️ Passo a Passo

Abra o **Query Editor** no Workbench (`Ctrl+T`) e execute os comandos abaixo, um por vez, observando o resultado de cada um.

### Parte A — Consultar usuários existentes

**1.** Consulte a lista de todos os usuários cadastrados no MySQL:
```sql
SELECT * FROM mysql.user;
```

> 💡 A tabela `mysql.user` é uma tabela de sistema que armazena as informações de todos os usuários do SGBD. Observe as colunas `Host` e `User`.

---

### Parte B — Criar um novo usuário

**2.** Crie um novo usuário local com senha:
```sql
CREATE USER 'seu_nome'@'localhost' IDENTIFIED BY '12345@';
```

> ⚠️ Substitua `seu_nome` pelo seu nome (sem acentos ou espaços). O `@'localhost'` indica que o usuário só pode se conectar localmente.

---

### Parte C — Conceder permissões

**3.** Conceda **todos** os privilégios ao novo usuário:
```sql
GRANT ALL PRIVILEGES ON *.* TO 'seu_nome'@'localhost';
```

**4.** Consulte os privilégios concedidos:
```sql
SHOW GRANTS FOR 'seu_nome'@'localhost';
```

> 💡 O `*.*` significa "todos os bancos e todas as tabelas". Em produção, você restringiria a um banco específico, por exemplo: `ON imobiliaria.*`.

---

### Parte D — Restringir permissões

**5.** Revogue todos os privilégios:
```sql
REVOKE ALL PRIVILEGES ON *.* FROM 'seu_nome'@'localhost';
```

**6.** Conceda apenas os privilégios de criação e leitura:
```sql
GRANT CREATE, SELECT ON *.* TO 'seu_nome'@'localhost';
```

**7.** Consulte novamente para confirmar a mudança:
```sql
SHOW GRANTS FOR 'seu_nome'@'localhost';
```

**8.** Efetive as mudanças no banco de dados:
```sql
FLUSH PRIVILEGES;
```

> 💡 O `FLUSH PRIVILEGES` recarrega as tabelas de permissões do MySQL. Em muitos cenários o MySQL aplica as alterações automaticamente, mas executar o FLUSH garante que tudo esteja atualizado.

---

### Parte E — Remover o usuário

**9.** Apague o usuário criado:
```sql
DROP USER 'seu_nome'@'localhost';
```

**10.** Confirme que o usuário foi removido:
```sql
SELECT User, Host FROM mysql.user;
```

✅ **Checkpoint:** O usuário que você criou não aparece mais na listagem.

---

## 🔍 O que observar

- A diferença entre `GRANT ALL PRIVILEGES` e `GRANT CREATE, SELECT` — o princípio do **menor privilégio** é fundamental em segurança de BD.
- O formato `'usuario'@'host'` identifica unicamente um usuário no MySQL.
- O comando `FLUSH PRIVILEGES` como boa prática após alterações de permissão.
- Em ambientes de produção, o DBA controla cuidadosamente quem tem acesso a cada banco.

---

## 📄 Gabarito

O script completo com todos os comandos está disponível em [`codigo-fonte/Gabarito_DCL.sql`](./codigo-fonte/Gabarito_DCL.sql).
