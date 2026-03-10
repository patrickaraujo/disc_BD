# 🟢 Bloco 2 — Prática DML: INSERT, UPDATE e DELETE

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual

---

## 🎯 O que você vai fazer neste bloco

- Revisar a sintaxe detalhada dos comandos DML: INSERT, DELETE e UPDATE
- Inserir 10 registros na tabela `Cidade` do banco da imobiliária
- Alterar um registro específico com `UPDATE ... WHERE`
- Alterar todos os registros de uma vez (sem WHERE) e observar o impacto
- Excluir registros com `DELETE` e testar o `ROLLBACK`
- Compreender a diferença entre DELETE com e sem WHERE

---

## 💡 Revisão — Sintaxe dos Comandos DML

### INSERT

```sql
-- Sintaxe padrão (colunas explícitas)
INSERT INTO Tabela (col01, col02) VALUES ('valor01', 'valor02');

-- Inserção múltipla (várias linhas de uma vez)
INSERT INTO Tabela (col01, col02) VALUES
    ('valor1a', 'valor1b'),
    ('valor2a', 'valor2b'),
    ('valorNa', 'valorNb');

-- Inserção com expressão
INSERT INTO Tabela (col01, col02) VALUES (15, col01 * 2);

-- Inserção sem listar colunas (ordem deve corresponder à estrutura da tabela)
INSERT INTO Tabela VALUES (1, 2, 3, N);

-- Inserção com valores padrão (colunas e valores vazios)
INSERT INTO Tabela () VALUES ();
```

> ⚠️ Se a lista de colunas e valores estiver vazia, o MySQL cria uma linha com os valores `DEFAULT` de cada coluna. Se alguma coluna **não** tiver DEFAULT definido e for NOT NULL, ocorrerá erro: `Error Code: 1364. Field 'nome_coluna' doesn't have a default value`.

---

### DELETE

```sql
-- Apagar registro(s) que satisfaçam a condição
DELETE FROM Tabela WHERE Condição;

-- Apagar TODOS os registros (cuidado!)
DELETE FROM Tabela;
```

> ⚠️ `DELETE FROM Tabela` **sem WHERE** apaga **todas** as linhas da tabela. A tabela continua existindo (diferente do `DROP`), mas ficará vazia. Diferente do `TRUNCATE`, o `DELETE` sem WHERE é uma operação DML e pode ser revertida com `ROLLBACK` (se o autocommit estiver desligado).

---

### UPDATE

```sql
-- Alterar registro(s) que satisfaçam a condição
UPDATE Tabela SET Coluna = 'Valor' WHERE Condição;

-- Alterar TODOS os registros (cuidado!)
UPDATE Tabela SET Coluna = 'Valor';
```

> ⚠️ `UPDATE` **sem WHERE** altera **todas** as linhas da tabela. Esta é uma das operações mais perigosas no dia a dia — sempre confira o WHERE antes de executar.

---

## 📋 Exercícios

### [Exercício 09 — INSERT e UPDATE na Tabela Cidade](./Exercicio09/README.md)

Inserir 10 cidades no banco da imobiliária e atualizar um registro específico.

### [Exercício 10 — UPDATE em Massa, DELETE e ROLLBACK](./Exercicio10/README.md)

Alterar todos os registros de uma vez, testar ROLLBACK, apagar registros e observar os resultados.

---

> 💡 Os gabaritos SQL estão disponíveis na pasta `codigo-fonte/` de cada exercício.
