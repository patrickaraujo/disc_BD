# 🧠 Atividade 4 — Praticando Views com Banco World

> **Duração:** 40-50 minutos  
> **Formato:** Prática hands-on  
> **Objetivo:** Dominar a criação e uso de views com o banco de dados World

---

## 📦 Pré-requisito: Banco World Instalado

Certifique-se de que o banco World está instalado:

```sql
SHOW DATABASES;
USE world;
SHOW TABLES; -- Deve mostrar: city, country, countrylanguage
```

Se não estiver instalado, consulte o diretório `world-db/` ou baixe em:  
https://dev.mysql.com/doc/index-other.html

---

## 📝 Exercício 1: View Simples de Cidades

**Criar uma view `vw_CidadesBrasil` que:**
- Mostre apenas cidades do Brasil (CountryCode = 'BRA')
- Exiba: ID, Name, Population
- Ordene por população decrescente

```sql
-- Seu código aqui
```

**Teste:**
```sql
SELECT * FROM vw_CidadesBrasil LIMIT 10;
```

---

## 📝 Exercício 2: View com Renomeação de Colunas

**Criar uma view `vw_PaisesSulAmericanos` que:**
- Mostre países da América do Sul
- Renomeie colunas: 'País', 'População', 'Área'
- Ordene por população

**Teste:**
```sql
SELECT * FROM vw_PaisesSulAmericanos;
```

---

## 📝 Exercício 3: View com Agregação

**Criar uma view `vw_CidadesPorPais` que:**
- Conte quantas cidades cada país tem
- Mostre: nome do país, quantidade de cidades
- Ordene por quantidade decrescente

**Teste:**
```sql
SELECT * FROM vw_CidadesPorPais LIMIT 10;

-- Quantas cidades o Brasil tem?
SELECT * FROM vw_CidadesPorPais WHERE `Nome do País` = 'Brazil';
```

**Esta view é atualizável?** Por quê?

---

## 📝 Exercício 4: View com JOIN (2 tabelas)

**Criar uma view `vw_CidadesComPais` que:**
- Una city e country
- Mostre: nome da cidade, nome do país, população da cidade, continente
- Filtrar apenas cidades com mais de 1 milhão de habitantes

**Teste:**
```sql
SELECT * FROM vw_CidadesComPais 
ORDER BY `População da Cidade` DESC 
LIMIT 10;
```

---

## 📝 Exercício 5: View com 3 Tabelas (Reproduzir vw_TESTE)

**Criar a view conforme o exemplo da aula:**

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

**Teste com diferentes filtros:**

```sql
-- Cidades do Brasil que falam português
SELECT * FROM vw_TESTE 
WHERE País = 'Brazil' AND Idioma = 'Portuguese'
LIMIT 10;

-- Cidades que falam espanhol
SELECT * FROM vw_TESTE 
WHERE Idioma = 'Spanish'
LIMIT 20;

-- Quantas combinações cidade-idioma existem?
SELECT COUNT(*) FROM vw_TESTE;
```

---

## 📝 Exercício 6: View Atualizável

**Seguir os passos da aula:**

1. Criar tabela CountryPop COM chave primária:

```sql
DROP TABLE IF EXISTS CountryPop;

CREATE TABLE CountryPop (
    name VARCHAR(50) PRIMARY KEY,
    population INT,
    continent VARCHAR(50)
);

INSERT INTO CountryPop 
SELECT name, population, continent 
FROM country;
```

2. Criar view de países asiáticos:

```sql
CREATE VIEW vw_AsiaPop AS 
SELECT name, population
FROM CountryPop 
WHERE continent = 'Asia';
```

3. Testar atualização via view:

```sql
-- Ver Japão antes
SELECT * FROM vw_AsiaPop WHERE name = 'Japan';

-- Atualizar via view
UPDATE vw_AsiaPop 
SET population = population + 1000 
WHERE name = 'Japan';

-- Verificar mudança na view
SELECT * FROM vw_AsiaPop WHERE name = 'Japan';

-- Verificar mudança na tabela base
SELECT * FROM CountryPop WHERE name = 'Japan';
```

4. Limpar:

```sql
DROP VIEW vw_AsiaPop;
DROP TABLE CountryPop;
```

---

## 📝 Exercício 7: Tentando Atualizar View com GROUP BY

**Reproduzir o erro da aula:**

```sql
-- Tentar atualizar view com agregação
UPDATE vw_CountryLangCount 
SET Name = 'Albania II' 
WHERE Name = 'Albania';
```

**Você deve receber o erro:**
```
Error Code: 1288. The target table vw_CountryLangCount 
of the UPDATE is not updatable
```

**Agora corrija atualizando a tabela base:**

```sql
-- Ver dados originais
SELECT * FROM country WHERE name LIKE '%Albania%';

-- Atualizar na tabela base
UPDATE country 
SET name = 'Albania Teste' 
WHERE code = 'ALB';

-- Verificar na view (mudou automaticamente!)
SELECT * FROM vw_CountryLangCount 
WHERE name LIKE '%Albania%';

-- Reverter alteração
UPDATE country 
SET name = 'Albania' 
WHERE code = 'ALB';
```

---

## 📝 Exercício 8: View com CONCAT

**Reproduzir o exemplo da tabela Imovel:**

1. Criar tabela Imovel (copie da aula)
2. Inserir 2 registros
3. Criar view vw_TESTE02 com endereço concatenado
4. Consultar a view
5. Comparar com tabela original

**Agora modifique:**

Crie sua própria view com CONCAT usando dados de `city` e `country`:

```sql
CREATE OR REPLACE VIEW vw_CidadeCompleta AS
SELECT 
    city.ID,
    CONCAT(city.Name, ' - ', country.Name, ' (', 
           country.Continent, ')') AS 'Localização Completa',
    city.Population AS 'População'
FROM city
INNER JOIN country ON city.CountryCode = country.code
LIMIT 100;
```

**Teste:**
```sql
SELECT * FROM vw_CidadeCompleta 
WHERE `Localização Completa` LIKE '%Brazil%';
```

---

## 📝 Exercício 9: View para Segurança

**Cenário:** Você quer mostrar países para usuários externos, mas SEM revelar informações sensíveis.

**Criar view `vw_PaisesPublico` que:**
- Mostre apenas: nome, continente, região
- NÃO mostre: população, área, PIB, governo, etc.

```sql
CREATE VIEW vw_PaisesPublico AS
SELECT 
    Name AS 'País',
    Continent AS 'Continente',
    Region AS 'Região'
FROM country;
```

**Teste:**
```sql
SELECT * FROM vw_PaisesPublico LIMIT 10;
```

💡 **Agora você pode dar acesso a esta view sem expor dados sensíveis!**

---

## 📝 Exercício 10: Gerenciamento de Views

**Execute os comandos:**

```sql
-- 1. Listar TODAS as views criadas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- 2. Ver código de uma view específica
SHOW CREATE VIEW vw_CidadesBrasil;

-- 3. Alterar uma view existente
CREATE OR REPLACE VIEW vw_CidadesBrasil AS
SELECT ID, Name, Population, District
FROM city
WHERE CountryCode = 'BRA'
ORDER BY Population DESC;

-- 4. Verificar alteração
SELECT * FROM vw_CidadesBrasil LIMIT 5;

-- 5. Excluir views de teste
DROP VIEW IF EXISTS vw_CidadeCompleta;
DROP VIEW IF EXISTS vw_PaisesPublico;
DROP VIEW IF EXISTS vw_TESTE;
DROP VIEW IF EXISTS vw_TESTE02;
```

---

## 📝 Exercício 11: Desafio Final

**Criar uma view complexa `vw_RelatorioMundial` que:**

- Una as 3 tabelas (city, country, countrylanguage)
- Mostre: cidade, país, continente, idioma oficial, população da cidade
- Filtre apenas idiomas oficiais (IsOfficial = 'T')
- Ordene por população da cidade decrescente
- Limite a 1000 registros (para performance)

```sql
-- Seu código aqui
CREATE OR REPLACE VIEW vw_RelatorioMundial AS
-- Complete...
```

**Teste diferentes consultas:**

```sql
-- Top 10 cidades mais populosas com seus idiomas oficiais
SELECT * FROM vw_RelatorioMundial LIMIT 10;

-- Cidades do Brasil com português oficial
SELECT * FROM vw_RelatorioMundial 
WHERE País = 'Brazil';

-- Cidades da Europa
SELECT * FROM vw_RelatorioMundial 
WHERE Continente = 'Europe'
LIMIT 20;
```

---

## ✅ Checklist de Conclusão

- [ ] View de cidades do Brasil criada
- [ ] View com renomeação de colunas criada
- [ ] View com agregação (GROUP BY) criada
- [ ] View com JOIN (2 tabelas) criada
- [ ] View com 3 tabelas (vw_TESTE) reproduzida
- [ ] Testou view atualizável com sucesso
- [ ] Entendeu por que view com GROUP BY não é atualizável
- [ ] Criou view com CONCAT
- [ ] Criou view para segurança
- [ ] Praticou gerenciamento de views
- [ ] Completou desafio final

---

## 🎯 Perguntas para Reflexão

1. **Qual a diferença entre uma view e uma tabela?**

2. **Por que uma view com GROUP BY não pode ser atualizada?**

3. **Quando você usaria uma view em vez de criar uma nova tabela?**

4. **Como views podem aumentar a segurança do banco de dados?**

5. **Qual a vantagem de usar CREATE OR REPLACE em vez de DROP + CREATE?**

---

## 💡 Dicas Finais

- Views NÃO ocupam espaço (exceto a definição)
- Use prefixo `vw_` para identificar views
- Views complexas podem afetar performance
- Sempre documente o propósito de cada view
- Use views para padronizar consultas em equipes
- Views são ótimas para relatórios recorrentes

---

## 📁 Arquivo de Referência

Todo o código de views está em:  
`arquivos/viewCode.sql`

---

> ✅ **Parabéns! Você dominou Views e completou a Aula 11!**

---

## 🎓 Resumo dos 4 Objetos Avançados

| Objeto | Retorna Valor | Modifica Dados | Quando Usar |
|--------|---------------|----------------|-------------|
| **Procedure** | Opcional | ✅ Sim | Lógica de negócio |
| **Trigger** | ❌ Não | ✅ Sim | Ações automáticas |
| **Function** | ✅ Sempre | ⚠️ Evitar | Cálculos reutilizáveis |
| **View** | ✅ Sim (virtual) | ⚠️ Limitado | Consultas complexas |

---

> 💭 *"Com Procedures, Triggers, Functions e Views, você transforma um banco de dados comum em um sistema inteligente, automatizado e seguro."*
