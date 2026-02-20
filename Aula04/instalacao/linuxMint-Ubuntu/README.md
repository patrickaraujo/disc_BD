# Como Instalar o MySQL no Linux Mint / Ubuntu

Este tutorial cobre a instalação completa e configuração segura do MySQL Community Server no Linux Mint e Ubuntu.

---

## 1. Atualizar os pacotes do sistema

Antes de instalar qualquer coisa, atualize a lista de pacotes:

```bash
sudo apt update
```

---

## 2. Instalar o MySQL Server

```bash
sudo apt install mysql-server
```

Aguarde o download e a instalação terminar.

---

## 3. Verificar se o MySQL está rodando

```bash
sudo systemctl status mysql
```

A saída deve mostrar algo assim:

```
● mysql.service - MySQL Community Server
     Active: active (running)
     Status: "Server is operational"
```

Se estiver **active (running)** e **"Server is operational"**, o MySQL foi instalado com sucesso. Pressione `q` para sair dessa tela.

---

## 4. Executar o script de segurança

O MySQL vem com um script que ajuda a proteger a instalação:

```bash
sudo mysql_secure_installation
```

### Respostas recomendadas para cada pergunta:

**Validate Password Component?**
```
Would you like to setup VALIDATE PASSWORD component? (y/N): N
```
> Recomendado `N` para ambientes de desenvolvimento. Escolha `Y` apenas se quiser forçar senhas complexas.

**Remove anonymous users?**
```
Remove anonymous users? (y/N): Y
```
> Sempre recomendado. Remove usuários sem conta definida.

**Disallow root login remotely?**
```
Disallow root login remotely? (y/N): Y
```
> Impede acesso remoto com o usuário root. Mantenha `Y` por segurança.

**Remove test database?**
```
Remove test database and access to it? (y/N): Y
```
> Remove o banco de dados de teste padrão, que não tem utilidade prática.

**Reload privilege tables?**
```
Reload privilege tables now? (y/N): Y
```
> Aplica todas as alterações imediatamente. Sempre responda `Y`.

---

## 5. Acessar o MySQL

No Linux Mint/Ubuntu, o usuário root do MySQL usa autenticação pelo sistema operacional (`auth_socket`), então não é necessário senha — basta usar `sudo`:

```bash
sudo mysql -u root -p
```

Quando pedir a senha, pressione **Enter** (deixe em branco).

Se tudo estiver certo, você verá o prompt do MySQL:

```
Welcome to the MySQL monitor. Commands end with ; or \g.
mysql>
```

---

## 6. Comandos básicos para começar

Dentro do prompt `mysql>`, você pode usar os seguintes comandos:

| Comando | Descrição |
|---|---|
| `SHOW DATABASES;` | Lista todos os bancos de dados |
| `CREATE DATABASE nome;` | Cria um novo banco de dados |
| `USE nome;` | Seleciona um banco de dados |
| `SHOW TABLES;` | Lista as tabelas do banco selecionado |
| `exit` | Sai do MySQL |

> **Importante:** Todo comando SQL deve terminar com `;`

---

## Observações

- A versão instalada por padrão via `apt` é o **MySQL 8.0**.
- Para instalar uma versão específica (como MySQL 9.x), é necessário adicionar o repositório oficial da Oracle.
- Para uso em produção, considere criar usuários específicos em vez de usar o root.
