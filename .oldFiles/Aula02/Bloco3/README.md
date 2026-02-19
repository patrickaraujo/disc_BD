# 📘 Bloco 3 — Instalação e Configuração do MySQL Community

> **Duração estimada:** 50 minutos  
> **Objetivo:** Instalar e configurar o ambiente MySQL para desenvolvimento

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Baixar o MySQL Community Server
- Instalar o MySQL no seu sistema operacional
- Configurar o MySQL Server
- Instalar o MySQL Workbench
- Realizar a primeira conexão
- Verificar se a instalação funcionou

---

## 💡 O que vamos instalar?

### MySQL Community Server

**O que é:**  
O SGBD MySQL propriamente dito — o servidor de banco de dados.

**Função:**
- Gerenciar bancos de dados
- Processar consultas SQL
- Armazenar dados

---

### MySQL Workbench

**O que é:**  
Interface gráfica para trabalhar com MySQL.

**Função:**
- Visualizar bancos de dados
- Escrever e executar SQL
- Administrar o servidor
- Modelar estruturas de dados

---

## 📥 Download

### Passo 1: Acessar o site oficial

🔗 **Site:** https://dev.mysql.com/downloads/

### Passo 2: Escolher o produto

Existem duas opções principais:

**Opção 1: MySQL Installer (Recomendado para Windows)**
- Instala tudo de uma vez
- Inclui MySQL Server + Workbench + outras ferramentas
- Link: https://dev.mysql.com/downloads/installer/

**Opção 2: Instalação separada**
- MySQL Server: https://dev.mysql.com/downloads/mysql/
- MySQL Workbench: https://dev.mysql.com/downloads/workbench/

💡 **Recomendação:** Use o MySQL Installer se estiver no Windows.

---

### Passo 3: Selecionar versão

**Versão recomendada:**  
MySQL 8.0.x (versão estável mais recente)

**Sistema Operacional:**  
Selecione seu SO (Windows, macOS, Linux)

**Arquitetura:**  
- 64-bit (x64) — mais comum
- 32-bit (x86) — computadores mais antigos

---

### Passo 4: Fazer o download

- Clique em "Download"
- Você pode criar conta ou clicar em "No thanks, just start my download"

---

## 🛠️ Instalação por Sistema Operacional

### Guias detalhados disponíveis:

Para instruções específicas do seu sistema operacional, consulte:

- [📁 Windows](./guia-instalacao/windows.md)
- [📁 Linux](./guia-instalacao/linux.md)
- [📁 macOS](./guia-instalacao/macos.md)

---

## ⚙️ Configuração Inicial Importante

### Durante a instalação, você precisará:

#### 1️⃣ Definir Senha do Root

**Root** é o usuário administrador principal do MySQL.

⚠️ **IMPORTANTE:**
- Escolha uma senha segura
- **ANOTE essa senha!** Você vai precisar dela sempre
- Não compartilhe com ninguém

**Sugestão para estudo:**  
Senha simples como `root123` (apenas em ambiente de aprendizado!)

---

#### 2️⃣ Configurar Tipo de Servidor

**Development Computer** (Recomendado para estudo)
- Usa menos recursos
- Ideal para desenvolvimento local

**Server Computer**
- Usa mais recursos
- Para servidores dedicados

**Dedicated Computer**
- Usa máximo de recursos
- Para servidores exclusivos de BD

💡 **Escolha:** Development Computer

---

#### 3️⃣ Porta do MySQL

**Porta padrão:** 3306

⚠️ **Mantenha a porta padrão** a menos que tenha conflito.

---

#### 4️⃣ Método de Autenticação

**Opções:**

**Use Strong Password Encryption (Recomendado)**
- Método mais seguro
- Padrão do MySQL 8.0

**Use Legacy Authentication**
- Compatibilidade com versões antigas
- Use apenas se necessário

💡 **Escolha:** Use Strong Password Encryption

---

## ✅ Verificando a Instalação

### Teste 1: MySQL está rodando?

**Windows:**
1. Abra "Serviços" (Win + R → `services.msc`)
2. Procure por "MySQL80" (ou sua versão)
3. Status deve estar: **Em execução**

**Linux:**
```bash
sudo systemctl status mysql
```

**macOS:**
```bash
sudo /usr/local/mysql/support-files/mysql.server status
```

---

### Teste 2: MySQL Workbench abre?

1. Abra o MySQL Workbench
2. Você deve ver a tela inicial com conexões

✅ **Se abriu, ótimo!**

---

### Teste 3: Consegue conectar?

1. No Workbench, clique na conexão "Local instance MySQL80"
2. Digite a senha do root
3. Deve abrir o ambiente de trabalho

✅ **Se conectou, instalação bem-sucedida!**

---

## 🔧 Resolução de Problemas Comuns

### Problema 1: "MySQL não inicia"

**Solução:**
- Windows: Reinicie o serviço MySQL80
- Linux: `sudo systemctl restart mysql`
- Verifique se a porta 3306 não está ocupada

---

### Problema 2: "Senha incorreta"

**Solução:**
- Verifique se digitou a senha corretamente
- Lembre-se: é case-sensitive
- Se esqueceu, precisará resetar a senha

---

### Problema 3: "Não consigo conectar"

**Checklist:**
- ✅ MySQL Server está rodando?
- ✅ Porta 3306 está correta?
- ✅ Firewall não está bloqueando?
- ✅ Senha está correta?

---

### Problema 4: "Connection timeout"

**Solução:**
- Verifique se o serviço MySQL está ativo
- Reinicie o computador
- Reinstale o MySQL se persistir

---

## 🎯 Configurações Recomendadas para Estudo

### Criar um usuário de desenvolvimento

Além do root, crie um usuário específico:

```sql
CREATE USER 'dev'@'localhost' IDENTIFIED BY 'dev123';
GRANT ALL PRIVILEGES ON *.* TO 'dev'@'localhost';
FLUSH PRIVILEGES;
```

💡 **Por quê?**  
É boa prática não usar root para tudo.

---

## 📋 Checklist Pós-Instalação

Marque conforme completar:

- [ ] MySQL Community Server instalado
- [ ] MySQL Workbench instalado
- [ ] Serviço MySQL rodando
- [ ] Senha do root anotada
- [ ] Primeira conexão bem-sucedida
- [ ] Ambientes testados

---

## ✅ Resumo do Bloco 3

Neste bloco você aprendeu:

- Como baixar o MySQL Community
- Processo de instalação
- Configurações iniciais importantes
- Como verificar se está funcionando
- Resolução de problemas comuns

---

## 🎯 Conceitos-chave para fixar

💡 **MySQL Server = SGBD (o gerenciador)**

💡 **MySQL Workbench = Interface gráfica**

💡 **Root = usuário administrador**

💡 **Porta 3306 = porta padrão do MySQL**

💡 **Development Computer = configuração para estudo**

---

## ➡️ Próximos Passos

No próximo bloco você vai aprender:

- Como navegar pelo MySQL Workbench
- Como criar seu primeiro schema (banco de dados)
- Como verificar estruturas criadas
- Primeiros comandos práticos

---

## 📚 Observações Importantes

🚫 **Neste bloco NÃO fizemos:**
- SQL ainda
- Criação de tabelas
- Modelagem formal

✅ **O foco foi em:**
- Instalação correta
- Configuração adequada
- Preparação do ambiente
- Verificação de funcionamento

> 💭 *"Um ambiente bem configurado é fundamental para aprender sem frustrações técnicas."*

---

## 🆘 Precisa de Ajuda?

**Recursos oficiais:**
- Documentação MySQL: https://dev.mysql.com/doc/
- Fórum MySQL: https://forums.mysql.com/
- Stack Overflow: Tag [mysql]

**Dica:** Sempre mencione sua versão do MySQL e sistema operacional ao pedir ajuda!
