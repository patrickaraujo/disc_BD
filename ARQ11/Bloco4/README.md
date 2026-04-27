# 📘 Bloco 4 — Views: Simplificando Consultas Complexas

> **Duração estimada:** 60 minutos  
> **Objetivo:** Criar tabelas virtuais para simplificar consultas recorrentes usando o banco World

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Entender o que são Views e quando usá-las
- Criar views simples e complexas
- Usar views com JOINs e GROUP BY
- Atualizar dados através de views
- Entender quando views são atualizáveis
- Criar views com múltiplas tabelas
- Usar CONCAT em views
- Gerenciar views

---

## 📦 Preparação: Banco de Dados World

### Sobre o Banco World

O banco **World** é um banco de dados de exemplo fornecido pelo MySQL que contém informações sobre:
- **city** - cidades do mundo
- **country** - países
- **countrylanguage** - idiomas falados em cada país

### Instalação do Banco World

> Se não estiver já disponível no MySQL é possível baixar no [site oficial](https://dev.mysql.com/doc/index-other.html).
> 
> Também está disponível no diretório `world-db/` desta aula.

**Para instalar:**
```sql
-- Via MySQL Workbench: File > Run SQL Script > selecione world.sql

-- Ou via linha de comando:
mysql -u root -p < world.sql
```

**Verificar instalação:**
```sql
SHOW DATABASES; -- Deve aparecer 'world'
USE world;
SHOW TABLES;   -- Deve mostrar: city, country, countrylanguage
```

---

## 💡 O que são Views?

### Definição

**View** (Visão) é uma **tabela virtual** baseada no resultado de uma consulta SELECT. Ela não armazena dados fisicamente, apenas a **definição da consulta**.

### Por que Views são Úteis?

Imagine escrever esta consulta 10 vezes por dia:

```sql
SELECT city.name, country.name, language 
FROM city 
INNER JOIN country ON city.CountryCode = country.code
INNER JOIN countrylanguage ON country.Code = countrylanguage.CountryCode;
```

Com uma view, você escreve **UMA VEZ** e usa sempre que precisar!

---

## 🛠️ Exemplo 1: View Simples

### Preparação

```sql
USE world;
SHOW TABLES; -- Ver tabelas disponíveis

-- Ver estrutura da tabela city
SELECT * FROM city LIMIT 5;
```

### Criando View Simples

```sql
-- Criar view que mostra apenas ID e Nome das cidades
CREATE VIEW vw_ViewCity AS 
SELECT ID, Name 
FROM city;

-- Consultar a view
SELECT * FROM vw_ViewCity LIMIT 3;
```

**Resultado:**
```
ID  | Name
----|----------
1   | Kabul
2   | Qandahar
3   | Herat
```

### Verificar que a View foi Criada

```sql
-- Views aparecem junto com as tabelas
SHOW TABLES;
```

Você verá `vw_ViewCity` listada como se fosse uma tabela!

---

## 🏷️ Exemplo 2: Renomeando Colunas na View

### Tentando Criar View com Mesmo Nome (ERRO)

```sql
-- Isso dará ERRO porque a view já existe
CREATE VIEW vw_ViewCity (Cidade) AS 
SELECT Name 
FROM city;
```

**Erro:**
```
Table 'vw_ViewCity' already exists
```

### Usar CREATE OR REPLACE

```sql
-- Substituir view existente
CREATE OR REPLACE VIEW vw_ViewCity (Cidade) AS 
SELECT Name 
FROM city;

-- Consultar view alterada
SELECT * FROM vw_ViewCity LIMIT 3;
```

**Resultado:**
```
Cidade
----------
Kabul
Qandahar
Herat
```

💡 **A coluna foi renomeada para "Cidade"!**

---

## 🌍 Exemplo 3: View com GROUP BY (Agregação)

### Contar Quantos Idiomas se Falam em Cada País

```sql
CREATE OR REPLACE VIEW vw_CountryLangCount AS
SELECT 
    Name, 
    COUNT(language) AS LangCount
FROM country, countrylanguage
WHERE code = countrycode 
GROUP BY name;
```

### Consultar a View

```sql
-- Ver primeiros 3 países
SELECT * FROM vw_CountryLangCount 
ORDER BY name 
LIMIT 3;

-- Ver quantos idiomas se falam no Brasil
SELECT * FROM vw_CountryLangCount 
WHERE name = 'Brazil';
```

### Comparar com Dados Originais

```sql
-- Ver idiomas do Brasil na tabela original
SELECT * FROM countrylanguage 
WHERE countrycode = 'BRA';
```

---

## 🔄 Views Atualizáveis vs Não Atualizáveis

### Quando Uma View É Atualizável?

✅ **É atualizável quando:**
- SELECT sem GROUP BY
- SELECT sem funções agregadas (COUNT, SUM, AVG, etc)
- SELECT sem DISTINCT
- Tem chave primária na tabela base
- JOINs simples

❌ **NÃO é atualizável quando:**
- Usa GROUP BY
- Usa funções agregadas
- Usa DISTINCT
- JOINs complexos

---

## 📝 Exemplo 4: Criando Tabela para View Atualizável

### Problema com Tabela Sem Chave Primária

```sql
-- Criar tabela SEM chave primária (não recomendado)
CREATE TABLE CountryPop 
SELECT name, population, continent 
FROM country;
```

❌ **Views sobre esta tabela podem não ser atualizáveis!**

### Solução: Criar com Chave Primária

```sql
-- Recriar tabela COM chave primária
DROP TABLE IF EXISTS CountryPop;

CREATE TABLE CountryPop (
    name VARCHAR(50) PRIMARY KEY,
    population INT,
    continent VARCHAR(50)
);

-- Inserir dados
INSERT INTO CountryPop 
SELECT name, population, continent 
FROM country;

-- Verificar
SELECT * FROM CountryPop LIMIT 5;
```

💡 **Por quê?** No MySQL, uma VIEW só permite UPDATE quando não há ambiguidade na identificação das linhas, o que exige uma chave única na tabela base.

---

## ✏️ Exemplo 5: View Atualizável

### Criar View de Países Europeus

```sql
CREATE VIEW vw_EuroPop AS 
SELECT name, population
FROM CountryPop 
WHERE continent = 'Europe';
```

### Consultar a View

```sql
SELECT * FROM vw_EuroPop 
WHERE name = 'San Marino';
```

### Atualizar VIA VIEW

```sql
-- Aumentar população em 1
UPDATE vw_EuroPop 
SET population = population + 1 
WHERE name = 'San Marino';

-- Verificar na view
SELECT * FROM vw_EuroPop 
WHERE name = 'San Marino';

-- Verificar na tabela original (também foi atualizada!)
SELECT name, population 
FROM CountryPop 
WHERE name = 'San Marino';
```

✅ **A view atualizou a tabela base!**

### Deletar VIA VIEW

```sql
-- Deletar registro via view
DELETE FROM vw_EuroPop 
WHERE name = 'San Marino';
```

### Limpar

```sql
DROP VIEW vw_EuroPop;
```

---

## ❌ Exemplo 6: View NÃO Atualizável (GROUP BY)

### Tentando Atualizar View com GROUP BY

```sql
-- Tentar atualizar view com agregação
UPDATE vw_CountryLangCount 
SET Name = 'Albania II' 
WHERE Name = 'Albania';
```

**Erro:**
```
Error Code: 1288. The target table vw_CountryLangCount 
of the UPDATE is not updatable
```

### Por Quê?

A VIEW `vw_CountryLangCount` não pode ser atualizada porque:
- Utiliza **GROUP BY**
- Utiliza **COUNT()** (função de agregação)
- O MySQL não consegue mapear o resultado para linhas específicas das tabelas originais

### Solução: Atualizar Tabela Base

```sql
-- Ver país original
SELECT * FROM country 
WHERE name LIKE '%Albania%';

-- Atualizar diretamente na tabela base
UPDATE country 
SET name = 'Albania II' 
WHERE code = 'ALB';
```

---

## 🔗 Exemplo 7: View com 3 Tabelas (INNER JOINs)

### Ver Estrutura das Tabelas

```sql
SELECT * FROM city LIMIT 3;
SELECT * FROM country LIMIT 3;
SELECT * FROM countrylanguage LIMIT 3;
```

### Criar View com 3 JOINs

```sql
CREATE OR REPLACE VIEW vw_TESTE AS 
SELECT 
    city.name AS 'Cidade', 
    country.name AS 'País', 
    language AS 'Idioma'
FROM city 
INNER JOIN country ON city.CountryCode = country.code
INNER JOIN countrylanguage ON country.Code = countrylanguage.CountryCode
ORDER BY language ASC;
```

### Consultar a View

```sql
-- Ver primeiras 10 linhas
SELECT * FROM vw_TESTE LIMIT 10;

-- Filtrar por idioma
SELECT * FROM vw_TESTE 
WHERE Idioma = 'Portuguese';

-- Filtrar por país
SELECT * FROM vw_TESTE 
WHERE País = 'Brazil'
LIMIT 10;
```

💡 **Uma consulta complexa agora é apenas `SELECT * FROM vw_TESTE`!**

---

## 📍 Exemplo 8: View com CONCAT (Concatenação)

### Criar Tabela de Imóveis

```sql
CREATE TABLE IF NOT EXISTS `world`.`Imovel` (
    `idImovel` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `QtdeQuartos` SMALLINT UNSIGNED NOT NULL,
    `QtdeBanheiros` SMALLINT UNSIGNED NOT NULL,
    `VistaMar` ENUM('N', 'S') NOT NULL,
    `Logradouro` VARCHAR(50) NOT NULL,
    `Numero` SMALLINT UNSIGNED NOT NULL,
    `Complemento` VARCHAR(25) NULL,
    `Bairro` VARCHAR(35) NOT NULL,
    `CEP` INT ZEROFILL UNSIGNED NOT NULL,
    PRIMARY KEY (`idImovel`)
) ENGINE = InnoDB;
```

### Inserir Dados

```sql
INSERT INTO Imovel (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, 
                    Numero, Complemento, Bairro, CEP) 
VALUES (2, 1, 'N', 'Rua ABC', 13, 'Apto 15', 'Boqueirão', 1153040);

INSERT INTO Imovel (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, 
                    Numero, Complemento, Bairro, CEP) 
VALUES (5, 3, 'S', 'Rua dos Ricos', 333, 'Apto 275', 'Pitangueiras', 1151030);

-- Ver dados inseridos
SELECT * FROM Imovel;
```

### Criar View com Endereço Concatenado

```sql
CREATE OR REPLACE VIEW vw_TESTE02 AS 
SELECT 
    IdImovel, 
    QtdeQuartos, 
    QtdeBanheiros, 
    VistaMar, 
    CONCAT(Logradouro, ', ', Numero, ', ', Complemento, ', ', 
           Bairro, ', ', CEP) AS 'Endereço Completo'
FROM Imovel;
```

### Consultar a View

```sql
SELECT * FROM vw_TESTE02;
```

**Resultado:**
```
IdImovel | QtdeQuartos | QtdeBanheiros | VistaMar | Endereço Completo
---------|-------------|---------------|----------|----------------------------------
1        | 2           | 1             | N        | Rua ABC, 13, Apto 15, Boqueirão, 1153040
2        | 5           | 3             | S        | Rua dos Ricos, 333, Apto 275, Pitangueiras, 1151030
```

### Comparar com Tabela Original

```sql
-- Tabela original (dados separados)
SELECT * FROM Imovel;
```

💡 **A view simplifica a visualização concatenando as colunas!**

---

## 🗑️ Gerenciando Views

### Listar Todas as Views

```sql
-- Ver apenas views (não tabelas)
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

### Ver Código de Uma View

```sql
SHOW CREATE VIEW vw_ViewCity;
```

### Alterar View

```sql
-- Opção 1: CREATE OR REPLACE
CREATE OR REPLACE VIEW vw_ViewCity AS
SELECT ID, Name, CountryCode
FROM city;

-- Opção 2: ALTER VIEW
ALTER VIEW vw_ViewCity AS
SELECT ID, Name
FROM city;
```

### Excluir View

```sql
DROP VIEW vw_TESTE;
DROP VIEW vw_TESTE02;
```

---

## 📊 Resumo: Views Atualizáveis

| Característica | View Atualizável | View NÃO Atualizável |
|----------------|------------------|----------------------|
| **GROUP BY** | ❌ Não tem | ✅ Tem |
| **Agregações (COUNT, SUM)** | ❌ Não tem | ✅ Tem |
| **DISTINCT** | ❌ Não tem | ✅ Tem |
| **Chave Primária** | ✅ Tem na tabela base | ⚠️ Pode não ter |
| **Pode UPDATE** | ✅ Sim | ❌ Não |
| **Pode DELETE** | ✅ Sim | ❌ Não |

---

## 🎯 Quando Usar Views?

### ✅ Use views para:

- **Simplificar consultas complexas** (JOINs, subconsultas)
- **Padronizar acesso** em equipes
- **Segurança** (ocultar colunas sensíveis)
- **Compatibilidade** (manter interface após mudanças)
- **Formatação** (CONCAT, DATE_FORMAT, etc)

### ❌ Evite views para:

- Operações que exigem alta performance
- Quando precisa modificar dados frequentemente
- Views muito complexas (muitos JOINs)
- Quando a tabela base é suficiente

---

## ✏️ Atividade Prática

### 📝 Atividade 4 — Praticando Views com World

**Objetivo:** Criar views usando o banco World

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

---

## ✅ Resumo do Bloco 4

Neste bloco você aprendeu:

- O que são Views (tabelas virtuais)
- Instalar e usar o banco World
- Criar views simples com CREATE VIEW
- Substituir views com CREATE OR REPLACE
- Criar views com GROUP BY e agregações
- Quando views são atualizáveis
- Importância da chave primária para views atualizáveis
- Criar views com múltiplos JOINs (3 tabelas)
- Usar CONCAT em views
- Gerenciar views (listar, alterar, excluir)

---

## 🎯 Conceitos-chave para fixar

💡 **View = tabela virtual (não armazena dados)**

💡 **CREATE OR REPLACE para atualizar views**

💡 **GROUP BY e COUNT impedem atualizações**

💡 **Chave primária necessária para views atualizáveis**

💡 **Views com JOINs simplificam consultas complexas**

💡 **CONCAT útil para formatar dados em views**

---

## 📚 Comandos SQL Praticados

```sql
-- Criar view
CREATE VIEW nome AS SELECT ...;

-- Substituir view
CREATE OR REPLACE VIEW nome AS SELECT ...;

-- Consultar view
SELECT * FROM nome_view;

-- Atualizar via view (se atualizável)
UPDATE nome_view SET ... WHERE ...;

-- Deletar via view (se atualizável)
DELETE FROM nome_view WHERE ...;

-- Listar views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Ver código
SHOW CREATE VIEW nome;

-- Excluir view
DROP VIEW nome;
```

---

## 🎓 Conclusão da Aula 11

Parabéns! Você completou todos os 4 blocos sobre **Objetos Avançados de BD**:

✅ **Bloco 1** - Stored Procedures  
✅ **Bloco 2** - Triggers  
✅ **Bloco 3** - Functions  
✅ **Bloco 4** - Views  

**Agora você domina:**
- Automatizar tarefas com procedures
- Proteger dados com triggers
- Reutilizar cálculos com functions
- Simplificar acessos com views

---

## 📁 Arquivo de Código

Todo o código deste bloco está disponível em:  
`arquivos/viewCode.sql`

---

> 💭 *"Views são como janelas customizadas para seus dados: você vê apenas o que precisa, da forma que precisa, sem modificar os dados originais."*
