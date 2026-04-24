# 📘 Bloco 4 — Views: Simplificando Consultas Complexas

> **Duração estimada:** 60 minutos  
> **Objetivo:** Criar tabelas virtuais para simplificar consultas recorrentes

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que são Views e quando usá-las
- Criar views simples e complexas
- Usar views com JOINs e GROUP BY
- Atualizar dados através de views
- Implementar segurança com views
- Gerenciar views
- Escolher entre views e tabelas reais

---

## 💡 O que são Views?

### Definição

**View** (Visão) é uma **tabela virtual** baseada no resultado de uma consulta SELECT. Ela não armazena dados fisicamente, apenas a **definição da consulta**.

### Analogia

Pense em um **atalho no desktop**:
- O atalho (view) aponta para um programa (consulta SELECT)
- Ao clicar (consultar a view), executa o programa (roda o SELECT)
- Se o programa muda, o atalho continua funcionando
- Você não duplica o programa, só cria um acesso rápido

---

## 🎯 Por que Usar Views?

### Problema Sem Views

Imagine que você escreve esta consulta 10 vezes por dia:

```sql
SELECT p.numero, c.nome AS cliente, pr.descricao AS produto, p.valor_total
FROM pedido p
INNER JOIN cliente c ON p.cliente_id = c.id
INNER JOIN item_pedido ip ON p.id = ip.pedido_id
INNER JOIN produto pr ON ip.produto_id = pr.id
WHERE p.status = 'ATIVO';
```

**Problemas:**
- ❌ Retrabalho constante
- ❌ Risco de erro ao reescrever
- ❌ Difícil manter consistência
- ❌ Se mudar estrutura, atualizar em 10 lugares

---

### Solução Com View

```sql
-- Criar a view UMA VEZ
CREATE VIEW vw_pedidos_ativos AS
SELECT p.numero, c.nome AS cliente, pr.descricao AS produto, p.valor_total
FROM pedido p
INNER JOIN cliente c ON p.cliente_id = c.id
INNER JOIN item_pedido ip ON p.id = ip.pedido_id
INNER JOIN produto pr ON ip.produto_id = pr.id
WHERE p.status = 'ATIVO';

-- Usar sempre que precisar
SELECT * FROM vw_pedidos_ativos;
```

✅ **Simples, rápido e sem erros!**

---

## 📝 Sintaxe Básica

```sql
CREATE [OR REPLACE] VIEW nome_view [(colunas)]
AS
SELECT ...
[WITH CHECK OPTION];
```

**Parâmetros:**
- `OR REPLACE` → Substitui view existente
- `(colunas)` → Renomeia colunas (opcional)
- `WITH CHECK OPTION` → Valida modificações

---

## 🛠️ Exemplo 1: View Simples

### Usando banco World
> Se não estiver já disponível no MySQL é possível baixar no [site](https://dev.mysql.com/doc/index-other.html) (também disponível aqui no diretório `world-db`).

```sql
USE world;

-- Ver tabelas disponíveis
SHOW TABLES;

-- Criar view simples: apenas ID e Nome das cidades
CREATE VIEW vw_ViewCity AS 
SELECT ID, Name 
FROM city;

-- Consultar a view
SELECT * FROM vw_ViewCity LIMIT 3;
```

**Verificar:**
```sql
SHOW TABLES;
-- Agora aparece "vw_ViewCity" como se fosse uma tabela!
```

---

## 🏷️ Exemplo 2: Renomeando Colunas

```sql
-- Criar view com nome de coluna customizado
CREATE OR REPLACE VIEW vw_ViewCity (Cidade) AS 
SELECT Name 
FROM City;

-- Consultar
SELECT * FROM vw_ViewCity LIMIT 3;
```

**Resultado:**
```
Cidade
Kabul
Qandahar
Herat
```

---

## 🔗 Exemplo 3: View com JOINs e GROUP BY

### Contar quantas línguas se falam em cada país

```sql
CREATE OR REPLACE VIEW vw_CountryLangCount AS
SELECT 
    Name, 
    COUNT(language) AS LangCount
FROM Country, CountryLanguage
WHERE code = countrycode 
GROUP BY name;

-- Consultar
SELECT * FROM vw_CountryLangCount ORDER BY name LIMIT 3;

-- Buscar país específico
SELECT * FROM vw_CountryLangCount WHERE name = 'Brazil';
```

---

## 🔄 Views Atualizáveis

Views podem receber INSERT, UPDATE e DELETE **se forem simples**.

### Quando uma view É atualizável:

✅ SELECT sem GROUP BY  
✅ SELECT sem funções agregadas (COUNT, SUM, etc)  
✅ SELECT sem DISTINCT  
✅ SELECT de uma única tabela (ou JOINs simples)  

### Quando NÃO é atualizável:

❌ Usa GROUP BY  
❌ Usa funções agregadas  
❌ Usa DISTINCT  
❌ JOINs complexos  

---

### Exemplo: View Atualizável

```sql
-- Criar tabela de teste
CREATE TABLE CountryPop 
SELECT name, population, continent 
FROM Country;

-- Criar view atualizável
CREATE VIEW vw_EuroPop AS 
SELECT Name, population 
FROM CountryPop 
WHERE continent = 'Europe';

-- Ver dados
SELECT * FROM vw_EuroPop WHERE name = 'San Marino';

-- ATUALIZAR via view
UPDATE vw_EuroPop 
SET Population = Population + 1 
WHERE name = 'San Marino';

-- Verificar (view E tabela foram atualizadas!)
SELECT * FROM vw_EuroPop WHERE name = 'San Marino';
SELECT * FROM CountryPop WHERE name = 'San Marino';
```

✅ **A view atualizou a tabela base!**

---

### Exemplo: View NÃO Atualizável

```sql
-- Tentar atualizar view com GROUP BY
UPDATE vw_CountryLangCount 
SET name = 'Albania II' 
WHERE name = 'Albania';
```

**Erro:**
```
Error Code: 1288. The target table vw_CountryLangCount 
of the UPDATE is not updatable
```

❌ **Não funciona porque usa GROUP BY!**

---

## 🔐 Views para Segurança

Views permitem **controlar o que cada usuário vê**.

### Exemplo

```sql
-- Tabela completa (dados sensíveis)
CREATE TABLE funcionario (
    id INT,
    nome VARCHAR(50),
    salario DECIMAL(10,2),
    departamento VARCHAR(30)
);

-- View pública (sem salário)
CREATE VIEW vw_func_publico AS
SELECT id, nome, departamento
FROM funcionario;

-- Dar acesso apenas à view
GRANT SELECT ON vw_func_publico TO 'usuario_comum'@'localhost';
```

💡 **Usuário comum vê nomes, mas NÃO vê salários!**

---

## 🎨 Exemplo Avançado: View com CONCAT

```sql
CREATE TABLE Imovel (
    idImovel INT UNSIGNED NOT NULL AUTO_INCREMENT,
    QtdeQuartos SMALLINT UNSIGNED NOT NULL,
    QtdeBanheiros SMALLINT UNSIGNED NOT NULL,
    VistaMar ENUM('N', 'S') NOT NULL,
    Logradouro VARCHAR(50) NOT NULL,
    Numero SMALLINT UNSIGNED NOT NULL,
    Complemento VARCHAR(25) NULL,
    Bairro VARCHAR(35) NOT NULL,
    CEP INT ZEROFILL UNSIGNED NOT NULL,
    PRIMARY KEY (idImovel)
);

-- View com endereço concatenado
CREATE OR REPLACE VIEW vw_ImovelCompleto AS 
SELECT 
    IdImovel, 
    QtdeQuartos, 
    QtdeBanheiros, 
    VistaMar, 
    CONCAT(Logradouro, ', ', Numero, ', ', Complemento, ', ', 
           Bairro, ', ', CEP) AS 'Endereço Completo'
FROM imovel;

-- Consultar
SELECT * FROM vw_ImovelCompleto;
```

---

## 🗑️ Gerenciando Views

### Listar Views

```sql
-- Ver todas as views do banco atual
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Ver código da view
SHOW CREATE VIEW vw_ViewCity;
```

### Alterar View

```sql
-- Opção 1: Usar OR REPLACE
CREATE OR REPLACE VIEW vw_teste AS
SELECT ...;

-- Opção 2: Usar ALTER
ALTER VIEW vw_teste AS
SELECT ...;
```

### Excluir View

```sql
DROP VIEW vw_EuroPop;
```

---

## 📊 View vs Tabela Real

| Aspecto | View | Tabela Real |
|---------|------|-------------|
| **Armazena dados** | ❌ Não | ✅ Sim |
| **Ocupa espaço** | ❌ Mínimo | ✅ Sim |
| **Performance leitura** | ⚠️ Depende da consulta | ✅ Rápido |
| **Atualização** | ⚠️ Limitada | ✅ Total |
| **Manutenção** | ✅ Fácil | ⚠️ Mais trabalhosa |
| **Usa dados atuais** | ✅ Sempre | ⚠️ Precisa atualizar |

---

## 🎯 Quando Usar Views?

### ✅ Use views para:

- Consultas complexas repetidas
- Simplificar acesso para usuários
- Segurança (ocultar colunas sensíveis)
- Padronizar consultas em equipes
- Compatibilidade (manter interface antiga após mudanças)

### ❌ Evite views para:

- Operações que precisam de alta performance
- Quando precisa modificar dados frequentemente
- Views muito complexas (muitos JOINs)
- Dados que mudam o tempo todo

---

## ✏️ Atividade Prática

### 📝 Atividade 4 — Criando Views

**Objetivo:** Criar views para simplificar consultas

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

---

## ✅ Resumo do Bloco 4

Neste bloco você aprendeu:

- O que são Views (tabelas virtuais)
- Criar views simples e complexas
- Usar views com JOINs, GROUP BY, CONCAT
- Views atualizáveis vs não atualizáveis
- Implementar segurança com views
- Gerenciar views (criar, alterar, excluir)
- Quando usar views vs tabelas reais

---

## 🎯 Conceitos-chave para fixar

💡 **View = tabela virtual (não armazena dados)**

💡 **Simplifica consultas complexas repetidas**

💡 **Pode ser atualizável se for simples**

💡 **Ótima para segurança e padronização**

💡 **Prefixo vw_ é boa prática**

---

## 🎓 Conclusão da Aula 11

Parabéns! Você completou todos os 4 blocos sobre **Objetos Avançados de BD**:

✅ **Bloco 1** - Stored Procedures (lógica reutilizável)  
✅ **Bloco 2** - Triggers (ações automáticas)  
✅ **Bloco 3** - Functions (cálculos reutilizáveis)  
✅ **Bloco 4** - Views (consultas simplificadas)  

**Agora você sabe:**
- Automatizar tarefas com procedures
- Proteger dados com triggers
- Reutilizar cálculos com functions
- Simplificar acessos com views

---

## 📚 Comandos SQL Aprendidos

```sql
-- Criar view
CREATE [OR REPLACE] VIEW nome AS
SELECT ...;

-- Consultar view
SELECT * FROM nome_view;

-- Atualizar via view
UPDATE nome_view SET ... WHERE ...;

-- Listar views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Ver código
SHOW CREATE VIEW nome;

-- Alterar view
ALTER VIEW nome AS SELECT ...;

-- Excluir view
DROP VIEW nome;
```

---

> 💭 *"Views são como janelas para seus dados: você vê apenas o que precisa, da forma que precisa, sem tocar nos dados reais."*
