# Instalação do MySQL e MySQL Workbench

Escolha o seu sistema operacional e siga as instruções correspondentes.

---

## 📖 Conceitos Fundamentais

### O que é o MySQL?

O MySQL é um **SGBD (Sistema de Gerenciamento de Banco de Dados) Relacional** — o software responsável por armazenar, processar e organizar os dados. Ele roda como um serviço em segundo plano (localmente ou em nuvem) e, por padrão, é acessado via linha de comando. Sozinho, não possui interface gráfica.

### O que é o MySQL Workbench?

O MySQL Workbench é a **ferramenta visual oficial da Oracle** para interagir com o MySQL. Ele reúne em um único ambiente:

- **Editor SQL** — com realce de sintaxe e autocompletar para escrever e executar consultas.
- **Modelagem ER** — criação visual de diagramas de Entidade-Relacionamento com geração automática de código SQL (*Forward Engineering*).
- **Administração** — gerenciamento de usuários, backups, monitoramento de performance (CPU, conexões, I/O) e visualização de logs.

### MySQL vs. MySQL Workbench

Para simplificar: o MySQL é o **motor** e o Workbench é o **painel de controle**.

| Característica | MySQL (Servidor) | MySQL Workbench (Cliente) |
|---|---|---|
| Natureza | O banco de dados em si | Software de interface |
| Função | Armazena e processa os dados | Visualiza e manipula dados e estrutura |
| Interface | Linha de comando | Gráfica (menus, diagramas, tabelas) |
| Dependência | Funciona de forma independente | Requer um servidor MySQL para conectar |

> O MySQL funciona sem o Workbench, mas o Workbench não funciona sem o MySQL.

---

## 🪟 Windows

Instalação do **MySQL** e **MySQL Workbench** no Windows:

[![Instalar MySQL e MySQL Workbench no Windows](https://img.youtube.com/vi/a5ul8o76Hqw/0.jpg)](https://www.youtube.com/watch?v=a5ul8o76Hqw)

🔗 [https://www.youtube.com/watch?v=a5ul8o76Hqw](https://www.youtube.com/watch?v=a5ul8o76Hqw)

---

## 🍎 macOS

### MySQL

Instalação do **MySQL** no macOS:

[![Instalar MySQL no macOS](https://img.youtube.com/vi/gcXp4b-XIxw/0.jpg)](https://www.youtube.com/watch?v=gcXp4b-XIxw)

🔗 [https://www.youtube.com/watch?v=gcXp4b-XIxw](https://www.youtube.com/watch?v=gcXp4b-XIxw)

### MySQL Workbench

Instalação do **MySQL Workbench** no macOS:

[![Instalar MySQL Workbench no macOS](https://img.youtube.com/vi/eonNlFxcDKw/0.jpg)](https://www.youtube.com/watch?v=eonNlFxcDKw)

🔗 [https://www.youtube.com/watch?v=eonNlFxcDKw](https://www.youtube.com/watch?v=eonNlFxcDKw)

---

## 🐧 Linux Mint / Ubuntu

Para Linux Mint e Ubuntu, siga os tutoriais escritos disponíveis na pasta `linuxMint-Ubuntu`:

### 1. Instalação do MySQL

> Cobre a instalação completa do MySQL Community Server e configuração segura via terminal.

➡️ [Acessar tutorial de instalação do MySQL](linuxMint-Ubuntu/README.md)

### 2. Instalação do MySQL Workbench

> Cobre o download e instalação da interface gráfica oficial do MySQL.

➡️ [Acessar tutorial de instalação do MySQL Workbench](linuxMint-Ubuntu/1-instalacao_do_MySQL_Workbench_para_Linux_Mint-Ubuntu.md)

### 3. Configuração da Conexão no MySQL Workbench

> Cobre a criação de usuário e configuração da conexão no Workbench.

➡️ [Acessar tutorial de configuração da conexão](linuxMint-Ubuntu/2-configconexao.md)

---

> 💡 **Dica:** Independente do sistema operacional, após a instalação certifique-se de que o serviço do MySQL está ativo antes de usar o Workbench.
