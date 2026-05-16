# 📘 Bloco 1 — Administração: Usuários e Privilégios

> **Duração estimada:** 45 minutos
> **Objetivo:** Aprender a criar e gerenciar **usuários** no MySQL, conceder e revogar **privilégios**, e aplicar o **princípio do menor privilégio** na concessão de acessos.
> **Modalidade:** Guiada — você executa cada passo do ciclo `CREATE USER → GRANT → REVOKE → GRANT específico → DROP`.

---

## 🎯 O que você vai construir neste bloco

Ao final deste bloco, você terá:

- Verificado e configurado o **`autocommit = 0`** (preparação de sessão para toda a ARQ14).
- Consultado a tabela administrativa **`mysql.user`** para listar usuários existentes.
- Criado o usuário **`rzampar@localhost`** com senha autenticada.
- Concedido **`ALL PRIVILEGES`** ao novo usuário (e entendido por que isso é **uma péssima prática em produção**).
- **Revogado** todos os privilégios e re-concedido **apenas o necessário** (`CREATE` e `SELECT`).
- Executado **`FLUSH PRIVILEGES`** para garantir que as mudanças se propaguem.
- Removido o usuário com **`DROP USER`**.

---

## 💡 Antes de começar — por que a ARQ14 abre por aqui?

Na **ARQ13**, construímos uma SP de transferência bancária com validação robusta. Mas deixamos duas perguntas em aberto:

| Pergunta | Onde será respondida |
|----------|----------------------|
| **Quem pode** chamar essa SP? Qualquer usuário do banco? | Bloco 1 desta aula (controle de **acesso**) |
| O que acontece se **duas sessões** tentam alterar a mesma conta **ao mesmo tempo**? | Blocos 2, 3 e 4 desta aula (controle de **concorrência**) |

Este bloco fecha a primeira lacuna. Os próximos fecham a segunda.

---

## 🧭 Passo 1 — Verificar e ajustar o `autocommit`

Antes de qualquer operação transacional, confirme que o `autocommit` está **desligado** (assim como fizemos na ARQ13):

```sql
SELECT @@autocommit;
```

| Retorno | Significado |
|---------|-------------|
| `1` | `autocommit` **ligado** — cada `INSERT/UPDATE/DELETE` é commitado automaticamente. **Indesejado** para esta aula. |
| `0` | `autocommit` **desligado** — você controla o `COMMIT`/`ROLLBACK` explicitamente. **Estado correto.** |

Se retornar `1`, desligue:

```sql
SET autocommit = 0;
```

> 💡 **Por que repetir o ajuste do `autocommit` no início de uma aula que fala de privilégios?** Porque cada **nova conexão** no Workbench começa com `autocommit = 1` por padrão. Em uma sessão antiga, o ajuste persiste; em uma nova, não. Como a partir do Bloco 2 vamos abrir **uma segunda conexão**, este lembrete é proativo.

---

## 🧭 Passo 2 — Inspecionar a tabela administrativa `mysql.user`

O MySQL mantém os usuários cadastrados na tabela **`mysql.user`**. Para listar:

```sql
SELECT * FROM mysql.user;
```

> ⚠️ Essa tabela **só é visível para usuários com privilégio administrativo** (tipicamente o `root`). Se você se logou com um usuário restrito, vai receber erro de permissão.

### O que olhar nessa tabela

| Coluna relevante | O que mostra |
|------------------|--------------|
| `User` | Nome do usuário (ex.: `root`, `mysql.sys`) |
| `Host` | De onde o usuário pode se conectar (`localhost`, `%`, IP específico) |
| `authentication_string` | **Hash** da senha (nunca a senha em texto claro) |
| `account_locked` | Se a conta está bloqueada (`Y`/`N`) |
| Várias colunas `*_priv` | Privilégios globais ativos (`Y` = concedido) |

> 💡 **Observação importante:** o MySQL identifica um usuário pelo **par `'usuario'@'host'`**, não apenas pelo nome. `'rzampar'@'localhost'` e `'rzampar'@'%'` são **dois usuários diferentes** do ponto de vista do MySQL — podem inclusive ter senhas e privilégios distintos.

---

## 🧭 Passo 3 — Criar um novo usuário

```sql
CREATE USER 'rzampar'@'localhost' IDENTIFIED BY '1234';
```

### Anatomia do comando

| Pedaço | O que faz |
|--------|-----------|
| `CREATE USER` | Cria a conta de usuário. |
| `'rzampar'` | Nome do usuário (use aspas simples). |
| `@'localhost'` | **Origem permitida** da conexão. `localhost` = apenas conexões a partir do próprio servidor. |
| `IDENTIFIED BY '1234'` | Define a **senha em texto claro** — o MySQL faz o hash automaticamente. |

> ⚠️ **Senha `'1234'` é didática, jamais use em produção.** Em ambiente real, use no mínimo 12 caracteres, com letras maiúsculas, minúsculas, números e símbolos.

### Possíveis variações do host

| Padrão | Significado |
|--------|-------------|
| `'usuario'@'localhost'` | Só conecta da própria máquina do servidor. |
| `'usuario'@'%'` | Conecta de **qualquer** host (curinga). Mais permissivo, mais arriscado. |
| `'usuario'@'192.168.1.50'` | Conecta apenas daquele IP específico. |
| `'usuario'@'%.empresa.com'` | Conecta de qualquer subdomínio. |

---

## 🧭 Passo 4 — Conceder TODOS os privilégios (a forma "preguiçosa")

```sql
GRANT ALL PRIVILEGES ON *.* TO 'rzampar'@'localhost';
```

### Anatomia do `GRANT`

| Pedaço | O que faz |
|--------|-----------|
| `GRANT ALL PRIVILEGES` | Concede **todos** os privilégios (`SELECT`, `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `DROP`, `ALTER`, `GRANT OPTION`, etc.) |
| `ON *.*` | Em **todos os schemas** e **todas as tabelas** (curinga duplo). |
| `TO 'rzampar'@'localhost'` | Destinatário. |

### Escopos possíveis no `ON`

| Escopo | Significado |
|--------|-------------|
| `ON *.*` | Todos os schemas e todas as tabelas. **Privilégios globais.** |
| `ON Financeiro.*` | Todas as tabelas do schema `Financeiro`. **Privilégios de schema.** |
| `ON Financeiro.Conta` | Apenas a tabela `Conta` do schema `Financeiro`. **Privilégios de tabela.** |
| `ON Financeiro.Conta(saldo)` | Apenas a coluna `saldo`. **Privilégios de coluna.** |

> ⚠️ **`GRANT ALL ON *.* ` é o equivalente a dar "chave mestra" para o usuário.** É a configuração mais perigosa possível: o usuário pode dropar bancos, criar outros usuários (via `GRANT OPTION`), ler dados sensíveis. Use **APENAS** em ambiente didático ou para contas de administração genuínas.

---

## 🧭 Passo 5 — Inspecionar os privilégios concedidos

```sql
SHOW GRANTS FOR 'rzampar'@'localhost';
```

Saída esperada (algo parecido com):

```
GRANT ALL PRIVILEGES ON *.* TO `rzampar`@`localhost`
```

> 💡 `SHOW GRANTS` lista as **linhas de `GRANT`** que reproduzem o estado atual de privilégios do usuário. É a forma canônica de auditar permissões.

---

## 🧭 Passo 6 — Revogar privilégios

Agora aplicamos o **princípio do menor privilégio**: removemos tudo e re-concedemos apenas o necessário.

```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'rzampar'@'localhost';
```

| Pedaço | O que faz |
|--------|-----------|
| `REVOKE ALL PRIVILEGES` | Remove todos os privilégios funcionais. |
| `, GRANT OPTION` | **Adicionalmente**, remove o direito de o usuário conceder privilégios a outros. Sem isso, o `GRANT OPTION` fica órfão. |
| `FROM 'rzampar'@'localhost'` | Destinatário. |

Confirme com `SHOW GRANTS` que o usuário agora só tem `USAGE` (que é "sem privilégios reais, só pode logar").

---

## 🧭 Passo 7 — Conceder apenas o necessário

Imagine que `rzampar` é um analista de relatórios: precisa **ler** dados e **criar** suas próprias tabelas de trabalho, mas **não** alterar dados existentes.

```sql
GRANT CREATE, SELECT ON *.* TO 'rzampar'@'localhost';
```

Re-confirme:

```sql
SHOW GRANTS FOR 'rzampar'@'localhost';
```

Agora a saída mostra apenas `GRANT SELECT, CREATE ON *.* TO …`.

> 💡 **Princípio do menor privilégio:** dê **somente** as permissões necessárias para a função do usuário. Se ele só lê, não pode escrever. Se só usa um schema, não vê outros. Reduz a superfície de ataque em caso de credencial vazada.

---

## 🧭 Passo 8 — Efetivar mudanças com `FLUSH PRIVILEGES`

```sql
FLUSH PRIVILEGES;
```

> 💡 **Quando isso é necessário?** Quando você altera as tabelas de privilégio (`mysql.user`, `mysql.db`, etc.) **diretamente via `UPDATE`/`INSERT`** — o MySQL cacheia privilégios em memória e o `FLUSH` força a releitura.
>
> **Para `GRANT` e `REVOKE` "normais", não é estritamente necessário** — esses comandos já fazem o flush internamente. Mas executar `FLUSH PRIVILEGES` por garantia é uma boa prática que aparece em quase todo material didático e roteiro de produção.

---

## 🧭 Passo 9 — Apagar o usuário

```sql
DROP USER 'rzampar'@'localhost';
```

Pronto — a conta `rzampar@localhost` deixa de existir. Se houvesse outras combinações (`rzampar@%`, `rzampar@192.168.1.50`), **continuariam existindo** — cada par `usuario@host` é uma conta separada, lembra?

---

## 📋 Resumo do ciclo completo de gerenciamento

```
   ┌─────────────────┐
   │   CREATE USER   │  cria a conta com senha
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │     GRANT       │  concede privilégios
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │   SHOW GRANTS   │  audita
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │     REVOKE      │  remove (parcial ou total)
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │   GRANT (novo)  │  re-concede o mínimo necessário
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ FLUSH PRIVILEGES│  força propagação
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │   DROP USER     │  remove a conta
   └─────────────────┘
```

---

## ✏️ Atividade Prática

### 📝 Atividade 1 — Gerenciando o ciclo de privilégios

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Criar dois usuários (um "leitor" e um "analista").
- Conceder permissões diferenciadas a cada um.
- Inspecionar `mysql.user` e `SHOW GRANTS`.
- Refletir sobre o princípio do menor privilégio em cenários reais.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa.**

➡️ [codigo-fonte/COMANDOS-BD-04-bloco1.sql](./codigo-fonte/COMANDOS-BD-04-bloco1.sql)

---

## ✅ Resumo do Bloco 1

Neste bloco você:

- Configurou `autocommit = 0` para a sessão.
- Inspecionou `mysql.user` e entendeu o par `'usuario'@'host'`.
- Executou o ciclo completo: `CREATE USER → GRANT → SHOW GRANTS → REVOKE → GRANT específico → DROP`.
- Aprendeu **escopos de privilégio** (`*.*`, `db.*`, `db.tabela`, `db.tabela(col)`).
- Aplicou o **princípio do menor privilégio** na prática.

---

## 🎯 Conceitos-chave para fixar

💡 **Usuário no MySQL = par `'nome'@'host'`** — não apenas o nome.

💡 **`GRANT ALL ON *.*`** é o equivalente a uma chave mestra — evite em produção.

💡 **Princípio do menor privilégio**: conceda apenas o necessário para a função.

💡 **`SHOW GRANTS`** é a ferramenta canônica de auditoria de permissões.

💡 **`FLUSH PRIVILEGES`** é redundante após `GRANT/REVOKE`, mas é prática defensiva.

---

## ➡️ Próximos Passos

Você já controla **quem pode** acessar o banco. Mas o que acontece quando **duas sessões** desse mesmo usuário (ou usuários diferentes) tentam alterar a **mesma tabela ao mesmo tempo**? Esse é o tema dos Blocos 2 e 3. Antes de avançar, abra **duas conexões** no Workbench — vamos precisar das duas.

Acesse: [📁 Bloco 2](../Bloco2/README.md)

---

> 💭 *"Conceder privilégio é fácil. Revogar sem quebrar nada é onde mora a competência."*
