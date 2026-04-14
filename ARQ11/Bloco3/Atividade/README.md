# 🧠 Atividade 3 — Praticando Functions

> **Duração:** 25-35 minutos  
> **Formato:** Prática hands-on  
> **Objetivo:** Criar functions para cálculos e transformações reutilizáveis

---

## 📋 Preparação

```sql
USE Procs_Armazenados;

-- Configurar antes de criar functions
SET GLOBAL log_bin_trust_function_creators = 1;
```

---

## 📝 Exercício 1: Function de Cálculo de Desconto

**Criar uma function `fn_calculaDesconto` que:**
- Receba: valor, percentual_desconto
- Retorne: valor com desconto aplicado
- Tipo de retorno: DECIMAL(10,2)

**Teste sua function:**

```sql
-- Calcular 10% de desconto em R$ 100,00
SELECT fn_calculaDesconto(100.00, 10); -- Deve retornar 90.00

-- Usar em consulta de produtos
SELECT 
    produto_nome,
    produto_preco AS 'Preço Normal',
    fn_calculaDesconto(produto_preco, 15) AS 'Preço com 15% OFF'
FROM produto;
```

---

## 📝 Exercício 2: Function de Cálculo de Acréscimo

**Criar uma function `fn_calculaAcrescimo` que:**
- Receba: valor, percentual_acrescimo
- Retorne: valor com acréscimo aplicado
- Exemplo: valor 100, acréscimo 20 → retorna 120

**Teste sua function:**

```sql
SELECT fn_calculaAcrescimo(100.00, 20); -- Deve retornar 120.00

-- Simular aumento de preços
SELECT 
    produto_nome,
    produto_preco AS 'Preço Atual',
    fn_calculaAcrescimo(produto_preco, 10) AS 'Preço com Aumento'
FROM produto;
```

---

## 📝 Exercício 3: Function de Classificação de Estoque

**Criar uma function `fn_classificaEstoque` que:**
- Receba: quantidade em estoque
- Retorne: 'CRÍTICO' se < 10, 'BAIXO' se 10-50, 'NORMAL' se 51-100, 'ALTO' se > 100
- Tipo de retorno: VARCHAR(20)

**Teste sua function:**

```sql
SELECT fn_classificaEstoque(5);   -- CRÍTICO
SELECT fn_classificaEstoque(30);  -- BAIXO
SELECT fn_classificaEstoque(75);  -- NORMAL
SELECT fn_classificaEstoque(150); -- ALTO

-- Usar em consulta
SELECT 
    produto_nome,
    produto_estoque,
    fn_classificaEstoque(produto_estoque) AS 'Classificação'
FROM produto;
```

---

## 📝 Exercício 4: Function de Validação de CPF

**Criar uma function `fn_validaTamanhoCPF` que:**
- Receba: cpf (CHAR ou VARCHAR)
- Retorne: TRUE se tem 11 caracteres, FALSE caso contrário
- Tipo de retorno: BOOLEAN

**Teste sua function:**

```sql
SELECT fn_validaTamanhoCPF('12345678901');  -- TRUE (11 dígitos)
SELECT fn_validaTamanhoCPF('123456789');    -- FALSE (9 dígitos)
SELECT fn_validaTamanhoCPF('123.456.789-01'); -- FALSE (tem pontos)
```

---

## 📝 Exercício 5: Function de Cálculo de Valor Total

**Criar uma function `fn_valorTotal` que:**
- Receba: preco_unitario, quantidade
- Retorne: valor total (preço × quantidade)
- Tipo de retorno: DECIMAL(10,2)

**Teste sua function:**

```sql
SELECT fn_valorTotal(25.50, 3); -- Deve retornar 76.50

-- Simular carrinho de compras
SELECT 
    produto_nome,
    produto_preco AS 'Preço Unit.',
    5 AS 'Quantidade',
    fn_valorTotal(produto_preco, 5) AS 'Total'
FROM produto;
```

---

## 📝 Exercício 6: Function Combinada (Desconto + Total)

**Criar uma function `fn_totalComDesconto` que:**
- Receba: preco_unitario, quantidade, percentual_desconto
- Calcule: (preco_unitario × quantidade) com desconto aplicado
- Use a function `fn_calculaDesconto` dentro desta
- Tipo de retorno: DECIMAL(10,2)

**Teste sua function:**

```sql
-- Preço: 100, Qtd: 2, Desconto: 10%
-- (100 × 2) - 10% = 180.00
SELECT fn_totalComDesconto(100.00, 2, 10);

-- Simular pedido com desconto
SELECT 
    produto_nome,
    produto_preco,
    3 AS 'Qtd',
    fn_totalComDesconto(produto_preco, 3, 15) AS 'Total com 15% OFF'
FROM produto;
```

---

## 📝 Exercício 7: Usar Functions Built-in

**Pratique functions nativas do MySQL:**

```sql
-- Formatação de data
SELECT 
    produto_nome,
    NOW() AS 'Data/Hora Atual',
    DATE_FORMAT(NOW(), '%d/%m/%Y') AS 'Data Formatada',
    DATE_FORMAT(NOW(), '%d/%m/%Y às %Hh%i') AS 'Data e Hora'
FROM produto
LIMIT 1;

-- Manipulação de strings
SELECT 
    produto_nome,
    UPPER(produto_nome) AS 'MAIÚSCULA',
    LOWER(produto_nome) AS 'minúscula',
    CONCAT('Produto: ', produto_nome) AS 'Concatenado'
FROM produto;

-- Funções matemáticas
SELECT 
    produto_preco,
    ROUND(produto_preco * 1.237, 2) AS 'Arredondado',
    FLOOR(produto_preco * 1.237) AS 'Piso',
    CEIL(produto_preco * 1.237) AS 'Teto'
FROM produto;
```

---

## 📝 Exercício 8: Listar e Gerenciar

```sql
-- Listar todas as functions
SHOW FUNCTION STATUS WHERE Db = 'Procs_Armazenados';

-- Ver código de uma function
SHOW CREATE FUNCTION fn_calculaDesconto;

-- Excluir uma function
DROP FUNCTION fn_totalComDesconto;
```

---

## ✅ Checklist de Conclusão

- [ ] Function de desconto criada e testada
- [ ] Function de acréscimo criada e testada
- [ ] Function de classificação criada e testada
- [ ] Function de validação criada e testada
- [ ] Function de valor total criada e testada
- [ ] Function combinada criada e testada
- [ ] Praticou functions built-in
- [ ] Entendeu diferença entre function e procedure

---

## 💡 Dicas

- Functions SEMPRE retornam valor
- Use functions em SELECT, WHERE, ORDER BY
- Não modifique dados (INSERT/UPDATE/DELETE) em functions
- Prefira DETERMINISTIC (mesmo input = mesmo output)
- Functions são ótimas para cálculos repetitivos

---

## 🎯 Desafio Extra

Crie uma function `fn_margemLucro` que:
- Receba: preco_venda, preco_custo
- Retorne: percentual de lucro
- Fórmula: ((preco_venda - preco_custo) / preco_custo) * 100

---

> ✅ **Parabéns! Você dominou Functions!**
