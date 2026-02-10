# 🍎 Guia de Instalação MySQL no macOS

> **Sistema:** macOS  
> **Método:** Homebrew (Recomendado) ou DMG

---

## 📥 Método 1: Homebrew (Recomendado)

### Instalar Homebrew (se não tiver)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Instalar MySQL
```bash
brew install mysql
```

### Iniciar MySQL
```bash
brew services start mysql
```

### Configuração segura
```bash
mysql_secure_installation
```

### Instalar MySQL Workbench
```bash
brew install --cask mysqlworkbench
```

---

## 📥 Método 2: DMG

1. Baixe o `.dmg` do site oficial
2. Abra o arquivo
3. Siga o instalador
4. Defina senha do root
5. MySQL irá iniciar automaticamente

---

## ✅ Testar Conexão

```bash
mysql -u root -p
```

---

> ✅ **Instalação concluída!**
