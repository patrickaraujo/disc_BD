# 🧠 Atividade 1 — Praticando Stored Procedures

> **Duração:** 30-40 minutos  
> **Formato:** Prática hands-on  
> **Objetivo:** Criar e usar stored procedures para gerenciar produtos

---

## 📋 Preparação

### Crie o banco de dados e a tabela

```sql
CREATE DATABASE IF NOT EXISTS Procs_Armazenados;
USE Procs_Armazenados;

CREATE TABLE produto (
    produto_id INT AUTO_INCREMENT,
    produto_nome VARCHAR(50) NOT NULL,
    produto_preco DECIMAL(10,2) NOT NULL,
    produto_estoque INT NOT NULL,
    PRIMARY KEY (produto_id)
);
```

---

## 📝 Exercício 1: Procedure de Inserção

**Criar uma procedure `sp_insereProduto` que:**
- Receba: nome, preço, estoque
- Valide: todos os parâmetros devem ser NOT NULL
- Valide: preço deve ser maior que 0
- Valide: estoque deve ser maior ou igual a 0
- Insira o produto se tudo estiver OK
- Retorne mensagem de sucesso ou erro

**Teste sua procedure:**

```sql
CALL sp_insereProduto('Notebook Dell', 3500.00, 10);
CALL sp_insereProduto('Mouse Logitech', 120.00, 50);
CALL sp_insereProduto('Teclado Mecânico', -50.00, 20); -- Deve dar erro
CALL sp_insereProduto('Monitor', null, 5); -- Deve dar erro
```

---

## 📝 Exercício 2: Procedure de Consulta

**Criar uma procedure `sp_consultaProduto` que:**
- Receba: produto_id (opcional)
- Se passar ID, retorne produto específico
- Se passar NULL, retorne todos os produtos
- Ordene por nome

**Teste sua procedure:**

```sql
CALL sp_consultaProduto(1);
CALL sp_consultaProduto(null);
```

---

## 📝 Exercício 3: Procedure de Atualização de Preço

**Criar uma procedure `sp_atualizaPreco` que:**
- Receba: produto_id, novo_preco
- Valide se produto existe
- Valide se preço é maior que 0
- Atualize o preço
- Retorne mensagem de sucesso ou erro

**Teste sua procedure:**

```sql
CALL sp_atualizaPreco(1, 3800.00);
CALL sp_atualizaPreco(999, 100.00); -- Produto não existe
```

---

## 📝 Exercício 4: Procedure de Aplicar Desconto

**Criar uma procedure `sp_aplicaDesconto` que:**
- Receba: produto_id, percentual_desconto (ex: 10 para 10%)
- Valide se produto existe
- Valide se desconto está entre 0 e 100
- Calcule novo preço: preco_atual * (1 - desconto/100)
- Atualize o preço
- Retorne o preço antigo e o novo

**Teste sua procedure:**

```sql
CALL sp_aplicaDesconto(1, 10); -- 10% de desconto
CALL sp_aplicaDesconto(2, 150); -- Deve dar erro (desconto inválido)
```

---

## 📝 Exercício 5: Procedure de Atualização de Estoque

**Criar uma procedure `sp_atualizaEstoque` que:**
- Receba: produto_id, quantidade (pode ser positivo ou negativo)
- Se quantidade > 0: adiciona ao estoque (entrada)
- Se quantidade < 0: remove do estoque (saída)
- Valide se há estoque suficiente para remoção
- Atualize o estoque
- Retorne estoque anterior e novo

**Teste sua procedure:**

```sql
CALL sp_atualizaEstoque(1, 5);   -- Adiciona 5 unidades
CALL sp_atualizaEstoque(1, -3);  -- Remove 3 unidades
CALL sp_atualizaEstoque(1, -100); -- Deve dar erro (estoque insuficiente)
```

---

## 📝 Exercício 6: Listar e Documentar

1. Liste todas as procedures criadas:
```sql
SHOW PROCEDURE STATUS WHERE Db = 'Procs_Armazenados';
```

2. Veja o código de uma procedure:
```sql
SHOW CREATE PROCEDURE sp_insereProduto;
```

3. Documente: Anote o que cada procedure faz e quando usá-la

---

## ✅ Checklist de Conclusão

- [ ] Procedure de inserção criada e testada
- [ ] Procedure de consulta criada e testada
- [ ] Procedure de atualização de preço criada e testada
- [ ] Procedure de desconto criada e testada
- [ ] Procedure de estoque criada e testada
- [ ] Todas validam parâmetros corretamente
- [ ] Retornam mensagens claras

---

## 💡 Dicas

- Use `IF...THEN...ELSE` para validações
- Use `BEGIN...END` para agrupar múltiplos comandos
- Teste SEMPRE com dados válidos E inválidos
- Documente suas procedures com comentários

---

> ✅ **Parabéns! Você dominou Stored Procedures!**
