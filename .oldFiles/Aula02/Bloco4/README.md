# 📘 Bloco 4 — Primeiros Passos Práticos: Criando seu Primeiro Schema

> **Duração estimada:** 50 minutos  
> **Objetivo:** Criar estruturas vazias e navegar com confiança no MySQL Workbench

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Navegar com confiança pelo MySQL Workbench
- Entender a estrutura de schemas e tabelas
- Criar seu primeiro schema (banco de dados)
- Verificar schemas criados
- Deletar schemas (com cuidado!)
- Preparar-se para criar tabelas na próxima aula

---

## 💡 Revisão Rápida: O que é um Schema?

**Schema** = Banco de Dados

É um container que agrupa:
- Tabelas
- Views
- Procedures
- Functions
- Outros objetos de BD

💡 **Analogia:** Schema é como uma pasta que organiza arquivos relacionados.

---

## 🖥️ Navegação no MySQL Workbench

### Interface Principal

Quando você conecta ao MySQL, vê:

```
┌─────────────────────────────────────────────┐
│  Navigator (esquerda)                       │
│  ├─ Schemas                                 │
│  ├─ Administration                          │
│  └─ Performance                             │
├─────────────────────────────────────────────┤
│  Query Editor (centro)                      │
│  Onde você escreve SQL                      │
├─────────────────────────────────────────────┤
│  Output (baixo)                             │
│  Resultados e mensagens                     │
└─────────────────────────────────────────────┘
```

---

### Painel Navigator (Esquerdo)

**Schemas:**
- Lista todos os bancos de dados
- Permite expandir para ver tabelas
- Mostra estrutura hierárquica

**Administration:**
- Gerenciamento do servidor
- Usuários e privilégios
- Backup e restore

**Performance:**
- Monitoramento de queries
- Dashboard de performance

---

### Query Editor (Central)

- Área para escrever comandos SQL
- Pode ter múltiplas abas
- Botões para executar queries

**Atalhos importantes:**
- `Ctrl + Enter` → Executar query atual
- `Ctrl + Shift + Enter` → Executar tudo
- `Ctrl + T` → Nova aba

---

## 🎨 Criando seu Primeiro Schema

### Método 1: Via Interface Gráfica (Mais Fácil)

**Passo a passo:**

1. No Navigator, clique com botão direito em **branco** (área de Schemas)
2. Selecione **"Create Schema..."**
3. Digite o nome: `meu_primeiro_bd`
4. Charset: `utf8mb4` (recomendado)
5. Collation: `utf8mb4_general_ci`
6. Clique em **"Apply"**
7. Revise o SQL gerado
8. Clique em **"Apply"** novamente
9. Clique em **"Finish"**

✅ **Schema criado!**

---

### Método 2: Via SQL (Mais Profissional)

No Query Editor, digite:

```sql
CREATE DATABASE meu_primeiro_bd
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

Execute: `Ctrl + Enter`

✅ **Schema criado!**

---

### 📝 Entendendo os Parâmetros

**CHARACTER SET utf8mb4:**
- Codificação de caracteres
- Suporta emojis e caracteres especiais
- É o padrão moderno

**COLLATE utf8mb4_general_ci:**
- Regras de comparação e ordenação
- `ci` = case insensitive (ignora maiúsculas/minúsculas)
- Adequado para a maioria dos casos

---

## 🔍 Verificando o Schema Criado

### Atualizar a lista

1. Clique no ícone de **"Refresh"** no Navigator
2. Ou pressione `F5`

Seu schema deve aparecer na lista!

---

### Expandir o schema

1. Clique na seta ao lado de `meu_primeiro_bd`
2. Você verá:
   - **Tables** (vazia por enquanto)
   - **Views**
   - **Stored Procedures**
   - **Functions**

---

### Definir como schema padrão

**Por que fazer isso?**  
Para não precisar especificar o schema em cada comando.

**Como fazer:**

**Opção 1:** Clique com botão direito no schema → **"Set as Default Schema"**

**Opção 2:** Clique duas vezes no schema

💡 O schema padrão fica em **negrito**.

---

## 🗑️ Deletando um Schema

⚠️ **CUIDADO!** Esta ação é **irreversível** e deleta tudo dentro do schema.

### Via Interface Gráfica

1. Clique com botão direito no schema
2. Selecione **"Drop Schema..."**
3. Confirme digitando o nome do schema
4. Clique em **"Drop Now"**

---

### Via SQL

```sql
DROP DATABASE meu_primeiro_bd;
```

⚠️ **Use com extremo cuidado!**

---

## 📊 Schemas de Sistema

Você verá alguns schemas que já existem:

**information_schema:**
- Metadados sobre todos os schemas
- Informações sobre tabelas, colunas, etc.
- **Não modifique!**

**mysql:**
- Configurações internas do MySQL
- Usuários, privilégios
- **Não modifique!**

**performance_schema:**
- Dados de performance
- Monitoramento interno
- **Não modifique!**

**sys:**
- Views simplificadas de performance
- Ajuda em análises
- **Não modifique!**

💡 **Regra de ouro:** Só mexa em schemas que você criou!

---

## 🎯 Boas Práticas para Nomear Schemas

### ✅ Bons nomes:
- `sistema_vendas`
- `controle_estoque`
- `bd_biblioteca`
- `app_delivery`

### ❌ Evite:
- `bd1`, `teste`, `sistema` (muito genéricos)
- `banco de dados` (espaços)
- `Sistema-Vendas` (caracteres especiais)
- Nomes muito longos (+ 30 caracteres)

---

### Convenções recomendadas:

**Snake case:** `meu_sistema_vendas`  
**Lowercase:** sempre minúsculas  
**Descritivo:** nome claro do propósito  
**Sem espaços:** use underscore  

---

## ✏️ Atividades Práticas

### 📝 Atividade 4 — Praticando Criação de Schemas

**Objetivo:** Ganhar confiança criando e gerenciando schemas

Acesse a atividade completa em: [📁 Atividade4/README.md](./Atividade4/README.md)

---

## 🎓 Preparação para a Próxima Aula

### O que você já sabe fazer:

✅ Conectar ao MySQL  
✅ Navegar pelo Workbench  
✅ Criar schemas  
✅ Deletar schemas  
✅ Definir schema padrão  

### O que vem a seguir:

🔜 Criar tabelas dentro dos schemas  
🔜 Definir colunas e tipos de dados  
🔜 Inserir dados  
🔜 Consultar dados com SELECT  

---

## ✅ Resumo do Bloco 4

Neste bloco você aprendeu:

- Navegação completa no MySQL Workbench
- Como criar schemas (via GUI e SQL)
- Como verificar e gerenciar schemas
- Boas práticas de nomenclatura
- Schemas de sistema (não mexer!)

---

## 🎯 Conceitos-chave para fixar

💡 **Schema = Banco de Dados**

💡 **Navigator = Painel de navegação**

💡 **Query Editor = Onde escreve SQL**

💡 **utf8mb4 = Codificação recomendada**

💡 **DROP = Deleta permanentemente**

---

## 🔑 Comandos SQL Aprendidos

```sql
-- Criar schema
CREATE DATABASE nome_schema;

-- Deletar schema (CUIDADO!)
DROP DATABASE nome_schema;

-- Ver schemas existentes
SHOW DATABASES;

-- Usar um schema
USE nome_schema;
```

---

## ➡️ Próximos Passos

Na próxima aula (Aula 03) você vai aprender:

- Modelo Entidade-Relacionamento (MER)
- Diagrama ER
- Como criar tabelas
- Tipos de dados
- Chaves primárias
- SQL básico (CREATE TABLE, INSERT)

---

## 📚 Observações Importantes

🚫 **Neste bloco NÃO criamos:**
- Tabelas
- Dados
- Relacionamentos

✅ **O foco foi em:**
- Preparação do ambiente
- Criação da "casa" (schema) onde as tabelas vão morar
- Familiarização com ferramentas

> 💭 *"Criar schemas vazios é como construir a fundação de uma casa. As tabelas são os cômodos que virão depois."*

---

## 💡 Dica Final

**Pratique criando e deletando schemas** até se sentir confortável.

Não tenha medo de errar — você está em ambiente de aprendizado!

Na próxima aula, esses schemas ganharão vida com tabelas e dados. 🚀
