-- -----------------------------------------------------------------------------
-- STORED PROCEDURE
-- -----------------------------------------------------------------------------

-- criando um novo Database para exemplificar a criação dos novos objetos no BD
create database Procs_Armazenados;
use Procs_Armazenados;

-- criando uma tabela para manipularmos os registros via Stored Procedure
CREATE TABLE usuario (
	usuario_CPF char(11), 
    usuario_nome varchar(20), 
    usuario_email varchar(35), 
    dt_cadastro datetime, 
    PRIMARY KEY (usuario_CPF)
    );

-- criando uma stored procedure para INCLUIR registros na tabela de usuários
delimiter //
create procedure sp_InsereUsuario(
	v_CPF char(11), 
    v_nome varchar(20),
	v_email varchar(35), 
    v_dt_cadastro datetime)
begin
	 if (v_cpf is not null and v_nome is not null and 
		v_email is not null and v_dt_cadastro is not null) 
	 then
		 begin
			 insert into usuario values (v_CPF, v_nome , v_email, v_dt_cadastro);
			 select 'Os registros foram inseridos com sucesso';
		 end;
	 else
		 begin
			 select 'Parametros inadequados';
		 end;
	 end if;
end
//

-- chamando / executando a stored procedure para INCLUIR os registros
CALL sp_insereUsuario ('03478956212', 'Rubens Zampar', 'rzampar@prof.unisa.br', '20221003');
CALL sp_insereUsuario ('03578956999', 'Pedro da Silva', 'pedro@prof.unisa.br', '20221003');
CALL sp_insereUsuario ('03788856955', 'Santiago Oliveira', '', '20221003');
CALL sp_insereUsuario ('04166656933', 'Juca Pereira', null, null);
CALL sp_insereUsuario ('04166656933', 'Juca Pereira');
CALL sp_insereUsuario ('04166656933', 'Juca Pereira',,);
CALL sp_insereUsuario ('04166656933', 'Juca Pereira', 'dddddddd', '20221003', 'pppp');

-- consultando os registros incluídos
select * from usuario;

-- criando uma stored procedure para CONSULTAR registros na tabela de usuários
delimiter //
create procedure sp_consultaUsuario (v_CPF char(11))
begin
 if (v_cpf is not null) then
	Select * from usuario where usuario_cpf = v_cpf;
 else
	Select * from usuario;
 end if;
end
//

-- chamando / executando a stored procedure para CONSULTAR os registros
CALL sp_consultaUsuario ('03478956212');
CALL sp_consultaUsuario ('03578956999');
CALL sp_consultaUsuario (null);

-- criando uma stored procedure para EXCLUIR registros na tabela de usuários
delimiter //
create procedure sp_deleteUsuario(v_CPF char(11))
begin
 if (v_cpf is not null) then
	 delete from usuario where usuario_cpf = v_cpf;
 else
	 delete from usuario;
 end if;
end
//

-- chamando / executando a stored procedure para EXCLUIR os registros
CALL sp_deleteUsuario ('03478956212');
CALL sp_deleteUsuario (null);

rollback;  -- estornando as inclusões e/ou exclusões
commit; -- confirmando as inclusões e/ou exclusões

-- consultando todas as linhas e todos os registros da tabela de usuário
select * from usuario;

-- excluindo fisicamente a stored procedure que exclui os usuários
Drop procedure sp_deleteUsuario 

-- ----------------------------------------------------------------------------
-- TRIGGER
-- ----------------------------------------------------------------------------

-- criando as tabelas de ITEMPEDIDO e PRODUTOS para executarmos as TRIGGER´s e
-- exemplificarmos o funcionamento
CREATE TABLE ItemPedido (
	CODIGOPRODUTO INT NOT NULL, 
    CODIGOPEDIDO INT NOT NULL, 
    QTD INT NOT NULL, 
    PRIMARY KEY (CODIGOPRODUTO, CODIGOPEDIDO)
    );
    
INSERT INTO ItemPedido VALUES 
                       (1, 10, 1), 
                       (2, 10, 3);

CREATE TABLE Produtos (
	CODIGOPRODUTO INT NOT NULL, 
    NOME VARCHAR(30) NOT NULL, 
    QTDESTOQUE INT NOT NULL, 
    PRECO DECIMAL(5,2), 
    PRIMARY KEY (CODIGOPRODUTO)
    );
    
INSERT INTO Produtos VALUES 
                     (1, 'DVD', 100, 50.00), 
                     (2, 'LIQUIDIFICADOR', 30, 180.00);

commit;

-- consultando os dados criados em ambas as tabelas
Select * from ItemPedido;
Select * from Produtos;

-- criando uma TRIGGER para atualizar (-) o Estoque do Produto a cada item incluído
-- esta Trigger ficará vinculada à tabela de ItemPedido
DELIMITER //
CREATE TRIGGER tg_atualiza_estoque AFTER INSERT ON ITEMPEDIDO
FOR EACH ROW BEGIN
	-- Utilizando variáveis
	SET @CODIGOPRODUTO = NEW.CODIGOPRODUTO;
	SET @QTD = NEW.QTD;
	-- Testando os valores recuperados
	IF (@CODIGOPRODUTO IS NOT NULL AND @QTD IS NOT NULL) THEN
		UPDATE PRODUTOS
		SET QTDESTOQUE = QTDESTOQUE - @QTD
		WHERE CODIGOPRODUTO = @CODIGOPRODUTO;
	END IF;
END ;
//

Select * from Produtos;
Select * from ItemPedido;

-- inserindo um novo Item de Pedido e acionando a Trigger que atualiza o estoque do produto
INSERT INTO ItemPedido VALUES (1, 11, 5);
Select * from ItemPedido;
Select * from Produtos;

-- criando tabela de auditoria para gravar todas as alterações de preço dos produtos
CREATE TABLE tab_audit (
	codigo int AUTO_INCREMENT, 
    usuario char(30) NOT NULL, 
    estacao char(30) NOT NULL, 
    dataautitoria datetime NOT NULL, 
    codigo_Produto int NOT NULL, 
    preco_unitario_novo DECIMAL(10,4) NOT NULL, 
    preco_unitario_antigo DECIMAL(10,4) NOT NULL, 
    primary key(codigo)
    );

-- criando a TRIGGER para registrar os preços alterados na tabela de auditoria
-- preços antigos e preços novos
-- esta Trigger ficará vinculada com a tabela de Produtos
DELIMITER //
CREATE TRIGGER Audita AFTER UPDATE ON PRODUTOS
FOR EACH ROW BEGIN
   SET @CODIGOPRODUTO = OLD.CODIGOPRODUTO;
   SET @PRECONOVO = NEW.PRECO;
   SET @PRECOANTIGO=OLD.PRECO;
      INSERT INTO TAB_AUDIT 
	   (usuario, estacao, dataautitoria, codigo_Produto, preco_unitario_novo, preco_unitario_antigo)
   VALUES 
       (CURRENT_USER, USER(), current_date, @CODIGOPRODUTO, @PRECONOVO, @PRECOANTIGO);
END
//

-- alterando o preço do produto para disparar a Trigger que alimentará a tabela de auditoria
UPDATE produtos SET preco = 202.50 WHERE codigoproduto = 2; 
Select * from Produtos;
Select * from tab_audit;

-- excluindo fisicamente a TRIGGER
DROP TRIGGER Audita;

-- -----------------------------------------------
-- FUNCTION
-- -----------------------------------------------
use procs_armazenados;

-- criando e populando a tabela VINHO para simularmos o uso de uma função para calcular o
-- valor do vinho com desconto de 10%
CREATE TABLE Vinho (
	codbar int, 
    nome varchar(20), 
    preco decimal (4,2), 
    PRIMARY KEY (codbar)
    );
    
INSERT INTO Vinho VALUES (1, 'Vinho AAA', 21.90);
INSERT INTO Vinho VALUES (2, 'Vinho BBB', 20.50);
INSERT INTO Vinho VALUES (3, 'Vinho CCC', 35.10);
INSERT INTO Vinho VALUES (4, 'Vinho DDD', 99.00);
INSERT INTO Vinho VALUES (5, 'Vinho EEE', 50.00);
commit;
select * from vinho;

-- Segundo a documentação do MySQL, ao criar uma função armazenada, devemos declarar que ela é determinística ou 
-- que não modifica os dados (atualizar, inserir ou deletar) no BD. Caso contrário, pode não ser seguro para 
-- recuperação ou replicação de dados. Caso isso não seja feito ocorre um erro. Então para relaxar essas condições 
-- na criação da função, você pode definir a variável global do sistema para 1.
-- Por padrão, essa variável tem um valor 0, mas você pode alterá-lo assim:

SET GLOBAL log_bin_trust_function_creators = 1;

-- Criando a FUNÇÃO que calculará o desconto do vinho
CREATE FUNCTION fn_desconto (x DECIMAL(5,2), y FLOAT) 
RETURNS DECIMAL(5,2)
RETURN (x * y);

-- Criando o PROCEDIMENTO que acionará a FUNÇÃO e listará o nome do vinho com o desconto calculado
CREATE PROCEDURE proc_desconto (VAR_VinhoCodBar INT)
SELECT (fn_desconto(Preco, 0.90)) AS 'Valor com desconto', Nome AS 'Vinho'
FROM Vinho
WHERE CodBar = var_VinhoCodBar;

select * from vinho;

-- acionando o procedimento e listando o vinho com desconto
CALL proc_desconto(5);

-- fazendo um Select e acionando a função
SELECT Preco AS 'Valor normal', (fn_desconto(Preco, 0.90)) AS 'Valor com desconto', Nome AS 'Vinho'
FROM Vinho
WHERE CodBar = 5;

SELECT usuario, dataautitoria AS 'data_original' FROM tab_audit;
SELECT usuario, DATE_FORMAT(dataautitoria,'%d/%m/%Y') AS 'data_formatada' FROM tab_audit;
SELECT usuario, DATE_FORMAT(dataautitoria,'%y/%m/%d') AS 'data_formatada' FROM tab_audit;
SELECT usuario, DATE_FORMAT(dataautitoria,'%d-%m às %Hh%i') AS 'data_formatada' FROM tab_audit;
SELECT usuario, DATE_FORMAT(dataautitoria,'%d-%m-%y às %Hh%i') AS 'data_formatada' FROM tab_audit;
SELECT usuario, DATE_FORMAT(dataautitoria,'%d/%m/%Y às %Hh%i') AS 'data_formatada' FROM tab_audit;

-- -----------------------------------------------
-- VIEW
-- -----------------------------------------------
use world;
show tables; -- Database Word do MySql

SELECT * FROM city;

-- criando uma VIEW simples
CREATE VIEW vw_ViewCity as Select ID, Name from city;

-- consultando a VIEW
SELECT * FROM vw_ViewCity LIMIT 3;

-- confirmando que a VIEW foi criada como uma tabela
show tables;

-- mostrando o erro ao tentar criar uma VIEW já existente
CREATE VIEW  vw_ViewCity (Cidade) as Select Name from City;

-- alterando uma VIEW
CREATE or REPLACE VIEW  vw_ViewCity (Cidade) as Select Name from City;

-- consultando a VIEW alterada
SELECT * FROM vw_ViewCity LIMIT 3;

-- Criando uma VIEW mais sofisticada, ou seja, para contar quantas línguas se falam em cada país que 
-- aparece nas tabelas Country e CountryLanguage. Teremos um registro apenas para cada país da 
-- tabela Country, contando quantas línguas aparecem na tabela para este único país na tabela CountryLanguage. 
CREATE or REPLACE VIEW vw_CountryLangCount
AS Select Name, count(language) as LangCount
FROM Country, CountryLanguage
WHERE code = countrycode 
GROUP BY name;

-- listando quantas linguas se falam no Brasil
select * from countrylanguage where countrycode = "BRA";

-- consultando o total de linguas por país
SELECT * FROM vw_CountryLangCount ORDER BY name LIMIT 3;
SELECT * FROM vw_CountryLangCount where name = 'brazil';

-- criando e listando os dados da tabela que contem os dados do PAIS, POPULAÇÃO e CONTINENTE
CREATE TABLE CountryPop SELECT name, population, continent FROM Country;
select * from CountryPop;

-- criando a VIEW baseada na tabela anterior para demostrar que conseguimos alterar a VIEW e 
-- consequentemente, alterar a tabela original
CREATE VIEW vw_EuroPop AS Select Name, population 
FROM CountryPop WHERE continent = 'Europe';

SELECT * FROM vw_EuroPop WHERE name = 'San Marino';

UPDATE vw_EuroPop SET Population = Population+1 WHERE name = 'San Marino';

SELECT * FROM vw_EuroPop WHERE name = 'San Marino';
SELECT name, population FROM countrypop WHERE name = 'San Marino';

delete from vw_europop WHERE name = 'San Marino';

DROP VIEW vw_europop;

-- tentando alterar uma view com registro agrupado
-- erro que será gerado: 
-- Error Code: 1288. The target table vw_CountryLangCount of the UPDATE is not updatable

UPDATE vw_CountryLangCount SET name = 'Albania II' where name = 'Albania';

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

select * from vw_teste;

-- Criando uma View com um exemplo de Select com projeção concatenada

CREATE TABLE IF NOT EXISTS `WORLD`.`Imovel` (
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

INSERT INTO IMOVEL (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, Numero, Complemento, Bairro, CEP) 
VALUES (2,1,'N','Rua ABC', 13, 'Apto 15', 'Boqueirão', 1153040);
INSERT INTO IMOVEL (QtdeQuartos, QtdeBanheiros, VistaMar, Logradouro, Numero, Complemento, Bairro, CEP) 
VALUES (5,3,'S','Rua dos Ricos', 333, 'Apto 275', 'Pitangueiras', 1151030);

select * from imovel;

CREATE or REPLACE VIEW vw_TESTE02 AS 
select IdImovel, QtdeQuartos, QtdeBanheiros, VistaMar, 
	CONCAT(Logradouro, ', ', Numero, ', ', Complemento, ', ', Bairro, ', ', CEP) as 'Endereço Completo'
from imovel;

select * from vw_teste02;
select * from imovel;

-- ------------------------------------------------------------------------------------------
-- FIM
-- ------------------------------------------------------------------------------------------