# Como Instalar o MySQL Workbench no Linux Mint / Ubuntu

O MySQL Workbench é uma interface gráfica oficial para gerenciar bancos de dados MySQL. Este tutorial cobre o download e instalação no Linux Mint / Ubuntu.

---

## 1. Acessar o site oficial

Acesse o site oficial do MySQL:

🔗 [https://www.mysql.com](https://www.mysql.com)

Navegue até **Downloads**:

🔗 [https://www.mysql.com/downloads/](https://www.mysql.com/downloads/)

---

## 2. Acessar a área de downloads da comunidade

Na página de downloads, clique em:

> **MySQL Community (GPL) Downloads »**

🔗 [https://dev.mysql.com/downloads/](https://dev.mysql.com/downloads/)

---

## 3. Selecionar o MySQL Workbench

Na lista de produtos, clique em **MySQL Workbench**:

🔗 [https://dev.mysql.com/downloads/workbench/](https://dev.mysql.com/downloads/workbench/)

---

## 4. Selecionar o sistema operacional

Na página do Workbench, você verá:

```
MySQL Workbench 8.0.46
Select Operating System:
```

Selecione **Ubuntu Linux** no menu dropdown.

---

## 5. Baixar o pacote correto

Escolha o pacote correspondente ao Ubuntu 24.04 (compatível com Linux Mint 22):

```
Ubuntu Linux 24.04 (x86, 64-bit), DEB Package
mysql-workbench-community_8.0.46-1ubuntu24.04_amd64.deb
```

Clique em **Download**.

---

## 6. Iniciar o download sem criar conta

Você será redirecionado para uma página pedindo login ou cadastro. Ignore e clique em:

> **No thanks, just start my download.**

O download do arquivo `.deb` começará automaticamente.

---

## 7. Instalar o arquivo .deb

Após o download terminar, abra o gerenciador de arquivos e navegue até a pasta **Downloads**.

Clique duas vezes no arquivo:

```
mysql-workbench-community_8.0.46-1ubuntu24.04_amd64.deb
```

O instalador gráfico abrirá automaticamente. Clique em **Instalar** e aguarde a conclusão.

> Se solicitado, confirme com a sua senha de usuário do sistema.

---

## 8. Abrir o MySQL Workbench

Após a instalação, procure por **MySQL Workbench** no menu de aplicativos e abra o programa.

Na tela inicial, você verá a conexão local já disponível:

```
Local instance MySQL
localhost:3306
```

Clique nela para conectar e começar a usar!

---

## Observações

- Certifique-se de que o **MySQL Server já está instalado e rodando** antes de usar o Workbench.
- O Workbench conecta automaticamente ao MySQL local instalado na sua máquina.
- Caso a conexão falhe, verifique se o serviço está ativo com `sudo systemctl status mysql`.


---

## Próximos Passos

➡️ [Configuração da Conexão no MySQL Workbench](./2-configConexao.md) — Como configurar o usuário e conectar ao banco
