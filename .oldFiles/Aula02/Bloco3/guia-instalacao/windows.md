# 🪟 Guia de Instalação MySQL no Windows

> **Sistema:** Windows 10/11  
> **Método:** MySQL Installer (Recomendado)

---

## 📥 Passo 1: Download do MySQL Installer

1. Acesse: https://dev.mysql.com/downloads/installer/
2. Escolha: **mysql-installer-community-X.X.XX.msi** (versão maior)
3. Clique em "Download"
4. Clique em "No thanks, just start my download"

---

## 💿 Passo 2: Executar o Instalador

1. Localize o arquivo `.msi` baixado
2. Clique duas vezes para executar
3. Windows pode pedir permissão de administrador → **Permitir**

---

## ⚙️ Passo 3: Escolher Tipo de Setup

O instalador mostrará opções:

### Developer Default (RECOMENDADO)
- ✅ MySQL Server
- ✅ MySQL Workbench
- ✅ Conectores
- ✅ Exemplos

**Escolha esta opção para ter tudo necessário**

### Outras opções:
- Server only → Apenas o servidor
- Client only → Apenas ferramentas cliente
- Full → Tudo (ocupa mais espaço)
- Custom → Escolher componentes

💡 **Recomendação:** Developer Default

---

## 📦 Passo 4: Verificar Requisitos

O instalador verifica dependências:

**Pode solicitar:**
- Visual C++ Redistributable
- Python (opcional)
- .NET Framework

Se aparecer algo vermelho:
- Clique em "Execute" para instalar automaticamente

---

## 🔧 Passo 5: Instalação dos Componentes

1. Clique em "Execute"
2. Aguarde a instalação (pode demorar 5-10 minutos)
3. Quando concluir, clique em "Next"

---

## ⚙️ Passo 6: Configuração do MySQL Server

### 6.1 — Type and Networking

**Config Type:** Development Computer  
**Port:** 3306 (mantenha padrão)  
**Protocolo:** TCP/IP  

Clique em "Next"

---

### 6.2 — Authentication Method

**Escolha:**  
✅ **Use Strong Password Encryption**

Clique em "Next"

---

### 6.3 — Accounts and Roles

**Definir senha do root:**

⚠️ **MUITO IMPORTANTE!**

1. Digite uma senha forte (ou `root123` para estudo)
2. Digite novamente para confirmar
3. **ANOTE ESTA SENHA!**

**Criar outro usuário (opcional):**
- Clique em "Add User"
- Username: dev
- Password: dev123
- Role: DB Admin

Clique em "Next"

---

### 6.4 — Windows Service

**Service Name:** MySQL80  
✅ **Start MySQL at System Startup** (marque)  
**Run Windows Service as:** Standard System Account

Clique em "Next"

---

### 6.5 — Apply Configuration

1. Clique em "Execute"
2. Aguarde as configurações serem aplicadas
3. Deve aparecer ✅ em todas as etapas
4. Clique em "Finish"

---

## 🎨 Passo 7: Configurar MySQL Workbench (se necessário)

Geralmente não precisa de configuração adicional.

Clique em "Next" até finalizar.

---

## ✅ Passo 8: Verificar Instalação

### 8.1 — Verificar Serviço

1. Pressione `Win + R`
2. Digite: `services.msc`
3. Procure por "MySQL80"
4. Status deve estar: **Em execução**

---

### 8.2 — Abrir MySQL Workbench

1. Procure "MySQL Workbench" no menu Iniciar
2. Abra o programa
3. Você verá a conexão "Local instance MySQL80"

---

### 8.3 — Testar Conexão

1. Clique duas vezes em "Local instance MySQL80"
2. Digite a senha do root
3. Marque "Save password in vault" (opcional)
4. Clique OK

✅ **Se abriu o ambiente de trabalho, sucesso!**

---

## 🔧 Resolução de Problemas

### Problema: "MySQL não aparece nos serviços"

**Solução:**
```
1. Abra CMD como administrador
2. Digite: sc query mysql80
3. Se não existir, reinstale
```

---

### Problema: "Serviço não inicia"

**Solução:**
1. Abra Serviços (services.msc)
2. Clique com direito em MySQL80
3. Propriedades → Tipo de inicialização → Automático
4. Clique em "Iniciar"

Se der erro, verifique logs em:
`C:\ProgramData\MySQL\MySQL Server 8.0\Data\`

---

### Problema: "Porta 3306 em uso"

**Solução:**
```
1. CMD como admin
2. netstat -ano | findstr :3306
3. Identifique o PID
4. Encerre o processo ou mude a porta do MySQL
```

---

## 📂 Locais Importantes

**MySQL Server:**
```
C:\Program Files\MySQL\MySQL Server 8.0\
```

**Dados:**
```
C:\ProgramData\MySQL\MySQL Server 8.0\Data\
```

**Workbench:**
```
C:\Program Files\MySQL\MySQL Workbench 8.0 CE\
```

---

## 🎯 Verificação Final

Execute estes comandos no CMD:

```bash
mysql --version
```

Deve mostrar a versão instalada.

---

## ✅ Checklist de Conclusão

- [ ] Instalador executado com sucesso
- [ ] MySQL Server instalado
- [ ] MySQL Workbench instalado
- [ ] Serviço MySQL80 rodando
- [ ] Senha do root anotada
- [ ] Conexão testada no Workbench

---

## 💡 Dicas Importantes

1. **Sempre anote a senha do root**
2. **Não desinstale Visual C++ Redistributable** (MySQL precisa)
3. **Se reinstalar, desinstale completamente primeiro**
4. **Backup antes de atualizar versões**

---

> ✅ **Instalação concluída! Você está pronto para o Bloco 4.**
