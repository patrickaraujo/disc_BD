-- -----------------------------------------------
-- VIEW
-- -----------------------------------------------
use world;
show tables; -- Database 'world' do MySql

SELECT * FROM city;

-- criando uma VIEW simples
CREATE VIEW vw_ViewCity as Select ID, Name from city;

-- consultando a VIEW
SELECT * FROM vw_ViewCity LIMIT 3;

-- confirmando que a VIEW foi criada como uma tabela
show tables;

-- mostrando o erro ao tentar criar uma VIEW já existente
CREATE VIEW  vw_ViewCity (Cidade) as Select Name from city;

-- alterando uma VIEW
CREATE OR REPLACE VIEW vw_ViewCity (Cidade) AS SELECT Name FROM city;

-- consultando a VIEW alterada
SELECT * FROM vw_ViewCity LIMIT 3;

-- Criando uma VIEW mais sofisticada, ou seja, para contar quantas línguas se falam em cada país que 
-- aparece nas tabelas Country e CountryLanguage. Teremos um registro apenas para cada país da 
-- tabela Country, contando quantas línguas aparecem na tabela para este único país na tabela CountryLanguage. 
CREATE or REPLACE VIEW vw_CountryLangCount
AS Select Name, count(language) as LangCount
FROM country, countrylanguage
WHERE code = countrycode 
GROUP BY name;

-- listando quantas linguas se falam no Brasil
select * from countrylanguage where countrycode = "BRA";

-- consultando o total de linguas por país
SELECT * FROM vw_CountryLangCount ORDER BY name LIMIT 3;
SELECT * FROM vw_CountryLangCount where name = 'brazil';

-- criando e listando os dados da tabela que contem os dados do PAIS, POPULAÇÃO e CONTINENTE
CREATE TABLE CountryPop SELECT name, population, continent FROM country;

-- Esta tabela é criada com chave primária (name) para garantir que a VIEW baseada nela
-- seja atualizável. No MySQL, uma VIEW só permite UPDATE quando não há ambiguidade
-- na identificação das linhas, o que exige uma chave única na tabela base.
DROP TABLE IF EXISTS CountryPop;

CREATE TABLE CountryPop (
    name VARCHAR(50) PRIMARY KEY,
    population INT,
    continent VARCHAR(50)
);

INSERT INTO CountryPop SELECT name, population, continent FROM country;

select * from CountryPop;

-- criando a VIEW baseada na tabela anterior para demostrar que conseguimos alterar a VIEW e 
-- consequentemente, alterar a tabela original
CREATE VIEW vw_EuroPop AS select name, population
FROM CountryPop WHERE continent = 'Europe';

SELECT * FROM vw_EuroPop WHERE name = 'San Marino';

UPDATE vw_EuroPop SET population = population + 1 WHERE name = 'San Marino';

SELECT * FROM vw_EuroPop WHERE name = 'San Marino';
SELECT name, population FROM CountryPop WHERE name = 'San Marino';

delete from vw_EuroPop WHERE name = 'San Marino';

DROP VIEW vw_EuroPop;

-- tentando alterar uma view com registro agrupado
-- erro que será gerado: 
-- Error Code: 1288. The target table vw_CountryLangCount of the UPDATE is not updatable

UPDATE vw_CountryLangCount SET Name = 'Albania II' where Name = 'Albania';
-- A VIEW vw_CountryLangCount não pode ser atualizada porque utiliza GROUP BY e funções
-- de agregação (COUNT), o que impede o MySQL de mapear o resultado da VIEW para linhas
-- específicas das tabelas originais. Por isso, qualquer alteração deve ser feita
-- diretamente na tabela base (country), onde os dados realmente estão armazenados.
SELECT * FROM country WHERE name LIKE '%Albania%';
UPDATE country SET name = 'Albania II' WHERE code = 'ALB';

-- Criando uma View com 3 tabelas
select * from city;
select * from country;
select * from countrylanguage;

CREATE or REPLACE VIEW vw_TESTE AS 
SELECT city.name as 'Cidade', country.name as 'País', language as 'Idioma'
FROM city 
     INNER JOIN country ON city.CountryCode = country.code
     INNER JOIN countrylanguage ON country.Code = countrylanguage.CountryCode
ORDER BY language asc;

select * from vw_TESTE;

-- Criando uma View com um exemplo de Select com projeção concatenada

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
  PRIMARY KEY (`idImovel`))
ENGINE = InnoDB;

INSERT INTO Imovel (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, Numero, Complemento, Bairro, CEP) 
VALUES (2,1,'N','Rua ABC', 13, 'Apto 15', 'Boqueirão', 1153040);

INSERT INTO Imovel (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, Numero, Complemento, Bairro, CEP) 
VALUES (5,3,'S','Rua dos Ricos', 333, 'Apto 275', 'Pitangueiras', 1151030);

select * from Imovel;

CREATE or REPLACE VIEW vw_TESTE02 AS 
select IdImovel, QtdeQuartos, QtdeBanheiros, VistaMar, 
	CONCAT(Logradouro, ', ', Numero, ', ', Complemento, ', ', Bairro, ', ', CEP) as 'Endereço Completo'
from Imovel;

select * from vw_TESTE02;
select * from Imovel;

-- ------------------------------------------------------------------------------------------
-- FIM
-- ------------------------------------------------------------------------------------------
