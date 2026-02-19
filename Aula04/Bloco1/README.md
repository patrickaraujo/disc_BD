# 📘 Bloco 1 — Do MER ao DER: Revisão e Preparação para a Prática

> **Duração estimada:** 50 minutos  
> **Objetivo:** Consolidar os conceitos do Modelo Lógico (DER) antes de implementá-lo no Workbench

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Situar o DER no processo completo de construção de um banco de dados
- Diferenciar os tipos de chave: primária, composta, substituta, secundária e estrangeira
- Identificar entidades, atributos e relacionamentos do MER e mapeá-los para o DER
- Ler a notação de Pé-de-Galinha em um diagrama
- Entender o papel do Dicionário de Dados na padronização

---

## 💡 Conceitos Fundamentais

### Onde estamos no caminho?

```
Análise de Requisitos
        ↓
Modelo Conceitual (MER)   ← Aulas 03, 23/02 e 25/02
        ↓
Modelo Lógico (DER)       ← ESTAMOS AQUI
        ↓
Modelo Físico (script SQL)
        ↓
Banco de Dados no SGBD
```

O DER é o **projeto de engenharia** do banco de dados. Cada decisão tomada aqui impacta diretamente o desempenho, a integridade e a manutenção futura.

---

### Exemplo de MER

> Representação visual dos elementos do Modelo Entidade-Relacionamento: entidades, atributos, relacionamentos e cardinalidades.

![Exemplo de MER — Cliente e Compra](./img/mer_cliente_compra.png)

---

### O que o DER possui?

- Todas as **tabelas** e os **relacionamentos** entre elas
- Todos os **atributos** (colunas) de cada tabela com seus tipos de dados
- A identificação da **chave primária** de cada tabela
- Os **relacionamentos via chaves estrangeiras**
- As **cardinalidades** expressas graficamente

---

### Tipos de Chave

#### 🔑 Chave Primária (PK — Primary Key)
Identifica **unicamente** cada registro. Não pode se repetir e não pode ser nula.

**Por que o CPF é melhor PK que o nome?**
Dois clientes podem se chamar "João Silva". Mas dois CPFs nunca são iguais — a unicidade é garantida por lei.

```
✅ CPF como PK: garante exclusividade
❌ Nome como PK: pode se repetir
```

---

#### 🔑🔑 Chave Composta (ou Concatenada)
Quando **nenhum campo sozinho** garante unicidade, dois ou mais campos juntos formam a chave.

**Exemplo:** RG sozinho pode se repetir entre estados diferentes (o mesmo número emitido em SP e em MG). Mas **RG + Órgão Expedidor** são únicos.

```
RG: 12.345.678-9  |  Órgão: SSP/SP  → ÚNICO
RG: 12.345.678-9  |  Órgão: SSP/MG  → diferente!
```

---

#### 🔢 Chave Substituta (Surrogate Key)
Um campo inteiro criado **artificialmente** pelo SGBD para ser a PK quando não existe um campo naturalmente único.

**Características:**
- Tipo `INT` com `AUTO_INCREMENT`
- O SGBD define o valor — você nunca preenche manualmente
- Nunca pode ser alterado
- Nunca é reaproveitado (mesmo se o registro for excluído)

```sql
id_pedido INT AUTO_INCREMENT PRIMARY KEY
-- O SGBD atribui: 1, 2, 3, 4... automaticamente
```

---

#### 🔍 Chave Secundária
Não é PK, mas **auxilia nas buscas**. Pode retornar múltiplos registros.

**Exemplo:** Um paciente esqueceu o CPF. O atendente busca pelo sobrenome. Sobrenome pode se repetir (não é PK), mas ajuda a localizar o registro entre poucos candidatos.

---

#### 🔗 Chave Estrangeira (FK — Foreign Key)
É a **PK de outra tabela** usada para estabelecer o relacionamento. Garante a **Integridade Referencial**: você não consegue inserir um valor na FK que não exista na PK referenciada.

```
Tabela: Pedidos
  id_cliente (FK) → referencia Clientes.id_cliente (PK)

❌ Inserir pedido com id_cliente = 999 quando cliente 999 não existe → ERRO
✅ Inserir pedido com id_cliente = 1 quando cliente 1 existe → OK
```

---

### Resumo das Chaves

| Tipo | Unicidade | Criação | Quando usar |
|------|-----------|---------|-------------|
| **PK** | Sim | Você define | Campo naturalmente único (ex: CPF) |
| **Composta** | Sim (em conjunto) | Você define | Quando 1 campo só não basta |
| **Surrogate** | Sim | SGBD cria automaticamente | Quando não há campo único natural |
| **Secundária** | Não | Você define | Auxiliar de busca |
| **FK** | Não | Vem de outra tabela | Todo relacionamento entre tabelas |

---

### Notação de Pé-de-Galinha (James Martin)

É a notação padrão usada pelo MySQL Workbench para representar cardinalidades no DER.

```
Estado ──────<  Cidade
        1    N

── (linha reta)  = lado "um"  (1)
──< (pé-de-galinha) = lado "muitos" (N)
```

**Leitura:** "Um Estado possui muitas Cidades. Cada Cidade pertence a um Estado."

| Símbolo | Significado         |
|---------|---------------------|
| `──`    | Um (1)              |
| `──<`   | Muitos (N)          |
| `──O<`  | Zero ou muitos (0..N)|
| `──O──` | Zero ou um (0..1)   |

---

### Dicionário de Dados

Em projetos com vários desenvolvedores, é fundamental **padronizar os nomes** dos atributos. Sem padrão, o mesmo campo pode aparecer como `dt_nasc`, `data_nascimento`, `dataNasc`, `DataNasc`... gerando conflitos em consultas.

O Dicionário de Dados documenta cada campo:

| Tabela  | Campo      | Tipo         | Descrição                        |
|---------|------------|--------------|----------------------------------|
| Cliente | cli_cpf    | VARCHAR(14)  | CPF do cliente — PK da tabela    |
| Cliente | cli_nome   | VARCHAR(100) | Nome completo do cliente         |
| Pedido  | ped_data   | DATE         | Data em que o pedido foi feito   |
| Pedido  | cli_cpf    | VARCHAR(14)  | FK → Cliente.cli_cpf             |

> 💡 Uma convenção comum é usar prefixo de tabela no nome do campo: `cli_` para Cliente, `ped_` para Pedido, etc.

---

## 🔗 Conexão com a Prática do Bloco 2

Tudo que você reviu agora vai aparecer de forma visual e interativa no MySQL Workbench:

| Conceito (teoria) | Como aparece no Workbench |
|-------------------|--------------------------|
| PK | Ícone 🔑 amarelo; flag **PK** marcada |
| Surrogate Key | Flag **AI** (Auto Increment) marcada |
| FK | Criada automaticamente ao desenhar o relacionamento |
| Cardinalidade 1:N | Conector **1:n** na barra lateral |
| Integridade Referencial | Bloqueio automático no INSERT |

---

## ✅ Resumo do Bloco 1

Neste bloco você revisou:

- A posição do DER no processo completo de modelagem
- Os 5 tipos de chave e quando usar cada um
- A notação de Pé-de-Galinha para cardinalidades
- A importância do Dicionário de Dados para padronização

---

## 🎯 Conceitos-chave para fixar

💡 **PK = unicidade garantida — o CPF é melhor que o nome porque nunca se repete**

💡 **Surrogate Key = o SGBD cria e controla — você nunca define o valor**

💡 **FK = relacionamento entre tabelas + integridade referencial automática**

💡 **Pé-de-Galinha = notação do Workbench para cardinalidades 1:N**

---

## ➡️ Próximos Passos

No Bloco 2 você vai colocar tudo isso em prática:

- Criar o DER diretamente no MySQL Workbench
- Gerar o banco físico via Forward Engineering
- Testar a integridade referencial inserindo dados reais

Acesse: [📁 Bloco 2](../Bloco2/README.md)

---

> 💭 *"O DER é o projeto. O Forward Engineering é a obra. Sem um bom projeto, a obra vai ao chão."*
