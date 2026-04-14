# 📘 Bloco 2 — Triggers: Ações Automáticas em Eventos

> **Duração estimada:** 60 minutos  
> **Objetivo:** Criar gatilhos que executam automaticamente em resposta a eventos

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que são Triggers e quando usá-las
- Diferenciar BEFORE e AFTER
- Criar triggers para INSERT, UPDATE e DELETE
- Usar operadores NEW e OLD
- Implementar auditoria automática
- Atualizar estoque automaticamente
- Excluir triggers

---

## 💡 O que são Triggers?

### Definição

**Trigger** (Gatilho) é um objeto do banco de dados que **dispara automaticamente** quando ocorre um evento específico (INSERT, UPDATE ou DELETE) em uma tabela.

### Analogia

Pense em um **alarme de segurança**:
- Você **configura** o alarme (cria a trigger)
- Quando alguém **abre a porta** (evento: INSERT/UPDATE/DELETE)
- O alarme **dispara automaticamente** (executa a trigger)
- Você **não precisa apertar nenhum botão**

---

## 🎭 Tipos de Triggers

### BEFORE (Antes)

Executada **ANTES** da ação original (INSERT/UPDATE/DELETE)

**Quando usar:**
- Validar dados antes de inserir
- Modificar valores antes de salvar
- Impedir ações indesejadas

### AFTER (Depois)

Executada **APÓS** a ação original (INSERT/UPDATE/DELETE)

**Quando usar:**
- Registrar auditoria
- Atualizar tabelas relacionadas
- Enviar notificações

---

## 🔑 Operadores NEW e OLD

### NEW

Acessa os **novos valores** que estão sendo inseridos/atualizados

**Disponível em:**
- INSERT → NEW.coluna (valor sendo inserido)
- UPDATE → NEW.coluna (valor novo)
- DELETE → ❌ não disponível

### OLD

Acessa os **valores antigos** antes da modificação

**Disponível em:**
- INSERT → ❌ não disponível
- UPDATE → OLD.coluna (valor antigo)
- DELETE → OLD.coluna (valor sendo deletado)

---

## 📝 Sintaxe Básica

```sql
DELIMITER //

CREATE TRIGGER nome_trigger
[BEFORE | AFTER] [INSERT | UPDATE | DELETE] ON nome_tabela
FOR EACH ROW 
BEGIN
    -- Corpo da trigger
    -- Acessa valores com NEW.coluna ou OLD.coluna
END //

DELIMITER ;
```

---

## 🛠️ Exemplo 1: Atualizar Estoque Automaticamente

### Cenário

Quando inserir um item no pedido, **diminuir automaticamente** o estoque do produto.

### Tabelas

```sql
CREATE TABLE ItemPedido (
    CODIGOPRODUTO INT NOT NULL, 
    CODIGOPEDIDO INT NOT NULL, 
    QTD INT NOT NULL, 
    PRIMARY KEY (CODIGOPRODUTO, CODIGOPEDIDO)
);

CREATE TABLE Produtos (
    CODIGOPRODUTO INT NOT NULL, 
    NOME VARCHAR(30) NOT NULL, 
    QTDESTOQUE INT NOT NULL, 
    PRECO DECIMAL(5,2), 
    PRIMARY KEY (CODIGOPRODUTO)
);
```

### Trigger

```sql
DELIMITER //

CREATE TRIGGER tg_atualiza_estoque 
AFTER INSERT ON ITEMPEDIDO
FOR EACH ROW 
BEGIN
    -- Captura valores do item inserido
    SET @CODIGOPRODUTO = NEW.CODIGOPRODUTO;
    SET @QTD = NEW.QTD;
    
    -- Valida se os valores existem
    IF (@CODIGOPRODUTO IS NOT NULL AND @QTD IS NOT NULL) THEN
        -- Atualiza estoque (diminui a quantidade vendida)
        UPDATE PRODUTOS
        SET QTDESTOQUE = QTDESTOQUE - @QTD
        WHERE CODIGOPRODUTO = @CODIGOPRODUTO;
    END IF;
END //

DELIMITER ;
```

### Testando

```sql
-- Inserir produtos
INSERT INTO Produtos VALUES 
    (1, 'DVD', 100, 50.00), 
    (2, 'LIQUIDIFICADOR', 30, 180.00);

-- Ver estoque ANTES
SELECT * FROM Produtos;
-- DVD: 100 unidades

-- Inserir item do pedido (a trigger dispara automaticamente!)
INSERT INTO ItemPedido VALUES (1, 11, 5);

-- Ver estoque DEPOIS
SELECT * FROM Produtos;
-- DVD: 95 unidades (100 - 5) ✅ TRIGGER FUNCIONOU!
```

💡 **Você não precisou fazer UPDATE manualmente!**

---

## 📊 Exemplo 2: Auditoria Automática de Alterações

### Cenário

Registrar **quem alterou**, **quando alterou** e **qual foi a alteração** nos preços dos produtos.

### Tabela de Auditoria

```sql
CREATE TABLE tab_audit (
    codigo INT AUTO_INCREMENT, 
    usuario CHAR(30) NOT NULL, 
    estacao CHAR(30) NOT NULL, 
    dataautitoria DATETIME NOT NULL, 
    codigo_Produto INT NOT NULL, 
    preco_unitario_novo DECIMAL(10,4) NOT NULL, 
    preco_unitario_antigo DECIMAL(10,4) NOT NULL, 
    PRIMARY KEY(codigo)
);
```

### Trigger de Auditoria

```sql
DELIMITER //

CREATE TRIGGER Audita 
AFTER UPDATE ON PRODUTOS
FOR EACH ROW 
BEGIN
    -- Captura valores antigos e novos
    SET @CODIGOPRODUTO = OLD.CODIGOPRODUTO;
    SET @PRECONOVO = NEW.PRECO;
    SET @PRECOANTIGO = OLD.PRECO;
    
    -- Registra a alteração na tabela de auditoria
    INSERT INTO TAB_AUDIT 
        (usuario, estacao, dataautitoria, codigo_Produto, 
         preco_unitario_novo, preco_unitario_antigo)
    VALUES 
        (CURRENT_USER, USER(), CURRENT_DATE, @CODIGOPRODUTO, 
         @PRECONOVO, @PRECOANTIGO);
END //

DELIMITER ;
```

### Testando

```sql
-- Alterar preço do produto
UPDATE produtos SET preco = 202.50 WHERE codigoproduto = 2; 

-- Ver o produto atualizado
SELECT * FROM Produtos;

-- Ver a auditoria (registro automático!)
SELECT * FROM tab_audit;
```

**Resultado da Auditoria:**
```
codigo | usuario | estacao | dataautitoria | codigo_Produto | preco_novo | preco_antigo
1      | root    | root@%  | 2024-04-04    | 2              | 202.50     | 180.00
```

✅ **Tudo registrado automaticamente pela trigger!**

---

## 📋 Tabela Resumo: NEW e OLD

| Evento | NEW disponível? | OLD disponível? | Uso comum |
|--------|----------------|-----------------|-----------|
| **INSERT** | ✅ Sim (valor inserido) | ❌ Não | Validar dados novos |
| **UPDATE** | ✅ Sim (valor novo) | ✅ Sim (valor antigo) | Auditoria, comparações |
| **DELETE** | ❌ Não | ✅ Sim (valor deletado) | Backup antes de deletar |

---

## 🗑️ Gerenciando Triggers

### Listar Triggers

```sql
-- Ver todas as triggers do banco atual
SHOW TRIGGERS;

-- Ver triggers de uma tabela específica
SHOW TRIGGERS WHERE `Table` = 'Produtos';
```

### Excluir Trigger

```sql
DROP TRIGGER Audita;
```

⚠️ **Não há confirmação! A trigger será deletada imediatamente.**

---

## ⚠️ Cuidados Importantes

### 1️⃣ Triggers não podem chamar CALL

❌ **ERRADO:**
```sql
CREATE TRIGGER teste AFTER INSERT ON tabela
FOR EACH ROW
BEGIN
    CALL sp_minhaStoredProcedure(); -- NÃO FUNCIONA!
END;
```

### 2️⃣ Evite triggers em cascata

Trigger A → dispara Trigger B → dispara Trigger C = CONFUSÃO!

### 3️⃣ Performance

Triggers executam a CADA linha modificada. Em operações com milhões de linhas, pode ser lento.

### 4️⃣ Debugging é difícil

Triggers são invisíveis. Se algo der errado, é mais difícil de debugar.

---

## 🎯 Quando Usar Triggers?

### ✅ Use triggers para:

- Auditoria automática
- Atualizar tabelas relacionadas
- Validações complexas
- Manter integridade referencial customizada
- Registrar histórico de alterações

### ❌ Evite triggers para:

- Lógica de negócio complexa (use Stored Procedures)
- Cálculos pesados
- Operações que precisam de controle manual
- Quando a aplicação já faz o controle

---

## ✏️ Atividade Prática

### 📝 Atividade 2 — Criando Triggers

**Objetivo:** Criar triggers para controle de estoque e auditoria

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

---

## ✅ Resumo do Bloco 2

Neste bloco você aprendeu:

- O que são Triggers e quando usá-las
- Diferença entre BEFORE e AFTER
- Operadores NEW (valores novos) e OLD (valores antigos)
- Criar triggers para eventos INSERT, UPDATE, DELETE
- Implementar auditoria automática
- Atualizar estoque automaticamente
- Excluir triggers

---

## 🎯 Conceitos-chave para fixar

💡 **Trigger = ação automática em resposta a evento**

💡 **BEFORE = antes do evento | AFTER = depois do evento**

💡 **NEW = novos valores | OLD = valores antigos**

💡 **FOR EACH ROW = executa para cada linha afetada**

💡 **Triggers são invisíveis para o usuário**

---

## ➡️ Próximos Passos

No próximo bloco você vai aprender:

- O que são Functions
- Diferença entre Function e Stored Procedure
- Criar funções para cálculos reutilizáveis
- Functions determinísticas
- Usar functions em SELECTs

---

## 📚 Comandos SQL Aprendidos

```sql
-- Criar trigger
DELIMITER //
CREATE TRIGGER nome
[BEFORE|AFTER] [INSERT|UPDATE|DELETE] ON tabela
FOR EACH ROW
BEGIN
    -- código usando NEW.coluna ou OLD.coluna
END //
DELIMITER ;

-- Listar triggers
SHOW TRIGGERS;

-- Excluir trigger
DROP TRIGGER nome_trigger;
```

---

> 💭 *"Triggers são como seguranças invisíveis: trabalham 24/7 protegendo e mantendo seus dados, sem você precisar pedir."*
