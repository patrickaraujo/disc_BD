# 📘 Bloco 3 — Functions: Cálculos Reutilizáveis

> **Duração estimada:** 50 minutos  
> **Objetivo:** Criar funções para cálculos e transformações reutilizáveis

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que são Functions e quando usá-las
- Diferenciar Function de Stored Procedure
- Criar functions determinísticas
- Usar functions em consultas SELECT
- Aplicar functions para cálculos de descontos
- Combinar functions com procedures
- Gerenciar functions

---

## 💡 O que são Functions?

### Definição

**Function** (Função) é um objeto do banco de dados que **sempre retorna um valor** e pode ser usado em expressões SQL, como em cláusulas SELECT, WHERE, etc.

### Analogia

Pense em uma **calculadora programável**:
- Você programa a fórmula (cria a function)
- Passa os números (parâmetros)
- Ela **sempre retorna um resultado**
- Você pode usar em qualquer cálculo

---

## 🆚 Function vs Stored Procedure

| Aspecto | Function | Stored Procedure |
|---------|----------|------------------|
| **Retorno** | ✅ Sempre retorna valor | ⚠️ Opcional |
| **Uso em SELECT** | ✅ Pode usar | ❌ Não pode |
| **Modificar dados** | ⚠️ Não recomendado | ✅ Sim |
| **Chamada** | `SELECT fn_nome()` | `CALL sp_nome()` |
| **Objetivo** | Cálculos, transformações | Lógica de negócio |

---

## 📝 Sintaxe Básica

```sql
CREATE FUNCTION nome_funcao (parametros)
RETURNS tipo_retorno
RETURN expressao;
```

### Exemplo simples:

```sql
CREATE FUNCTION fn_dobro (x INT)
RETURNS INT
RETURN (x * 2);
```

**Usando:**
```sql
SELECT fn_dobro(5); -- Retorna: 10
```

---

## ⚙️ Configuração Necessária

Antes de criar functions, execute:

```sql
SET GLOBAL log_bin_trust_function_creators = 1;
```

**Por quê?**  
MySQL exige que functions sejam determinísticas (mesmo input = mesmo output) ou que não modifiquem dados. Essa configuração relaxa essa restrição.

---

## 🛠️ Exemplo Prático Completo: Sistema de Vinícola

### Cenário

Uma vinícola quer oferecer **10% de desconto** em pagamentos à vista. Em vez de calcular manualmente toda vez, vamos criar uma function.

### Tabela

```sql
CREATE TABLE Vinho (
    codbar INT, 
    nome VARCHAR(20), 
    preco DECIMAL(4,2), 
    PRIMARY KEY (codbar)
);

INSERT INTO Vinho VALUES 
    (1, 'Vinho AAA', 21.90),
    (2, 'Vinho BBB', 20.50),
    (3, 'Vinho CCC', 35.10),
    (4, 'Vinho DDD', 99.00),
    (5, 'Vinho EEE', 50.00);
```

---

### Passo 1: Criar a Function

```sql
CREATE FUNCTION fn_desconto (x DECIMAL(5,2), y FLOAT) 
RETURNS DECIMAL(5,2)
RETURN (x * y);
```

**Parâmetros:**
- `x` = preço original
- `y` = percentual (0.90 = 10% desconto, 0.85 = 15% desconto)

**Retorna:** preço com desconto

---

### Passo 2: Criar Procedure que Usa a Function

```sql
CREATE PROCEDURE proc_desconto (VAR_VinhoCodBar INT)
SELECT 
    (fn_desconto(Preco, 0.90)) AS 'Valor com desconto', 
    Nome AS 'Vinho'
FROM Vinho
WHERE CodBar = VAR_VinhoCodBar;
```

---

### Passo 3: Usando

```sql
-- Opção 1: Via procedure
CALL proc_desconto(5);
```

**Resultado:**
```
Valor com desconto | Vinho
45.00              | Vinho EEE
```

```sql
-- Opção 2: Direto no SELECT
SELECT 
    Preco AS 'Valor normal', 
    fn_desconto(Preco, 0.90) AS 'Valor com desconto', 
    Nome AS 'Vinho'
FROM Vinho
WHERE CodBar = 5;
```

**Resultado:**
```
Valor normal | Valor com desconto | Vinho
50.00        | 45.00              | Vinho EEE
```

---

## 🔢 Exemplo 2: Formatação de Datas

```sql
-- Formatar data no formato brasileiro
SELECT 
    usuario, 
    DATE_FORMAT(dataautitoria, '%d/%m/%Y') AS 'data_formatada' 
FROM tab_audit;

-- Formatar data e hora
SELECT 
    usuario, 
    DATE_FORMAT(dataautitoria, '%d/%m/%Y às %Hh%i') AS 'data_formatada' 
FROM tab_audit;
```

**DATE_FORMAT** é uma function built-in (nativa) do MySQL!

---

## 💡 Functions Built-in Úteis

### Funções de Data

```sql
-- Data atual
SELECT CURRENT_DATE;      -- 2024-04-04
SELECT CURDATE();         -- 2024-04-04

-- Data e hora
SELECT NOW();             -- 2024-04-04 15:30:00
SELECT CURRENT_TIMESTAMP; -- 2024-04-04 15:30:00

-- Extrair partes
SELECT YEAR(NOW());       -- 2024
SELECT MONTH(NOW());      -- 4
SELECT DAY(NOW());        -- 4
```

### Funções de String

```sql
-- Concatenar
SELECT CONCAT('Rua ABC', ', ', '123'); -- Rua ABC, 123

-- Maiúscula/Minúscula
SELECT UPPER('texto');    -- TEXTO
SELECT LOWER('TEXTO');    -- texto

-- Substring
SELECT SUBSTRING('MySQL', 1, 2); -- My
```

### Funções Matemáticas

```sql
SELECT ROUND(15.7);       -- 16
SELECT FLOOR(15.7);       -- 15
SELECT CEIL(15.3);        -- 16
SELECT ABS(-10);          -- 10
SELECT POW(2, 3);         -- 8
```

---

## 🗑️ Gerenciando Functions

### Listar Functions

```sql
-- Ver todas as functions do banco atual
SHOW FUNCTION STATUS WHERE Db = DATABASE();

-- Ver código da function
SHOW CREATE FUNCTION fn_desconto;
```

### Excluir Function

```sql
DROP FUNCTION fn_desconto;
```

---

## 🎯 Quando Usar Functions?

### ✅ Use functions para:

- Cálculos matemáticos reutilizáveis
- Conversões e formatações
- Validações que retornam boolean
- Transformações de dados
- Expressões complexas em SELECT/WHERE

### ❌ Evite functions para:

- Modificar dados (INSERT/UPDATE/DELETE)
- Lógica de negócio complexa (use Procedures)
- Operações pesadas que afetam performance
- Quando você não precisa usar em SELECT

---

## 🎨 Exemplo Avançado: Validação de CPF

```sql
DELIMITER //

CREATE FUNCTION fn_validaCPF(cpf CHAR(11))
RETURNS BOOLEAN
BEGIN
    DECLARE valido BOOLEAN DEFAULT FALSE;
    
    -- Verifica se tem 11 dígitos
    IF LENGTH(cpf) = 11 THEN
        SET valido = TRUE;
    END IF;
    
    RETURN valido;
END //

DELIMITER ;
```

**Usando:**
```sql
SELECT 
    usuario_nome,
    usuario_CPF,
    fn_validaCPF(usuario_CPF) AS 'CPF Válido'
FROM usuario;
```

---

## ⚠️ Cuidados Importantes

### 1️⃣ Functions devem ser determinísticas

Mesmo input deve sempre gerar mesmo output.

❌ **EVITE:**
```sql
CREATE FUNCTION fn_hora()
RETURNS TIME
RETURN NOW(); -- Não é determinístico!
```

### 2️⃣ Não modifique dados em functions

❌ **EVITE:**
```sql
CREATE FUNCTION fn_teste()
RETURNS INT
BEGIN
    UPDATE tabela SET campo = 1; -- NÃO FAÇA ISSO!
    RETURN 1;
END;
```

### 3️⃣ Performance

Functions executam a CADA linha em um SELECT. Em grandes datasets, pode ser lento.

---

## ✏️ Atividade Prática

### 📝 Atividade 3 — Criando Functions

**Objetivo:** Criar functions para cálculos e transformações

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

---

## ✅ Resumo do Bloco 3

Neste bloco você aprendeu:

- O que são Functions e quando usá-las
- Diferença entre Function e Stored Procedure
- Functions sempre retornam valor
- Usar functions em SELECT, WHERE, etc.
- Criar functions para cálculos de desconto
- Functions built-in úteis (DATE_FORMAT, CONCAT, etc.)
- Gerenciar functions

---

## 🎯 Conceitos-chave para fixar

💡 **Function = sempre retorna valor**

💡 **Pode usar em SELECT, WHERE, ORDER BY**

💡 **Ideal para cálculos e transformações**

💡 **Não deve modificar dados**

💡 **Prefixo fn_ é boa prática**

---

## ➡️ Próximos Passos

No próximo bloco você vai aprender:

- O que são Views
- Criar "tabelas virtuais"
- Simplificar consultas complexas
- Views atualizáveis
- Segurança com views

---

## 📚 Comandos SQL Aprendidos

```sql
-- Configurar antes de criar functions
SET GLOBAL log_bin_trust_function_creators = 1;

-- Criar function
CREATE FUNCTION nome(params)
RETURNS tipo
RETURN expressao;

-- Usar function
SELECT fn_nome(valor);

-- Listar functions
SHOW FUNCTION STATUS WHERE Db = DATABASE();

-- Ver código
SHOW CREATE FUNCTION nome;

-- Excluir function
DROP FUNCTION nome;
```

---

> 💭 *"Functions são como fórmulas do Excel: crie uma vez, use em qualquer lugar, sempre com o resultado correto."*
