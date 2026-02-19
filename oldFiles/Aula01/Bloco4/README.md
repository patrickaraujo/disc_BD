# 📘 Bloco 4 — Primeiro Contato: MySQL e MySQL Workbench

> **Duração estimada:** 50 minutos  
> **Objetivo:** Conhecer o ambiente MySQL Workbench e visualizar dados estruturados na prática

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que é o MySQL e o MySQL Workbench
- Diferenciar o SGBD da interface gráfica
- Navegar pelo MySQL Workbench
- Visualizar bancos de dados, tabelas, linhas e colunas
- Reconhecer dados estruturados na prática
- Perder o medo do ambiente de banco de dados

---

## 💡 Conceitos Fundamentais

### O que é o MySQL?

**MySQL** é um Sistema de Gerenciamento de Banco de Dados (SGBD) relacional.

**Características:**
- Open source (código aberto)
- Um dos SGBDs mais populares do mundo
- Usado por Facebook, YouTube, Netflix, entre outros
- Trabalha principalmente com dados estruturados
- Organiza dados em tabelas relacionadas

💡 **Importante:** MySQL é o **gerenciador**. Ele não contém dados por padrão — você cria os bancos de dados dentro dele.

---

### O que é o MySQL Workbench?

**MySQL Workbench** é uma interface gráfica (GUI) para o MySQL.

**Características:**
- Facilita a interação com o MySQL
- Permite visualizar dados sem escrever código
- Fornece ferramentas visuais para administração
- Não é um SGBD — é apenas uma ferramenta de acesso

**Analogia:**  
- MySQL = motor do carro
- MySQL Workbench = painel de controle do carro

Você poderia dirigir sem o painel, mas seria muito mais difícil.

---

## 🔧 Ambiente MySQL Workbench

### Elementos da Interface

Quando você abre o MySQL Workbench, você vê:

1. **Conexões** — servidores MySQL disponíveis
2. **Schemas** — bancos de dados no servidor
3. **Tabelas** — estruturas que armazenam os dados
4. **Query Editor** — área para escrever comandos SQL

💡 **Nesta aula:** vamos apenas **observar**, não escrever SQL ainda.

---

## 📊 Estrutura de Dados Relacionais

### Hierarquia de Organização

```
Servidor MySQL
└── Schema (Banco de Dados)
    └── Tabela
        └── Linhas (Registros)
            └── Colunas (Atributos)
```

**Exemplo visual:**

```
📁 LOJA_ONLINE (Schema/Banco de Dados)
├── 📄 Clientes (Tabela)
│   ├── Linha 1: João Silva | CPF: 123.456.789-00 | Email: joao@email.com
│   └── Linha 2: Maria Santos | CPF: 987.654.321-00 | Email: maria@email.com
└── 📄 Produtos (Tabela)
    ├── Linha 1: Notebook Dell | R$ 3.500,00 | 10 em estoque
    └── Linha 2: Mouse Logitech | R$ 120,00 | 50 em estoque
```

---

### Anatomia de uma Tabela

Uma tabela é composta por:

#### 🔹 Colunas (Atributos)
- Representam características dos dados
- Têm nomes e tipos definidos
- Exemplo: `nome`, `cpf`, `email`, `data_nascimento`

#### 🔹 Linhas (Registros/Tuplas)
- Representam uma entrada completa
- Cada linha é um "item" da tabela
- Exemplo: dados completos de um cliente

**Visualização:**

```
Tabela: CLIENTES
┌────┬─────────────┬──────────────────┬───────────────────┐
│ ID │    NOME     │       CPF        │       EMAIL       │
├────┼─────────────┼──────────────────┼───────────────────┤
│ 1  │ João Silva  │ 123.456.789-00   │ joao@email.com    │ ← LINHA/REGISTRO
│ 2  │ Maria Santos│ 987.654.321-00   │ maria@email.com   │ ← LINHA/REGISTRO
└────┴─────────────┴──────────────────┴───────────────────┘
  ↑       ↑              ↑                    ↑
 COLUNAS/ATRIBUTOS
```

---

## 🖥️ Navegação Básica no MySQL Workbench

### Passo 1 — Abrir uma Conexão

1. Abra o MySQL Workbench
2. Clique duas vezes na conexão local
3. Digite a senha (se solicitado)

✅ Você está conectado ao servidor MySQL!

---

### Passo 2 — Visualizar Schemas (Bancos de Dados)

1. No painel esquerdo, clique em **"Schemas"**
2. Você verá uma lista de bancos de dados disponíveis
3. Exemplos comuns:
   - `information_schema` (sistema)
   - `mysql` (sistema)
   - `performance_schema` (sistema)
   - Bancos criados por você

💡 **Importante:** Bancos de sistema não devem ser alterados!

---

### Passo 3 — Explorar um Schema

1. Clique na **seta** ao lado de um schema para expandir
2. Você verá:
   - **Tables** — tabelas do banco
   - **Views** — visões (veremos depois)
   - **Stored Procedures** — procedimentos (veremos depois)

---

### Passo 4 — Visualizar uma Tabela

1. Expanda **"Tables"**
2. Clique com botão direito em uma tabela
3. Selecione **"Select Rows - Limit 1000"**

✅ Os dados da tabela aparecem em formato visual!

---

### Passo 5 — Entender o que você está vendo

Ao visualizar os dados:

- **Cada coluna** = um atributo/característica
- **Cada linha** = um registro completo
- **Conjunto de linhas** = os dados estruturados

**Exemplo do que você vê:**

```
┌────┬─────────────┬───────┬──────────┐
│ id │ nome        │ idade │ cidade   │
├────┼─────────────┼───────┼──────────┤
│ 1  │ João        │ 25    │ São Paulo│
│ 2  │ Maria       │ 30    │ Rio      │
│ 3  │ Pedro       │ 22    │ Brasília │
└────┴─────────────┴───────┴──────────┘
```

---

## 🎓 Conceitos Práticos Importantes

### O que você NÃO deve fazer agora

❌ Não tente modificar dados  
❌ Não execute comandos SQL sem entender  
❌ Não delete tabelas ou schemas  
❌ Não mexa nos bancos de sistema

---

### O que você DEVE fazer agora

✅ Observe a estrutura  
✅ Navegue entre schemas e tabelas  
✅ Visualize os dados  
✅ Identifique linhas e colunas  
✅ Perca o medo do ambiente  

💡 **Frase-chave:** "Hoje você não manda no banco. Você só observa."

---

## 🔍 Dados Estruturados na Prática

### Por que isso é "estruturado"?

Observe que:

1. **Cada coluna tem um tipo fixo**
   - Nome: texto
   - Idade: número
   - Data: data

2. **Todas as linhas seguem a mesma estrutura**
   - Não há linhas "diferentes"

3. **Há organização clara**
   - Você sabe onde cada informação está

💡 **Isso é a essência de dados estruturados!**

---

### Conexão com o Bloco 1

Lembra das classificações de dados?

- ✅ Esses dados estão **estruturados**
- ✅ Seguem um **formato definido**
- ✅ Podem ser **processados por máquina**
- ✅ Organizados em **tabelas relacionais**

---

## ✏️ Atividades Práticas

### 📝 Atividade 4 — Explorando o MySQL Workbench

**Objetivo:** Familiarizar-se com o ambiente e visualizar dados reais

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Conectar ao MySQL
- Navegar entre schemas e tabelas
- Visualizar e descrever estruturas de dados
- Identificar linhas, colunas e tipos de dados

---

## 🎯 Perguntas Frequentes

### "Preciso saber SQL agora?"

❌ **Não!** Nesta aula, apenas observamos. SQL vem depois.

---

### "E se eu apagar algo sem querer?"

Se você está apenas **visualizando** (Select Rows), não há risco.

---

### "Por que algumas tabelas têm tantas colunas?"

Sistemas reais armazenam muitas informações. É normal ver tabelas com 10, 20, 30+ colunas.

---

### "Posso criar meu próprio banco?"

Sim, mas faremos isso nas próximas aulas, com orientação adequada.

---

## ✅ Resumo do Bloco 4

Neste bloco você aprendeu:

- MySQL é o SGBD, MySQL Workbench é a interface gráfica
- Como navegar pelo MySQL Workbench
- Como visualizar schemas, tabelas, linhas e colunas
- O que são dados estruturados na prática
- Como explorar um banco de dados sem modificá-lo

---

## 🎯 Conceitos-chave para fixar

💡 **MySQL = SGBD**  
💡 **MySQL Workbench = Interface Gráfica**  
💡 **Schema = Banco de Dados**  
💡 **Tabela = Estrutura que armazena dados**  
💡 **Linha = Registro individual**  
💡 **Coluna = Atributo/característica**

---

## ➡️ Próximos Passos

Nas próximas aulas você vai aprender:

- Modelo Relacional de Dados
- Como criar seus próprios bancos de dados
- Linguagem SQL para manipular dados
- Como modelar estruturas de dados
- Relacionamentos entre tabelas

---

## 📚 Observações Importantes

🚫 **Neste bloco NÃO fizemos:**
- SQL (comandos)
- Criação de bancos ou tabelas
- Modificação de dados

✅ **O foco agora foi:**
- Visualização do ambiente
- Compreensão da estrutura
- Familiarização com a ferramenta
- Perda do medo inicial

> 💭 *"A melhor forma de aprender banco de dados é começar observando como os dados são organizados."*

---

## 🎓 Dica Final

**Para consolidar o aprendizado:**

1. Explore diferentes schemas
2. Abra várias tabelas
3. Observe os tipos de dados
4. Tente identificar a finalidade de cada tabela
5. Compare estruturas diferentes

**Lembre-se:**  
Você está apenas **observando**. Não há problema em explorar — desde que não modifique nada ainda!
