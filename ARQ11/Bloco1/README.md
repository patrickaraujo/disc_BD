# 📘 Bloco 1 — Stored Procedures: Automatizando Tarefas Repetitivas

> **Duração estimada:** 60 minutos  
> **Objetivo:** Criar e utilizar procedimentos armazenados para encapsular lógica de negócio

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que são Stored Procedures e quando usá-las
- Criar procedures com e sem parâmetros
- Implementar validações dentro de procedures
- Executar (chamar) procedures
- Modificar e excluir procedures
- Compreender as vantagens de usar procedures

---

## 💡 O que são Stored Procedures?

### Definição

**Stored Procedure** (Procedimento Armazenado) é uma coleção de instruções SQL que ficam **armazenadas no servidor do banco de dados** de forma **pré-compilada**, aguardando que um usuário faça sua execução/chamada.

### Analogia

Pense em uma **receita de bolo guardada num caderno**:
- A receita (procedure) fica guardada (armazenada no BD)
- Você não precisa reescrevê-la toda vez
- Basta dizer "faça o bolo de chocolate" (chamar a procedure)
- Os ingredientes mudam (parâmetros), mas o processo é o mesmo

---

## ✨ Vantagens das Stored Procedures

### 1️⃣ Modularidade e Reutilização

```sql
-- SEM procedure: você escreve isso em 10 lugares diferentes
INSERT INTO usuario VALUES (...);
-- validações...
-- mensagens...

-- COM procedure: você escreve UMA VEZ e usa em 10 lugares
CALL sp_insereUsuario(parametros);
```

**Benefício:** Altere em um lugar, reflete em todo o sistema!

---

### 2️⃣ Diminuição de Tráfego de Rede (I/O)

**Sem procedure:**
```
Aplicação → Envia INSERT completo → Servidor
Aplicação → Envia UPDATE completo → Servidor  
Aplicação → Envia SELECT completo → Servidor
```

**Com procedure:**
```
Aplicação → CALL sp_nome(parametros) → Servidor
            ↓
         Executa tudo no servidor
            ↓
         Retorna apenas resultado
```

💡 **Menos dados trafegando = mais rápido!**

---

### 3️⃣ Rapidez na Execução

- Procedures ficam **pré-compiladas** na memória cache
- As ações já estão **pré-carregadas**
- Após a primeira execução, ficam ainda mais rápidas
- Dependem apenas dos valores dos parâmetros

---

### 4️⃣ Segurança

- Usuários podem executar procedures **sem acesso direto às tabelas**
- Você controla **o que** pode ser feito
- Evita SQL Injection em aplicações

---

## 📝 Sintaxe Básica

```sql
DELIMITER //

CREATE PROCEDURE nome_procedure ([parâmetros])
BEGIN
    -- Corpo da procedure
    -- Instruções SQL
END //

DELIMITER ;
```

### Entendendo cada parte:

**DELIMITER //**
- Muda o delimitador padrão de `;` para `//`
- Por quê? Porque vamos usar `;` dentro da procedure
- Sem isso, o MySQL tentaria executar antes de terminar

**nome_procedure**
- Nome que você escolhe
- Boa prática: prefixo `sp_` (stored procedure)
- Exemplo: `sp_insereUsuario`

**[parâmetros]**
- Opcional
- Formato: `nome_parametro TIPO`
- Exemplo: `v_CPF char(11), v_nome varchar(20)`

**BEGIN...END**
- Delimita o corpo da procedure
- Todas as instruções SQL ficam aqui

**DELIMITER ;**
- Volta o delimitador ao padrão `;`

---

## 🛠️ Exemplo Prático Completo

### Cenário

Você tem uma tabela de usuários:

```sql
CREATE TABLE usuario (
    usuario_CPF char(11), 
    usuario_nome varchar(20), 
    usuario_email varchar(35), 
    dt_cadastro datetime, 
    PRIMARY KEY (usuario_CPF)
);
```

**Problema:** Precisamos inserir usuários, mas:
- CPF não pode ser nulo
- Nome não pode ser nulo
- Email não pode ser nulo
- Data não pode ser nula

Se escrevermos esse código em 10 lugares diferentes, vira uma bagunça!

---

### Solução: Stored Procedure

```sql
DELIMITER //

CREATE PROCEDURE sp_InsereUsuario(
    v_CPF char(11), 
    v_nome varchar(20),
    v_email varchar(35), 
    v_dt_cadastro datetime
)
BEGIN
    -- Validação: todos os parâmetros devem ter valor
    IF (v_cpf IS NOT NULL AND v_nome IS NOT NULL AND 
        v_email IS NOT NULL AND v_dt_cadastro IS NOT NULL) 
    THEN
        BEGIN
            -- Se tudo OK, insere
            INSERT INTO usuario VALUES (v_CPF, v_nome, v_email, v_dt_cadastro);
            SELECT 'Os registros foram inseridos com sucesso';
        END;
    ELSE
        BEGIN
            -- Se algum parâmetro estiver nulo, avisa
            SELECT 'Parâmetros inadequados';
        END;
    END IF;
END //

DELIMITER ;
```

---

### Executando a Procedure

```sql
-- Chamada correta (todos os parâmetros)
CALL sp_insereUsuario('03478956212', 'Rubens Zampar', 
                      'rzampar@prof.unisa.br', '20221003');

-- Chamada com email vazio (vai dar erro)
CALL sp_insereUsuario('03788856955', 'Santiago Oliveira', '', '20221003');

-- Chamada com parâmetro NULL (vai dar erro)
CALL sp_insereUsuario('04166656933', 'Juca Pereira', null, null);
```

**Resultado:**
- Primeira chamada: ✅ "Os registros foram inseridos com sucesso"
- Segunda e terceira: ❌ "Parâmetros inadequados"

---

## 🔍 Exemplo 2: Procedure de Consulta

```sql
DELIMITER //

CREATE PROCEDURE sp_consultaUsuario (v_CPF char(11))
BEGIN
    IF (v_cpf IS NOT NULL) THEN
        -- Se passou CPF, busca específico
        SELECT * FROM usuario WHERE usuario_cpf = v_cpf;
    ELSE
        -- Se passou NULL, lista todos
        SELECT * FROM usuario;
    END IF;
END //

DELIMITER ;
```

**Executando:**

```sql
-- Consultar usuário específico
CALL sp_consultaUsuario('03478956212');

-- Consultar TODOS os usuários
CALL sp_consultaUsuario(null);
```

💡 **Uma procedure, dois comportamentos!**

---

## 🗑️ Exemplo 3: Procedure de Exclusão

```sql
DELIMITER //

CREATE PROCEDURE sp_deleteUsuario(v_CPF char(11))
BEGIN
    IF (v_cpf IS NOT NULL) THEN
        -- Deleta usuário específico
        DELETE FROM usuario WHERE usuario_cpf = v_cpf;
    ELSE
        -- ⚠️ CUIDADO: deleta TODOS!
        DELETE FROM usuario;
    END IF;
END //

DELIMITER ;
```

**Executando:**

```sql
-- Deletar usuário específico
CALL sp_deleteUsuario('03478956212');

-- ⚠️ PERIGOSO: Deletar todos
CALL sp_deleteUsuario(null);
```

---

## 🛡️ Cuidados Importantes

### ⚠️ Transações

```sql
-- Se quiser testar sem comprometer dados:
START TRANSACTION;

CALL sp_deleteUsuario('03478956212');
SELECT * FROM usuario; -- Verifica

ROLLBACK;  -- Desfaz tudo
-- OU
COMMIT;    -- Confirma as alterações
```

---

### 🗑️ Excluindo uma Procedure

```sql
DROP PROCEDURE sp_deleteUsuario;
```

⚠️ **Cuidado:** Não há confirmação! A procedure será deletada imediatamente.

---

### 📝 Listando Procedures Existentes

```sql
-- Ver todas as procedures do banco atual
SHOW PROCEDURE STATUS WHERE Db = DATABASE();

-- Ver o código de uma procedure específica
SHOW CREATE PROCEDURE sp_insereUsuario;
```

---

## 🎯 Boas Práticas

### ✅ Nomenclatura

- Use prefixo `sp_` para stored procedures
- Nomes descritivos: `sp_insereUsuario`, não `sp_iu`
- CamelCase ou snake_case, seja consistente

### ✅ Validação

- **SEMPRE** valide parâmetros de entrada
- Retorne mensagens claras de erro
- Use `IF...THEN...ELSE`

### ✅ Documentação

```sql
DELIMITER //

-- =====================================================
-- Procedure: sp_insereUsuario
-- Descrição: Insere novo usuário com validação
-- Parâmetros:
--   v_CPF: CPF do usuário (11 dígitos)
--   v_nome: Nome completo
--   v_email: Email válido
--   v_dt_cadastro: Data de cadastro
-- Retorna: Mensagem de sucesso ou erro
-- =====================================================
CREATE PROCEDURE sp_insereUsuario(...)
BEGIN
    ...
END //
```

---

## ✏️ Atividade Prática

### 📝 Atividade 1 — Criando suas Próprias Procedures

**Objetivo:** Criar procedures para gerenciar produtos

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

---

## ✅ Resumo do Bloco 1

Neste bloco você aprendeu:

- O que são Stored Procedures
- Vantagens: modularidade, performance, segurança
- Como criar procedures com parâmetros
- Como executar procedures com CALL
- Como validar dados dentro de procedures
- Como excluir procedures

---

## 🎯 Conceitos-chave para fixar

💡 **Stored Procedure = código SQL reutilizável no servidor**

💡 **DELIMITER // necessário para usar ; dentro da procedure**

💡 **CALL nomeProcedure(parametros) para executar**

💡 **Sempre valide parâmetros!**

💡 **Prefixo sp_ é boa prática**

---

## ➡️ Próximos Passos

No próximo bloco você vai aprender:

- O que são Triggers
- Diferença entre BEFORE e AFTER
- Como automatizar ações em INSERT/UPDATE/DELETE
- Auditoria automática de alterações
- Atualização automática de estoque

---

## 📚 Comandos SQL Aprendidos

```sql
-- Criar procedure
DELIMITER //
CREATE PROCEDURE nome(params)
BEGIN
    -- código
END //
DELIMITER ;

-- Executar procedure
CALL nome_procedure(valores);

-- Excluir procedure
DROP PROCEDURE nome_procedure;

-- Listar procedures
SHOW PROCEDURE STATUS WHERE Db = DATABASE();

-- Ver código da procedure
SHOW CREATE PROCEDURE nome_procedure;
```

---

> 💭 *"Stored Procedures são como funções em programação: escreva uma vez, use sempre que precisar."*
