# 🐧 Guia de Instalação MySQL no Linux

> **Distribuições:** Ubuntu/Debian, Fedora/RHEL, Arch  
> **Método:** Gerenciador de pacotes

---

## 📋 Ubuntu/Debian

### Atualizar repositórios
```bash
sudo apt update
```

### Instalar MySQL Server
```bash
sudo apt install mysql-server
```

### Verificar status
```bash
sudo systemctl status mysql
```

### Executar configuração segura
```bash
sudo mysql_secure_installation
```

Siga as instruções para definir senha do root.

### Instalar MySQL Workbench
```bash
sudo apt install mysql-workbench
```

---

## 📋 Fedora/RHEL

### Instalar MySQL Server
```bash
sudo dnf install mysql-server
```

### Iniciar serviço
```bash
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

### Configuração segura
```bash
sudo mysql_secure_installation
```

### Instalar Workbench
```bash
sudo dnf install mysql-workbench
```

---

## ✅ Testar Conexão

```bash
mysql -u root -p
```

Digite a senha quando solicitado.

---

> ✅ **Instalação concluída!**
