# 🧠 Atividade 4 — Praticando Views

> **Duração:** 30-40 minutos  
> **Formato:** Prática hands-on  
> **Objetivo:** Criar views para simplificar consultas complexas

---

## 📋 Preparação

```sql
USE Procs_Armazenados;

-- Criar tabelas para relacionamentos
CREATE TABLE categoria (
    categoria_id INT AUTO_INCREMENT,
    categoria_nome VARCHAR(30) NOT NULL,
    PRIMARY KEY (categoria_id)
);

CREATE TABLE fornecedor (
    fornecedor_id INT AUTO_INCREMENT,
    fornecedor_nome VARCHAR(50) NOT NULL,
    fornecedor_cidade VARCHAR(30),
    PRIMARY KEY (fornecedor_id)
);

-- Adicionar colunas em produto
ALTER TABLE produto 
ADD COLUMN categoria_id INT,
ADD COLUMN fornecedor_id INT;

-- Inserir dados de exemplo
INSERT INTO categoria VALUES 
    (null, 'Eletrônicos'),
    (null, 'Periféricos'),
    (null, 'Móveis');

INSERT INTO fornecedor VALUES 
    (null, 'Dell Brasil', 'São Paulo'),
    (null, 'Logitech', 'Rio de Janeiro'),
    (null, 'Genérico LTDA', 'Curitiba');

UPDATE produto SET categoria_id = 1, fornecedor_id = 1 WHERE produto_id = 1;
UPDATE produto SET categoria_id = 2, fornecedor_id = 2 WHERE produto_id = 2;
```

---

## 📝 Exercício 1: View Simples

**Criar uma view `vw_produtos_simples` que:**
- Mostre apenas: produto_nome, produto_preco
- Renomeie colunas para: 'Produto' e 'Preço'
- Ordene por nome

**Teste sua view:**

```sql
SELECT * FROM vw_produtos_simples;
```

---

## 📝 Exercício 2: View com Cálculo

**Criar uma view `vw_produtos_com_desconto` que:**
- Mostre: nome, preço original, preço com 10% desconto
- Use a function `fn_calculaDesconto` (se criou no Bloco 3)
- Ou calcule direto: preco * 0.90

**Teste sua view:**

```sql
SELECT * FROM vw_produtos_com_desconto;
```

---

## 📝 Exercício 3: View com JOIN

**Criar uma view `vw_produtos_completo` que:**
- Una: produto, categoria, fornecedor
- Mostre: nome do produto, preço, nome da categoria, nome do fornecedor
- Use INNER JOIN

**Teste sua view:**

```sql
SELECT * FROM vw_produtos_completo;

-- Filtrar na view
SELECT * FROM vw_produtos_completo 
WHERE `Nome da Categoria` = 'Eletrônicos';
```

---

## 📝 Exercício 4: View com Classificação

**Criar uma view `vw_produtos_classificados` que:**
- Mostre: nome, preço, estoque
- Adicione coluna 'Situação Estoque' usando CASE:
  - 'CRÍTICO' se estoque < 10
  - 'BAIXO' se estoque 10-50
  - 'NORMAL' se estoque 51-100
  - 'ALTO' se estoque > 100

**Teste sua view:**

```sql
SELECT * FROM vw_produtos_classificados;

-- Ver apenas produtos críticos
SELECT * FROM vw_produtos_classificados 
WHERE `Situação Estoque` = 'CRÍTICO';
```

---

## 📝 Exercício 5: View de Relatório

**Criar uma view `vw_relatorio_estoque` que:**
- Agrupe por categoria
- Mostre: nome da categoria, quantidade de produtos, valor total em estoque
- Valor total = SUM(preco * estoque)
- Ordene por valor total decrescente

**Teste sua view:**

```sql
SELECT * FROM vw_relatorio_estoque;
```

**⚠️ Esta view NÃO é atualizável (usa GROUP BY)!**

---

## 📝 Exercício 6: View Atualizável

**Criar uma view `vw_produtos_ativos` que:**
- Mostre apenas produtos com estoque > 0
- Mostre: produto_id, produto_nome, produto_preco, produto_estoque
- SEM GROUP BY, SEM funções agregadas

**Teste atualizando via view:**

```sql
-- Ver produtos
SELECT * FROM vw_produtos_ativos;

-- Atualizar via view
UPDATE vw_produtos_ativos 
SET produto_preco = produto_preco * 1.05 
WHERE produto_id = 1;

-- Verificar (tabela original também foi atualizada!)
SELECT * FROM produto WHERE produto_id = 1;
```

---

## 📝 Exercício 7: View de Segurança

**Criar uma view `vw_produtos_publico` que:**
- Esconda informações sensíveis
- Mostre apenas: nome do produto, categoria
- NÃO mostre: preço, estoque, fornecedor

**Cenário:** Esta view seria usada para consulta pública

```sql
SELECT * FROM vw_produtos_publico;
```

---

## 📝 Exercício 8: View com CONCAT

**Criar uma view `vw_info_completa` que:**
- Concatene informações em texto
- Exemplo: "Notebook Dell - Categoria: Eletrônicos - Fornecedor: Dell Brasil"
- Use CONCAT()

**Teste sua view:**

```sql
SELECT * FROM vw_info_completa;
```

---

## 📝 Exercício 9: Usar Banco World

```sql
USE world;

-- Ver tabelas disponíveis
SHOW TABLES;

-- Criar view: cidades do Brasil
CREATE OR REPLACE VIEW vw_cidades_brasil AS
SELECT ID, Name AS 'Cidade', Population AS 'População'
FROM city
WHERE CountryCode = 'BRA'
ORDER BY Population DESC;

-- Consultar
SELECT * FROM vw_cidades_brasil LIMIT 10;

-- Criar view com JOIN
CREATE OR REPLACE VIEW vw_paises_america AS
SELECT 
    co.Name AS 'País',
    co.Continent AS 'Continente',
    co.Population AS 'População',
    co.Capital
FROM country co
WHERE co.Continent = 'South America'
ORDER BY co.Population DESC;

SELECT * FROM vw_paises_america;
```

---

## 📝 Exercício 10: Gerenciar Views

```sql
USE Procs_Armazenados;

-- Listar todas as views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Ver código de uma view
SHOW CREATE VIEW vw_produtos_completo;

-- Alterar view
CREATE OR REPLACE VIEW vw_produtos_simples AS
SELECT produto_nome AS 'Produto', produto_preco AS 'R$'
FROM produto
WHERE produto_estoque > 0;

-- Excluir view
DROP VIEW vw_produtos_publico;
```

---

## ✅ Checklist de Conclusão

- [ ] View simples criada e testada
- [ ] View com cálculo criada e testada
- [ ] View com JOIN criada e testada
- [ ] View com CASE criada e testada
- [ ] View de relatório (GROUP BY) criada
- [ ] View atualizável criada e testada
- [ ] View de segurança criada
- [ ] View com CONCAT criada
- [ ] Praticou com banco World
- [ ] Entendeu quando view é atualizável

---

## 💡 Dicas

- Views NÃO armazenam dados, apenas a consulta
- Use prefixo `vw_` para identificar views
- Views com GROUP BY não são atualizáveis
- Views são ótimas para segurança e padronização
- OR REPLACE facilita manutenção
- SHOW FULL TABLES mostra views separadas

---

## 🎯 Desafio Extra

Crie uma view que:
- Mostre top 5 produtos mais caros
- Inclua classificação de estoque
- Mostre valor total em estoque de cada um
- Use pelo menos um JOIN

---

> ✅ **Parabéns! Você completou TODOS os blocos da Aula 11!**

---

## 🎓 Resumo Final da Aula 11

Você aprendeu a criar e usar:

✅ **Stored Procedures** - Lógica reutilizável  
✅ **Triggers** - Ações automáticas  
✅ **Functions** - Cálculos reutilizáveis  
✅ **Views** - Consultas simplificadas  

**Agora você pode:**
- Automatizar tarefas no banco de dados
- Proteger integridade dos dados
- Reutilizar cálculos complexos
- Simplificar acesso para usuários
- Implementar segurança em nível de dados

---

> 💭 *"Objetos avançados de BD transformam seu banco de dados de um simples repositório em um sistema inteligente e automatizado."*
