# 🛠️ Bloco 2 — Mãos na Massa: DER e Modelo Físico no MySQL Workbench

> **Duração estimada:** 50 minutos  
> **Objetivo:** Criar o primeiro DER no MySQL Workbench e gerar o banco de dados físico via Forward Engineering

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Criar um novo modelo (`.mwb`) no MySQL Workbench
- Adicionar tabelas e definir colunas, tipos de dados e chaves primárias
- Criar relacionamentos 1:N entre tabelas (gerando a FK automaticamente)
- Executar o **Forward Engineering** para transformar o DER em banco físico no MySQL
- Verificar as tabelas criadas e testar a integridade referencial com INSERTs

---

## 💡 Conceitos Revisados Neste Bloco

Você já conhece estes conceitos da teoria — agora vai vê-los funcionando de verdade:

### DER → Modelo Físico: a cadeia completa

```
Mini-mundo (problema real)
        ↓
  Modelo Conceitual (MER)      ← Aulas anteriores
        ↓
  Modelo Lógico (DER)          ← Aula 02/03/26
        ↓
  Modelo Físico (script SQL)   ← ESTE BLOCO
        ↓
  Banco de Dados no MySQL
```

### O que é o Forward Engineering?

É o processo pelo qual o MySQL Workbench lê o DER que você desenhou e **gera automaticamente os comandos SQL** (`CREATE TABLE`, chaves, relacionamentos) e os executa no servidor.

```
DER no canvas  ──[Forward Engineering]──▶  Banco físico no MySQL
```

### Tipos de dados mais usados no Workbench

| Tipo        | Uso                                      | Exemplo               |
|-------------|------------------------------------------|-----------------------|
| `INT`       | Números inteiros; ideal para PKs com AI  | id, código            |
| `VARCHAR(n)`| Texto de tamanho variável até n caracteres| nome, email, sigla   |
| `DATE`      | Data (AAAA-MM-DD)                        | data_nascimento       |
| `DECIMAL(p,s)` | Valor monetário ou decimal exato      | preco, salario        |
| `TINYINT(1)`| Booleano (0 = falso, 1 = verdadeiro)     | ativo, status         |

### Flags do editor de tabela

| Flag | Significado        | Quando usar                          |
|------|--------------------|--------------------------------------|
| PK   | Primary Key        | O campo que identifica unicamente o registro |
| NN   | Not Null           | Campo obrigatório — não pode ficar em branco |
| AI   | Auto Increment     | SGBD preenche automaticamente (surrogate key) |
| UQ   | Unique             | Valor não pode se repetir, mas não é PK |

---

## ✏️ Atividade Prática

### 📝 Tutorial Guiado — Criando o DER Estado × Cidade

Siga o passo a passo completo em: [📁 Atividade/README.md](./Atividade/README.md)

**O que você vai construir:**

```
┌─────────────────────┐         ┌────────────────────────────┐
│       Estado        │         │          Cidade             │
├─────────────────────┤         ├────────────────────────────┤
│ 🔑 SiglaUF VARCHAR(2)│ 1──── N │ 🔑 CodCidade INT (AI)      │
│    Estado VARCHAR(45)│         │    Cidade VARCHAR(45)      │
└─────────────────────┘         │  🔗 Estado_SiglaUF VARCHAR(2)│
                                └────────────────────────────┘
```

**Resumo dos passos:**
1. Criar novo modelo (`.mwb`) e abrir o canvas EER Diagram
2. Adicionar a tabela `Estado` (PK: SiglaUF)
3. Adicionar a tabela `Cidade` (PK surrogate: CodCidade com AUTO_INCREMENT)
4. Criar o relacionamento 1:N (FK gerada automaticamente)
5. Executar Forward Engineering → banco físico criado no MySQL
6. Verificar as tabelas e testar INSERTs com integridade referencial

---

## ✅ Resumo do Bloco 2

Neste bloco você aprendeu na prática:

- O MySQL Workbench funciona como **ferramenta CASE**: desenhe o modelo, ele gera o SQL
- **Forward Engineering** converte o DER em banco físico com um clique
- A **FK é criada automaticamente** a partir do relacionamento desenhado no canvas
- A **integridade referencial funciona em tempo real**: o MySQL rejeita dados inválidos na FK
- A diferença entre **PK natural** (SiglaUF) e **PK surrogate** (CodCidade com AUTO_INCREMENT)

---

## 🎯 Conceitos-chave para fixar

💡 **Workbench = ferramenta CASE que gera o script SQL a partir do DER**

💡 **Forward Engineering = DER → banco físico automaticamente**

💡 **FK gerada pelo relacionamento no canvas — você não precisa criar na mão**

💡 **AUTO_INCREMENT = o SGBD cuida do valor — você nunca define manualmente**

💡 **Integridade Referencial = FK bloqueia dados inconsistentes**

---

## ➡️ Próximos Passos

Na próxima aula você vai aprender:

- Processo de Normalização — 1ª a 4ª Forma Normal (11/03)
- Como validar e melhorar a estrutura do DER que você acabou de criar
- Por que entidades "surgem" durante a normalização

---

> 💭 *"O Workbench não escreve o SQL por mágica — ele traduz as decisões que você tomou no DER. Quanto melhor o modelo, melhor o banco."*
