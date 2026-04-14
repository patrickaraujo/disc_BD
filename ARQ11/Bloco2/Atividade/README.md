# 🧠 Atividade 2 — Praticando Triggers

> **Duração:** 30-40 minutos  
> **Formato:** Prática hands-on  
> **Objetivo:** Criar triggers para automatizar ações no banco de dados

---

## 📋 Preparação

```sql
USE Procs_Armazenados;

-- Tabela de histórico de alterações
CREATE TABLE historico_preco (
    id INT AUTO_INCREMENT,
    produto_id INT NOT NULL,
    preco_antigo DECIMAL(10,2) NOT NULL,
    preco_novo DECIMAL(10,2) NOT NULL,
    usuario VARCHAR(50),
    data_alteracao DATETIME,
    PRIMARY KEY (id)
);

-- Tabela de log de exclusões
CREATE TABLE log_exclusao (
    id INT AUTO_INCREMENT,
    tabela VARCHAR(50),
    registro_id INT,
    descricao TEXT,
    usuario VARCHAR(50),
    data_exclusao DATETIME,
    PRIMARY KEY (id)
);
```

---

## 📝 Exercício 1: Trigger de Auditoria de Preço

**Criar uma trigger `tg_audita_preco` que:**
- Dispara AFTER UPDATE na tabela `produto`
- Registra na tabela `historico_preco`:
  - produto_id
  - preco_antigo (OLD.produto_preco)
  - preco_novo (NEW.produto_preco)
  - usuario (CURRENT_USER)
  - data_alteracao (NOW())

**Teste sua trigger:**

```sql
-- Ver preço atual
SELECT * FROM produto WHERE produto_id = 1;

-- Alterar preço (trigger dispara automaticamente!)
UPDATE produto SET produto_preco = 4000.00 WHERE produto_id = 1;

-- Ver histórico
SELECT * FROM historico_preco;
```

---

## 📝 Exercício 2: Trigger de Validação de Estoque

**Criar uma trigger `tg_valida_estoque` que:**
- Dispara BEFORE UPDATE na tabela `produto`
- Valida se novo estoque não fica negativo
- Se ficar negativo, impede a alteração com SIGNAL
- Se OK, permite a alteração

**Teste sua trigger:**

```sql
-- Produto com 10 unidades em estoque
UPDATE produto SET produto_estoque = -5 WHERE produto_id = 1;
-- Deve dar erro!

-- Produto com 10 unidades
UPDATE produto SET produto_estoque = 5 WHERE produto_id = 1;
-- Deve funcionar
```

**Dica para SIGNAL:**
```sql
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Estoque não pode ser negativo';
```

---

## 📝 Exercício 3: Trigger de Log de Exclusão

**Criar uma trigger `tg_log_exclusao` que:**
- Dispara BEFORE DELETE na tabela `produto`
- Registra na tabela `log_exclusao`:
  - tabela = 'produto'
  - registro_id = OLD.produto_id
  - descricao = nome do produto deletado
  - usuario = CURRENT_USER
  - data_exclusao = NOW()

**Teste sua trigger:**

```sql
-- Inserir produto de teste
INSERT INTO produto VALUES (null, 'Produto Teste', 10.00, 5);

-- Ver produto
SELECT * FROM produto WHERE produto_nome = 'Produto Teste';

-- Deletar (trigger dispara!)
DELETE FROM produto WHERE produto_nome = 'Produto Teste';

-- Ver log
SELECT * FROM log_exclusao;
```

---

## 📝 Exercício 4: Trigger de Desconto Automático

**Cenário:** Produtos com estoque acima de 100 unidades ganham automaticamente 10% de desconto.

**Criar uma trigger `tg_desconto_estoque_alto` que:**
- Dispara BEFORE UPDATE na tabela `produto`
- Verifica se novo estoque > 100
- Se sim, aplica 10% desconto no preço
- Atualiza o preço automaticamente

**Teste sua trigger:**

```sql
-- Produto com estoque baixo e preço 100.00
UPDATE produto SET produto_estoque = 50 WHERE produto_id = 2;
-- Preço continua 100.00

-- Aumentar estoque para mais de 100
UPDATE produto SET produto_estoque = 150 WHERE produto_id = 2;
-- Preço deve ir para 90.00 automaticamente!

SELECT * FROM produto WHERE produto_id = 2;
```

---

## 📝 Exercício 5: Trigger de Preço Mínimo

**Criar uma trigger `tg_preco_minimo` que:**
- Dispara BEFORE INSERT e BEFORE UPDATE
- Valida se preço é menor que 1.00
- Se for, ajusta automaticamente para 1.00
- Não bloqueia a operação, apenas corrige

**Teste sua trigger:**

```sql
-- Tentar inserir produto com preço 0
INSERT INTO produto VALUES (null, 'Teste Preço', 0.50, 10);

-- Ver produto (preço deve estar 1.00)
SELECT * FROM produto WHERE produto_nome = 'Teste Preço';

-- Tentar atualizar para preço muito baixo
UPDATE produto SET produto_preco = 0.10 WHERE produto_nome = 'Teste Preço';

-- Ver produto (preço deve estar 1.00)
SELECT * FROM produto WHERE produto_nome = 'Teste Preço';
```

---

## 📝 Exercício 6: Listar e Gerenciar

```sql
-- Listar todas as triggers
SHOW TRIGGERS;

-- Ver código de uma trigger específica
SHOW CREATE TRIGGER tg_audita_preco;

-- Excluir uma trigger
DROP TRIGGER tg_desconto_estoque_alto;
```

---

## ✅ Checklist de Conclusão

- [ ] Trigger de auditoria de preço criada e testada
- [ ] Trigger de validação de estoque criada e testada
- [ ] Trigger de log de exclusão criada e testada
- [ ] Trigger de desconto automático criada e testada
- [ ] Trigger de preço mínimo criada e testada
- [ ] Entendeu diferença entre BEFORE e AFTER
- [ ] Sabe usar NEW e OLD corretamente

---

## 💡 Dicas

- BEFORE = antes da ação (pode validar/modificar)
- AFTER = depois da ação (pode auditar/registrar)
- NEW = novos valores
- OLD = valores antigos
- SIGNAL = gera erro customizado
- FOR EACH ROW = executa para cada linha

---

> ✅ **Parabéns! Você dominou Triggers!**
