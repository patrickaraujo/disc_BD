# Configurando a Conexão no MySQL Workbench

Após instalar o MySQL Workbench, ao abrir o programa e tentar conectar, pode aparecer o seguinte erro:

```
Cannot Connect to Database Server
Access denied for user 'root'@'localhost'
```

Isso acontece porque o MySQL Workbench tenta conectar usando **senha**, mas o root do MySQL no Linux usa autenticação pelo sistema operacional (`auth_socket`). A solução é criar um novo usuário com senha.

---

## 1. Criar um novo usuário no MySQL

Abra o terminal e entre no MySQL:

```bash
sudo mysql
```

Crie um novo usuário com senha:

```sql
CREATE USER 'aulasBD_UNISA'@'localhost' IDENTIFIED BY 'Unisa@2026';
```

Para exibir todos os usuários (opcional):

```sql
SELECT user, host FROM mysql.user;
```

Dê todos os privilégios ao usuário:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'aulasBD_UNISA'@'localhost' WITH GRANT OPTION;
```

Aplique as mudanças:

```sql
FLUSH PRIVILEGES;
```

Saia do MySQL:

```sql
exit
```

---

## 2. Configurar a conexão no MySQL Workbench

Abra o MySQL Workbench e na tela inicial, clique no **ícone de chave inglesa** ao lado da conexão **"Local instance 3306"** para editar.

Na janela **Manage Server Connections**, preencha os campos:

| Campo | Valor |
|---|---|
| Connection Name | Local instance 3306 |
| Connection Method | Standard (TCP/IP) |
| Hostname | localhost |
| Port | 3306 |
| Username | aulasBD_UNISA |

---

## 3. Salvar a senha

No campo **Password**, clique em **"Store in Keychain..."**.

Na janela que abrir, digite a senha:

```
Unisa@2026
```

Confirme clicando em **OK**. A senha ficará salva e não será pedida toda vez que conectar.

---

## 4. Testar a conexão

Clique em **"Test Connection"**. Se aparecer uma mensagem de sucesso, a conexão está configurada corretamente.

Clique em **Close** para fechar a janela de configuração e depois clique na conexão para entrar no banco de dados.

---

## Observações

- O usuário `root` não funciona diretamente no Workbench no Linux pois usa `auth_socket`.
- Sempre que precisar criar novos usuários, use o terminal com `sudo mysql`.
- Guarde bem o usuário e senha criados, pois serão necessários para acessar o Workbench.
