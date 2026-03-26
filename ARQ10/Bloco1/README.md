# 📘 Bloco 1 — Preparação do Ambiente e Introdução ao SELECT

> **Duração estimada:** 50 minutos  
> **Objetivo:** Construir o banco de dados `familia02`, criar tabelas com relacionamento FK e entender o fluxo de transações (COMMIT/ROLLBACK)

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Criar um banco de dados com configuração de charset
- Criar tabelas com chave primária e inserir dados
- Entender o conceito de transação com `COMMIT` e `ROLLBACK`
- Adicionar uma coluna a uma tabela existente com `ALTER TABLE`
- Criar uma chave estrangeira com `ON DELETE CASCADE`
- Compreender a integridade referencial na prática
- Executar o `SELECT *` para verificar os dados inseridos

---

## 💡 Conceitos Fundamentais

### Onde estamos no caminho?

```
Aulas anteriores
  ↓
DDL (CREATE, ALTER, DROP)         ← Já estudamos
DML (INSERT, UPDATE, DELETE)      ← Já estudamos
DCL (GRANT, REVOKE)               ← Já estudamos
  ↓
DML — SELECT                      ← ESTAMOS AQUI
```

O `SELECT` é o comando mais utilizado em SQL. Tudo que fizemos até agora (criar banco, tabelas, inserir dados) foi preparação para este momento: **consultar** os dados de forma inteligente.

---

### Passo 1 — Criando o Banco de Dados

```sql
CREATE DATABASE familia02
DEFAULT CHARSET = utf8
DEFAULT COLLATE = utf8_general_ci;
```

**O que cada linha faz:**
- `CREATE DATABASE familia02` → cria o schema (banco de dados)
- `DEFAULT CHARSET = utf8` → define o conjunto de caracteres padrão (suporte a acentos)
- `DEFAULT COLLATE = utf8_general_ci` → define a regra de comparação (`ci` = case insensitive — não diferencia maiúsculas de minúsculas)

```sql
USE familia02;
```

📌 **Sempre execute o `USE` antes de criar tabelas**, senão o MySQL não sabe em qual banco trabalhar.

---

### Passo 2 — Criando a Tabela PAI

```sql
CREATE TABLE pai (
  id    INT NOT NULL,
  nome  VARCHAR(50),
  idade SMALLINT,
  PRIMARY KEY (id)
);
```

**Destaques:**
- `INT NOT NULL` → o campo `id` é obrigatório e não aceita nulo
- `PRIMARY KEY (id)` → define `id` como chave primária
- `SMALLINT` → tipo inteiro pequeno (até 32.767), suficiente para idade

---

### Passo 3 — Inserindo Dados na Tabela PAI

```sql
INSERT INTO pai (id, nome, idade)
VALUES (1, 'João', 30), (2, 'Maria', 45), (3, 'Pedro', 30),
       (4, 'Manoel', 50), (5, 'Antônio', 30), (6, 'Sebastião', 45),
       (7, 'Evandro', 29);
```

Verificando:
```sql
SELECT * FROM pai;
```

| id | nome      | idade |
|----|-----------|-------|
| 1  | João      | 30    |
| 2  | Maria     | 45    |
| 3  | Pedro     | 30    |
| 4  | Manoel    | 50    |
| 5  | Antônio   | 30    |
| 6  | Sebastião | 45    |
| 7  | Evandro   | 29    |

---

### Passo 4 — Criando a Tabela FILHA e Inserindo Dados

```sql
CREATE TABLE filha (
  id   INT PRIMARY KEY,
  nome VARCHAR(50)
);

INSERT INTO filha (id, nome)
VALUES (1, 'Ana'), (2, 'Fabia'), (3, 'José'),
       (4, 'Nando'), (5, 'Fernanda'), (6, 'Igor');
```

Verificando:
```sql
SELECT * FROM filha;
```

---

### Passo 5 — COMMIT e ROLLBACK (Controle de Transação)

```sql
COMMIT;
```

O `COMMIT` **grava fisicamente** todas as operações pendentes no banco. Sem ele, as alterações podem ser desfeitas.

---

#### ⚠️ Demonstração: Tabelas sem relacionamento

Neste momento, `pai` e `filha` são **tabelas independentes**. Veja:

```sql
DELETE FROM pai WHERE id = 4;
SELECT * FROM pai;    -- Manoel sumiu
SELECT * FROM filha;  -- Filha intacta (não há FK)
```

Agora, desfazemos a exclusão:

```sql
ROLLBACK;
SELECT * FROM pai;    -- Manoel voltou!
SELECT * FROM filha;  -- Continua intacta
```

📌 **O ROLLBACK só funciona antes do COMMIT.** Após o COMMIT, não há volta.

---

### Passo 6 — Criando o Relacionamento (FK com CASCADE)

Primeiro, adicionamos a coluna que receberá a FK:

```sql
ALTER TABLE filha ADD parente_id INT;
```

Agora, criamos a constraint de chave estrangeira:

```sql
ALTER TABLE filha
ADD CONSTRAINT FK_parente
FOREIGN KEY (parente_id) REFERENCES pai(id)
ON DELETE CASCADE;
```

**O que cada parte faz:**

| Cláusula | Significado |
|----------|-------------|
| `ADD CONSTRAINT FK_parente` | Nomeia a restrição (facilita manutenção) |
| `FOREIGN KEY (parente_id)` | A coluna da tabela `filha` que será a FK |
| `REFERENCES pai(id)` | Aponta para a PK da tabela `pai` |
| `ON DELETE CASCADE` | Ao excluir um pai, exclui automaticamente os filhos vinculados |

---

### Passo 7 — Vinculando Registros

A coluna `parente_id` foi criada com valor `NULL`. Precisamos vincular manualmente:

```sql
UPDATE filha SET parente_id = 1 WHERE id = 1;
UPDATE filha SET parente_id = 2 WHERE id = 2;
UPDATE filha SET parente_id = 3 WHERE id = 3;
COMMIT;
```

Verificando:
```sql
SELECT * FROM filha;
```

| id | nome     | parente_id |
|----|----------|------------|
| 1  | Ana      | 1          |
| 2  | Fabia    | 2          |
| 3  | José     | 3          |
| 4  | Nando    | NULL       |
| 5  | Fernanda | NULL       |
| 6  | Igor     | NULL       |

📌 **Os registros 4, 5 e 6 ainda não possuem pai vinculado** — o `parente_id` é `NULL` porque permitimos nulos ao criar a coluna.

---

## ✏️ Atividades Práticas

### 📝 Atividade 1 — Montagem do Ambiente e Verificação

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Executar todo o script do Bloco 1 no MySQL Workbench
- Verificar os dados com `SELECT *`
- Responder questões conceituais sobre COMMIT, ROLLBACK e integridade referencial

---

## 📂 Código-fonte

O script SQL completo deste bloco está disponível em:

➡️ [codigo-fonte/COMANDOS-BD-01-bloco1.sql](./codigo-fonte/COMANDOS-BD-01-bloco1.sql)

---

## ✅ Resumo do Bloco 1

Neste bloco você aprendeu:

- A criar um banco de dados com charset UTF-8
- A criar tabelas com PK e inserir múltiplos registros
- A diferença entre `COMMIT` (gravar) e `ROLLBACK` (desfazer)
- Que tabelas sem FK são independentes — excluir um registro em uma não afeta a outra
- A adicionar uma coluna FK com `ALTER TABLE` e `ADD CONSTRAINT`
- Que `ON DELETE CASCADE` propaga a exclusão automaticamente

---

## 🎯 Conceitos-chave para fixar

💡 **COMMIT = gravação definitiva — após ele, não há ROLLBACK**

💡 **ROLLBACK = desfazer transações pendentes — só funciona antes do COMMIT**

💡 **ON DELETE CASCADE = pai excluído → filhos vinculados também são excluídos**

💡 **FK com NULL permitido = registro pode existir sem vínculo com a tabela pai**

---

## ➡️ Próximos Passos

No Bloco 2 você vai aprender a consultar dados de **múltiplas tabelas** usando JOINs:

- Produto Cartesiano (o que acontece quando você erra a junção)
- INNER JOIN, LEFT JOIN, RIGHT JOIN e FULL JOIN
- Exclusão em cascata na prática

Acesse: [📁 Bloco 2](../Bloco2/README.md)

---

> 💭 *"Antes de consultar, é preciso construir. O SELECT só brilha quando o banco está bem estruturado."*
